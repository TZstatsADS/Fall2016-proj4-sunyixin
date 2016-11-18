library(rhdf5)
files.list = list.files("data", full.names = T, recursive = T)
n = length(files.list) #2350
features = NULL
for(i in 1:n) 
{
  sound = h5read(files.list[i], "/analysis")
  songs = sound$songs #songs attribute
  sound$songs = NULL
  sound$sections_confidence = NULL
  sound$sections_start = NULL
  #Basic statistics for other attributes, including mean, median and standard deviation
  basic_stats = lapply(sound, function(x) {
    m1 = mean(x)
    m2 = median(x)
    s = sd(x)
    c(m1,m2,s)
  })
  basic_stats_vec = unlist(basic_stats) 
  #use tempo and loudness of songs
  songs_tempo = songs$tempo
  songs_loudness = songs$loudness
  features = rbind(features,
                   c(basic_stats_vec)) 
  H5close()
}
#song names
song = substr(files.list, 12, nchar(files.list)-3)
rownames(features) = song

dim(features)
View(features) 
#save the features
save(features, file = "proj_features.Rdata")
load("proj_features.Rdata")


files.list = list.files("TestSongFile100", full.names = T, recursive = T)
n = length(files.list) #100 test songs
features2 = NULL
for(i in 1:n) 
{
  sound = h5read(files.list[i], "/analysis")
  songs = sound$songs #songs attribute
  sound$songs = NULL
  sound$sections_confidence = NULL
  sound$sections_start = NULL
  #Basic statistics for other attributes, including mean, median and standard deviation
  basic_stats = lapply(sound, function(x) {
    m1 = mean(x)
    m2 = median(x)
    s = sd(x)
    c(m1,m2,s)
  })
  basic_stats_vec = unlist(basic_stats) 
  #use tempo and loudness of songs
  songs_tempo = songs$tempo
  songs_loudness = songs$loudness
  features2 = rbind(features2,
                   c( basic_stats_vec)) 
  H5close()
}

load("lyr.RData")

features_all = rbind(features2, features)
features_all = scale(features_all)
distances = dist(features_all)

distances = as.matrix(distances)


knn = apply(distances[101:2400,1:100],2,function(x) order(x)[1:20])

rec = apply(knn,2, function(x) {
  apply(lyr[x,-1],2,sum)
})

song = substr(files.list[1:100], 12, nchar(files.list)-3)
colnames(rec) = song
words = row.names(rec)
best.word = words[apply(rec,2,which.max)]
best.word
#Most possible word has lower rank
sub <- read.csv("sample_submission.csv", header = T)
rank.word = apply(rec,2,function(x) nrow(rec)+ 1 - order(x))
sub[1:100,3:5002] = t(rank.word)
save(sub, file = "rank word.Rdata")









