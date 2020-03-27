library(xgboost)

dup_horiz


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
    
    
    m.cv<-xgboost(data=train.score,
                  label=as.numeric(true.class.cv)-1,
                  eta = 0.1,
                  max_depth = 15, 
                  nrounds=25, 
                  subsample = 0.5,
                  colsample_bytree = 0.5,
                  seed = 1,
                  #eval_metric = "merror",
                  objective = "multi:softmax",
                  num_class = 22,
                  nthread = 3)
    
    result<-predict(m.cv,test.score)
    
    t<-table(t=validation.calss,prediction=result+1)
    zhengque[i,j]=sum(diag(t))/sum(t)
  }
  
}

print(zhengque)

best<-which.max(colMeans(zhengque))#21


#run the model
best.train.score<-as.matrix(haha[,-ncol(haha)]) %*% a$scaling[,1:best]
start<-proc.time()
best.xgboost<-xgboost(data=best.train.score,
                      label=as.numeric(haha$emotion_idx)-1,
                      eta = 0.1,
                      max_depth = 15, 
                      nrounds=25, 
                      subsample = 0.5,
                      colsample_bytree = 0.5,
                      seed = 1,
                      #eval_metric = "merror",
                      objective = "multi:softmax",
                      num_class = 22,
                      nthread = 3)
end<-proc.time()
print(end-start)

#user  system elapsed 
#2.11    0.78    1.83 

start<-proc.time()
result<-predict(best.xgboost,newdata = as.matrix(hehe[,-ncol(haha)]) %*% a$scaling[,1:best])
end<-proc.time()
(end-start)
#user  system elapsed 
#0.08    0.00    0.06 

t<-table(t=hehe$emotion_idx,prediction=result+1)
sum(diag(t))/500 #0.402





