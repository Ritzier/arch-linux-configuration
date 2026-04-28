# Hard Disk

## I/O Scheduler

1. Check currently disk mode

```bash
cat /sys/block/nvme0n1/queue/scheduler
```

```bash
[none] mq-deadline kyber bfq
```

| Scheduler   | Goal                       | Best for                 | Key trait              |
| ----------- | -------------------------- | ------------------------ | ---------------------- |
| none        | raw hardware performance   | NVMe                     | no scheduling overhead |
| mq-deadline | latency + fairness         | SSD / NVMe / general use | predictable latency    |
| kyber       | latency control under load | SSD / high IO contention | stable responsiveness  |
| bfq         | fairness processes         | HDD                      | fair bandwidth sharing |

3. Template config (Effective immediately)

NVMe:

```bash
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler
```

HDD:

```bash
echo bfq | sudo tee /sys/block/sdb/queue/scheduler
```

4. Persistent Scheduler Rules (`udev-based`)

```/etc/udev/rules.d/60-scheduler.rules
ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="nvme*n1", ATTR{queue/scheduler}="none"
ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
```

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block
```
