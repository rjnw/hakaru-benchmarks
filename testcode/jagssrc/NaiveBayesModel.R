#!/usr/bin/env Rscript

suppressMessages(library('rjags'))

args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 7) {
    # R --slave -f NaiveBayesModel.R --args "../../input/news/" 2 2 5 1 "./NaiveBayesModel.jags" 10
    cat("NaiveBayesModel.R <input.path> <min.seconds> <step.seconds> <min.sweeps> <step.sweeps> <model> <holdout.modulo>\n")
    quit(save="no",status=1)
}

inputPath = args[1]
minSeconds = as.numeric(args[2])
stepSeconds = as.numeric(args[3])
minSweeps = as.numeric(args[4])
stepSweeps = as.numeric(args[5])
modelFile = args[6]
holdoutModulo = as.numeric(args[7])

topics <- scan(file.path(inputPath, "news", "topics"), quiet=TRUE)+1
words  <- scan(file.path(inputPath, "news", "words"), quiet=TRUE)+1
docs   <- scan(file.path(inputPath, "news", "docs"), quiet=TRUE)+1

docsSize  <- length(topics)
topicSize <- length(unique(topics))
vocabSize <- length(unique(words))

## write(docsSize, file="")
## write(topicSize,file="")
## write(vocabSize, file="")
## write(length(docs), file="")
## write("docs", file="")

## write(docs, file="", append=TRUE)
## write("topics", file="")
## write(topics, file="", append=TRUE)
## write("words", file="")
## write(words, file="", append=TRUE)


holdoutFilter <- function (x) {if(x%%holdoutModulo==0) return(TRUE) else return(FALSE)}
topicIndices <- Filter(holdoutFilter, array(0:docsSize))
## write("topicindices: ", file="", append=TRUE)
## write(topicIndices, file="", append=TRUE)

topics[topicIndices] <- NA

write("running nb", file="", append=TRUE)
time0 <- proc.time()["elapsed"]

model <- jags.model(modelFile, #'NaiveBayesModel.jags',
                    data = list('Nwords'     = length(words),
                                'Ndocs'      = docsSize,
                                'Ntopics'    = topicSize,
                                'Nvocab'     = vocabSize,
                                'onesTopics' = rep(1,topicSize),
                                'onesVocab'  = rep(1,vocabSize),
                                'z'          = topics,
                                'w'          = words,
                                'doc'        = docs),
                    n.chains = 1,
                    n.adapt = 0,
                    quiet=TRUE)
time1 <- proc.time()["elapsed"]
write(c(time0, time1), file="")

time2 <- time1
time2goal = time2 + minSeconds
time2subgoal = time2 + stepSeconds
itergoal = minSweeps
iterstep = stepSweeps
iter <- 0

while (time2 < time2goal || iter < itergoal) {
    samples <- jags.samples(model, variable.names=c("z"), n.iter=1)
    time2 <- proc.time()["elapsed"]
    iter <- model$iter()
    write(c(time2, iter), file="", append=TRUE)
    write(samples$z, ncolumns=docsSize, file="", append=TRUE)
    time2subgoal = time2 + as.numeric(args[4])
}
