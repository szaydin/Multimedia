


library(rattle)
library(NbClust)
library(cluster)
library(HSAUR)
library(png)


#1. First of all, start by cleaning the workspace and setting the working directory. 
rm(list=ls())
setwd("/Users/szaydin/Desktop/UofA2017-2018/Cmput414/project")


	
#2. Import the dataset clustering_data.csv into a data frame and plot the points.
	imageData <- readPNG("input.png")
	# 3D Matrix 128*128*3
	r <- matrix( imageData[,,1],nrow=128*128,ncol=1)
	g <- matrix( imageData[,,2],nrow=128*128,ncol=1)
	b <- matrix( imageData[,,3],nrow=128*128,ncol=1)
	imgMat<-cbind(r,g,b)
	
	colnames(imgMat) <- c("R","G","B")
	dfmClust <- data.frame(imgMat)
	
	
	#Look at the data and the data frame structure 
	head(dfmClust)
	str(dfmClust)
	sigma = diag(var(dfmClust))
	mio   = c( mean(dfmClust[,1]),mean(dfmClust[,2]),mean(dfmClust[,3]))
	
	matClust = scale(dfmClust) 
	tempOriginData <- matClust
	#Standarize (subtract from mean) and divide by standard deviation 
	#Then result is now a matrix 
	
	
	# plot(Y ~ X,
		# data = matClust)
	# points(Y ~ X, col="red",
		# data = matClust)
#3. Perform a k-means clustering on the data with 10 clusters and 15 iterations.
set.seed(1234)   #To reproduce same results every run [the pesudo random generators seed] 
kmClust <- kmeans(matClust,16, iter.max = 15)#nstart generate 20 initial random centroids and choose the best one for the algorithm.


#examine results 
kmClust
kmClust$cluster
kmClust$centers
kmClust$size
str(kmClust)
kmClust$iter

#4. Print the cluster centroids.
	kmClust$centers

#5. Plot data such that each point is colored according to its cluster.
plot(tempOriginData, col=kmClust$cluster)

#6. 6. Display the 16 centroids of the clusters. What do these centroids represent?

points(kmClust$center,col=rep("blue",10),pch=10,cex=5)



 #7. Assign each pixel to the centroid of its cluster.

									
  for (i in 1:16384) 
  {
     imgMat[i,1] <- kmClust$center[ kmClust$cluster[i],"R"] * sigma[1] + mio[1];
     imgMat[i,2] <- kmClust$center[ kmClust$cluster[i],"G"] * sigma[2] + mio[2];
     imgMat[i,3] <- kmClust$center[ kmClust$cluster[i],"B"] * sigma[3] + mio[3];
	 

  }
  
  #8. Reshape the data frame again to a 3-dimensional form.

   savedImg <- array(imgMat , dim = c(128,128,3))
	
	#9. Write the compressed image in a file named compressed.png. Now check its size.
   
	writePNG(savedImg , 'compressed.png')
	
