#!/bin/bash

# Hyper-V分辨率设置脚本 - 1920x1080

# 确保脚本以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以root权限运行此脚本 (sudo ./set_resolution.sh)"
    exit 1
fi

echo "开始设置Hyper-V分辨率为1920x1080..."

# 检查是否为Hyper-V环境
if ! dmesg | grep -i hyper-v > /dev/null; then
    echo "警告: 未检测到Hyper-V环境，脚本可能不适用于当前系统"
    echo "是否继续? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "操作已取消"
        exit 0
    fi
fi

# 安装必要的包
apt-get update
apt-get install -y xserver-xorg-video-fbdev

# 创建grub配置文件
cat > /etc/default/grub.d/resolution.cfg << EOF
# 设置Hyper-V分辨率为1920x1080
GRUB_CMDLINE_LINUX_DEFAULT="\$GRUB_CMDLINE_LINUX_DEFAULT video=hyperv_fb:1920x1080"
EOF

# 更新grub
update-grub

echo "分辨率设置完成！请重启系统以应用更改"
echo "重启命令: sudo reboot"

# 提示用户重启
echo "是否立即重启系统? (y/n)"
read -r reboot_now
if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
    echo "系统将在5秒后重启..."
    sleep 5
    reboot
fi
