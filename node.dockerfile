FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
# Linuxにベースとして導入されるツールはdockerfileに記述する。
# k8sに付随するツール群はansibleで構成管理する。
RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends -y \
    # kernel
    kmod \
    systemd \
    systemd-sysv \
    conntrack \
    ethtool \
    # network
    curl \
    dnsutils \
    netcat-openbsd \
    net-tools \
    iproute2 \
    iputils-ping \
    tcpdump \
    traceroute \
    tshark \
    wget \
    # util
    vim \
    jq \
    sudo \
    procps \
    ca-certificates \
    gnupg \
    apt-transport-https \
    locales \
    # ansible
    openssh-server \
    python3 \
    && apt-get clean\
    && rm -rf /var/lib/apt/lists/*

# 日本語化
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8
ENV TZ=Asia/Tokyo
RUN sed -i -e 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# ansible標準はsshでの接続
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir /var/run/sshd &&\
    echo 'root:root' | chpasswd
EXPOSE 22
COPY config/etc/ssh/sshd_config.d /etc/ssh/sshd_config.d
COPY --chown=root:root .ssh/*.pub /root/.ssh/authorized_keys.d/
RUN mkdir -p /root/.ssh && \
    cat /root/.ssh/authorized_keys.d/*.pub > /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

# config
COPY config/config_map /etc/kubernetes/config_map

# bashではなくsystemdを起動(/tmpの初期化実行)
CMD ["/sbin/init"]
