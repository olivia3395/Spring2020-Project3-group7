# Project: Can you recognize the emotion from an image of a face? 
<img src="figs/CE.jpg" alt="Compound Emotions" width="500"/>
(Image source: https://www.pnas.org/content/111/15/E1454)

### [Full Project Description](doc/project3_desc.md)

Term: Spring 2020

+ Team Group 7
+ Team members
	+ Saier Gong
	+ Kaiqi Wang
	+ Yuyao Wang
	+ Wenjun Yang
	+ Ziyang Zhang

+ Project summary: In this project, we created a classification engine for facial emotion recognition. The process has two main steps. The first step is to reduce the dimension of features and the next step is to use these reduced "new features" to train a classifier. We tried many different methods to finish this project, including (K)PCA+(K)SVM/xgboost/GBM..., LDA+SVM/xgboost/GBM/KNN, etc. By comparing training time, test time and accuracy, finally we choose the PCA+LDA method as the optimal classifier. 
	
**Contribution statement**: ([default](doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
