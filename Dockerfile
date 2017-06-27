FROM ubuntu:14.04

RUN apt-get update -y && \
    apt-get install -y python-pip python-dev build-essential wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://releases.hashicorp.com/consul-template/0.18.2/consul-template_0.18.2_linux_amd64.tgz && \
    tar -zxf consul-template_0.18.2_linux_amd64.tgz && \
    mv ./consul-template /usr/local/bin/consul-template

COPY . /app
WORKDIR /app

RUN pip install -r requirements.txt

EXPOSE 7070

CMD ["consul-template", "-config", "/app/vault.hcl"]
