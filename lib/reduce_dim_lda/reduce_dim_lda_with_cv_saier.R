#delete the duplicated right face
library(purrr)
leftmid_idx <- c(1:9,19:26,35:44,50:52,56:59,62,63,64:71)
fiducial_pt_list_leftmid<- map(fiducial_pt_list, function(x) return(x[leftmid_idx,]))

#306 duplicates index
n.m <- 44
middle <- c(18:21,27,30,31,34,35,44)
d <- rep(1, 946)
m=matrix(rep(0, n.m^2),n.m,n.m,byrow=T)
k=1
for(i in 1:(n.m-1))for(j in (i+1):n.m){
  m[i,j] <- m[j,i] <- d[k]
  k=k+1
}
m[middle,] <- -1
m[,middle] <- -1
m[middle,middle] <- -2
ind <- c()
k=1
for(i in 1:(n.m-1)) for(j in (i+1):n.m){
  if(m[j,i] == -1) ind <- c(ind, k)
  k=k+1
}
dup_horiz <- ind[!(ind %in% cumsum(43:1)[-middle])]




dat_train_leftmid<-feature(fiducial_pt_list_leftmid,train_idx)
dat_train_leftmid<-dat_train_leftmid[,-dup_horiz]

dat_test_leftmid<-feature(fiducial_pt_list_leftmid,test_idx)
dat_test_leftmid<-dat_test_leftmid[,-dup_horiz]

library(dplyr)
#scale the data
#haha<-scale(dat_train_leftmid[,-1587],center = TRUE,scale = TRUE) %>%
#  as.data.frame() %>%
#  mutate(emotion_idx=dat_train_leftmid$emotion_idx) %>%
#  mutate(emotion_idx=factor(emotion_idx,levels = foo))
#hehe<-scale(dat_test_leftmid[,-1587],center = TRUE,scale = TRUE) %>%
#  as.data.frame() %>%
#  mutate(emotion_idx=dat_test_leftmid$emotion_idx) %>%
#  mutate(emotion_idx=factor(emotion_idx,levels = foo))

haha<-dat_train_leftmid
hehe<-dat_test_leftmid
library(MASS)
a<-lda(haha[,-1587],grouping=haha$emotion_idx)

score_lda<-as.matrix(haha[,-1587]) %*% a$scaling #new 21 variables
test_score_lda<-as.matrix(hehe[,-1587]) %*% a$scaling


#####cross validation
cv.k<-createFolds(1:2000,K)
zhengque<-matrix(nrow = 5,ncol =21 )
for (i in 1:K) {
  index<-cv.k[[i]]
  dat_train_cv<-haha[-index,-1587] #train data in this step
  true.class.cv<-haha$emotion_idx[-index]
  
  dat_validation<-haha[index,-1587] #test data in this step
  validation.calss<-haha$emotion_idx[index]
  
  model<-lda(dat_train_cv,grouping = true.class.cv)
  
  for (j in 1:21) {
    LD.matrix<-model$scaling[,1:j]
    train.score<-as.matrix(dat_train_cv) %*% LD.matrix

    
    test.score<-as.matrix(dat_validation) %*% LD.matrix

    
    m.cv<-lda(train.score,grouping = true.class.cv)
    
    result<-predict(m.cv,test.score)$class

    t<-table(t=validation.calss,prediction=result)
    zhengque[i,j]=sum(diag(t))/sum(t)
  }
  
}

print(zhengque)

best<-which.max(colMeans(zhengque))


#run the model
best.train.score<-as.matrix(haha[,-1587]) %*% a$scaling[,1:best]
best.lda<-lda(best.train.score,grouping = haha$emotion_idx)

result<-predict(best.lda,newdata = as.matrix(hehe[,-1587]) %*% a$scaling[,1:best])$class
t<-table(t=hehe$emotion_idx,prediction=result)
sum(hehe$emotion_idx==result)/500



#ad.lda<-lda(score_lda,grouping = haha$emotion_idx)

#result<-predict(ad.lda,score_lda)$class
#tt<-table(t=haha$emotion_idx,prediction=result)
#sum(diag(tt))/sum(tt)




#result<-predict(ad.lda,test_score_lda)$class
#tt<-table(t=dat_test_leftmid$emotion_idx,prediction=result)
#sum(diag(tt))/sum(tt)


#--------------------------------------------------------------------------------------------------------

