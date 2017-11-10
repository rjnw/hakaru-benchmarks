FROM base/devel

ENV NAME Hakaru-Benchmark
RUN pacman -Syy --noconfirm; pacman-db-upgrade; pacman -S --noconfirm openssh zsh llvm gsl stack emacs-nox git racket-minimal
COPY zshrc /root/.zshrc
COPY init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]