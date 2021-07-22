FROM kalilinux/kali-rolling

WORKDIR /app/

COPY webdiscover.sh /app/webdiscover.sh

RUN \
    apt-get update && \
    apt-get install -y \
    python-setuptools \
    python3-setuptools \
    python3-pip \
    git \
    curl \
    wget \
    python \
    python3 \
    zip \
    unzip \
    seclists \
    ffuf \
    dnsrecon \
    subfinder \
    whatweb \
    gospider \
    exploitdb


RUN wget https://raw.githubusercontent.com/darkoperator/dnsrecon/master/namelist.txt -O /usr/share/namelist.txt

RUN wget https://github.com/projectdiscovery/nuclei/releases/download/v2.4.0/nuclei_2.4.0_linux_amd64.zip && unzip nuclei_2.4.0_linux_amd64.zip && mv nuclei /usr/bin/nuclei && cd /opt && git clone https://github.com/projectdiscovery/nuclei-templates.git

RUN ["chmod", "+x", "./webdiscover.sh"]

ENTRYPOINT [ "./webdiscover.sh" ]
