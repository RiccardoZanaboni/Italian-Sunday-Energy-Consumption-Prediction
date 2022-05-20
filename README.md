# Italian Sunday Energy Consumption Prediction

*Model Identification and Data Analysis course project at University of Pavia  
Developed in collaboration with: @FabioMoroni97, @frahferra and @DanielBelcore

## General Overview

*Goal: Identify a model for the time series value of Sunday as a function of day of the year and time of day*  

The provided dataset is composed of Italian energy consumption data for a two-year period.
Having to predict only the Sundays, we filter the data at available to us by taking taking into account only the Sundays.    
It tends to be the case that in the second year the values are lower, a factor not easy to notice in previous dates, considering all days of the week.

![img2_1](https://user-images.githubusercontent.com/48378307/169618061-aee77774-d234-470a-86aa-f993bb079f02.png)
![img2_2](https://user-images.githubusercontent.com/48378307/169618064-076a5edf-08bc-4873-8728-1d95573cd04e.png)

## Model Development
Since there were no particular demands in the delivery, as a first attempt we opted for a polynomial matryoshka type model.

![image](https://user-images.githubusercontent.com/48378307/169618270-e802ba57-bee9-4517-be2a-5551a1243982.png)

![image](https://user-images.githubusercontent.com/48378307/169618322-fbb07ad9-6342-48e7-8264-8dd68304124c.png)

The data exhibit very rapid variations that of simple polynomials struggle to follow.We should increasingly increase the degree maximum of the monomials employed, as can be noticed by observing the trend of the SSRs of validation.
![image](https://user-images.githubusercontent.com/48378307/169618360-a035c7ad-fec1-46bf-9287-7eba9d7e4af5.png)

Looking more deeply at the three-dimensional scatterplots of Sundays by year, it can be seen that they are periodic trends, for both variables, for both days of the year and hours of the day, with an increasing annual trend. Therefore, given these new considerations, we tried to identify the pattern by exploiting the Fourier series

## Fourier series model
Initially we used the same number of harmonics for both variables, writing everything in a single loop.
![image](https://user-images.githubusercontent.com/48378307/169618708-de6a0e8d-2d6a-47cd-b11a-9fd090f1659e.png)

#### Problems
As we note from the scatter plot, the model does not estimate the annual trend correctly, resulting in a graph that is shifted.
![image](https://user-images.githubusercontent.com/48378307/169618786-3452ae99-f99d-4aa1-b579-263698630ed4.png)
#### Solutions
The annual trend is estimated and subtracted from the source data, on which the Fourier model is calculated.
![image](https://user-images.githubusercontent.com/48378307/169619469-def9d5be-4903-4795-9f62-406ea66b89a9.png)

## Final Function and its graph

![image](https://user-images.githubusercontent.com/48378307/169619908-3a92a134-4637-4388-8c67-1cd21d5d0d20.png)
![image](https://user-images.githubusercontent.com/48378307/169619946-3c5bd935-3f00-4c68-8ab6-969906a2b6d2.png)

