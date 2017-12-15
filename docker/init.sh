#!/bin/zsh
echo "en_US.UTF-8 UTF-8" >> etc/locale.gen
locale-gen

cd /usr/bin
ln -s llvm-config-5.0 llvm-config

cd /hakaru-benchmarks
git pull --rebase
cd ./sham
git pull --rebase
cd ../hakrit
git pull --rebase
cd ../hakaru
git pull --rebase
cd ../
make setup
raco setup hakrit sham

if [ ! -d ./20_newsgroups ]; then
fi

/bin/zsh
