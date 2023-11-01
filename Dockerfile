FROM ubuntu:22.04 AS python_boilerplate_base_image

RUN apt update && apt install -y \
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
    python-is-python3 \
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
    xvfb && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://install.python-poetry.org | python -  # install poetry in an isolated environment
RUN export PATH="/root/.local/bin:$PATH"

FROM python_boilerplate_base_image AS build

COPY . /src
RUN cd /src && git clean -xfd
RUN cmake -S /src -B /build -D CMAKE_BUILD_TYPE=Debug && cmake --build /build

FROM python_boilerplate_base_image AS python_boilerplate_image
COPY --from=build /src /src
COPY --from=build /build /build
