# Project-4: Words for Music

### [Project Description](doc/project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**coursework login required**)
+ [Data description](doc/readme.html)

+ Projec title: Words for Music
+ Project summary: Use feature of music find the best way to predict words of music. Find some interesting assoication between words and melody in music. I try to use K-mean cluster and KNN analysis to do this project. Also I find in train data the tempo and loudness of song is the very great feature in predict word. 

+ Contributor's name: Yixin Sun
+ Uni : ys2879

## Idea

### 1.1 Feature choie
I review the dataset for feature, think of which one has best effect to lyrics. Since I am intesting in the tempo and loudness, I think those two feature can exactly influence words of song. So the songs attribute is my first choice. I also choose other feature as basic statistics, including mean, meidan and standard deviation.

#### 1. KNN 

First of all, I try to use knn to build the connect to word and melody in each song. 
I took all of the features's descriptive statistics as the base of the similarity measure, and of cause I use loudness and tempo in songs as my feature too. Then I use 100 of 2350 as the new song and extracted features same as old song. I put them together to standardization. Then I calculate the Euclidean distance. Then I found a song for each of 20 recent songs and calculated the old word frequency.


#### 2. K-Means Cluster Analysis

Second I try to use k-means to find association between word and feature.

**Number of Cluster**
![image](https://github.com/TZstatsADS/Fall2016-proj4-sunyixin/blob/master/doc/Number%20of%20Clusters.png)

From the comparison of the 100 cluster, it seems no significant change when number of cluster larger than 15. 

1. Using 15 clusters and get them means, then append cluster assignment in feature dataset.
2. Loading Bag of Words, count word frequencies songs inside each cluster, sort words according to probability,rank each word according to the sort result.
3. Choose 1:250 of 2350 as the new song. Decide which cluster the new song belong to use minimum distance between feature and cluster mean. I assume new song in each cluster have same possible words.

#### 3. Association rules Within Lyric data

First, I transform the values in lyr data set which are not 0s into 1s, then our data set is a binary data frame. Set support to 0.2, confidence to 0.6, we have 1070351 rules,  so there are too many rules, we need to set higher values, at last, we use support 0.6, confidence to 0.6, this gives only 86 rules now. So we find that lots of rules are in the following format: E.g. if we both have ‘a’ and ‘and’ then we probability also have ‘the’ with support 0.6204255, confidence 0.9649239 and lift 1.194087. There are lots of words like ‘I’, ’a’, ’and’, ’the’, ‘to’, ‘is’, ‘it’, it seems we need to remove to find a better pattern.

**Inspect the top 30 rules **
![image](https://github.com/TZstatsADS/Fall2016-proj4-sunyixin/blob/master/doc/30%20rules.png)

As we can see in graph, rules with high lift have typically a relatively low support

## Result

Test for 100 songs. I remove feature of songs. Only consider the basic statistic in another feature. Obtain the rank of songs word.

	
Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.


