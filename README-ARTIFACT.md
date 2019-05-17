# hakaru-benchmarks artifact

We have successfully tested our virtual machine image using VirtualBox versions
5.2.30 and 6.0, but version 5.2.18 could not boot.  The username is "hakaru"
and the password is "ton618".

The quantitative evaluation in our paper is produced by a pipeline in which
a Hakaru program is

1. transformed into a Hakaru IR program by a Haskell program that invokes Maple
   to do symbolic math (the simplification and histogram transformations), then

2. compiled and run by a Racket program that uses the Sham library to invoke
   LLVM to generate machine code.

## Step 1: the simplification and histogram transformations

Step 1 requires Maple, so we enclose its output and it can be skipped.  Inside
the directory `/home/hakaru/hakaru-benchmarks/testcode/`, step 1 turns the
Hakaru source programs in the subdirectory `hksrc` into the outputs in the
subdirectories `hksimp`, `hkrkt`, `hssrc`.  The 3 output subdirectories are
equivalent but in different syntaxes:

* `hksimp/*.hk` is in the same readable Hakaru syntax as the input.
* `hkrkt/*.hkr` is in an S-expression syntax accepted by step 2.
* `hssrc/*.hs` is in Haskell, whose compilation using GHC forms our old backend.

Repeating step 1 requires the Haskell program: to build it, start a terminal,
cd to `/home/hakaru/hakaru-benchmarks/`, then run `make build-hakaru`.  It also
requires a Maple installation, which can be either local or remote.  Once you
have Maple installed somewhere, set up the Maple part of Hakaru by following
the instructions under the section "Extending Hakaru with Maple" in
`/home/hakaru/hakaru-benchmarks/hakaru/docs/intro/installation.md`.  Then,
point Hakaru at your Maple installation either by setting the environment
variable `LOCAL_MAPLE` or (to access a remote Maple installation by `ssh`) by
overriding some of the environment variables `MAPLE_SSH`, `MAPLE_USER`,
`MAPLE_SERVER`, and `MAPLE_COMMAND`.

Given a Hakaru and Maple installation, a good starting point for playing with
our array simplifier is to feed it the program described in Section 3.2 of our
paper under "But pointwise simplification is not enough".  Create a text file,
say called `loop.hk`, containing the following Hakaru expression:
```
fn n nat:
fn mu real:
simplify(
    x <~ plate i of n: normal(mu, 1)
    y <~ plate i of n: normal(x[i], 1)
    z <~ plate i of n: normal(x[i], 1)
    return (y,z)
)
```
Then run `/home/hakaru/hakaru-benchmarks/hkbin/hk-maple FILENAME` and expect
the following output:
```
fn n nat:
fn mu real:
weight
  (exp(nat2real(n) * mu ^ 2 * (-1/4))
   * exp(mu ^ 2 * (+1/4)) ** nat2real(n),
   y5 <~ plate i of n: normal(mu, sqrt(2/1))
   z3 <~ plate i of n:
         normal(mu * (+1/2) + y5[i] * (+1/2), sqrt(6/1) * (1/2))
   return (y5, z3))
```

## Step 2: code generation and comparison against other systems

To repeat Step 2, start a terminal, cd to `/home/hakaru/hakaru-benchmarks/`,
then run `make allbench`. This command takes a day to finish and will produce 6
PDF files of the benchmark plots shown in the paper.  These output plots are in
`/home/hakaru/hakaru-benchmarks/output/` and are:

* gmm-25-5000.pdf
* gmm-50-10000.pdf
* NaiveBayesGibbs-Accuracy.pdf
* NaiveBayesGibbs-Likelihood.pdf
* ldalikelihood-50.pdf
* ldalikelihood-100.pdf

Because these runs produce large log files, the `allbench` target removes the
log files after producing the plots.  To keep the log files, use another target
easily found in `/home/hakaru/hakaru-benchmarks/Makefile`.  For example, to run
the Naive Bayes topic model and keep the log files, execute `make nb` rather
than `make run-nb`.
