#!/usr/bin/env Rscript

suppressMessages(library('rjags'))

args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 7) {
    # R --slave -f NaiveBayesModel.R --args "../../input/news/" 2 2 2 1 "./NaiveBayesModel.jags" 1000
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

topics <- scan(file.path(inputPath, "topics"))
words  <- scan(file.path(inputPath, "words"))
docs   <- scan(file.path(inputPath, "docs"))

docsSize  <- length(topics)
topicSize <- length(unique(topics))
vocabSize <- length(unique(words))

holdoutFilter <- function (x) {if(x%%holdoutModulo==0) return(TRUE) else return(FALSE)}
topicIndices <- Filter(holdoutFilter, array(0:docsSize))

topics[topicIndices] <- NA

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
                    n.adapt = 10,
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
