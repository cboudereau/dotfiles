# docker build -t sysbench:ubuntu-22.04 .

FROM ubuntu:22.04

RUN apt update -y && apt install -y sysbench

ENTRYPOINT ["sysbench"]

CMD ["--help"]