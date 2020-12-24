FROM ubuntu:20.04

RUN echo "\e[1;32mUpdating packages and installing SFTP server package...\e[0m" && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' -fuy --allow-downgrades --allow-remove-essential --allow-change-held-packages upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' -fuy --allow-downgrades --allow-remove-essential --allow-change-held-packages dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' -fuy --allow-downgrades --allow-remove-essential --allow-change-held-packages install ssh && \
    DEBIAN_FRONTEND=noninteractive apt-get  -o Dpkg::Options::='--force-confold' -y clean

ARG AGENT_GPG_FINGERPRINT=3EE5B012FA7B400CD952601E4689F1F0F358FABA
ARG AGENT_GPG_SOURCE=https://containerssh.io/gpg.txt

RUN echo "\e[1;32mInstalling ContainerSSH guest agent...\e[0m" && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' -fuy --allow-downgrades --allow-remove-essential --allow-change-held-packages install gpg && \
    wget -q -O - https://api.github.com/repos/containerssh/agent/releases/latest | grep browser_download_url | grep -e "agent_.*_linux_amd64.deb" | awk ' { print $2 } ' | sed -e 's/"//g' > /tmp/assets.txt && \
    wget -q -O /tmp/agent.deb $(cat /tmp/assets.txt |grep -v .sig) && \
    wget -q -O /tmp/agent.deb.sig $(cat /tmp/assets.txt |grep .sig) && \
    wget -q -O - $AGENT_GPG_SOURCE | gpg --import && \
    echo -e "5\ny\n" | gpg --command-fd 0 --batch --expert --edit-key $AGENT_GPG_FINGERPRINT trust && \
    test $(gpg --status-fd=1 --verify /tmp/agent.deb.sig /tmp/agent.deb | grep VALIDSIG | grep $AGENT_GPG_FINGERPRINT | wc -l) -eq 1 && \
    dpkg -i /tmp/agent.deb && \
    rm -rf /tmp/* && \
    rm -rf ~/.gnupg && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' -fuy --allow-downgrades --allow-remove-essential --allow-change-held-packages remove gpg && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confold' -y clean && \
    /usr/bin/containerssh-agent -h

CMD ["/bin/bash"]
SHELL ["/bin/bash"]
ONBUILD RUN echo "The ContainerSSH guest image is not intended as a base image and may change at any time. Please build your own image." >&2 && exit 1
