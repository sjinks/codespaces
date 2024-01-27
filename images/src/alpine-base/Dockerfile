FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV CONTAINER_USER ${USERNAME}

RUN \
    apk upgrade --no-cache && \
    apk add --no-cache \
        runit \
        bash \
        openssh-client \
        gnupg \
        procps \
        lsof \
        htop \
        net-tools \
        psmisc \
        curl \
        wget \
        rsync \
        ca-certificates \
        unzip \
        zip \
        nano \
        vim \
        less \
        jq \
        libgcc \
        libstdc++ \
        krb5-libs \
        libintl \
        libssl3 \
        lttng-ust \
        tzdata \
        userspace-rcu \
        zlib \
        sudo \
        coreutils \
        sed \
        grep \
        which \
        ncdu \
        shadow \
        strace \
        mandoc man-pages \
        git \
        su-exec gettext github-cli

COPY rootfs /

RUN \
    groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd -s /bin/bash --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" && \
    echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" && \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"

# From /etc/profile.d/locale.sh
ENV CHARSET UTF-8
ENV LANG C.UTF-8
ENV LC_COLLATE C

ENTRYPOINT ["/usr/local/bin/runit-wrapper"]
