FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove unnecessary files
RUN rm -f /lib/systemd/system/multi-user.target.wants/*
RUN rm -rf /etc/update-motd.d/60-unminimize

RUN systemctl mask systemd-firstboot.service systemd-udevd.service systemd-modules-load.service \
    && systemctl unmask systemd-logind

RUN apt-get update \
    && apt-get install -y locales openssh-server sudo dos2unix \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /conf \
    && echo root > /conf/root_passwd \
    && echo guest > /conf/guest_user \
    && echo guest > /conf/guest_passwd \
    && echo '/bin/bash' > /conf/guest_shell

RUN useradd -m -s /bin/bash guest \
    && echo "guest:guest" | chpasswd

RUN echo "root:root" | chpasswd

COPY binaries/ttyd.x86_64 /bin/ttyd.x86_64
COPY binaries/ttyd.aarch64 /bin/ttyd.aarch64
COPY binaries/ttyd.service /lib/systemd/system/ttyd.service
RUN chmod +x /bin/ttyd.x86_64 /bin/ttyd.aarch64
RUN ln -s /bin/ttyd.$(uname -m) /bin/ttyd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN systemctl enable ssh ttyd

EXPOSE 22
EXPOSE 7681

RUN apt-get update \
    && apt-get install -y curl vim openssl iproute2 iputils-ping net-tools lsof unzip git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["tail", "-f", "/dev/null"]