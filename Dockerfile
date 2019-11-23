FROM alpine:3

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

RUN apk --update add --no-cache --virtual .build-deps \
        python3 \
        py3-setuptools \
        nodejs-current \
        npm \
 && pip3 install -U pip \
 && pip install -U awscli \
 && npm i -g aws-cdk

ARG USER_NAME="cdk"

RUN addgroup -g 1000 -S ${USER_NAME} \
 && adduser -u 1000 -S  ${USER_NAME} -G ${USER_NAME}

COPY --chown=cdk:cdk entrypoint.sh /home/cdk/entrypoint.sh

RUN chmod 744 /home/cdk/entrypoint.sh

# USER ${USER_NAME}

ENTRYPOINT [ "/home/cdk/entrypoint.sh" ]
