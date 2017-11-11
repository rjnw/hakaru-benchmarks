#!/bin/zsh
echo "en_US.UTF-8 UTF-8" >> etc/locale.gen
locale-gen
cd /hakaru-benchmarks
git pull --rebase
git submodule update
make setup
/bin/zsh
