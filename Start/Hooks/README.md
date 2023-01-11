# Hooks

### Mariadb

```shell
wget -q -O /etc/pacman.d/hooks/97-mariadb.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/97-mariadb.hook && \
wget -q -O /etc/pacman.d/hooks/98-98-mariadb-upgrade.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/98-98-mariadb-upgrade.hook
```

### Postgresql

#### Install

```shell
yes | pacman -S postgresql postgresql-libs postgresql-old-upgrade
```

#### Hook

```shell
wget -q -O /etc/pacman.d/hooks/95-postgresql.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/95-postgresql.hook && \
wget -q -O /etc/pacman.d/hooks/96-postgresql.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/96-postgresql.hook && \
wget -q -O /etc/pacman.d/hooks/97-postgresql.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/97-postgresql.hook && \
wget -q -O /etc/pacman.d/hooks/98-postgresql.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/98-postgresql.hook
```

#### Test

```shell
wget -q -O- https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/Start/Tool/Test/pg-test-env.sh | bash && \
/usr/bin/su -c '/usr/bin/wget -q -O- https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/Start/Tool/Test/pg-test.sh | /usr/bin/bash' postgres
```

### Redis

```shell
wget -q -O /etc/pacman.d/hooks/97-redis.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/97-redis.hook
```
