#####cross validation
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
library(kernlab)
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
    
    
    m.cv<-ksvm(train.score,true.class.cv,scale = c(),type = "C-svc",kernel = 'vanilladot',C=100)
    
    result<-predict(m.cv,test.score,type="response")
    
    t<-table(t=validation.calss,prediction=result)
    zhengque[i,j]=sum(diag(t))/sum(t)
  }
  
}

print(zhengque)

best<-which.max(colMeans(zhengque))#10


#run the model
start<-proc.time()
best.train.score<-as.matrix(haha[,-ncol(haha)]) %*% a$scaling[,1:best]
best.ksvm<-ksvm(best.train.score,haha$emotion_idx,scaled=c(),C=100,type="C-svc",kernal="vanilladot")
end<-proc.time()
(end-start)
# user  system elapsed 
# 1.47    0.03    1.55 

start<-proc.time()
result<-predict(best.ksvm,newdata = as.matrix(hehe[,-ncol(hehe)]) %*% a$scaling[,1:best],type="response")
end<-proc.time()
(end-start)
#user  system elapsed 
#0.30    0.07    0.41 
t<-table(t=hehe$emotion_idx,prediction=result)
sum(hehe$emotion_idx==result)/500 #0.386(ok) 0.358 0.378 0.378 ||| 0.324







cv.k<-createFolds(1:2000,K)
zhengque<-matrix(nrow = 5,ncol =21 )
for (i in 1:K) {
  index<-cv.k[[i]]
  dat_train_cv<-dat_train_leftmid[-index,-ncol(haha)] #train data in this step
  true.class.cv<-dat_train_leftmid$emotion_idx[-index]
  
  dat_validation<-dat_train_leftmid[index,-ncol(haha)] #test data in this step
  validation.calss<-dat_train_leftmid$emotion_idx[index]
  
  model<-lda(dat_train_cv,grouping = true.class.cv)
  
  for (j in 1:21) {
    LD.matrix<-model$scaling[,1:j]
    train.score<-as.matrix(dat_train_cv) %*% LD.matrix
    train<-cbind(train.score,emotion_idx=haha$emotion_idx) %>%
      as.data.frame()
    
    
    test.score<-as.matrix(dat_validation) %*% LD.matrix
    test<-cbind(test.score,emotion_idx=hehe$emotion_idx) %>%
      as.data.frame()
    
    
    m.cv<-svm(emotion_idx~.,data = train,kernel = "radial",gamma=0.1,cost=1)
    
    result<-predict(m.cv,test.score)
    
    t<-table(t=validation.calss,prediction=result)
    zhengque[i,j]=sum(diag(t))/sum(t)
  }
  
}
print(zhengque)

best<-which.max(colMeans(zhengque))#=13


#run the model
best.train.score<-as.matrix(haha[,-ncol(haha)]) %*% a$scaling[,1:best]
start<-proc.time()
best.svm<-svm(emotion_idx~.,data = cbind(best.train.score,emotion_idx=haha$emotion_idx),kernel = "radial",gamma=0.1,cost=1)
end<-proc.time()
(end-start)

#user  system elapsed 
#0.90    0.00    0.92 

start<-proc.time()
result<-predict(best.svm,newdata =as.matrix(hehe[,-ncol(hehe)]) %*% a$scaling[,1:best])
end<-proc.time()
(end-start)
#user  system elapsed 
#0.11    0.00    0.13 


t<-table(t=dat_test$emotion_idx,prediction=result)
sum(diag(t))/sum(t) #0.02
