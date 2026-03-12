#!/usr/bin/env bash
set -eu

sudo apt update
sudo apt install -y \
  git \
  curl \
  wget \
  ca-certificates \
  gnupg \
  lsb-release \
  bash-completion \
  nano \
  neovim \
  htop \
  btop \
  tree \
  unzip \
  zip \
  rsync \
  jq \
  ripgrep \
  net-tools \
  dnsutils \
  avahi-daemon \
  mosquitto-clients \
  iputils-ping \
  tcpdump \
  lsof

sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon

echo "Base tools installation complete."
