# Copyright (c) 2020-2021, Jan Cajthaml <jan.cajthaml@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ---------------------------------------------------------------------------- #

FROM amd64/debian:buster-slim

ENV container docker
ENV LANG C.UTF-8
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE no
ENV LDFLAGS "-Wl,-z,-now -Wl,-z,relro"
ENV RUST_VERSION 1.50.0
ENV LIBRARY_PATH /usr/lib
ENV LD_LIBRARY_PATH /usr/lib
ENV RUSTUP_HOME /usr/local/rustup
ENV CARGO_HOME /usr/local/cargo
ENV CC gcc
ENV CXX g++
ENV PATH="${CARGO_HOME}/bin:${PATH}"
ENV XDG_CONFIG_HOME /usr/share
ENV PKG_CONFIG_ALLOW_CROSS 1

RUN dpkg --add-architecture armhf
RUN dpkg --add-architecture amd64
RUN dpkg --add-architecture arm64

RUN \
    echo "installing debian packages" && \
    apt-get update && \
    apt-get -y install --no-install-recommends \
      ca-certificates \
      wget \
      git \
      grc \
      tar \
      pkg-config \
      binutils \
      gcc \
      gcc-arm-linux-gnueabi \
      gcc-arm-linux-gnueabihf \
      gcc-aarch64-linux-gnu \
      g++ \
      g++-arm-linux-gnueabi \
      g++-arm-linux-gnueabihf \
      g++-aarch64-linux-gnu \
      libc6 \
      libc6-armhf-cross \
      libc6-dev \
      libc6-dev-armhf-cross \
      libzmq5:amd64>=4.2.1~ \
      libzmq5:armhf>=4.2.1~ \
      libzmq5:arm64>=4.2.1~ \
      libzmq3-dev:amd64>=4.2.1~ \
      libzmq3-dev:armhf>=4.2.1~ \
      libzmq3-dev:arm64>=4.2.1~ && \
    \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    :

RUN \
    echo "installing rust ${RUST_VERSION}" && \
    \
    wget "https://static.rust-lang.org/rustup/archive/1.23.1/x86_64-unknown-linux-gnu/rustup-init"; \
    chmod +x rustup-init; \
    ./rustup-init -y \
      --no-modify-path \
      --profile minimal \
      --default-toolchain ${RUST_VERSION} \
      --default-host x86_64-unknown-linux-gnu \
    ; \
    rm rustup-init; \
    chmod -R a+w ${RUSTUP_HOME} ${CARGO_HOME}

RUN \
    rustup update && \
    rustup component add clippy

ENTRYPOINT [ "rustc" ]
