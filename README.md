# Linux SSH密钥登录配置工具

这个仓库包含一个简单的脚本，用于在Linux服务器上快速配置SSH密钥登录。

## 使用方法

1. 将你的SSH公钥文件命名为`authorized_keys`并放在与脚本相同的目录中
2. 在服务器上执行以下命令：
   ```bash
   sudo ./setup.sh
   ```

## 功能

- 自动安装并配置SSH服务
- 设置正确的文件权限
- 添加公钥到authorized_keys
- 配置SSH服务器启用密钥认证并禁用密码登录
- 重启SSH服务应用更改

## 注意事项

- 此脚本需要以root权限运行
- 确保公钥文件与脚本在同一目录
- 执行后密码登录将被禁用，请确保密钥登录正常工作
