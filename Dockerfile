FROM alpine:latest

WORKDIR /app

# 拷贝必要的文件
COPY files/entrypoint.sh /app/entrypoint.sh

# 安装必要的包，并设置时区
RUN apk update && apk upgrade && \
    apk add --no-cache tzdata bash wget sudo && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    chmod +x /app/entrypoint.sh && \
    rm -rf /var/cache/apk/*

# 设置容器的入口点
ENTRYPOINT ["/app/entrypoint.sh"]
