FROM alpine:3 as Downloader

WORKDIR /tmp

RUN apk --update add --no-cache --virtual .build-deps \
    curl \
 && rm -rf /var/cache/apk/* \
 && curl -sSLo /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py

FROM alpine:3

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

COPY --from=Downloader /tmp/get-pip.py /tmp/get-pip.py

RUN apk --update add --no-cache --virtual .build-deps \
        python3 \
        nodejs-current \
        npm \
 && rm -rf /var/cache/apk/* \
 && python3 /tmp/get-pip.py \
 && rm -rf /tmp/get-pip.py \
 && pip install -U setuptools \
 && pip install -U awscli \
 && npm i -g aws-cdk

ARG USER_NAME="cdk"

RUN addgroup -g 1000 -S ${USER_NAME} \
 && adduser -u 1000 -S  ${USER_NAME} -G ${USER_NAME}

COPY --chown=cdk:cdk entrypoint.sh /home/cdk/entrypoint.sh

RUN chmod 744 /home/cdk/entrypoint.sh

# USER ${USER_NAME}

ENTRYPOINT [ "/home/cdk/entrypoint.sh" ]
