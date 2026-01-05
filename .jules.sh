#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Install git and curl
sudo apt update -y && sudo apt install -y curl git

# Install mise
sudo install -dm 755 /etc/apt/keyrings
curl -fSs https://mise.jdx.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.pub 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.pub arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update -y
sudo apt install -y mise

# Install Ruby build dependencies
sudo apt install -y build-essential libssl-dev zlib1g-dev \
libreadline-dev libyaml-dev libgmp-dev libncurses5-dev \
libffi-dev libgdbm-dev rustc
