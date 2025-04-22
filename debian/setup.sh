#!/bin/bash

# SSH密钥登录简单配置脚本

# 确保脚本以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以root权限运行此脚本 (sudo ./setup.sh)"
    exit 1
fi

# 公钥文件路径
PUBLIC_KEY_FILE="$(dirname "$0")/authorized_keys"

# 检查公钥文件是否存在
if [ ! -f "$PUBLIC_KEY_FILE" ]; then
    echo "错误: 公钥文件不存在，请确保authorized_keys文件与脚本在同一目录"
    exit 1
fi

echo "开始配置SSH密钥登录..."

# 安装SSH服务
apt-get update
apt-get install -y openssh-server

# 设置root用户的.ssh目录
SSH_DIR="/root/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 添加公钥到authorized_keys
cat "$PUBLIC_KEY_FILE" > "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"

# 配置SSH服务
SSH_CONFIG="/etc/ssh/sshd_config"
cp "$SSH_CONFIG" "$SSH_CONFIG.bak"

# 修改SSH配置
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$SSH_CONFIG"
sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/' "$SSH_CONFIG"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "$SSH_CONFIG"
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' "$SSH_CONFIG"
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' "$SSH_CONFIG"
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' "$SSH_CONFIG"
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' "$SSH_CONFIG"

# 重启SSH服务
systemctl restart ssh || service ssh restart

echo "SSH密钥登录配置完成！"
