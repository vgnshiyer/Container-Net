FROM ubuntu:22.04

# Setup environment
RUN apt-get update \
    && apt-get install -y systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup locales, SSH and sudo
RUN apt-get update \
    && apt-get install -y locales openssh-server sudo dos2unix \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install tools
RUN apt-get update \
    && apt-get install -y curl vim openssl iproute2 iputils-ping net-tools lsof unzip git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove unnecessary services
RUN rm -rf /etc/systemd/system/*.wants/* \
    && rm -rf /lib/systemd/system/local-fs.target.wants/* \
    && rm -rf /lib/systemd/system/sockets.target.wants/*udev* \
    && rm -rf /lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -rf /lib/systemd/system/basic.target.wants/* \
    && rm -rf /lib/systemd/system/anaconda.target.wants/* \
    && rm -rf /etc/update-motd.d/60-unminimize \
    && rm -rf /etc/update-motd.d/10-help-text

# add user
RUN useradd -m -s /bin/bash guest \
    && echo "guest:guest" | chpasswd
RUN echo "guest ALL=(ALL) ALL" >> /etc/sudoers

RUN echo "root:root" | chpasswd

# Setup ttyd
COPY binaries/ttyd.x86_64 /bin/ttyd.x86_64
COPY binaries/ttyd.aarch64 /bin/ttyd.aarch64
COPY binaries/ttyd.service /lib/systemd/system/ttyd.service
RUN chmod +x /bin/ttyd.x86_64 /bin/ttyd.aarch64
RUN ln -s /bin/ttyd.$(uname -m) /bin/ttyd

# Setup SSH
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

EXPOSE 22
EXPOSE 7681

# Setup services to run on boot
RUN systemctl enable ssh ttyd

ENTRYPOINT ["/sbin/init"]