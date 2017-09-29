# linux dev environment for LEDE project 
FROM ubuntu:14.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install subversion g++ zlib1g-dev build-essential git python \
libncurses5-dev gawk gettext unzip file libssl-dev wget -y

RUN git clone https://github.com/lede-project/source.git lede
ADD dot_config /lede/.config

RUN adduser omega

RUN chown -R omega:omega lede
WORKDIR lede
USER omega

RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a

RUN make defconfig
RUN make -j8 V=s
