#!/usr/bin/env Rscript

suppressMessages(library('rjags'))
suppressMessages(library('coda'))
suppressMessages(library('assertthat'))
suppressMessages(library('reshape2'))
suppressMessages(library('MASS'))

ascending <- function (x) all(diff(x) >= 0)

scan.file <- function (f, suffix) {
    scan(paste(f, suffix, sep="."), quiet=TRUE) + 1
}

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  cat("naive_bayes_sweeps.R <docsPerTopic> <sweeps> <chains>\n")
} else {

docsPerTopic <- as.numeric(args[1])
sweeps       <- as.numeric(args[2])
chains       <- as.numeric(args[3])

topics <- scan.file("topics", docsPerTopic)
words  <- scan.file("words",  docsPerTopic)
docs   <- scan.file("docs",   docsPerTopic)

invisible(assert_that(ascending(topics)))
invisible(assert_that(ascending(docs)))

docsSize  <- length(topics)
topicSize <- length(unique(topics))
vocabSize <- length(unique(words))

# We take a subset of the smaller dataset to use as
# a test set
trainTestSplit <- fractions(9/10)
testDocsPerTopic <- ceiling(docsPerTopic * (1 - trainTestSplit))
topicIndices <- c(sapply(0:(topicSize-1),
                         function(i)
                           (docsPerTopic*i+1):(docsPerTopic*i+testDocsPerTopic)))

zTrues <- topics[topicIndices]
topics[topicIndices] <- NA

time0 <- proc.time()["elapsed"]

model <- jags.model('naive_bayes.jags',
                    data = list('Nwords'     = length(words),
                                'Ndocs'      = docsSize,
                                'Ntopics'    = topicSize,
                                'Nvocab'     = vocabSize,
                                'onesTopics' = rep(1,topicSize),
                                'onesVocab'  = rep(1,vocabSize),
                                'z'          = topics,
                                'w'          = words,
                                'doc'        = docs),
                    n.chains = chains,
                    n.adapt = 10,
                    quiet=TRUE)

time1 <- proc.time()["elapsed"]
write(c(time0, time1), file="")
time2 <- time1
time2goal = time2 + as.numeric(args[3])
time2subgoal = time2 + as.numeric(args[4])
itergoal = as.numeric(args[5])
iterstep = as.numeric(args[6])
iter <- 0
while (time2 < time2goal || iter < itergoal) {
    update(model, iterstep-1)
    samples <- jags.samples(model, variable.names=c("z"), n.iter=1)
    time2 <- proc.time()["elapsed"]
    iter <- model$iter()
    if (time2 >= time2subgoal || time2 >= time2goal && iter >= itergoal) {
        time2subgoal = time2 + as.numeric(args[4])
        write(c(time2, iter), file="", append=TRUE)
        write(samples$z, ncolumns=length(t), file="", append=TRUE)
    }


}
