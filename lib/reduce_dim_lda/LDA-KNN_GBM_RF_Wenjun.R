## Load package
library(R.matlab)
library(readxl)
library(dplyr)
library(EBImage)
library(ggplot2)
library(caret)


### Step 0 set work directories
set.seed(0)
setwd("C:/Users/YWJ97/Desktop/ADS/Spring2020-Project3-group7/Spring2020-Project3-Group7/data/train_set/")

train_dir <- "C:/Users/YWJ97/Desktop/ADS/Spring2020-Project3-group7/Spring2020-Project3-Group7/data/train_set/" # This will be modified for different data sets.

train_image_dir <- paste(train_dir, "images/", sep="")

train_pt_dir <- paste(train_dir,  "points/", sep="")

train_label_path <- paste(train_dir, "label.csv", sep="") 


### Step 1: set up controls for evaluation experiments.

run.cv=TRUE # run cross-validation on the training set

K <- 5  # number of CV folds

run.feature.train=TRUE # process features for training set

run.test=TRUE # run evaluation on an independent test set

run.feature.test=TRUE # process features for test set


### Step 2: import data and train-test split 
#train-test split

info <- read.csv(train_label_path)

n <- nrow(info)

n_train <- round(n*(4/5), 0)

train_idx <- sample(info$Index, n_train, replace = F)

test_idx <- setdiff(info$Index,train_idx)

n_files <- length(list.files(train_image_dir))


#function to read fiducial points
#input: index
#output: matrix of fiducial points corresponding to the index
##--------------------------------------------------------------------------------------------------------##
leftmid_idx <- c(1:9,19:26,35:44,50:52,56:59,62,63,64:71)

length(leftmid_idx)

fiducial_pt_list_lm <- lapply(fiducial_pt_list, function(mat){return(mat[leftmid_idx,])})

#306 duplicate index

n.m <- 44

## index within leftmid_idx

middle <- c(18:21,27,30,31,34,35,44)

length(middle)

# 946=((44*44)-44)/2

d <- rep(1, 946)

m=matrix(rep(0, n.m^2),n.m,n.m,byrow=T)

k=1

for(i in 1:(n.m-1))for(j in (i+1):n.m){
  
  m[i,j] <- m[j,i] <- d[k]
  
  k=k+1
  
}
# mark distance related to 10 middle point
m[middle,] <- -1

m[,middle] <- -1

m[middle,middle] <- -2

ind <- c()

k=1

for(i in 1:(n.m-1)) {
  
  for(j in (i+1):n.m){
  
    if(m[j,i] == -1) ind <- c(ind, k)
  
    k=k+1
  
  }
}

## mark duplicate horizontal distance

dup_horiz <- ind[!(ind %in% cumsum(43:1)[-middle])]

### Step 3: construct features and responses

source("../lib/feature.R")

dat_train_leftmid<-feature(fiducial_pt_list_lm,train_idx)

dat_train_leftmid<-dat_train_leftmid[,-dup_horiz]

dat_test_leftmid<-feature(fiducial_pt_list_lm,test_idx)

dat_test_leftmid<-dat_test_leftmid[,-dup_horiz]

library(dplyr)

library(MASS)

a<-lda(dat_train_leftmid[,-1587],grouping=dat_train_leftmid$emotion_idx)

score_lda<-as.matrix(dat_train_leftmid[,-1587]) %*% a$scaling #new 21 variables

test_score_lda<-as.matrix(dat_test_leftmid[,-1587]) %*% a$scaling

## Now we get data with reduced feature. We can proceed to 

##--------------------------------------------------------------------------------------------------------##

key_point=c(1:9,19:25,35:44,64:71)
readMat.matrix <- function(index){
  return(round(readMat(paste0(train_pt_dir, sprintf("%04d", index), ".mat"))[[1]][key_point,],0))
}

#load fiducial points
fiducial_pt_list_reduced <- lapply(1:n_files, readMat.matrix)



### Step 3: construct features and responses
source("../lib/feature.R")
tm_feature_train <- NA
if(run.feature.train){
  tm_feature_train <- system.time(dat_train_reduced <- feature(fiducial_pt_list_reduced, train_idx))
}

tm_feature_test <- NA
if(run.feature.test){
  tm_feature_test <- system.time(dat_test_reduced <- feature(fiducial_pt_list_reduced, test_idx))
}



dat_train_reduced[,1123]
library(MASS)
f <- paste(names(dat_train_reduced)[1123], "~", paste(names(dat_train_reduced)[-1123], collapse=" + "))
lda_reduced = lda(as.formula(paste(f)), data = dat_train_reduced)
pred=predict(lda_reduced, dat_test_reduced)
sum(pred$class==dat_test_reduced[,1123])/500

### Step 4: Train a KNN model with training features and responses



# # 加载包和数据
# install.packages("gbm")
# install.packages("mlbench")
# library(gbm)
# library(mlbench)
# data(PimaIndiansDiabetes2,package='mlbench')
# # 将响应变量转为0-1格式
# data <- PimaIndiansDiabetes2
# data$diabetes <- as.numeric(data$diabetes)
# data <- transform(data,diabetes=diabetes-1)
# # 使用gbm函数建模
# model <- gbm(diabetes~.,data=data,shrinkage=0.01,
#              distribution='bernoulli',cv.folds=5,
#              n.trees=3000,verbose=F)
# # 用交叉检验确定最佳迭代次数
# best.iter <- gbm.perf(model,method='cv')
# best.iter
# summary(model,best.iter)
# plot.gbm(model,1,best.iter)
# # 用caret包观察预测精度
# library(caret)
# data <- PimaIndiansDiabetes2
# fitControl <- trainControl(method = "cv", number = 5,returnResamp = "all")
# model2 <- train(diabetes~., data=data,method='gbm',distribution='bernoulli',trControl = fitControl,verbose=F,tuneGrid = data.frame(.n.trees=best.iter,.shrinkage=0.01,.interaction.depth=1))
# model2
# ?train
