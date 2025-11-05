#!/usr/bin/env bash

set -e  # 遇到错误时立即退出

# 定义默认参数
WORK_DIR="${WORK_DIR:-/app}"  # 直接使用路径而非 '/app'
PORT="${PORT:-40000}"
USERNAME="${USERNAME:-}"
PASSWORD="${PASSWORD:-}"

# 判断处理器架构
case "$(uname -m)" in
  aarch64 | arm64) ARCH="arm64" ;;
  x86_64 | amd64) ARCH="amd64" ;;
  armv7*) ARCH="arm" ;;
  *) echo "Unsupported architecture: $(uname -m)" && exit 1 ;;
esac

# 创建工作目录（如不存在）
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# 下载 wireproxy 主程序
WPROXY_URL="https://github.com/nap0o/nezha/releases/download/wireproxy/wireproxy_linux_${ARCH}.tar.gz"
if ! wget -O wireproxy.tar.gz "${WPROXY_URL}"; then
  echo "Failed to download wireproxy."
  exit 1
fi

# 解压缩并设置权限
tar -xzvf wireproxy.tar.gz
chmod +x wireproxy
rm wireproxy.tar.gz

# 配置文件路径（确保变量引用正确）
CONF_FILE="${WORK_DIR}/wireproxy.conf"

# 生成 wireproxy 配置文件
cat > "${CONF_FILE}" << EOF
[Interface]
Address = 172.16.0.2/32
Address = 2606:4700:110:8bf3:612a:4cb:916c:1618/128
MTU = 1420
PrivateKey = MCkOw3/3tlW+Um3ZNJyjm78MNNaVirp457AXQBi14Vk=
DNS = 1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = engage.cloudflareclient.com:4500

[Socks5]
BindAddress = 0.0.0.0:${PORT}
EOF

# 如果设置了用户名和密码，则追加到配置文件
if [[ -n "${USERNAME}" && -n "${PASSWORD}" ]]; then
  cat >> "${CONF_FILE}" << EOF
Username = ${USERNAME}
Password = ${PASSWORD}
EOF
fi

# 运行 wireproxy
exec "${WORK_DIR}/wireproxy" --config "${CONF_FILE}"  --silent
