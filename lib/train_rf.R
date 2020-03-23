train <- function(feature_df = pairwise_data, par = NULL){
  
  trControl <- trainControl(method = "cv",
                            number = 20,
                            search = 'grid')
  
  rf_default <- train(emotion_idx ~ .,
                      data = feature_df,
                      method = "rf",
                      metric = "Accuracy",
                      tuneLength = 15,
                      trControl = trControl)
  print(rf_default)
  
  plot(rf_default)
  
  grid_tuned <- expand.grid(.mtry = (1:15)) 
  
  rf_gridsearch <- train(emotion_idx ~ ., 
                         data = feature_df,
                         method = 'rf',
                         metric = 'Accuracy',
                         tuneGrid = grid_tuned)
  print(rf_gridsearch)
  
  best_mtry <- 2
  store_maxnode <- list()
  tuneGrid <- expand.grid(.mtry = best_mtry)
  for (maxnodes in c(1: 10)) {
    set.seed(2305)
    rf_maxnode <- train(emotion_idx ~ .,
                        data = feature_df,
                        method = "rf",
                        metric = "Accuracy",
                        tuneGrid = tuneGrid,
                        trControl = trControl,
                        importance = TRUE,
                        nodesize = 6,
                        maxnodes = maxnodes,
                        ntree = 300)
    current_iteration <- toString(maxnodes)
    store_maxnode[[current_iteration]] <- rf_maxnode
  }
  results_mtry <- resamples(store_maxnode)
  summary(results_mtry)
  
  store_maxtrees <- list()
  for (ntree in c(25, 50, 100, 150, 200, 300, 400, 500)) {
    set.seed(2305)
    rf_maxtrees <- train(emotion_idx ~ .,
                         data = feature_df,
                         method = "rf",
                         metric = "Accuracy",
                         tuneGrid = tuneGrid,
                         trControl = trControl,
                         importance = TRUE,
                         nodesize = 6,
                         maxnodes = 10,
                         ntree = ntree)
    key <- toString(ntree)
    store_maxtrees[[key]] <- rf_maxtrees
  }
  results_tree <- resamples(store_maxtrees)
  summary(results_tree)
  
  trControl <- trainControl(method = "cv",
                            number = 20,
                            search = 'grid')
  grid_tuned <- expand.grid(.mtry = 2) 
  store_maxtrees <- list()
  
  rf_maxtrees <- train(emotion_idx ~ .,
                       data = feature_df,
                       method = "rf",
                       metric = "Accuracy",
                       tuneGrid = grid_tuned,
                       trControl = trControl,
                       importance = TRUE,
                       nodesize = 6,
                       tuneLength = 12,
                       ntree = 300)
  
  print(rf_maxtrees)
  
  #Based on the accuracy table, the accuracy rate and Kappa reach the highest when ntree = 300, trueLength = 12, nodeside = 6 and mtry = 2 which around 42% accuracy.
  
  set.seed(2305)
  tm_train = NA
  trControl <- trainControl(method = "cv",
                            number = 20,
                            search = 'grid')
  grid_tuned <- expand.grid(.mtry = 2) 
  tm_train <- system.time(train_final_model_rf <- train(emotion_idx ~ .,
                                                        data = feature_df,
                                                        method = "rf",
                                                        metric = "Accuracy",
                                                        tuneGrid = grid_tuned,
                                                        trControl = trControl,
                                                        importance = TRUE,
                                                        nodesize = 6,
                                                        tuneLength = 12,
                                                        ntree = 300))
  save(train_final_model_rf, file="../train_final_model_rf.RData")
  print(tm_train)
  
  return(model = train_final_model_rf)
}
