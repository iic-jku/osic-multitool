FROM quay.io/pypa/manylinux2014_aarch64:latest

# user for non-root commands
RUN useradd -ms /bin/bash human

# build LLVM-15
RUN git clone --depth=1 --branch release/15.x https://github.com/llvm/llvm-project.git
RUN cd llvm-project \
    && mkdir build && cd build \
    && cmake -G "Unix Makefiles" -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" -DCMAKE_INSTALL_PREFIX=~/tools/llvm -DCMAKE_BUILD_TYPE=Release ../llvm \
    && make -j $(nproc) \
    && make install

ENV LLVM_CONFIG=~/tools/llvm/bin/llvm-config

# install rust
RUN yum group install "Development Tools" -y && \
    yum clean all

ENV RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo
ENV PATH $CARGO_HOME/bin:$PATH

RUN mkdir -p "$CARGO_HOME" && mkdir -p "$RUSTUP_HOME" && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable && \
    chmod -R a=rwX $CARGO_HOME

# set path variables
ENV PATH="$PATH:/root/tools/llvm/bin"
ENV LLVM_CONFIG=/root/tools/llvm/bin/llvm-config

# install Python3.8 https://gist.github.com/wpupru/deda1cd96ea242d9a790e50cd0c97e9f
RUN yum install wget gcc openssl-devel bzip2-devel libffi-devel -y
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz && \
    tar xzf Python-3.8.0.tgz && \
    cd Python-3.8.0 && \
    ./configure --enable-optimizations && \
    make altinstall

RUN ln -s /usr/local/bin/python3.8 /usr/bin/python3 && \
    ln -s /usr/local/bin/pip3.8 /usr/bin/pip3

# download OpenVAF repository
RUN mkdir /io && \
    cd /io && \
    git clone https://github.com/iic-jku/OpenVAF


# sed -i 's/i8/libc::c_char/g' openvaf/llvm/src/initialization.rs && \
# sed -i 's/llround/lround/g' openvaf/mir_llvm/src/intrinsics.rs && \
# sed -i 's/llround/lround/g' openvaf/mir_llvm/src/builder.rs && \

# OpenVAF build
RUN cd /io/OpenVAF && \
    cargo build --release

# Python packages for compiling vae
#RUN pip3 install wheel

# VerilogAE build
#RUN cd /io/OpenVAF && \
#    cargo xtask verilogae build --manylinux
