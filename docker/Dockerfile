FROM ubuntu:17.10

ENV NAME Hakaru-Benchmark
RUN add-apt-repository "deb http://apt.llvm.org/artful/ llvm-toolchain-artful main"; \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add - ; \
    add-apt-repository ppa:plt/racket; apt-get update; \
    apt-get install -y openssh-client git libgsl-dev software-properties-common racket wget r-cran-rjags zsh llvm-5.0; \
    git clone https://github.com/rjnw/hakaru-benchmarks.git; \
    cd /hakaru-benchmarks; \
    git clone https://github.com/hakaru-dev/hakaru; \
    git clone https://github.com/rjnw/sham; \
    git clone https://github.com/rjnw/hakaru-rktjit hakrit ; \
    wget -qO- https://get.haskellstack.org/ | sh ; \
    stack setup
RUN cd /hakaru-benchmarks; raco pkg install disassemble; \
    wget http://mallet.cs.umass.edu/dist/mallet-2.0.8.tar.gz; \
    tar -xzvf mallet-2.0.8.tar.gz; apt-get install -y openjdk-8-jre-headless; \
    wget http://qwone.com/~jason/20Newsgroups/20news-19997.tar.gz -O 20news-19997.tar.gz; tar -xzvf 20news-19997.tar.gz;
RUN cd /hakaru-benchmarks; make hakaru; make setup
COPY zshrc /root/.zshrc
COPY init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]