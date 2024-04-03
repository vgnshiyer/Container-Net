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
ARG PACKAGES
ENV PACKAGES=$PACKAGES
RUN dnf update -y \
    && dnf install -y curl $(echo $PACKAGES | sed 's/,[ ]*/ /g') \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Remove unnecessary services
RUN rm -rf /etc/systemd/system/*.wants/* \
    && rm -rf /lib/systemd/system/local-fs.target.wants/* \
    && rm -rf /lib/systemd/system/sockets.target.wants/*udev* \
    && rm -rf /lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -rf /lib/systemd/system/basic.target.wants/* \
    && rm -rf /lib/systemd/system/anaconda.target.wants/* \
    && rm -rf /etc/update-motd.d/* \
    && rm -rf /etc/legal

# add custom message to look cool
COPY /scripts/add_motd.sh add_motd.sh
RUN chmod +x add_motd.sh
RUN ./add_motd.sh

RUN systemctl mask systemd-firstboot.service systemd-udevd.service systemd-modules-load.service \
    && systemctl unmask systemd-logind

# add user
RUN echo "root:root" | chpasswd

ARG USERS
ENV USERS=$USERS
COPY /scripts/create_users.sh create_users.sh
RUN chmod +x create_users.sh
RUN ./create_users.sh

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