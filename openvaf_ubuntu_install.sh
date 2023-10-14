#!/bin/sh
# SPDX-FileCopyrightText: 2023 Harald Pretl, IIC@JKU
# SPDX-License-Identifier: Apache-2.0
#
# Script based on a template by Markus Mueller, Semimod
# Semimod's OpenVAF is compiled and installed

apt-get -y update && apt-get -y upgrade
apt-get install -y build-essential wget git python3 rustc cargo
apt-get install -y clang clang-tools lld
apt-get install -y libclang-common-14-dev libz-dev

export LLVM_CONFIG=/usr/bin/llvm-config-14
[ ! -f /usr/bin/clang-cl ] && ln -s /usr/bin/clang-cl-14 /usr/bin/clang-cl
[ ! -f /usr/bin/llvm-lib ] && ln -s /usr/bin/llvm-lib-14 /usr/bin/llvm-lib

cd /tmp || exit
git clone https://github.com/pascalkuthe/OpenVAF
cd OpenVAF || exit
if [ "$(arch)" = "aarch64" ]; then
    sed -i 's/i8/u8/g' openvaf/llvm/src/initialization.rs
fi
cargo build --release --bin openvaf

cp target/release/openvaf /usr/local/bin/openvaf
