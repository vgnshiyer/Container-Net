#!/bin/bash

# Read users from env
IFS=',' read -ra GUESTS <<< "$USERS"

# create users
for i in "${GUESTS[@]}"; do
    IFS=':' read -ra USER <<< "$i"
    useradd -m -d /home/${USER[0]} -s /bin/bash ${USER[0]}
    echo "${USER[0]}:${USER[1]}" | chpasswd
    echo "${USER[0]} ALL:(ALL) ALL" >> /etc/sudoers
done