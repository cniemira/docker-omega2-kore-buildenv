FROM ubuntu:17.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install subversion  \
g++ zlib1g-dev build-essential git python libncurses5-dev gawk \
gettext unzip file libssl-dev wget -y

RUN git clone https://github.com/lede-project/source.git lede
ADD dot_config /lede/.config

RUN adduser omega
RUN chown -R omega:omega lede
USER omega

WORKDIR /lede
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a

RUN make defconfig
RUN make -j8 V=s

RUN git clone https://github.com/jorisvink/kore.git ./kore
ADD cross_compile.sh /lede/cross_compile.sh

RUN /lede/cross_compile.sh /lede/kore
CMD /lede/cross_compile /mnt
