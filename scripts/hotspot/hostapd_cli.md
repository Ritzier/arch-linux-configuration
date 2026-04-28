## Show connected device

```sh
hostapd_cli -i ap0 all_sta
```

## Show ACCEPTED `MAC`

```sh
hostapd_cli -i ap0 ACCEPT_ACL SHOW
```

## Add `MAC` to Accept

```sh
hostapd_cli -i ap0 ACCEPT_ACL ADD_MAC d4:ba:fa:d1:db:cb
```

## Deauthenticate (force disconnect)

```sh
hostapd_cli -i ap0 deauthenticate d4:ba:fa:d1:db:cb
```

## Remove from ACCEPT_ACL

```sh
hostapd_cli -i ap0 ACCEPT_ACL DEL_MAC d4:ba:fa:d1:db:cb
```
