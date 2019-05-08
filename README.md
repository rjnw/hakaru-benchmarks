# hakaru-benchmarks
benchmarking hakaru and other probabilistic programming systems

### Installation
#### If using docker `docker` folder contains the `Dockerfile` for setting up a docker instance.
#### otherwise
```sh
apt-get update
apt-get install -y software-properties-common openssh-client git libgsl-dev zsh wget r-cran-rjags python-setuptools libgmp-dev clang sudo python-scipy
add-apt-repository "deb http://apt.llvm.org/artful/ llvm-toolchain-artful main"
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add -
add-apt-repository ppa:plt/racket
apt-get update
apt-get install -y racket llvm-5.0
git clone https://github.com/rjnw/hakaru-benchmarks.git
wget -qO- https://get.haskellstack.org/ | sh
raco pkg install disassemble
```

### Setup
To build all the packages involved `make setup` at the root directory

Individual setup commands
* `make submodule-init` intializing and updating submodules
* `build-hakaru`
* `build-rkt`
* `build-augur` + `copy-augur-lib`
* `build-psi`
* `build-haskell`
* `build-stan`
* `build-input`

### Benchmarks
#### GmmGibbs
* with 25 classes and 5000 points `make gmm-25`
* with 50 classes and 10000 points `make gmm-50`

output pdfs `hakaru-benchmarks/output/gmm-25-5000.pdf` and `hakaru-benchmarks/output/gmm-50-10000.pdf`


#### Naive Bayes Gibbs
* to run benchmark `make nb`

two output pdfs `hakaru-benchmarks/output/NaiveBayesGibbs-Accuracy.pdf` and `hakaru-benchmarks/output/NaiveBayesGibbs-Likelihood.pdf`


#### LDA
* LDA 50 topics `make lda-50`
* LDA 100 topics `make lda-100`

output pdfs `hakaru-benchmarks/output/ldalikelihood-50.pdf` and `hakaru-benchmarks/output/ldalikelihood-100.pdf`