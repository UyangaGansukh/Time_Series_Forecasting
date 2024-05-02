# Time_Series_Forecasting

This project aims to explore the relationship between Consumer Sentiment Index (CSI) and several economic indicators, and develop a forecasting model to forecast Consumer Sentiment Index for 12-month period from April 2024. It includes data retrieval, preprocessing, exploratory data analysis, model selection, forecasting and interpretation of results. Economic and financial datasets were retrieved from the Federal Reserve Economic Data (FRED) database.

## Programs and programming languages
- MATLAB R2022a or later, Econometrics Toolbox

## Data Retrieval
Data is imported from the FRED database using MATLAB's FRED API interface. The following economic indicators are retrieved:

- Consumer Sentiment Index (UMCSENT)
- Unemployment Rate (UNRATE)
- Consumer Price Index (CPI)
- AAA Corporate Bond Yield (AAA)
- BAA Corporate Bond Yield (BAA)
- 3-Month Yield on Treasuries (GS3M)
- 10-Year Yield on Treasuries (GS10)
- Real Disposable Personal Income (A229RX0)
- Personal Consumption Expenditures (PCEDG)

## Exploratory Data Analysis
The project includes extensive exploratory data analysis, including:
- Visualizations of each economic time-series
- Seasonality checks
- Unit root tests for stationarity
- Granger Causality tests to assess causality between consumer sentiment and other variables

## Model Selection
The project employs model selection techniques, including:
- AIC and BIC criteria for lag selection in Autoregressive (AR) models
- Stepwise selection to identify significant predictors in the model

## Results
The project's main findings include:
- Identification of significant predictors of consumer sentiment
- Forecasting Model for Consumer Sentiment Index
- Interpretation of results and implications for consumer expectation formation

## Files Included
- `README.md`: This file provides an overview of the project.
- `consumer_sentiment_analysis.m`: MATLAB script containing the entire project code.
- Plots visualizing the data and results of the analysis.

