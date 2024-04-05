<!--<img width="501" alt="Screenshot 2024-04-05 at 10 53 21 AM" src="https://github.com/vgnshiyer/Container-Net/assets/39982819/d4f99c16-d6b7-4835-a7d9-c4d0f1706aed">-->
# Container-Net

A lightweight container based network using docker. (Practice Linux Administration without blowing off your AWS bills)

<img width="266" alt="Screenshot 2024-04-05 at 11 46 22 AM" src="https://github.com/vgnshiyer/Container-Net/assets/39982819/6ff40de3-f5c4-424d-9b7e-5c472fcaddec">

<!-- Badges -->
[![](https://badgen.net/github/license/vgnshiyer/Container-Net)](https://github.com/vgnshiyer/Container-Net/blob/master/LICENSE)
[![](https://img.shields.io/badge/Follow-vgnshiyer-0A66C2?logo=linkedin)](https://www.linkedin.com/comm/mynetwork/discovery-see-all?usecase=PEOPLE_FOLLOWS&followMember=vgnshiyer)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-yellow.svg?logo=buymeacoffee)](https://www.buymeacoffee.com/vgnshiyer)

## Description

Container-Net is a fully functional minimalistic network of servers on your local machine using Docker. 

### Features

- Offers a minimalistic, container-based approach to simulate a network of servers on your local machine, avoiding the overhead associated with virtual machines or cloud services.
- Enables practice with Linux administration, networking commands, and DevOps tools without incurring costs associated with cloud services like AWS.

## Getting Started

**Prerequisites**
    
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) client.

**Installation & Setup**

- Fork this [repository](https://github.com/vgnshiyer/Container-Net).
- Clone this repository. `git clone https://github.com/YOUR-GITHUB-USERNAME/Container-Net`
- Open the directory on vscode.
- Start Container-Net. `cd Container-Net && docker-compose build`
- Open your web browser [localhost:7681](localhost:7681) to access server 1.
- Login using the guest user. (guest1:guest1)

Web Termminal is accesible via port-forwarding for each server, configured by the \<SERVERNAME\>_TTYD_PORT arg in the `.env` file.

## How to's?

**How to add users to the servers?**

Edit the USERS arg in the `.env` file. Add them separated by comma as below.
```
# .env
USERS=username1:password1,username2:password2
```

**Note:** You can choose to bind the home directory of the user to a directory on your local machine using `docker volumes`. For eg.,
```
# docker-compose.yml
volumes:
  - ./data/ubuntu1/home/guest1:/home/guest1
```

**Note:** By default, the added users will have sudo access. To remove sudo access, comment `line no. 11` in `/image-templates/scripts/create_users.sh` file.
```
# scripts/create_users.sh
# echo "${USER[0]} ALL=(ALL:ALL) ALL" >> /etc/sudoers <-- this line
```

**How to add default packaged to the image.**

Edit the <OS>_PACKAGE arg in the `.env` file. Add packages supported by the default package manager for the OS. For eg.,
```
# .env
UBUNTU_PACKAGES=vim,openssl,git
```

The above args will be passed as build arguments for the image template, which will be used internally as environment variables.

**How to add servers to the network?**

- Choose an image template from `/image-templates` directory.
- Specify the name of the image in the \<SERVERNAME\>_DOCKERFILE arg in the `.env` file.
- Optionally add the above args for users to add and packages to install.
- Specify the port forwardings in the `.env` file and `docker-compose.yml` file.
For eg., 
```
# docker-compose.yml
<servername>:
    <hostname: servername>
    <container_name: servername>
    build:
      context: "./image-templates" # image path
      dockerfile: ${SERVERNAME_DOCKERFILE} # image dockerfile name
      args:
        - USERS=${USERS} # users to add
        - PACKAGES=${SERVERNAME_PACKAGES} # packages to install
    image: <servername>
    privileged: true
    volumes: # bind user home directories to local directories
      - ./data/<servername>/home/guest1:/home/guest1
      - ./data/<servername>/home/guest2:/home/guest2
      - ./data/<servername>/root:/root
    ports:
      - ${SERVERNAME_PORT_SSHD}:22 # ssh
      - ${SERVERNAME_PORT_TTYD}:7681 # web terminal
    networks:
      - container_net
```

## Contributing

Thank you for considering contributing to this project! Your help is greatly appreciated.

To contribute to this project, please follow these guidelines:

### Opening Issues
If you encounter a bug, have a feature request, or want to discuss something related to the project, please open an issue on the GitHub repository. When opening an issue, please provide:

**Bug Reports**: Describe the issue in detail. Include steps to reproduce the bug if possible, along with any error messages or screenshots.

**Feature Requests**: Clearly explain the new feature you'd like to see added to the project. Provide context on why this feature would be beneficial.

**General Discussions**: Feel free to start discussions on broader topics related to the project.

### Steps

1️⃣ Fork the GitHub repository https://github.com/vgnshiyer/Container-Net \
2️⃣ Create a new branch for your changes (git checkout -b feature/my-new-feature). \
3️⃣ Make your changes and test them thoroughly. \
4️⃣ Push your changes and open a Pull Request to `main`.

*Please provide a clear title and description of your changes.*

## Bonus

Here is a detailed tutorial on how to setup ansible on Container-Net on my [website](https://vgnshiyer.dev/).

## Version History

* 0.1
    * Initial Release.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/vgnshiyer/Container-Net/blob/main/LICENSE) file for details.
