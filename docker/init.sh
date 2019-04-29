#!/bin/zsh
echo "en_US.UTF-8 UTF-8" >> etc/locale.gen
locale-gen

# mkdir -p /home/rajan/work/
# ln -s /hakaru-benchmarks /home/rajan/work/hakaru-benchmarks/

# export LOCAL_MAPLE="/home/rajan/work/hakaru-benchmarks/maple2017/bin/maple"
# cd /hakaru-benchmarks/hakaru/maple
# echo 'libname := "/home/rajan/work/hakaru-benchmarks/hakaru/maple",libname:' >> /root/.mapleinit
# ../../maple2017/bin/maple ./update-archive.mpl

cd /usr/bin
ln -s llvm-config-5.0 llvm-config

# cd /hakaru-benchmarks
# git pull --rebase
# cd ./sham
# git pull --rebase
# cd ../hakrit
# git pull --rebase
# cd ../hakaru
# git pull --rebase
# cd ../
cd /hakaru-benchmarks
# make setup
# raco setup hakrit sham

# if [ ! -d ./20_newsgroups ]; then
# fi

/bin/zsh
