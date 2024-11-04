#!/usr/bin/env sh

guix shell git just direnv -- \
    git clone https://github.com/kyurivlis/config; \
    cd config/rde; \
    mkdir -p ~/.config/guix; \
    echo /tmp/config/rde >> ~/.config/guix/shell-authorized-directories; \
    direnv allow; \
    guix shell
