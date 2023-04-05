#!/bin/sh

echo never > /sys/kernel/mm/transparent_hugepage/enabled
su -l test -c "redis-server /opt/redis/redis.conf"