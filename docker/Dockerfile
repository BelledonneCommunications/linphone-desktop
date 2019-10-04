FROM ubuntu:xenial

MAINTAINER Nicolas Michon <nicolas.michon@belledonne-communications.com>


# Configure locale
RUN apt-get update && \
    apt-get install -y locales && \
    apt-get clean && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ENV SHELL=/bin/bash

RUN id

RUN apt-get install software-properties-common

RUN add-apt-repository ppa:beineri/opt-qt-5.11.1-xenial

# Install common general tools
RUN apt-get update && \
    apt-get install -y nano sudo vim && \
    apt-get clean

# Install development tools
RUN apt-get update && \
    apt-get install -y alien at autoconf bison ccache clang cmake doxygen elfutils g++ gdb git graphviz intltool libtool lsb-release make nasm ninja-build openssh-client patch python-pip python-pystache python-six yasm && \
    apt-get clean && \
    pip install sphinx javasphinx sphinx_csharp

RUN apt-get install qt511-meta-full

# Install linphone & flexisip dependencies development packages
RUN apt-get install -y libasound2-dev libavcodec-dev libavutil-dev libbsd-dev libegl1-mesa-dev libglew-dev libgsm1-dev libjansson-dev libmariadb-dev-compat libmbedtls-dev libopus-dev libpq-dev libprotobuf-dev libpulse-dev libqt5svg5-dev libsnmp-dev libspeex-dev libspeexdsp-dev libsqlite3-dev libsrtp2-dev libssl-dev libswscale-dev libturbojpeg0-dev libv4l-dev libvpx-dev libxerces-c-dev libxml2-dev libxv-dev protobuf-compiler xsdcxx

# Configure user bc
RUN useradd -ms /bin/bash bc && \
    echo 'bc:cotcot' | chpasswd && \
    echo 'bc ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER bc
WORKDIR /home/bc

CMD bash

