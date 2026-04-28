# ZRAM Configuration

1. Difference **RAM** / **SWAP** / **ZRAM**

- **RAM (Physical Memory)**:
    - Fastest
    - CPU directly visit
    - Storing "Currently running data"

- **Disk Swap**:
    - Moves inactive memory pages to disk (SSD/HDD)”
    - Media: SSD / HDD
    - Characteristic: Extremely slow (orders of magnitude slower than RAM)
    - Advantages: Large capacity
    - Disadvatanges: High I/O latency

```
RAM -> page out -> SSD/HDD -> page in
（Slow I/O）
```

- **ZRAM (Compressed RAM swap)**
    - Essence: Create a "compressed block device" in RAM
    - Purpose: Used for swapping, but the data remains in memory
    - Compression / Decompression overhead

```
RAM -> compressed pages stored in RAM (not new memory allocation)
（CPU + RAM 带宽）
```

## Memory vs Disk Swap vs zram Comparison

| Feature                    | RAM (Physical Memory)    | Disk Swap (SSD/HDD)                       | ZRAM (Compressed RAM Swap)            |
| -------------------------- | ------------------------ | ----------------------------------------- | ------------------------------------- |
| Storage medium             | DRAM                     | SSD / HDD                                 | RAM                                   |
| Access latency             | ~nanoseconds             | ~microseconds to milliseconds             | ~tens to hundreds of nanoseconds      |
| Throughput                 | Very high (50-200+ GB/s) | Low (100 MB/s - 7 GB/s depending on disk) | High (limited by CPU + RAM bandwidth) |
| Mechanism                  | Direct memory access     | Page out to disk                          | Compress pages in RAM                 |
| CPU overhead               | Low                      | Low                                       | Medium (compression / decompression)  |
| Space efficiency           | None                     | High (large disk capacity)                | High (compressed memory pages)        |
| Performance under pressure | Best                     | Worst (I/O bottleneck)                    | Good (degrades gracefully)            |
| Swap usage role            | OOM when full            | Severe slowdown / thrashing               | Slower but still responsive           |
| Compression                | No                       | No                                        | Yes (LZ4 / ZSTD etc.)                 |
| Typical use case           | Active working memory    | Last-resort memory extension              | Fast swap for memory pressure         |
| Power efficiency           | High                     | Low (disk activity)                       | Medium (CPU usage)                    |

- **RAM** -> fastest, primary working set
- **Disk Swap** -> capacity extension, but very slow
- **ZRAM** -> trade CPU for speed by keeping swap inside RAM with compression

## Configuration

### Installation

```bash
sudo pacman -S zram-generator
```

### Configuration

```/etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
```

### Enable and Apply

Reboot or restart systemd service:

```bash
sudo systemctl daemon-reexec
sudo systemctl restart systemd-zram-setup@zram0
```

### Configuration Options

#### zram-size

Defines how much RAM is allocated to ZRAM

```ini
zram-size = ram        # 100% of RAM
zram-size = ram / 2    # 50% of RAM (recommended for most systems)
zram-size = 8G         # fixed size
```

#### compression-algorithm

Check supported algorithms:

```bash
cat /sys/block/zram0/comp_algorithm
```

```bash
lzo-rle lzo lz4 lz4hc [zstd] deflate 842
```

Available algorithms:

| Algorithm | Speed                | Compression Ratio | CPU Usage | Best Use Case                    | Note                                  |
| --------- | -------------------- | ----------------- | --------- | -------------------------------- | ------------------------------------- |
| lz4       | ⭐⭐⭐⭐⭐           | Medium            | Very low  | Real-time / gaming / low latency | Best latency, lowest, overhead        |
| lz4hc     | ⭐⭐⭐⭐             | Medium-high       | Low       | Balance fast compression         | Slightly better compression than lz4  |
| zstd      | ⭐⭐⭐⭐⭐ (balance) | High              | Medium    | General purpose (recommended)    | Best overall trade-off                |
| lzo       | ⭐⭐⭐               | Low-medium        | Low       | Legacy / compatibility           | Older default in some systems         |
| lzo-rle   | ⭐⭐⭐               | Low-medium        | Low       | Embedded / simple workloads      | Variants of lzo with RLE optimization |
| 842       | ⭐⭐                 | Medium            | Medium    | PowerPC / niche systems          | Rare on modern x86 systems            |
| deflate   | ⭐                   | High              | High      | Compatibility / legacy systems   | Slow, CPU heavy                       |

#### swap-priority

Controls swap usage priority:

| Value             | Behavior               |
| ----------------- | ---------------------- |
| Higher (e.g. 100) | Used first (preferred) |
| Lower (e.g. 10)   | Used later             |
| Negative          | Lowest priority        |

### Optional: Lower Disk Swap Usage

```/etc/fstab
/swapfile none swap defaults,pri=10 0 0
```

```/etc/sysctl.d/99-swappiness.conf
vm.swappiness=80
vm.vfs_cache_pressure=50
```

Apply withou reboot:

```sh
sudo sysctl --system
```

#### `vm.swappiness`

| Value | Behavior                    |
| ----- | --------------------------- |
| 60    | Balance                     |
| 80    | Prefer swapping earlier     |
| 30-40 | Avoid swap unless necessary |

#### `vm.vfs_cache_pressure`

Linux has two major types of filesystem-related caches: - **Page Cache**: caches file contents (data blocks) - **VFS
Cache**: - inode cache (file metadata) - dentry cache (directory lookup result)

`vm.vfs_cache_pressure` controls:

How aggressively the kernel reclaims VFS cache (inode/dentry) when the system is under memory pressure

##### Value meaning

Default value:

```
vm.vfs_cache_pressure = 100
```

| Value | Behavior                          |
| ----- | --------------------------------- |
| < 100 | Prefer keeping inode/dentry cache |
| = 100 | Default balance behavior          |
| > 100 | More aggressive VFS cache reclaim |

##### Intuition

###### Page Cache vs VFS Cache

When memory pressure happens:

```
Reclaim order:
1. page cache (file data)
2. anonymouse memory (swap)
3. vfs cache (inode/dentry)
```

`vfs_cache_pressure` adjusts:

- How quickly step 3 (VFS cache reclaim) happens

#### Why VFS cache matetrs

##### inode / dentry cache role:

- inode cache: file metadata (permissions, size, block mapping)
- dentry cache: path resolution results (e.g. `/a/b/c` lookup speed)

Purpose: reduce cost of `stat()`, `open()`, and path traversal

#### Increasing vs decreasing the value

##### Increase (e.g. 200-500)

```
vm.vfs_cache_pressure = 200
```

- ✔ More aggressive VFS cache reclaim
- ✔ Lower memory usage
- ❌ Slower filesystem operations (more re-lookup required)

Best for :

- Memory-constrained systems
- Workloads with less frequent file access

#### Decrease (e.g. 50–80)

```
vm.vfs_cache_pressure = 50
```

- ✔ Keeps more VFS cache in memory
- ✔ Faster file/dir access
- ❌ Higher RAM usage

Best for:

- Development environments
- Build systems (gcc, rust, etc.)
- Frequent filesystem access workloads
