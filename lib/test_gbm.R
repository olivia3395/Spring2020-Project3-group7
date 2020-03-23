########################################
### Classification with testing data ###
########################################

test <- function(model, dat_test){
  
  ### Input: 
  ###  - the fitted classification model using training data
  ###  - processed features from testing images 
  ### Output: training model specification
  
  ### load libraries
  library("gbm")
  library("MASS")
  
  pred <- predict(model, n.trees = model$n.trees, dat_test)
  
  return(pred)
}