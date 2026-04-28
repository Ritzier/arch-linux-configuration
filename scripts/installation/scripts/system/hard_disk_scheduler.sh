tee /etc/udev/rules.d/60-scheduler.rules >/dev/null <<'EOF'
ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="nvme*n1", ATTR{queue/scheduler}="none"
ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
EOF

udevadm control --reload-rules
udevadm trigger --subsystem-match=block
