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

jags <- jags.model('naive_bayes.jags',
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

##start.time <- Sys.time()

##update(jags, sweeps);

##samples <- jags.samples(jags, c('z'), 1);
##zPredicts <- samples$"z"[topicIndices]
## end.time <- Sys.time()
## duration <- difftime(end.time, start.time, units="sec")

samplesC <- coda.samples(jags,
                         c('z'),
                         sweeps);

mk_acc <- function(samples) {
    zPred <- samples[topicIndices]
    length(zTrues[zPred == zTrues])/length(zTrues)
}

d <- melt(sapply(1:sweeps,
          function(j) {
              sapply(1:chains,
                     function(i) {
                         mk_acc(as.vector(samplesC[j,][[i]]))
                     })
          }));

if (chains == 1 ) {
    d$Var1 <- 1
    d$Var2 <- 1:sweeps
    d <- d[c("Var1", "Var2", "value")]
}

colnames(d) <- c("Chains", "Sweeps", "Accuracy")
d$System <- "JAGS"
d <- d[c("System","Chains","Sweeps","Accuracy")]
write.csv(d, row.names=FALSE, quote=FALSE, file="nbsweeps2.csv")


## cat("JAGS",
##     as.numeric(docsSize),
##     format(sweeps),
##     format(trial),
##     format(accuracy),
##     sep=",",
##     fill=TRUE)

## print(zPredicts)
## print(zTrues)

}
