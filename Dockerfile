# 使用 Alpine Linux 作为基础镜像
FROM alpine:3.20

# 安装必要的依赖
RUN apk update && apk add --no-cache \
    bash \
    curl \
    openssh-server \
    openssh-client \
    sudo \
    build-base \
    libffi-dev \
    openssl-dev \
    readline-dev \
    sqlite-dev \
    zlib-dev \
    vim \
    gnupg

# 安装 Git 2.40
RUN apk add --no-cache git

# 安装 Python 3.10
RUN apk add --no-cache python3 py3-pip

# 安装 Node.js、npm、pnpm 和 yarn
RUN apk add --no-cache nodejs npm
RUN npm install -g pnpm yarn

# 生成 SSH 主机密钥
RUN ssh-keygen -A

# 配置 SSH 服务
RUN mkdir -p /var/run/sshd
# 复制自定义的 sshd_config 文件到容器内
COPY sshd_config /etc/ssh/sshd_config
# 清除 root 用户的密码
RUN passwd -d root
# 创建 root 用户的 .ssh 目录并设置权限
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
# 创建 authorized_keys 文件并设置权限
RUN touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys

# 创建 root 用户的 .ssh 目录
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# 修改 root 用户的默认 shell 为 bash
RUN sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

# 创建或修改 .bash_profile 文件，使其加载 .bashrc
RUN echo 'if [ -f ~/.bashrc ]; then' >> /root/.bash_profile && \
    echo '  . ~/.bashrc' >> /root/.bash_profile && \
    echo 'fi' >> /root/.bash_profile

# 暴露 SSH 端口
EXPOSE 22

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]