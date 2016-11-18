#Extract features-------------------------------------------------
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")
library(rhdf5)
files = list.files("/Users/mac/Downloads/Project4_data/data/", pattern = ".h5",
                   full.names = TRUE, recursive = TRUE)
features_df = NULL
songnames = c()
for(file in files) {
sound = h5read(file, "/analysis")

songname = gsub(".*/(.*).h5$","\\1",file)
songnames = c(songnames, songname)
#replace using mean and median values
features_df = rbind(features_df,
                    unlist(lapply(sound[c(-c(1:2,14))], function(x) {
                      c(mean(x), median(x))
                    }))
                    )

H5close()
}
features_df = data.frame(songnames, features_df)
features_df$songnames = NULL
rownames(features_df) = songnames
features_df[is.na(features_df)] <- 0
#Cluster using the features of songs---------------------
# Determine number of clusters
wss = (nrow(features_df)-1)*sum(apply(features_df,2,var))
kmin = 2
kmax = 100
for (i in kmin:kmax) {
  wss[i] <- sum(kmeans(features_df, centers = i)$withinss)
}
plot(1:100, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

# K-Means Cluster Analysis
#using 6 clusters
fit = kmeans(features_df, 15) 
#get cluster means 
cluster_means = aggregate(features_df,by=list(fit$cluster),FUN=mean)
#append cluster assignment
features_df = data.frame(features_df, cluster = fit$cluster)
save(cluster_means, file = "cluster_means.rdata")
save(features_df, file = "features_df.rdata")
#Loading bag of words------------------------------------------------
load("/Users/mac/Downloads/Project4_data/lyr.RData")
head(lyr[1:4,1:5])
lyr1 = lyr[,-c(2,3,6:30)]
#It looks there are some words not suitable
tmp_df = data.frame(track_id = rownames(features_df),cluster = features_df$cluster)
merge_df = merge(tmp_df,lyr,by.x = "track_id", by.y = "dat2$track_id")
words_probabilites_in_clusters = matrix(0, nrow = ncol(merge_df) - 2, ncol = 15)
for(i in 1:15) {
  sub = merge_df[merge_df$cluster == i,]
  sums = colSums(sub[,-c(1,2)])
  words_probabilites_in_clusters[ ,i] = sums/sum(sums)
}
rownames(words_probabilites_in_clusters) = colnames(merge_df)[-c(1:2)]
save(words_probabilites_in_clusters, file = "words_probabilites_in_clusters.rdata")

#Working out the algorithm--------------------------------------------
load("cluster_means.rdata")
load("features_df.rdata")
load("words_probabilites_in_clusters.rdata")
#require(rhdf5)
#the new songs are:
newsongs_files = list.files("/Users/mac/Downloads/Project4_data/TestSongFile100/", pattern = ".h5",
                   full.names = TRUE, recursive = TRUE)
newsongs_features = NULL
newsongs_songnames = c()
for(file in newsongs_files) {
  sound = h5read(file, "/analysis")
  songname = gsub(".*/(.*).h5$","\\1",file)
  newsongs_songnames = c(newsongs_songnames, songname)
  newsongs_features =  rbind(newsongs_features ,
                                          unlist(lapply(sound[c(-c(1:2,14))], function(x) {
                                            c(mean(x), median(x))
                                          }))
  )
  
  H5close()
}
newsongs_features = data.frame(newsongs_features)
newsongs_features[is.na(newsongs_features)] <- 0
rownames(newsongs_features) = newsongs_songnames

class_result = apply(newsongs_features, 1, function(x) {
  distances = apply(cluster_means[,-1], 1, function(y) {
    sum((x - y)^2)
  })
  which.min(distances)
})

res = words_probabilites_in_clusters[ ,class_result]
colnames(res) = newsongs_songnames
best_word = rownames(res)[apply(res,2,which.max)]

res1 = data.frame(res)
for( x in colnames(res1)){
  res1[[x]][order(-res1[[x]])] = 1:nrow(res1)
}
sub <- read.csv("sample_submission.csv", header = T)
sub = sub[1:100,]
sub[1:100,3:5002] = t(res1)
sub[order(sub$X)]
save(sub, file = "word for music.RData")


#association rules
library(arules)
library(arulesViz)
songs = lyr[,1]
lyr[,1] = NULL
rownames(lyr) = songs
lyr10 = apply(lyr,1,function(x) {
  x[x!=0] = 1
  x})
rules = apriori(t(lyr10),
                  parameter = list(support = 0.2, confidence = 0.4))

summary(rules)
rules = apriori(t(lyr10),
                parameter = list(support = 0.6, confidence = 0.6))

summary(rules)
#inspect for the top 10 rules with the highest confidence 
inspect(head(rules, n = 10, by = "confidence"))
#We can see that rules with high lift have typically a relatively low support.
plot(rules, measure=c("support", "lift"), shading="confidence")
plot(rules, method="matrix", measure=c("lift", "confidence"))
plot(rules, method="graph", control=list(type="itemsets"))
