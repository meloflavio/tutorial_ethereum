FROM ubuntu:18.04

RUN apt-get update && apt-get install -y software-properties-common net-tools
RUN add-apt-repository -y ppa:ethereum/ethereum && apt-get update
RUN apt-get -y install ethereum

ADD ./genesis.json /root/genesis.json

EXPOSE 8545 30303 30303/udp
RUN mkdir -p /root/datadir

ENTRYPOINT "bash"

