#!/bin/bash

# SSH密钥登录一键配置脚本
# 在服务器上执行此脚本即可完成SSH密钥设置

# 确保脚本以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以root权限运行此脚本 (sudo ./setup.sh)"
    exit 1
fi

# 获取当前用户
CURRENT_USER=$(logname || whoami)
echo "当前用户: $CURRENT_USER"

# 公钥文件路径
PUBLIC_KEY_FILE="$(dirname "$0")/authorized_keys"

# 检查公钥文件是否存在
if [ ! -f "$PUBLIC_KEY_FILE" ]; then
    echo "错误: 公钥文件 '$PUBLIC_KEY_FILE' 不存在"
    echo "请确保authorized_keys文件与脚本在同一目录"
    exit 1
fi

echo "开始配置SSH密钥登录..."

# 确保SSH服务已安装
apt-get update
apt-get install -y openssh-server

# 启动SSH服务并设置为开机自启
systemctl start ssh
systemctl enable ssh

# 检查防火墙并开放SSH端口
if command -v ufw &> /dev/null; then
    ufw allow ssh
fi

# 创建用户的.ssh目录
USER_HOME=$(eval echo ~$CURRENT_USER)
SSH_DIR="$USER_HOME/.ssh"

mkdir -p "$SSH_DIR"
touch "$SSH_DIR/authorized_keys"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/authorized_keys"
chown -R "$CURRENT_USER:$CURRENT_USER" "$SSH_DIR"

# 添加公钥到authorized_keys
cat "$PUBLIC_KEY_FILE" >> "$SSH_DIR/authorized_keys"
echo "公钥已添加到 $SSH_DIR/authorized_keys"

# 配置SSH服务器以使用密钥认证
SSH_CONFIG="/etc/ssh/sshd_config"
cp "$SSH_CONFIG" "$SSH_CONFIG.bak"

# 更新SSH配置
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$SSH_CONFIG"
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' "$SSH_CONFIG"
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' "$SSH_CONFIG"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' "$SSH_CONFIG"

# 重启SSH服务以应用更改
systemctl restart ssh

echo "✅ SSH密钥认证已成功设置"
echo "✅ 现在你可以使用对应的私钥通过SSH连接到此服务器"
echo "✅ 密码认证已被禁用，请确保你的密钥工作正常"
