FROM ollama/ollama:0.18.3-rc1-rocm
ARG HOME=/root
ADD --unpack=true https://nodejs.org/dist/v24.14.1/node-v24.14.1-linux-x64.tar.xz ${HOME}/bin
RUN mkdir -p ${HOME}/bin && mv ${HOME}/bin/node-v24.14.1-linux-x64 ${HOME}/bin/node
ENV PATH=${PATH}:${HOME}/bin/node/bin
RUN npm install -g cline