ARG BUILD_FROM
FROM $BUILD_FROM

ARG NAME=openvpnclient

# Add env
ENV LANG C.UTF-8

# install openvpn package
RUN apk add --update --no-cache openvpn jq python3 bash python3-dev \
    build-base \
    linux-headers \
    pcre-dev \
    py-pip \
    curl \
    openssl

# setup python within an virtual environment
RUN python3 -m venv /$NAME/venv && \
        source /$NAME/venv/bin/activate && \
        pip install --upgrade pip --no-cache-dir && \
        pip install --upgrade  --no-cache-dir setuptools wheel

COPY . /tmp/$NAME

RUN source /$NAME/venv/bin/activate && \
    cd /tmp/$NAME && python setup.py bdist_wheel &&\
    pip install  --no-cache-dir dist/* && cd / && rm -r /tmp/$NAME

WORKDIR /$NAME/venv/

# expose name of working dir to environment
ENV NAME $NAME

ENTRYPOINT /bin/bash /$NAME/venv/bin/run.sh