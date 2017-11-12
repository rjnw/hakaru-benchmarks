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


---

# File format
```
file    := ([:line:]<newline>)*
line   := (<leftParen>[:time:]<space>[:sweeps:]<space>[:state:]<rightParen>)*
state  := <leftbracket>([:number:]<space>)*<rightBracket>
sweeps := [:number:]
time   := [:number:]
```
### Not posix compliant :wink:
* `<stuff>` is a literal, apply common sense
* `[:stuff:]` is either defined or number
* `()` is like regexp group wherever used, mostly for `*`