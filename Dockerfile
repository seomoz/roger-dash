FROM ubuntu:14.04

RUN apt-get update -y && \
    apt-get install -y python-pip python-dev build-essential wget && \
    rm -rf /var/lib/apt/lists/*

ADD https://github.com/funnylookinhat/vaultexec/releases/download/v0.2.3/vaultexec_linux_amd64 /usr/local/bin/vaultexec
ADD https://github.com/seomoz/roger-fetch-vault-token/releases/download/v0.3.1/roger-fetch-vault-token_linux_amd64 /usr/local/bin/roger-fetch-vault-token
RUN chmod +x /usr/local/bin/vaultexec && \
    chmod +x /usr/local/bin/roger-fetch-vault-token

COPY . /app
WORKDIR /app

RUN pip install -r requirements.txt

EXPOSE 7070

CMD ["python", "server.py"]
