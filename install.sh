#!/bin/bash
## edited by qq1247004718
##date 2026-01-18
## os debian or ubuntn
apt update -y && apt install -y  python3 python3-pip openssl wget git xxd && cd /opt
git clone https://github.com/1247004718/mtprotoproxy.git && cd mtprotoproxy/
secret=$(openssl rand -hex 16)

function get_ip_public() {
    public_ip=$(curl -s https://api.ip.sb/ip -A Mozilla --ipv4)
    [ -z "$public_ip" ] && public_ip=$(curl -s ipinfo.io/ip -A Mozilla --ipv4)
    echo $public_ip
}

while true; do
        default_port=8443
        echo -e "请输入一个客户端连接端口 [1-65535]"
        read -p "(默认端口: ${default_port}):" input_port
        [ -z "${input_port}" ] && input_port=${default_port}
        expr ${input_port} + 1 &>/dev/null
        if [ $? -eq 0 ]; then
            if [ ${input_port} -ge 1 ] && [ ${input_port} -le 65535 ] && [ ${input_port:0:1} != 0 ]; then
                echo
                echo "---------------------------"
                echo "port = ${input_port}"
                echo "---------------------------"
                echo
                break
            fi
        fi
        echo -e "[\033[33m错误\033[0m] 请重新输入一个客户端连接端口 [1-65535]"
    done

while true; do
        default_domain="endfield.gryphline.com"
        echo -e "请输入一个需要伪装的域名："
        read -p "(默认域名: ${default_domain}):" input_domain
        [ -z "${input_domain}" ] && input_domain=${default_domain}
        http_code=$(curl -I -m 10 -o /dev/null -s -w %{http_code} $input_domain)
        if [ $http_code -eq "200" ] || [ $http_code -eq "302" ] || [ $http_code -eq "301" ]; then
            echo
            echo "---------------------------"
            echo "伪装域名 = ${input_domain}"
            echo "---------------------------"
            echo
            break
        fi
        echo -e "[\033[33m状态码：${http_code}错误\033[0m] 域名无法访问,请重新输入或更换域名!"
    done


while true; do
	    public_ip=$(get_ip_public)
        default_tag=""
        echo -e "请输入你需要推广的TAG："
        echo -e "若没有,请联系 @MTProxybot 进一步创建你的TAG, 可能需要信息如下："
        echo -e "IP&PORT ${public_ip}:${input_port}"
        echo -e "SECRET(可以随便填): ${secret}"
        read -p "(留空则跳过):" input_tag
        [ -z "${input_tag}" ] && input_tag=${default_tag}
        if [ -z "$input_tag" ] || [[ "$input_tag" =~ ^[A-Za-z0-9]{32}$ ]]; then
            echo
            echo -e  "\033[31m---------------------------\033[0m"
            echo "PROXY TAG = ${input_tag}"
            echo -e "\033[31m---------------------------\033[0m"
            echo
            break
        fi
        echo -e "[\033[33m错误\033[0m] TAG格式不正确!"
    done

domain_hex=$(echo -n "${input_domain}" | xxd -p)
client_secret="ee${secret}${domain_hex}"
public_ip=$(get_ip_public)

cat > ./config.py <<EOF
PORT = ${input_port}
USERS = {
    "tg":  "${secret}",
}
MODES = {
    # Classic mode, easy to detect
    "classic": False,
    # Makes the proxy harder to detect
    # Can be incompatible with very old clients
    "secure": False,
    # Makes the proxy even more hard to detect
    # Can be incompatible with old clients
    "tls": True
}
TLS_DOMAIN = "${input_domain}"
EOF

if [ ! -z ${input_tag} ];then
echo -e "AD_TAG = \"${input_tag}\"" >> ./config.py
fi

echo -e "TMProxy+TLS代理: \033[32m运行中\033[0m"
echo -e "服务器IP：\033[31m$public_ip\033[0m"
echo -e "服务器端口：\033[31m${input_port}\033[0m"
echo -e "MTProxy Secret:  \033[31m$client_secret\033[0m"
echo -e "TG一键链接: https://t.me/proxy?server=${public_ip}&port=${input_port}&secret=${client_secret}"
echo -e "TG一键链接: tg://proxy?server=${public_ip}&port=${input_port}&secret=${client_secret}"

echo -e "TG一键链接: https://t.me/proxy?server=${public_ip}&port=${input_port}&secret=${client_secret}" > ./mtpinfo.txt
echo -e "TG一键链接: tg://proxy?server=${public_ip}&port=${input_port}&secret=${client_secret}" >> ./mtpinfo.txt
cp mtp.service /etc/systemd/system/mtp.service
systemctl daemon-reload && systemctl enable mtp.service && systemctl restart mtp.service && systemctl status mtp.service
