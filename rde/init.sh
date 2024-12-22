#!/bin/sh
herd stop guix-daemon
guix-daemon --substitute-urls='https://bordeaux.guix.gnu.org http://ci.guix.trop.in' --discover=yes &

guix shell git just direnv -- \
    git clone https://github.com/kyurivlis/config; \
    cd config/rde; \
    mkdir -p ~/.config/guix; \
    direnv allow; \
    guix shell -m manifest.scm
