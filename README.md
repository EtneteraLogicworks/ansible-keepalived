# keepalived role

Role deploys `keepalived` managing IP failover between the two servers.

Primary server muset have `failover_role` variable set to **master**.
Secondary server muset have `failover_role` variable set to **backup**.

## Proměnné

| Variable      | Mandatory | Default    | Description |
| ------------- | --------- | ---------- | ----------- |
| failover_role | yes       |            | Value `master` or `backup` |
|               |           |            |             |
| keepalived    | yes       |            | Main configuration dictionary |
| .instances    | no        | []         | Every item of the array contains configuration of the single VRRP instance |
| ..name        | yes       |            | Name of the VRRP instance |
| ..state       | ne        | "BACKUP"   | Stav MASTER nebo BACKUP |
| ..priority    | yes       |            | Priorita uzlů v tom, kdo získá VIP. Vyšší vyhrává. (0..255) |
| ..password    | yes       |            | Password with maximum of 8 characters |
| ..ipv4        | yes       |            | Virtual IPv4 address |
| ..router_id   | yes       |            | ID for the router group (0..255) |
| ..interface   | no        | "ens1"     | Network interface |
| ..advert_int  | no        | "1"        | Keepalived interval in seconds (float) |
| ..nopreempt   | no        | true       | Disable automatic handover of the VIP address back to node with higher priority after it recovers. To make if work state of both nodes [must](https://www.keepalived.org/manpage.html) be set to `BACKUP` |
| ..notify      | no        |            | Path no notify script |
|               |           |            |             |
| .sync_groups  | no        | []         | Every item of the array contains configuration of the single vrrp_sync_group |
| ..name        | yes       |            | Name of the vrrp_sync_group |
| ..members     | yes       |            | Array of VRRP instances name |
| ..notify      | no        |            | Path no notify script |


## Examples

### Basic IP failover for single interface

Server 1 (primary):

```yaml
keepalived:
  - name: 'failover'
    priority: 150
    password: 'drak'
    ipv4: '192.168.18.18'
    router_id: 18
```

Server 2 (backup):

```yaml
keepalived:
  - name: 'failover'
    priority: 100
    password: 'drak'
    ipv4: '192.168.18.18'
    router_id: 18
```

### Multiple dependent interfaces failover

Server 1 (primary):

```yaml
keepalived:
  sync_groups:
    - name: 'router'
      members:
        - 'wan'
        - 'lan'
      notify: '/opt/scripts/keepalived_notify.sh'

  instances:
    - name: 'wan'
      interface: 'ens1'
      priority: 10
      password: 'iheslo'
      ipv4: '18.18.18.18'
      router_id: 1

    - name: 'lan'
      interface: 'ens2'
      priority: 10
      password: 'iheslo'
      ipv4: '10.10.10.10'
      router_id: 1
```

Server 2 (backup):

```yaml
keepalived:
  sync_groups:
    - name: 'router'
      members:
        - 'wan'
        - 'lan'
      notify: '/opt/scripts/keepalived_notify.sh'

  instances:
    - name: 'wan'
      interface: 'ens1'
      priority: 5
      password: 'iheslo'
      ipv4: '18.18.18.18'
      router_id: 1

    - name: 'lan'
      interface: 'ens2'
      priority: 5
      password: 'iheslo'
      ipv4: '10.10.10.10'
      router_id: 1
```
