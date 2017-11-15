#install.packages("readr")
#install.packages("ggplot2")
#install.packages("tidyr")
#install.packages("dplyr")
library(readr)
library(ggplot2)
library(tidyr)
library(dplyr)

# This script expects each line of the data to be in the format (accuracy:tab:)*
# It also expects the first line of the data to describe time values
# in the format: (time:tab:)*
# This format will be satisfied by the output of the accuracy calculators.
# For example, runners/hk/GmmGibbs/Accuracy.hs satisfies this output format.

testdata <- "0.5\t1.0\n0.36\t0.344\n0.39\t0.378\n0.35\t0.389"

t <- read_tsv(testdata,col_names=TRUE)
t <- rowid_to_column(t)

g <- gather(t,key=time,value=acc,-rowid,convert=TRUE)

# plot all trials
# alltrials <- ggplot(g, aes(x=acc,y=time,group=rowid)) +
#                geom_path(aes(color = rowid))
# print(alltrials)

# plot mean of all trials
h <- g %>%
       group_by(time) %>%
       summarize(mean_acc = mean(acc))

meantrial <- ggplot(h, aes(x=mean_acc,y=time)) +
               geom_path()
print(meantrial)