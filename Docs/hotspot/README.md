# Linux Software Hotspot

```bash
enp42s0 -> Internet (WAN)
wlp41s0 -> WiFi AP (LAN: 192.168.50/24)
```

## Traffic Flow

```bash
WiFi Client
   ↓
wlp41s0 (192.168.50.0/24)
   ↓
Linux IP Forwarding
   ↓
NAT (nftables masquerade)
   ↓
enp42s0 → Internet
```

## 1. Disable Network Manager (Optional)

> Only do this if you fully manage networking manually

```bash
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
```

## 2. Configure WiFi AP Interface

```bash
sudo ip addr add 192.168.50.1/24 dev wlp41s0
sudo ip link set wlp41s0 up
```

#### Notes

- `192.168.50.1` = Gateway (AP host)
- This subnet is used for:
    - DHCP server (if configured)
    - NAT routing
    - Client IP allocation (e.g. 192.168.50.10–200)

## 3. Start Hostapd (Access Point)

```bash
sudo hostapd /etc/hostapd/hostapd.conf
```

Expected Succeful Output

```
AP-ENABLED
```

Typical Association Log

```
wlp41s0: interface state UNINITIALIZED->COUNTRY_UPDATE
wlp41s0: interface state COUNTRY_UPDATE->HT_SCAN
wlp41s0: interface state HT_SCAN->ENABLED
wlp41s0: AP-ENABLED
wlp41s0: STA xx:xx:xx:xx:xx:xx IEEE 802.11: associated (aid 1)
wlp41s0: AP-STA-CONNECTED xx:xx:xx:xx:xx:xx
wlp41s0: WPA: pairwise key handshake completed (RSN)
wlp41s0: EAPOL-4WAY-HS-COMPLETED xx:xx:xx:xx:xx:xx
```

## 4. Enable IPv4 Forward

### Temporary (runtime)

```bash
sysctl -w net.ipv4.ip_forward=1
```

### Persistent

```/etc/sysctl.d/99-ipforward.conf
net.ipv4.ip_forward=1
```

Reload it

```
sysctl --system
```

## 5. Configure NAT (nftables)

### Create NAT table

```bash
nft add table ip hotspot
```

### Add postrouting chain

```bash
nft add chain ip hotspot postrouting \
{ type nat hook postrouting priority 100 \; }
```

### Add masquerade rule

```bash
nft add rule ip hotspot postrouting oifname "enp42s0" masquerade
```

### Optional Improvements (Recommended)

#### Persist nftables rules

Save config:

```bash
sudo nft list ruleset > /etc/nftables.conf
```

Enable service:

```bash
sudo systemctl enable --now nftables
```

## 6. DHCP + DNS with `dnsmasq`

### Configuration

Create or edit:

```/etc/dnsmasq.conf
interface=wlp41s0
bind-interfaces

# DHCP range for WiFi clients
dhcp-range=192.168.50.10,192.168.50.100,255.255.255.0,12h

# Default gateway (router)
dhcp-option=option:router,192.168.50.1

# DNS servers pushed to clients
dhcp-option=option:dns-server,8.8.8.8,1.1.1.1

# (Optional) prevent upstream DNS leakage / enforce local resolution control
domain-needed
bogus-priv
```

```
sudo systemctl enable --now dnsmasq
```

### Notes on Improvements

- `dhcp-range` now explicitly includes subnet mask (`255.255.255.0`) -> improves compatibility and avoids edge-case
  routing issues.
- Replaced numeric options:
    - `dhcp-option=3` -> `option:router` (clearer intent)
    - `dhcp-option=6` -> `option:dns-server` (more readable, less error-prone)
- Added optional hardening options:
    - `domain-needed` → blocks plain unqualified DNS queries upstream
    - `bogus-priv` → avoids leaking RFC1918 queries to upstream DNS

### Verify DNSMASQ Working

Check DHCP leases:

```bash
cat /var/lib/misc/dnsmasq.leases
```

```bash
UNCONN 0      0            127.0.0.1:53         0.0.0.0:*    users:(("dnsmasq",pid=254926,fd=8))
UNCONN 0      0         192.168.50.1:53         0.0.0.0:*    users:(("dnsmasq",pid=254926,fd=6))
UNCONN 0      0      0.0.0.0%wlp41s0:67         0.0.0.0:*    users:(("dnsmasq",pid=254926,fd=4))
UNCONN 0      0                [::1]:53            [::]:*    users:(("dnsmasq",pid=254926,fd=10))
```

Expected:

- UDP 67 (DHCP)
- UDP 53 (DNS, if enabled)
