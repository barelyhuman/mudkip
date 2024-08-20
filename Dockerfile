FROM ubuntu:latest

RUN apt -y update \
    ; apt install -y curl xz-utils git build-essential gcc-mingw-w64 \
    ; curl https://nim-lang.org/download/nim-2.0.8.tar.xz -o nim.tar.xz \
    ; tar xvf nim.tar.xz \
    ; cd nim-2.0.8 \
    ; ./build.sh \
    ; bin/nim c koch \
    ; ./koch boot -d:release \
    ; ./koch tools 

ENV PATH="$PATH:/nim-2.0.8/bin:/.nimble/bin"

WORKDIR /app

CMD ["/bin/bash"]
