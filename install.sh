#!/bin/bash

# 全局变量
RELEASE_TAG="v1.0.2"  # 与备份匹配
REPO_URL="https://github.com/rem1x-hwong/rem1x-hwong-XrayR-custom-release.git"
SERVICE_NAME="XrayR.service"
CONFIG_FILE="/etc/XrayR/config.yml"
BINARY_PATH="/usr/local/XrayR/XrayR"

# 检查 root
if [ "$EUID" -ne 0 ]; then
  echo "错误：必须使用 root 用户运行此脚本！"
  exit 1
fi

# 显示菜单
show_menu() {
  echo "XrayR 管理菜单（魔改版）"
  echo "0. 安装/升级 XrayR"
  echo "3. 卸载 XrayR"
  echo "6. 重启 XrayR"
  echo "7. 查看 XrayR 日志"
  echo "8. 修改 XrayR 配置"
  echo "其他任意键退出"
  read -p "请输入选择: " choice
}

# 功能0: 安装/升级（原有逻辑）
install_xrayr() {
  # 安装依赖
  apt update -y || yum update -y
  apt install -y git wget curl unzip nano || yum install -y git wget curl unzip epel-release nano

  # 创建目录
  mkdir -p /etc/XrayR
  mkdir -p /usr/local/XrayR
  mkdir -p /lib/systemd/system

  # 下载大二进制文件从 Release
  wget -O ${BINARY_PATH} https://github.com/rem1x-hwong/rem1x-hwong-XrayR-custom-release/releases/download/${RELEASE_TAG}/XrayR
  chmod +x ${BINARY_PATH}

  # 克隆仓库获取小文件
  TMP_DIR="/tmp/custom-xrayr"
  git clone ${REPO_URL} ${TMP_DIR}

  # 复制配置和文件
  cp -r ${TMP_DIR}/etc/XrayR/* /etc/XrayR/

  # 复制服务文件
  cp ${TMP_DIR}/lib/systemd/system/${SERVICE_NAME} /lib/systemd/system/

  # 清理临时文件
  rm -rf ${TMP_DIR}

  # 设置服务
  systemctl daemon-reload
  systemctl enable XrayR
  systemctl start XrayR

  echo "安装/升级完成！使用 'systemctl status XrayR' 检查状态。"
}

# 功能3: 卸载 XrayR
uninstall_xrayr() {
  echo "卸载 XrayR..."
  systemctl stop XrayR
  systemctl disable XrayR
  rm -f /lib/systemd/system/XrayR.service
  rm -rf /etc/XrayR
  rm -rf /usr/local/XrayR
  systemctl daemon-reload
  echo "卸载完成！"
}

# 功能6: 重启 XrayR
restart_xrayr() {
  echo "重启 XrayR..."
  systemctl restart XrayR
  echo "重启完成！检查状态: systemctl status XrayR"
}

# 功能7: 查看 XrayR 日志
view_log() {
  echo "查看 XrayR 日志..."
  journalctl -u XrayR -e --no-pager -n 100
}

# 功能8: 修改 XrayR 配置
edit_config() {
  if ! command -v nano &> /dev/null; then
    echo "nano 未安装，正在安装..."
    apt install -y nano || yum install -y nano
  fi
  echo "修改配置: ${CONFIG_FILE}"
  nano ${CONFIG_FILE}
  echo "修改完成！重启生效: systemctl restart XrayR"
}

# 主循环
while true; do
  show_menu
  case $choice in
    0) install_xrayr ;;
    3) uninstall_xrayr ;;
    6) restart_xrayr ;;
    7) view_log ;;
    8) edit_config ;;
    *) echo "退出脚本。" ; exit 0 ;;
  esac
done
