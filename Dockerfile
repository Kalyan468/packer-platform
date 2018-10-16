FROM alpine:3.6

LABEL name="packer-image-builder"

RUN apk update \
  && apk add --no-cache make python2 python2-dev musl-dev py2-cffi py2-crypto py2-jinja2 py2-markupsafe py2-paramiko \
  py2-yaml py-openssl py-pip unzip curl gcc git bash

RUN pip install ansible==2.2.1.0 \
  && pip install azure-cli

RUN curl -o /tmp/packer.zip https://releases.hashicorp.com/packer/1.2.2/packer_1.2.2_linux_amd64.zip \
  && unzip /tmp/packer.zip -d /usr/local/sbin

ADD . /platform-packer
WORKDIR /platform-packer

CMD ["make"]
