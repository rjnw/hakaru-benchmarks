#!/bin/zsh
git clone git://github.com/rjnw/hakaru-benchmarks.git
cd /hakaru-benchmarks
git clone git://github.com/hakaru-dev/hakaru
git clone git://github.com/rjnw/sham
git clone git://github.com/rjnw/hakaru-rktjit hakrit
make setup
/bin/zsh
