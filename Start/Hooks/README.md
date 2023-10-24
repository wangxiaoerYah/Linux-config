# Hooks

## Script Install
```shell
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/Start/Hooks/scripts/Hook.sh | bash

```








### Postgresql

#### Install

```shell
yes | pacman -S postgresql postgresql-libs postgresql-old-upgrade
```

#### Hook

```shell
wget -q -O /etc/pacman.d/hooks/95-postgresql.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/root/etc/pacman.d/hooks/95-postgresql.hook && \
wget -q -O /etc/pacman.d/hooks/96-postgresql.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/root/etc/pacman.d/hooks/96-postgresql.hook && \
wget -q -O /etc/pacman.d/hooks/97-postgresql.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/root/etc/pacman.d/hooks/97-postgresql.hook && \
wget -q -O /etc/pacman.d/hooks/98-postgresql.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/root/etc/pacman.d/hooks/98-postgresql.hook
```

#### Test

```shell
wget -q -O- https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/Start/Tool/Test/pg-test-env.sh | bash && \
/usr/bin/su -c '/usr/bin/wget -q -O- https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/Start/Tool/Test/pg-test.sh | /usr/bin/bash' postgres
```

### Redis

```shell
wget -q -O /etc/pacman.d/hooks/97-redis.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/root/etc/pacman.d/hooks/97-redis.hook
```
