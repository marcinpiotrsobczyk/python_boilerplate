FROM ubuntu:22.04 AS base_image

RUN apt-get update && \
    apt-get install -y \
    bats \
    git \
    cmake \
    make \
    gcc \
    g++ \
    build-essential \
    clang-format \
    clang-tidy \
    autoconf \
    libtool \
    screen \
    python3 \
    python3-pip \
    python3-venv \
    libluajit-5.1-dev \
    libmysqlclient-dev \
    libboost-system-dev \
    libboost-iostreams-dev \
    libboost-filesystem-dev \
    libpugixml-dev \
    libcrypto++-dev \
    libfmt-dev \
    libboost-date-time-dev \
    libboost-all-dev \
    jq \
    docker.io \
    wget \
    curl \
    iputils-ping \
    ncat \
    postgresql-client \
    xvfb && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://install.python-poetry.org | python3 -  # install poetry in an isolated environment
ENV PATH="${PATH}:/root/.local/bin"

RUN wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.16.3/hadolint-Linux-x86_64

RUN chmod +x /bin/hadolint


FROM base_image AS image

ADD . /src
RUN cd /src && git clean -xfd
WORKDIR /src
