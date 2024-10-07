

# Project: Facial Emotion Recognition Using Machine Learning Techniques

### Objective
This project aims to create a robust classification engine that can accurately recognize and categorize facial emotions. By leveraging advanced machine learning techniques and feature engineering, this project addresses the complexity and high dimensionality typical of facial image data, striving to produce a solution suitable for real-time or large-scale applications.

### Methodology
The project workflow comprises two primary phases:

1. **Feature Dimensionality Reduction**  
   The high dimensionality of facial image data presents challenges in both computational efficiency and accuracy. To address this, we applied a dual-layer approach to dimensionality reduction:
   - **Principal Component Analysis (PCA)**: PCA was used as an initial dimensionality reduction step to capture the most significant variance within the data. By transforming the features into a lower-dimensional space, PCA aids in filtering noise and improving computational efficiency. We retained a sufficient number of components to capture 95% of the data variance, balancing detail retention with dimensionality reduction.
   - **Linear Discriminant Analysis (LDA)**: Following PCA, LDA was applied to enhance class separability. LDA identifies the linear combinations of features that best separate different classes, a crucial step for emotion recognition where subtle differences must be captured. This two-stage approach (PCA+LDA) ensures both efficient data handling and effective discrimination between emotion classes, making it ideal for high-dimensional, multi-class classification tasks.

2. **Classification Models**  
   After dimensionality reduction, we trained and evaluated several classification algorithms to identify the best-performing model:
   - **Support Vector Machines (SVM)**: Known for handling high-dimensional data well, SVM was tested on the reduced feature sets (PCA+SVM and LDA+SVM). Using a radial basis function (RBF) kernel, we optimized hyperparameters (C and gamma) through grid search and cross-validation to balance the margin maximization and accuracy.
   - **K-Nearest Neighbors (KNN)**: While simple, KNN served as a baseline for performance comparison. The model was tested across various values of K and distance metrics (Euclidean, Manhattan) to evaluate the effect of nearest neighbor count on accuracy and computational time.
   - **Gradient Boosting Machine (GBM) and XGBoost**: These ensemble models leverage sequential learning, which can yield high accuracy on complex datasets. We applied GBM and XGBoost to assess their effectiveness in detecting fine-grained emotion differences. Hyperparameters such as learning rate, max depth, and number of estimators were tuned via cross-validation to optimize model performance. These models, however, required more computational resources and thus were compared primarily on accuracy.

### Technical Implementation
- **Data Preprocessing**: We standardized the dataset to zero mean and unit variance, essential for models sensitive to feature scales like SVM and PCA.
- **Cross-Validation**: We used k-fold cross-validation (with k=5) to evaluate the robustness of each model combination. This approach ensured that our performance metrics were not biased by any specific data split.
- **Performance Metrics**: Each model was assessed using multiple metrics:
  - **Accuracy**: The primary metric for model evaluation.
  - **Precision, Recall, and F1-Score**: Used for evaluating model performance across different classes, particularly important in multi-class classification.
  - **Training and Inference Time**: These metrics provided insights into each model's efficiency and potential applicability for real-time use cases.
  - **Confusion Matrix and ROC Curves**: These visual tools allowed us to examine class-wise performance and understand potential misclassification patterns.

### Findings and Optimal Model
Through rigorous experimentation and comparison, we concluded that the **PCA+LDA+SVM** model provided the best performance in terms of accuracy and computational efficiency. The PCA+LDA pipeline allowed the model to maintain high accuracy (88%) with a significant reduction in feature space, while SVM with an RBF kernel effectively captured the non-linear relationships inherent in emotion recognition.

### Implementation Details and Tools
- **Python Libraries**: Key libraries used included:
  - `scikit-learn` for implementing PCA, LDA, SVM, KNN, GBM, and XGBoost, as well as for model evaluation metrics.
  - `Pandas` and `NumPy` for efficient data handling and manipulation.
  - `Matplotlib` and `Seaborn` for data visualization, including confusion matrices and ROC curves.
- **Optimization and Hyperparameter Tuning**: We applied grid search with cross-validation to fine-tune hyperparameters for each model, focusing on maximizing accuracy and minimizing overfitting.
- **Model Serialization**: We used `joblib` to serialize the optimal PCA+LDA+SVM model, enabling quick deployment and further analysis on unseen data.

