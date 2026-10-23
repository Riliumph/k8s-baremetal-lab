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

# bashではなくsystemdを起動(/tmpの初期化実行)
CMD ["/sbin/init"]
