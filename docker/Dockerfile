FROM base/devel

ENV NAME Hakaru-Benchmark
RUN pacman -Syy --noconfirm; pacman-db-upgrade; pacman -S --noconfirm openssh zsh llvm gsl stack emacs-nox git racket-minimal
RUN raco pkg install --auto compiler-lib disassemble
RUN git clone git://github.com/rjnw/hakaru-benchmarks.git; \
    cd /hakaru-benchmarks; \
    git clone git://github.com/hakaru-dev/hakaru; \
    git clone git://github.com/rjnw/sham; \
    git clone git://github.com/rjnw/hakaru-rktjit hakrit
RUN cd /hakaru-benchmarks; make init; make hakaru
RUN cd /hakaru-benchmarks; make setup
COPY zshrc /root/.zshrc
COPY init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]