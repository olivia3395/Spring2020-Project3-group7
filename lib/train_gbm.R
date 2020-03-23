###########################################################
### Train a classification model with training features ###
###########################################################
train <- function(feature_df = pairwise_data, par = NULL){
  ### Train an SVM model using processed features from training images
  
  ### Input:
  ### - a data frame containing features and labels
  ### - a parameter list
  ### Output: trained model
  
  ### load libraries
  library("gbm")
  library("MASS")
  
  gbm_model <- gbm(emotion_idx~., data = feature_df, 
                   distribution = "multinomial",
                   n.trees = 203,
                   shrinkage = 0.10, 
                   interaction.depth = 1,
                   n.minobsinnode = 18,
                   bag.fraction = 0.8,
                   cv.folds = 6
  )
  
  return(model = gbm_model)
}
