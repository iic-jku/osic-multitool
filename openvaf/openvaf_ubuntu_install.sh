#!/bin/sh
# SPDX-FileCopyrightText: 2023 Harald Pretl, IIC@JKU
# SPDX-License-Identifier: Apache-2.0
#
# Script based on a template by Markus Mueller, Semimod
# Semimod's OpenVAF is compiled and installed

apt-get -y update && apt-get -y upgrade
apt-get install -y build-essential wget git python3 rustc cargo
apt-get install -y clang-15 clang-tools-15 lld-15
apt-get install -y libclang-common-15-dev libz-dev

export LLVM_CONFIG=/usr/bin/llvm-config-15
[ ! -f /usr/bin/clang ] && ln -s /usr/bin/clang-15 /usr/bin/clang
[ ! -f /usr/bin/clang-cl ] && ln -s /usr/bin/clang-cl-15 /usr/bin/clang-cl
[ ! -f /usr/bin/llvm-lib ] && ln -s /usr/bin/llvm-lib-15 /usr/bin/llvm-lib
[ ! -f /usr/bin/lld ] && ln -s /usr/bin/lld-15 /usr/bin/lld
[ ! -f /usr/bin/ld.lld ] && ln -s /usr/bin/ld.lld-15 /usr/bin/ld.lld

cd /tmp || exit
git clone https://github.com/pascalkuthe/OpenVAF
cd OpenVAF || exit
if [ "$(arch)" = "aarch64" ]; then
    sed -i 's/i8/u8/g' openvaf/llvm/src/initialization.rs
fi
cargo build --release --bin openvaf

cp target/release/openvaf /usr/local/bin/openvaf
