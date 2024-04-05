FROM alpine:latest

# Setup environment
RUN apk update \
    && apk add openrc \
    && rm -rf /var/cache/apk/*

# Setup locales, SSH and sudo
RUN apk update \
    && apk add openssh sudo dos2unix \
    && rm -rf /var/cache/apk/*

# Install tools
ARG PACKAGES
ENV PACKAGES=$PACKAGES
RUN apk update \
    && apk add curl $(echo $PACKAGES | tr ',' ' ') \
    && rm -rf /var/cache/apk/*

# add custom message to look cool
COPY /scripts/add_motd.sh add_motd.sh
RUN chmod +x add_motd.sh
RUN ./add_motd.sh

# add users
RUN echo "root:root" | chpasswd

ARG USERS
ENV USERS=$USERS
COPY /scripts/create_users.sh create_users.sh
RUN chmod +x create_users.sh
RUN ./create_users.sh

# Setup ttyd
COPY binaries/ttyd.x86_64 /bin/ttyd.x86_64
COPY binaries/ttyd.aarch64 /bin/ttyd.aarch64
RUN chmod +x /bin/ttyd.x86_64 /bin/ttyd.aarch64
RUN ln -s /bin/ttyd.$(uname -m) /bin/ttyd

# Setup SSH
RUN sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

EXPOSE 22
EXPOSE 7681

# Setup services to run on boot
RUN rc-update add sshd \
    && rc-update add ttyd

ENTRYPOINT ["/sbin/init"]