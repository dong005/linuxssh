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
echo "使用公钥文件: $PUBLIC_KEY_FILE"

# 确保SSH服务已安装
echo "正在安装SSH服务..."
apt-get update
apt-get install -y openssh-server

# 启动SSH服务并设置为开机自启
echo "正在启动SSH服务..."
systemctl start ssh || service ssh start
systemctl enable ssh || update-rc.d ssh defaults

# 检查防火墙并开放SSH端口
if command -v ufw &> /dev/null; then
    echo "正在配置防火墙..."
    ufw allow ssh
fi

# 创建用户的.ssh目录
USER_HOME=$(eval echo ~$CURRENT_USER)
SSH_DIR="$USER_HOME/.ssh"

echo "正在设置SSH目录: $SSH_DIR"
mkdir -p "$SSH_DIR"
touch "$SSH_DIR/authorized_keys"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/authorized_keys"
chown -R "$CURRENT_USER:$CURRENT_USER" "$SSH_DIR"

# 添加公钥到authorized_keys
echo "正在添加公钥到authorized_keys文件..."
cat "$PUBLIC_KEY_FILE" >> "$SSH_DIR/authorized_keys"
echo "公钥内容:"
cat "$PUBLIC_KEY_FILE"
echo "公钥已添加到 $SSH_DIR/authorized_keys"

# 配置SSH服务器以使用密钥认证
SSH_CONFIG="/etc/ssh/sshd_config"
echo "正在备份SSH配置文件..."
cp "$SSH_CONFIG" "$SSH_CONFIG.bak"

echo "正在更新SSH配置..."
# 更新SSH配置
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$SSH_CONFIG"
sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/' "$SSH_CONFIG"
sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' "$SSH_CONFIG"

# 临时保留密码登录，确保密钥登录正常后再禁用
# sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' "$SSH_CONFIG"
# sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' "$SSH_CONFIG"
echo "注意: 暂时保留密码登录，确保密钥登录正常后再禁用"

# 确保root用户可以使用密钥登录
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "$SSH_CONFIG"
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' "$SSH_CONFIG"
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' "$SSH_CONFIG"

# 重启SSH服务以应用更改
echo "正在重启SSH服务..."
systemctl restart ssh || service ssh restart

echo "SSH配置完成！请尝试使用密钥登录"
echo "如果密钥登录成功，可以通过以下命令禁用密码登录:"
echo "sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
echo "sudo systemctl restart ssh"

# 显示当前SSH配置
echo "当前SSH配置状态:"
grep -E "PubkeyAuthentication|PasswordAuthentication|PermitRootLogin|AuthorizedKeysFile" "$SSH_CONFIG"

# 检查authorized_keys文件内容
echo "authorized_keys文件内容:"
cat "$SSH_DIR/authorized_keys"
