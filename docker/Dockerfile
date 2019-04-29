FROM ubuntu:17.10

ENV NAME Hakaru-Benchmark

RUN apt-get update;
RUN apt-get install -y software-properties-common openssh-client git libgsl-dev zsh wget r-cran-rjags python-setuptools libgmp-dev clang sudo python-scipy;
RUN add-apt-repository "deb http://apt.llvm.org/artful/ llvm-toolchain-artful main"; \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add - ; \
    add-apt-repository ppa:plt/racket; apt-get update;
RUN apt-get install -y racket llvm-5.0;
RUN git clone https://github.com/rjnw/hakaru-benchmarks.git; \
    wget -qO- https://get.haskellstack.org/ | sh ;
RUN cd /hakaru-benchmarks; raco pkg install disassemble; \
    wget http://mallet.cs.umass.edu/dist/mallet-2.0.8.tar.gz; \
    tar -xzvf mallet-2.0.8.tar.gz; apt-get install -y openjdk-8-jre-headless; \
    wget http://qwone.com/~jason/20Newsgroups/20news-19997.tar.gz -O 20news-19997.tar.gz; tar -xzvf 20news-19997.tar.gz ;
COPY zshrc /root/.zshrc
COPY init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]