import json
import os

import requests


class GreaseManager:
    def __init__(self):
        self.qutebrowser_config = os.path.expanduser("~/.config/qutebrowser/")
        self.grease_dir = os.path.join(self.qutebrowser_config, "greasemonkey")
        self.package_file = os.path.join(
            self.qutebrowser_config, "grease-packages.json"
        )
        self.meta_file = os.path.expanduser(
            "~/.local/share/qutebrowser/.script_meta.json"
        )

        self.meta = self._load_meta()

    def _load_packages(self):
        if not os.path.exists(self.package_file):
            print(f"File not found: {self.package_file}")
            return []

        with open(self.package_file, "r") as file:
            return json.load(file)

    def _load_meta(self):
        if os.path.exists(self.meta_file):
            with open(self.meta_file, "r") as f:
                return json.load(f)
        return {}

    def _save_meta(self):
        os.makedirs(os.path.dirname(self.meta_file), exist_ok=True)
        with open(self.meta_file, "w") as f:
            json.dump(self.meta, f, indent=2)

    def _download_script(self, url: str):
        headers = {}

        if url in self.meta:
            if "etag" in self.meta[url]:
                headers["If-None-Match"] = self.meta[url]["etag"]
            if "last_modified" in self.meta[url]:
                headers["If-Modified-Since"] = self.meta[url]["last_modified"]

        try:
            r = requests.get(url, headers=headers)

            if r.status_code == 304:
                print(f"[SKIP] No update: {url}")
                return

            if r.status_code == 200:
                os.makedirs(self.grease_dir, exist_ok=True)
                filename = os.path.join(self.grease_dir, url.split("/")[-1])

                with open(filename, "wb") as f:
                    f.write(r.content)

                self.meta[url] = {
                    "etag": r.headers.get("ETag"),
                    "last_modified": r.headers.get("Last-Modified"),
                }

                print(f"[UPDATED] {filename}")
            else:
                print(f"[ERROR] {url} -> {r.status_code}")

        except Exception as e:
            print(f"[FAIL] {url} -> {e}")

    def install(self):
        packages = self._load_packages()

        # Return if empty packages
        if not packages:
            print("No packages found.")
            return

        # Clean up meta if files are missing
        to_remove = []

        for url in self.meta:
            filename = os.path.join(self.grease_dir, url.split("/")[-1])

            if not os.path.exists(filename):
                print(f"[MISSING] Removing stale meta: {url}")
                to_remove.append(url)

        for url in to_remove:
            del self.meta[url]

        # Download / Update packages
        for url in packages:
            self._download_script(url)

        print(self.meta)
        self._save_meta()
