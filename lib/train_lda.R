train <- function(feature_df = pairwise_data, par = NULL){
  ### Train a lda model using processed features from training images
  
  ### Input:
  ### - a data frame containing features and labels
  ### - a parameter list
  ### Output: trained model
  
  ### load libraries
  library("MASS")
  ### Train with SVM
  lda_model <- lda(emotion_idx ~ ., data=dat_train_pca) 
  
  return(model = lda_model )
}
