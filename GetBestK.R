library(NbClust)
library(cluster)
library(HSAUR)
library(bmp)

# First , start by cleaning the workspace and setting the working directory.
rm(list=ls())
setwd("/Users/szaydin/Desktop/UofA2017-2018/Cmput414/project")


#2. Import the dataset clustering_data.csv into a data frame and plot the points.
dfmClust <- read.bmp("Orig1.bmp")

#Look at the data and the data frame structure 
head(dfmClust)
str(dfmClust)
#Store sigma and mio of data before standarize 
sigma <- (var(dfmClust))
mio   <- c( mean(dfmClust))

#Standarize (subtract from mean) and divide by standard deviation 
#Then result is now a matrix 
dataClust <- scale(dfmClust) 
tempOriginData <- dataClust
 

# determine the best number of clusters by two different ways.

#3. First Method 
#Manual calculation of the within sum square 
#Calculate initial within cluster sum of squares 
#Here we assume that all data are single cluster 
wss <- (nrow(tempOriginData)-1) * sum(apply(tempOriginData,2,var))
#cumulative  sum of variance of columns of tempOriginData
# both X and Y Variances = 1 

for (i in 1:20) 
{
  wss[i] <- sum(kmeans(tempOriginData, centers=i)$withinss)
}

plot(1:20, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")

 


##################
#Best cluster size is 15 
 
 

#Perform a k-means clustering on the data with the best number of clusters chosen
#in step 3. Choose an appropriate number of iterations.
set.seed(1234)   #To reproduce same results every run [the pesudo random generators seed] 


kmClustOpt <- kmeans(dfmClust,16, nstart = 20 , iter.max = 100)#nstart generate 20 initial random centroids and choose the best one for the algorithm.



#examine results 
kmClustOpt
kmClustOpt$cluster
kmClustOpt$centers
kmClustOpt$size
str(kmClustOpt)
kmClustOpt$iter

# Print the cluster centroids.
kmClustOpt$centers

#Restore original data 
dataClust <- vector(mode = "list", length = length(dataClust))

for (i in 1:length(dataClust)) 
{
  dataClust[i] <- kmClustOpt$center[ kmClustOpt$cluster[i] ] * sigma[1] + mio[1];
}

# Plot data such that each point is colored according to its cluster.
plot(tempOriginData, col=kmClustOpt$cluster)

#  Overlay the cluster centroids on the above plot. Plot them as solid filled triangles.
points(kmClustOpt$center,col=rep("blue",3),pch=10,cex=5)
 
