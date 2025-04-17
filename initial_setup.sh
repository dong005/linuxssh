#!/bin/bash

# Ubuntu初始设置脚本
# 执行系统更新和升级

echo "正在更新软件包列表..."
sudo apt update

echo "正在升级已安装的软件包..."
sudo apt upgrade -y

echo "系统更新完成！"

#切换目录
cd /home
#安装仓库
sudo apt install git curl wget -y
#克隆仓库
sudo git clone http://github.com/dong005/linuxssh.git
sudo git clone http://github.com/dong005/safetime.git

#安装linuxssh
cd /home/linuxssh/ubuntu
sudo chmod +x *
sudo bash ./setup.sh

#安装safetime
cd /home/safetime
sudo chmod +x *
sudo ./install.sh

# 使用snap安装Telegram和Signal
echo "正在安装Telegram..."
sudo snap install telegram-desktop

echo "正在安装Signal..."
sudo snap install signal-desktop

echo "Telegram和Signal安装完成！"

#安装windsurf
curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | sudo gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null

sudo apt-get update
sudo apt-get upgrade windsurf -y