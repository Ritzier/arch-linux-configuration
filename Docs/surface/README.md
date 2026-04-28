## Create USB Bootable

My device surface 7+ cant start Rufus

only work with direct write to usb

```bash
sudo dd bs=4M if=archlinux-x86_64.iso of=/dev/sdX conv=fsync oflag=direct status=progress
```

## System Package

```/etc/pacman.conf
[linux-surface]
SigLevel = Optional TrustAll
Server = https://pkg.surfacelinux.com/arch/
```

no need to install

1: `linux` replaced by `linux-surface`

2: `linux-headers` replaced by `linux-surface-headers`

### Boot Manager

in my case, im using `efibootmgr` install it if missing

```bash
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0 238.5G  0 disk
├─nvme0n1p1 259:1    0   477M  0 part /boot
└─nvme0n1p2 259:2    0   238G  0 part /
```

make sure have these three file

```bash
ls /boot
# initramfs-linux-surface.img  intel-ucode.img  vmlinuz-linux-surface
```

build efibootmgr:

```bash
efibootmgr --create \
  --disk /dev/nvme0n1 --part 1 \
  --label "Arch Linux" \
  --loader '\vmlinuz-linux-surface' \
  --unicode 'root=UUID=1878aa39-6630-4b5c-a6fb-ab365b629de4 rw loglevel=3 initrd=\intel-ucode.img initrd=\initramfs-linux-surface.img'
```

### surface-control

power control

## Touch Screen

`touchegg` require

```touchegg.conf
<touchégg>
  <application name="All">

    <gesture type="TAP" fingers="1">
      <action type="MOUSE_CLICK">
        <button>1</button>
      </action>
    </gesture>

    <gesture type="TAP" fingers="2" direction="">
      <action type="MOUSE_CLICK">
        <button>3</button>
      </action>
    </gesture>

  </application>
</touchégg>
```

### touchegg services

```~/.config/systemd/user/touchegg.service
[Unit]
Description=Touchegg Gesture Service (User)
After=graphical-session.target

[Service]
Type=simple

# Run both commands sequentially
ExecStart=/bin/sh -c 'touchegg --daemon & touchegg'

# Restart if it crashes
Restart=on-failure
RestartSec=2

# Optional: environment (Wayland/X11 compatibility)
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
```

### Firefox Scrolling Issue

finger hold and move down it action as virtual highlight not scrolling down

Add to fix it:

```/etc/security/pam_env.conf
# Firefox touch scrolling
MOZ_USE_XINPUT2 DEFAULT=1
```

## X11 HiDpi

```~/.Xresources
Xft.dpi: 192
Xft.autohint: 0
Xft.lcdfilter: lcddefault
Xft.hintstyle: hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
```

```~/.xinitrc
xrdb -merge ~/.Xresources
```
