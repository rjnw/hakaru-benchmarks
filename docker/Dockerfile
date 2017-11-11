FROM ubuntu:17.10

ENV NAME Hakaru-Benchmark
RUN apt-get update; apt-get install -y openssh-client git libgsl-dev emacs-nox software-properties-common wget r-cran-rjags; \
    add-apt-repository "deb http://apt.llvm.org/artful/ llvm-toolchain-artful main"; \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add - ; \
    apt-get install -y llvm-5.0 ; \
    add-apt-repository ppa:plt/racket; apt-get update; apt-get install -y racket zsh ; \
    git clone git://github.com/rjnw/hakaru-benchmarks.git; \
    cd /hakaru-benchmarks; \
    git clone git://github.com/hakaru-dev/hakaru; \
    git clone git://github.com/rjnw/sham; \
    git clone git://github.com/rjnw/hakaru-rktjit hakrit ; \
    wget -qO- https://get.haskellstack.org/ | sh ; \
    stack setup
RUN cd /hakaru-benchmarks; make init; make hakaru
RUN cd /hakaru-benchmarks; make setup
COPY zshrc /root/.zshrc
COPY init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]