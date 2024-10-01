FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
    ccache build-essential python sudo libgcc-5-dev uuid-dev nasm iasl gcc-aarch64-linux-gnu wget && \
    wget "https://github.com/tianocore/edk2/releases/download/vUDK2018/edk2-vUDK2018.tar.gz" -O edk2.tar.gz && \
    tar zxf edk2.tar.gz && rm -rf edk2.tar.gz && \
    mv edk2-* /usr/local/edk2-vUDK2018 && \
    cd /usr/local/edk2-vUDK2018 && \
    source edksetup.sh && \
    sed -i 's/-Werror //g' BaseTools/Source/C/Makefiles/header.makefile && \
    cat BaseTools/Source/C/Makefiles/header.makefile && \
    sed -i 's/^ACTIVE_PLATFORM .*/ACTIVE_PLATFORM = MdePkg\/MdePkg.dsc/g' Conf/target.txt && \
    sed -i 's/^TARGET .*/TARGET = RELEASE/g' Conf/target.txt && \
    sed -i 's/^TARGET_ARCH .*/TARGET_ARCH = AARCH64/g' Conf/target.txt && \
    sed -i 's/^TOOL_CHAIN_TAG .*/TOOL_CHAIN_TAG = GCC5/g' Conf/target.txt && \
    sed -i 's/ENV(GCC5_AARCH64_PREFIX)/\/usr\/bin\/aarch64-linux-gnu-/g' Conf/tools_def.txt && \
    make -C BaseTools && \
    make -C BaseTools/Source/C && \
    build