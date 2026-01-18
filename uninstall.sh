#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#Check Root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: 需要root权限才能执行本脚本${CEND}"; exit 1; }
# 删除文件
rm -f /opt/mtprotoproxy
# 删除服务文件
systemctl stop mtp.service
systemctl disable mtp.service
rm -rf /etc/systemd/system/mtp.service
systemctl daemon-reload
clear
echo "卸载成功！"
