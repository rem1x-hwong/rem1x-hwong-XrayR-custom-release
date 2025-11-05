#!/bin/bash

# 检查 root
if [ "$EUID" -ne 0 ]; then
  echo "错误：必须使用 root 用户运行此脚本！"
  exit 1
fi

# 安装依赖（类似官方）
apt update -y || yum update -y
apt install -y git wget curl unzip || yum install -y git wget curl unzip epel-release

# 创建目录
mkdir -p /etc/XrayR
mkdir -p /lib/systemd/system

# 下载大二进制文件从 Release
RELEASE_TAG="v1.0.0"
wget -O /etc/XrayR/XrayR https://github.com/rem1x-hwong/rem1x-hwong-XrayR-custom-release/releases/download/${RELEASE_TAG}/XrayR
chmod +x /etc/XrayR/XrayR

# 克隆仓库获取小文件
TMP_DIR="/tmp/custom-xrayr"
git clone https://github.com/rem1x-hwong/rem1x-hwong-XrayR-custom-release.git ${TMP_DIR}

# 复制配置和文件
cp -r ${TMP_DIR}/etc/XrayR/* /etc/XrayR/

# 复制服务文件
cp ${TMP_DIR}/lib/systemd/system/XrayR.service /lib/systemd/system/

# 清理临时文件
rm -rf ${TMP_DIR}

# 设置服务
systemctl daemon-reload
systemctl enable XrayR
systemctl start XrayR

echo "安装完成！使用 'systemctl status XrayR' 检查状态。"
