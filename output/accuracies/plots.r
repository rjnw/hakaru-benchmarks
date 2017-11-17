#install.packages("readr")
#install.packages("ggplot2")
#install.packages("tidyr")
#install.packages("dplyr")
#install.packages("tibble")
library(readr)
library(ggplot2)
library(tidyr)
library(dplyr)
library(tibble)

# This script expects each line of the data to be in the format (accuracy:tab:)*
# It also expects the first line of the data to describe time values
# in the format: (time:tab:)*
# This format will be satisfied by the output of the accuracy calculators.
# For example, runners/hk/GmmGibbs/Accuracy.hs satisfies this output format.

args <- commandArgs(trailingOnly=TRUE)
benchmark_path <- args[1]
fname <- args[2]

# testdata1 <- "0.5\t1.0\n0.36\t0.344\n0.39\t0.378\n0.35\t0.389"
hkdata <- paste(benchmark_path,"hk",fname,sep="/")
t1 <- read_tsv(hkdata,col_names=TRUE)
t1 <- rowid_to_column(t1)
t1 <- add_column(t1,backend="hs")

# testdata2 <- "0.5\t1.0\n0.32\t0.33\n0.35\t0.37\n0.35\t0.36"
jagsdata <- paste(benchmark_path,"jags",fname,sep="/")
t2 <- read_tsv(jagsdata,col_names=TRUE)
t2 <- rowid_to_column(t2)
t2 <- add_column(t2,backend="jags")

rktdata <- paste(benchmark_path,"rkt",fname,sep="/")
t3 <- read_tsv(rktdata,col_names=TRUE)
t3 <- rowid_to_column(t3)
t3 <- add_column(t3,backend="rkt")

t <- full_join(t1,t2)
t <- full_join(t,t3)
g <- gather(t,key=time,value=acc,-rowid,-backend,convert=TRUE)

# plot all trials
# alltrials <- ggplot(g, aes(x=acc,y=time,group=rowid)) +
#                geom_path(aes(color = rowid))
# print(alltrials)

# plot mean of all trials
h <- g %>%
     group_by(time,backend) %>%
     summarize(mean_accuracy = mean(acc))

meantrials <- ggplot(h, aes(x=time,y=mean_accuracy,group=backend)) +
               geom_path(aes(color=backend))
print(meantrials)

output <- args[3]
ggsave(file = output)