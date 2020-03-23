library(purrr)
#choose the points on one side of each face and in the middle of each face
leftmid_idx <- c(1:9,19:26,35:44,50:52,56:59,62,63,64:71)
fiducial_pt_list_leftmid<- map(fiducial_pt_list, function(x) return(x[leftmid_idx,]))


#let's see the features of these chosen points on every face provided.
data<-feature(fiducial_pt_list_leftmid,c(train_idx,test_idx))

#emotion is a vector containing all the unique emotions on the faces provided
emotion<-unique(data$emotion_idx)



#1st: in the data dataset, calculate the mean of each feature in each emotion group, respectively;
#2nd: heihei is a data frame containing the mean of each feature in each emotion.
heihei<-c()
library(dplyr)
for (i in 1:length(emotion)) {
  datadata<-data %>%
    filter(emotion_idx==emotion[i]) %>%
    dplyr::select(-emotion_idx) %>%
    colMeans()
  h<-t(as.matrix(datadata))
  h<-cbind(h,emotion_idx=emotion[i])
  
  heihei<-rbind(heihei,h)
  heihei<-as.data.frame(heihei)
  
}


#heihei<-heihei %>%
#  pivot_longer(cols = -emotion_idx,
#               names_to = "feature",
#               values_to = "value")


#-------------------------------------------------------------------
#Then, according to heihei data frame, if one feature changes very little in different emotions, 
#we can say that this feature is not useful in distinguishing emotions. So, we can delete features 
#that have small variation between emotions.

feature.var<-map_dbl(heihei[,-ncol(heihei)],function(x) var(x))

#the following, I choose different variation level to delete features: <10%;<15%;<20%;<25% quantile 
q<-quantile(feature.var,0.1)
new_index_10<-which(feature.var<q) #delete these features



q<-quantile(feature.var,0.15)
new_index_15<-which(feature.var<q) #delete these features



q<-quantile(feature.var,0.2)
new_index_20<-which(feature.var<q) #delete these features


q<-quantile(feature.var,0.25)
new_index_25<-which(feature.var<q) #delete these features

