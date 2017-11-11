suppressMessages(library(rjags))

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 6) {
    cat("R --slave -f gmmModel.R --args <classes> <input.file> <min.seconds> <step.seconds> <min.sweeps> <step.sweeps>\n")
    # Command-line arguments:
    #   <classes> is how many clusters to classify points into
    #   <input.file> points to a file containing whitespace-delimited
    #       data points (reals)
    #   <min.seconds> is the minimum number of seconds to run
    #   <step.seconds> is the minimum number of seconds to run before each report
    #   <min.sweeps> is the minimum number of sweeps to perform
    #   <step.sweeps> is the number of sweeps to perform before possibly reporting
    # Standard output:
    #   First line is "time0 time1" where
    #     time0 is the elapsed real time before jags reads the model
    #     time1 is the elapsed real time after jags reads the model
    #   After the first line, pairs of lines where
    #     the first line is "time2 sweeps" where
    #       time2 is the elapsed real time after making that many sweeps
    #     the second line is whitespace-delimited 1-based classifications
    quit(save="no", status=1)
}
as <- array(1,as.numeric(args[1]))
t <- as.vector(read.table(args[2], header=FALSE), mode="numeric")
time0 <- proc.time()["elapsed"]
model <- jags.model("gmmModel.jags",
    data = list("as" = as, "t" = t),
    n.chains = 1,
    n.adapt = 0,
    quiet = TRUE)
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
