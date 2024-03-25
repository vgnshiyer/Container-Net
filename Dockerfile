FROM ubuntu:22.04

CMD ["/bin/bash"]
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

COPY ttyd.x86_64 /bin/ttyd.x86_64
COPY ttyd.aarch64 /bin/ttyd.aarch64

EXPOSE 7681

CMD tail -f /dev/null
# RUN ln -s /bin/ttyd.$(uname -m) /bin/ttyd