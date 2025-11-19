FROM alpine:3.18

RUN apk add --no-cache bash curl jq python3 py3-pip && \
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-444.0.0-linux-x86_64.tar.gz && \
    tar -xf google-cloud-cli-444.0.0-linux-x86_64.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    rm google-cloud-cli-444.0.0-linux-x86_64.tar.gz

ENV PATH $PATH:/app/google-cloud-sdk/bin

WORKDIR /app

COPY . .

CMD ["bash", "auto_chat.sh"]