#!/bin/zsh
echo "en_US.UTF-8 UTF-8" >> etc/locale.gen
locale-gen
git pull --rebase git://github.com/rjnw/hakaru-benchmarks.git
cd /hakaru-benchmarks
git pull --rebase git://github.com/hakaru-dev/hakaru
git pull --rebase git://github.com/rjnw/sham
git pull --rebase git://github.com/rjnw/hakaru-rktjit hakrit
make setup
/bin/zsh
