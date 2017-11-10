FROM base/devel

ENV NAME Hakaru-Benchmark

RUN pacman -Syyu --noconfirm
RUN pacman-db-upgrade
RUN pacman -S --noconfirm zsh llvm gsl stack

ENV SHELL /bin/zsh
