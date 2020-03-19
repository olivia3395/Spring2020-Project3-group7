data<-feature(fiducial_pt_list_leftmid,c(train_idx,test_idx))

emotion<-unique(data$emotion_idx)
heihei<-c()

for (i in 1:length(emotion)) {
  h<-t(as.matrix(data %>%
    filter(emotion_idx==emotion[i]) %>%
    select(-emotion_idx) %>%
    colMeans()))
  h<-cbind(h,emotion_idx=emotion[i])
  
  heihei<-rbind(heihei,h)
  heihei<-as.data.frame(heihei)
  
}


#heihei<-heihei %>%
#  pivot_longer(cols = -emotion_idx,
#               names_to = "feature",
#               values_to = "value")
library(purrr)
feature.var<-map_dbl(heihei[,-ncol(heihei)],function(x) var(x))
q<-quantile(feature.var,0.1)
new_index_10<-which(feature.var<q) #delete these features



q<-quantile(feature.var,0.15)
new_index_15<-which(feature.var<q) #delete these features



q<-quantile(feature.var,0.2)
new_index_20<-which(feature.var<q) #delete these features


q<-quantile(feature.var,0.25)
new_index_25<-which(feature.var<q) #delete these features

