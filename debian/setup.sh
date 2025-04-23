#!/bin/bash

# SSH密钥登录配置脚本 (Debian 12兼容优化版)

if [ "$(id -u)" -ne 0 ]; then
    echo "请以root权限运行此脚本 (sudo ./setup.sh)"
    exit 1
fi

# 公钥文件路径检查
PUBLIC_KEY_FILE="$(dirname "$0")/authorized_keys"
if [ ! -f "$PUBLIC_KEY_FILE" ]; then
    echo "错误: 公钥文件不存在，请确保authorized_keys文件与脚本在同一目录"
    exit 1
fi

echo "正在安装和配置SSH服务..."
apt update
apt install -y openssh-server

# 设置密钥登录
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cp "$PUBLIC_KEY_FILE" /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# 备份并配置SSH
SSH_CONFIG="/etc/ssh/sshd_config"
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak"

sed -i '/^PubkeyAuthentication/d' "$SSH_CONFIG"
echo "PubkeyAuthentication yes" >> "$SSH_CONFIG"

sed -i '/^PermitRootLogin/d' "$SSH_CONFIG"
echo "PermitRootLogin yes" >> "$SSH_CONFIG"

sed -i '/^PasswordAuthentication/d' "$SSH_CONFIG"
echo "PasswordAuthentication no" >> "$SSH_CONFIG"

# 启动SSH服务并设置开机自启动
systemctl restart ssh
systemctl enable ssh

echo "🎉 SSH密钥登录配置已成功完成!"
