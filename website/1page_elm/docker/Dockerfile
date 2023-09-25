FROM ubuntu:latest
ENV IN_DOCKER=true

RUN apt-get update 
RUN apt-get upgrade -y
RUN apt-get install -y \
      adduser \
      curl \
      make \
      nodejs \
      npm \
      sudo \
      vim

EXPOSE 5016

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz && \
    gunzip elm.gz && \
    chmod +x elm && \
    mv elm /usr/local/bin/

# NOTE: you actually do need unsafe perm to install elm packages with npm
RUN npm install -g elm-test
RUN npm install -g elm-format
#RUN npm install -g elm-package
RUN npm install -g elm-review
RUN npm install -g http-server 


# install VS Code (code-server)
RUN curl -fsSL https://code-server.dev/install.sh | sh
# install VS Code extensions
RUN code-server --install-extension elmTooling.elm-ls-vscode
RUN code-server --install-extension ms-vscode.makefile-tools

# NOTE: we need to set HOME, because elm uses $HOME/.elm to save packages.
#       if this doesn't persist between runs, you get CORRUPT BINARY errors.
ENV HOME=/mnt
VOLUME /mnt
# NOTE: docker-compose mounts code in /mnt

# User in the container
RUN adduser elm --home /mnt/elm
RUN echo "elm ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
COPY elmdev.sh /elmdev.sh
CMD /elmdev.sh

USER elm
WORKDIR /mnt/elm
