#delete the duplicated right face
library(purrr)
leftmid_idx <- c(1:9,19:26,35:44,50:52,56:59,62,63,64:71)
fiducial_pt_list_leftmid<- map(fiducial_pt_list, function(x) return(x[leftmid_idx,]))



dup_horiz<-new_index_20


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
a<-lda(haha[,-ncol(haha)],grouping=haha$emotion_idx)

score_lda<-as.matrix(haha[,-ncol(haha)]) %*% a$scaling #new 21 variables
test_score_lda<-as.matrix(hehe[,-ncol(hehe)]) %*% a$scaling


#####cross validation
library(caret)
cv.k<-createFolds(1:2000,K)
zhengque<-matrix(nrow = 5,ncol =21 )
for (i in 1:K) {
  index<-cv.k[[i]]
  dat_train_cv<-haha[-index,-ncol(haha)] #train data in this step
  true.class.cv<-haha$emotion_idx[-index]
  
  dat_validation<-haha[index,-ncol(haha)] #test data in this step
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

best<-which.max(colMeans(zhengque))#13


#run the model
best.train.score<-as.matrix(haha[,-ncol(haha)]) %*% a$scaling[,1:best]
start<-proc.time()
best.lda<-lda(best.train.score,grouping = haha$emotion_idx)
end<-proc.time()
print(end-start)
#user  system elapsed 
#0.01    0.00    0.05 

start<-proc.time()
result<-predict(best.lda,newdata = as.matrix(hehe[,-ncol(haha)]) %*% a$scaling[,1:best])$class
end<-proc.time()
(end-start)
#user  system elapsed 
#0.05    0.00    0.06 

t<-table(t=hehe$emotion_idx,prediction=result)
sum(hehe$emotion_idx==result)/500 #0.434



#ad.lda<-lda(score_lda,grouping = haha$emotion_idx)

#result<-predict(ad.lda,score_lda)$class
#tt<-table(t=haha$emotion_idx,prediction=result)
#sum(diag(tt))/sum(tt)




#result<-predict(ad.lda,test_score_lda)$class
#tt<-table(t=dat_test_leftmid$emotion_idx,prediction=result)
#sum(diag(tt))/sum(tt)


#--------------------------------------------------------------------------------------------------------

