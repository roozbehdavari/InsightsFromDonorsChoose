# Insights From DonorsChoose

DonorsChoose.org is an online charity that makes it easy for anyone to help students in need. Public school teachers from every corner of America post classroom project requests on DonorsChoose.org, and anyone can give any amount to the project that most inspires them.

The goal of this project is gaining actionable insights by analyzing the funded and not funded projects in the last 10 years. It is specifically geared toward public schools in Los Angeles.

The xxx-preProcessing ipython notebooks explains the data cleaning, exploratory analysis, preprocessing, and feature engineering for different parts of a classroom project request: 

- Projects
- Essays
- Donations

Modeling is done in two steps:

1. Finding the important actionable features using random forest and gradient boosting classifier (Finding-Importanct-Variables.ipynb)
2. Quantifying the effect of different features using logistic regression (Quantifying-Actionable-Features-Effect.ipynb)

You can find the presentation at:
Presentation: http://www.slideshare.net/RoozbehDavari/insights-from-donorschoose
