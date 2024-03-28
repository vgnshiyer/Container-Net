FROM fedora:latest

# Setup environment
RUN dnf update -y \
    && dnf install -y systemd \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Setup locales, SSH and sudo
RUN dnf update -y \
    && dnf install -y glibc-langpack-en openssh-server sudo dos2unix \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Install tools
RUN dnf update -y \
    && dnf install -y curl vim openssl iproute iputils net-tools lsof unzip git \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Remove unnecessary services
RUN rm -rf /etc/systemd/system/*.wants/* \
    && rm -rf /lib/systemd/system/local-fs.target.wants/* \
    && rm -rf /lib/systemd/system/sockets.target.wants/*udev* \
    && rm -rf /lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -rf /lib/systemd/system/basic.target.wants/* \
    && rm -rf /lib/systemd/system/anaconda.target.wants/*

RUN systemctl mask systemd-firstboot.service systemd-udevd.service systemd-modules-load.service \
    && systemctl unmask systemd-logind

# add user
RUN useradd -m -d /home/guest -s /bin/bash guest \
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
RUN systemctl enable sshd ttyd

ENTRYPOINT ["/sbin/init"]