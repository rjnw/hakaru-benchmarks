# Output format for benchmarks
* A directory for each benchmark
* * Subdirectories rkt, hs, jags ...
* * A file with the name similar to name from input

|Benchmark|Filename format|
|---|---|
|ClinicalTrial|10,100,1000, ...|
|LinearRegression|10,100,1000, ...|
|GmmGibbs|[3,6,9, ...]-[10,100,1000, ...]|
|NaiveBayesGibbs| ? |
|LDA|?|

---

# File format
```
file    := ([:line:]<newline>)*
line    := ([:sweep:]<tab>)*
sweep   := [:time:]<space>[:nsweeps:]<space>[:state:]
state   := <leftbracket>([:number:]<space>)*<rightBracket>
nsweeps := [:number:]
time    := [:number:]
```
### Not posix compliant :wink:
* `<stuff>` is a literal, apply common sense
* `[:stuff:]` is either defined or number
* `()` is like regexp group wherever used, mostly for `*`