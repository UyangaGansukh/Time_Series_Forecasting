clear all;
close all;
clc;

%% import from FRED
url = 'https://fred.stlouisfed.org/';
c = fred(url);


UMCSENT = 'UMCSENT'; % January 1978 - current
UMCSENT = fetch(c,UMCSENT);

% get dataset
UMCSENT = UMCSENT.Data; 

%get date
date = UMCSENT(:,1); 
date = datetime(date,'ConvertFrom','datenum'); % 
% manually add the March date from http://www.sca.isr.umich.edu/tables.html
date = [date; datetime(2024,03,01)]; % #857 observations, but earliers dates are irregular
% get consumer sentiment index
UMCSENT = UMCSENT(:,2);
% manually add the March data from http://www.sca.isr.umich.edu/tables.html

% VARIABLE 1: CONSUMENT SENTIMENT
UMCSENT =[UMCSENT;79.4];


%% specify a regular start date
tau0 = datetime(1978,01,01);

UMCSENT = UMCSENT(date>=tau0);

% tau1 = date(end); % =01-Feb-2024, no need as we have updated March data
%date = date(date>=tau0); % #435 observations



%% include potential explanatory variables from Fred
% unemployment rate, inflation, junk bonds spread, T-bill (over 3 month) interest spread, 
% real disposable personal income, per capita(Ln diff --> growth rate),
% personal consumption expenditures, durable goods



% VARIABLE 2: UNEMPLOYMENT RATE
UNRATE = 'UNRATE';
UNRATE = fetch(c,UNRATE);
UNRATE = UNRATE.Data; 

UNRATEdate = UNRATE(:,1); 
UNRATEdate = datetime(UNRATEdate,'ConvertFrom','datenum');
% UNRATEdate = UNRATEdate>=tau0;

UNRATE = UNRATE(:,2); 
UNRATE = UNRATE(UNRATEdate>=tau0);


% VARIABLE 3: CONSUMER PRICE INDEX: All Items: Total for United States 
CPI= 'CPALTT01USM657N';
CPI = fetch(c,CPI);
CPI = CPI.Data; 

CPIdate = CPI(:,1); 
InfRdate = datetime(CPIdate,'ConvertFrom','datenum');
INFR = CPI(:,2);
INFR = INFR(InfRdate>=tau0);

% VARIABLE 4: JUNK BOND SPREAD
% Moody's Seasoned Aaa Corporate Bond Yield
AAA = 'AAA';
AAA = fetch(c,AAA);
AAA = AAA.Data; 

AAAdate = AAA(:,1); 
AAAdate = datetime(AAAdate,'ConvertFrom','datenum');
AAA = AAA(:,2);
AAA = AAA(AAAdate>=tau0);


% Moody's Seasoned Baa Corporate Bond Yield
BAA = 'BAA';
BAA = fetch(c,BAA);
BAA = BAA.Data; 

BAAdate = BAA(:,1); 
BAAdate = datetime(BAAdate,'ConvertFrom','datenum');
BAA = BAA(:,2);
BAA = BAA(BAAdate>=tau0);

% transform: AAA-BAA to get junk bond spread
JSPREAD = BAA-AAA;


% VARIABLE 5: INTEREST RATE SPREAD
% 10-Year Treasury Constant Maturity
GS10 = 'GS10';
GS10 = fetch(c,GS10);
GS10 = GS10.Data; 

GS10date = GS10(:,1); 
GS10date = datetime(GS10date,'ConvertFrom','datenum');
GS10 = GS10(:,2);
GS10 = GS10(GS10date>=tau0);


%3-Month Treasury Constant Maturity

GS3 = 'GS3';
GS3 = fetch(c,GS3);
GS3 = GS3.Data; 

GS3date = GS3(:,1); 
GS3date = datetime(GS3date,'ConvertFrom','datenum');
GS3 = GS3(:,2);
GS3 = GS3(GS3date>=tau0);

ISPREAD10=GS10-GS3;



% VARIABLE 6: REAL DISPOSABLE PERSONAL INCOME: Per Capita 
% UNITS: billions of 2017 chained dollars
RDPIPCA = 'A229RX0';
RDPIPCA = fetch(c,RDPIPCA);
RDPIPCA = RDPIPCA.Data; % up to Feb--> use lag maybe

RDPIPCAdate = RDPIPCA(:,1); 
RDPIPCAdate = datetime(RDPIPCAdate,'ConvertFrom','datenum');
RDPIPCA = RDPIPCA(:,2);
RDPIPCA = RDPIPCA(RDPIPCAdate>=tau0);

% return billions
RDPIPCA = 10^9 .* RDPIPCA;

% log transformation
logRDPIPCA = log(RDPIPCA);
% growth rate
RDPIPCA_GR = diff(log(RDPIPCA));


% % VARIABLE 7: PERSONAL CONSUMPTION EXPENDITURES: Durable Goods
% UNITS: billions of US dollars
PCEDG = 'PCEDG'; 
PCEDG = fetch(c,PCEDG);
PCEDG = PCEDG.Data; % up to Feb

PCEDGdate = PCEDG(:,1); 
PCEDGdate = datetime(PCEDGdate,'ConvertFrom','datenum');
PCEDG = PCEDG(:,2);

PCEDG = PCEDG(PCEDGdate>=tau0);

% return to billions for log transformation
PCEDG = 10^9 .* PCEDG;

% log transformation
logPCEDG= log(PCEDG);

% growth rate
PCEDG_GR = diff(log(PCEDG));


%% Plot all series to find leading indicators & seasonalities

date_2=date(date>=tau0);

figure(1)
plot(date_2, UMCSENT)
title('Consumer Sentiment');

figure(2)
plot(date_2, UNRATE)
title('Unemployment Rate');

figure(3)
plot(date_2, INFR)
title('Inflation rate');

figure(4)
plot(date_2, JSPREAD)
title('Junk bond spread');

figure(5)
plot(date_2, ISPREAD10)
title('T-bill Interest rate spread (10y-3m)');

figure(6)
plot(date_2(2:end), RDPIPCA)
title('Real Disposable Personal Income');

figure(7)
plot(date_2(2:end), logRDPIPCA)
title('ln(Real Disposable Personal Income)');

figure(8)
plot(date_2(2:end), PCEDG)
title('Personal Consumption Expeditures');

figure(9)
plot(date_2(2:end), logPCEDG)
title('Ln(Personal Consumption Expeditures)');

figure(10)
subplot(4, 1, 1);
plot(date_2, UMCSENT);
title('Consumer Sentiment');

subplot(4, 1, 2);
plot(date_2, UNRATE);
title('Unemployment Rate');

subplot(4, 1, 3);
plot(date_2, INFR);
title('Inflation rate');

subplot(4, 1, 4);
plot(date_2, ISPREAD10)
title('10-year Treasury Bill Interest Rate Spread');

figure(11)
subplot(4, 1, 1);
plot(date_2, UMCSENT);
title('Consumer Sentiment');

subplot(4, 1, 2);
plot(date_2, JSPREAD);
title('Junk Bond Spread');

subplot(4, 1, 3);
plot(date_2(2:end), RDPIPCA);
title('Real Disposable Personal Income');

subplot(4, 1, 4);
plot(date_2(2:end), PCEDG);
title('Personal Consumption Expeditures');

% combine plots in one plot
figure(12)
yyaxis left
plot(date_2,UMCSENT);% unit: Index 1966:Q1=100
yyaxis right
plot(date_2,UNRATE);

yyaxis left
ylabel('Sentiment Index')

yyaxis right
ylabel('(%)')
% add additional dat against each axis
hold on
yyaxis right
plot(date_2,INFR,'-g',date_2,JSPREAD,'-m',date_2,ISPREAD10,'-b',LineWidth=1); % inflation rate, junk bond spread, interest spread 
% the three vars are clustered around the same level, but are at different
% level than unemployment rate, this is normal
hold off

% ref https://www.mathworks.com/help/matlab/ref/legend.html#bt6tbh9
legend({'Consumer Sentiment Index','Unemployment Rate','Inflation Rate','Junk Bond Spread','10year interest rate spread'},'Location','northeast','NumColumns',2);
legend('boxoff')

% add the gray recession plot 
% ref https://www.mathworks.com/help/econ/recessionplot.html
recessionplot %recessionplot overlays shaded US recession bands, 
% as reported by the National Bureau of Economic Research (NBER), 
% on a time series plot in the current axes.
plot(date_2, UMCSENT);
ylabel('Consumer Sentiment Index');


%% Test unit root with trend for log(PDI) and log(PDE)
% lag of differences
adftest(logRDPIPCA,Model="TS",lags=12) %0

adftest(logPCEDG,Model="TS",lags=12) %0

%% Test unit root for the rest of all variables
% VAR1: consumer sentiment
adftest(UMCSENT,Model="ARD",lags=12) %1


% VAR2: unemploymenr rate
adftest(UNRATE,Model="ARD",lags=12) %0


% VAR3: inflation rate
[h,pValue,stat,cValue] = adftest(INFR,Model="ARD",lags=12); %1


% VAR4: junk bond spread
[h,pValue,stat,cValue] = adftest(JSPREAD,Model="ARD",lags=12); %1


% VAR5: 10year interest rate spread
[h,pValue,stat,cValue] = adftest(ISPREAD10,Model="ARD",lags=12); %1


%% Seasonality check 1 - Consumer Sentiment: no seasonality observed
figure(13)
subplot(3, 3, 1);
plot(date_2(1:12), UMCSENT(1:12))

subplot(3, 3, 2);
plot(date_2(61:72), UMCSENT(61:72))

subplot(3, 3, 3);
plot(date_2(121:132), UMCSENT(121:132))

subplot(3, 3, 4);
plot(date_2(181:192), UMCSENT(181:192))

subplot(3, 3, 5);
plot(date_2(241:252), UMCSENT(241:252))

subplot(3, 3, 6);
plot(date_2(301:312), UMCSENT(301:312))

subplot(3, 3, 7);
plot(date_2(361:372), UMCSENT(361:372))

subplot(3, 3, 8);
plot(date_2(421:432), UMCSENT(421:432))

subplot(3, 3, 9);
plot(date_2(482:493), UMCSENT(482:493))

sgtitle('Consumer Sentiment Index: Annual Trend');




%% Seasonality check 2 - Inflation: no seasonality
figure(14)
subplot(3, 3, 1);
plot(date_2(1:12), INFR(1:12))

subplot(3, 3, 2);
plot(date_2(61:72), INFR(61:72))

subplot(3, 3, 3);
plot(date_2(121:132), INFR(121:132))

subplot(3, 3, 4);
plot(date_2(181:192), INFR(181:192))

subplot(3, 3, 5);
plot(date_2(241:252), INFR(241:252))

subplot(3, 3, 6);
plot(date_2(301:312), INFR(301:312))

subplot(3, 3, 7);
plot(date_2(361:372), INFR(361:372))

subplot(3, 3, 8);
plot(date_2(421:432), INFR(421:432))

subplot(3, 3, 9);
plot(date_2(482:493), INFR(482:493))

sgtitle('Inflation Rate: Annual Trend');



%% Seasonality check 3 - T-bill interest rates spread: no seasonality
figure(15)
subplot(3, 3, 1);
plot(date_2(1:12), ISPREAD10(1:12))

subplot(3, 3, 2);
plot(date_2(61:72), ISPREAD10(61:72))

subplot(3, 3, 3);
plot(date_2(121:132), ISPREAD10(121:132))

subplot(3, 3, 4);
plot(date_2(181:192), ISPREAD10(181:192))

subplot(3, 3, 5);
plot(date_2(241:252), ISPREAD10(241:252))

subplot(3, 3, 6);
plot(date_2(301:312), ISPREAD10(301:312))

subplot(3, 3, 7);
plot(date_2(361:372), ISPREAD10(361:372))

subplot(3, 3, 8);
plot(date_2(421:432), ISPREAD10(421:432))

subplot(3, 3, 9);
plot(date_2(482:493), ISPREAD10(482:493))

sgtitle('T-bill Interest Rate Spread: Annual Trend');


%% Seasonality check 4 - Junk bond spread: no seasonality 
figure(16)
subplot(3, 3, 1);
plot(date_2(1:12), JSPREAD(1:12))

subplot(3, 3, 2);
plot(date_2(61:72), JSPREAD(61:72))

subplot(3, 3, 3);
plot(date_2(121:132), JSPREAD(121:132))

subplot(3, 3, 4);
plot(date_2(181:192), JSPREAD(181:192))

subplot(3, 3, 5);
plot(date_2(241:252), JSPREAD(241:252))

subplot(3, 3, 6);
plot(date_2(301:312), JSPREAD(301:312))

subplot(3, 3, 7);
plot(date_2(361:372), JSPREAD(361:372))

subplot(3, 3, 8);
plot(date_2(421:432), JSPREAD(421:432))

subplot(3, 3, 9);
plot(date_2(482:493), JSPREAD(482:493))

sgtitle('Junk Bond Spread: Annual Trend');


%% Granger Causality Test
p = 12;
q = 12; 

% Unemployment Granger causes CSI: significant pvalue, thus reject null hypothesis
x = UNRATE;
OLSmdl = fitlm([lagmatrix(x,1:q) lagmatrix(UMCSENT,1:p)],UMCSENT);
[EstCov,se,coeff]=hac(OLSmdl,'display','off',Type="HC");
R=zeros(q,1+p+q); R(1:q,2:q+1)=eye(q);
EstCov = 0.5*(EstCov+EstCov');
[h,pValue,stat,cValue]=waldtest(coeff(2:q+1,1),R,EstCov);

disp('Unemployment Rate');
fprintf('pvalue: %0.3f\n', pValue);
% fprintf('AIC: %0.2f\n', OLSmdl.ModelCriterion.AIC);
% fprintf('BIC: %0.2f\n', OLSmdl.ModelCriterion.BIC);
disp(' ');


% Inflation rate Granger causes CSI: reject null hypothesis
x = INFR;
OLSmdl = fitlm([lagmatrix(x,1:q) lagmatrix(UMCSENT,1:p)],UMCSENT);
[EstCov,se,coeff]=hac(OLSmdl,'display','off',Type="HC");
R=zeros(q,1+p+q); R(1:q,2:q+1)=eye(q);
EstCov = 0.5*(EstCov+EstCov');
[h,pValue,stat,cValue]=waldtest(coeff(2:q+1,1),R,EstCov);

disp('Inflation rate');
fprintf('pvalue: %0.3f\n', pValue);
% fprintf('AIC: %0.2f\n', OLSmdl.ModelCriterion.AIC);
% fprintf('BIC: %0.2f\n', OLSmdl.ModelCriterion.BIC);
disp(' ');



% T-bill interest rate spread Granger causes CSI: reject null hypothesis
x = ISPREAD10;
OLSmdl = fitlm([lagmatrix(x,1:q) lagmatrix(UMCSENT,1:p)],UMCSENT);
[EstCov,se,coeff]=hac(OLSmdl,'display','off',Type="HC");
R=zeros(q,1+p+q); R(1:q,2:q+1)=eye(q);
EstCov = 0.5*(EstCov+EstCov');
[h,pValue,stat,cValue]=waldtest(coeff(2:q+1,1),R,EstCov);

disp('T-bill interest rate spread');
fprintf('pvalue: %0.3f\n', pValue);
% fprintf('AIC: %0.2f\n', OLSmdl.ModelCriterion.AIC);
% fprintf('BIC: %0.2f\n', OLSmdl.ModelCriterion.BIC);
disp(' ');




% Junk bond spread Granger causes CSI: reject null hypothesis
x = JSPREAD;
OLSmdl = fitlm([lagmatrix(x,1:q) lagmatrix(UMCSENT,1:p)],UMCSENT);
[EstCov,se,coeff]=hac(OLSmdl,'display','off',Type="HC");
R=zeros(q,1+p+q); R(1:q,2:q+1)=eye(q);
EstCov = 0.5*(EstCov+EstCov');
[h,pValue,stat,cValue]=waldtest(coeff(2:q+1,1),R,EstCov);

disp('Junk bond rate spread');
fprintf('pvalue: %0.4f\n', pValue);
% fprintf('AIC: %0.2f\n', OLSmdl.ModelCriterion.AIC);
% fprintf('BIC: %0.2f\n', OLSmdl.ModelCriterion.BIC);
disp(' ');



% Personal Income Granger causes CSI: ambiguous
x = RDPIPCA_GR;
OLSmdl = fitlm([lagmatrix(x,1:q) lagmatrix(UMCSENT(3:end),1:p)],UMCSENT(3:end));
[EstCov,se,coeff]=hac(OLSmdl,'display','off',Type="HC");
R=zeros(q,1+p+q); R(1:q,2:q+1)=eye(q);
EstCov = 0.5*(EstCov+EstCov');
[h,pValue,stat,cValue]=waldtest(coeff(2:q+1,1),R,EstCov);

disp('Personal Income');
fprintf('pvalue: %0.3f\n', pValue);
% fprintf('AIC: %0.2f\n', OLSmdl.ModelCriterion.AIC);
% fprintf('BIC: %0.2f\n', OLSmdl.ModelCriterion.BIC);
disp(' ');



% Consumption Expenditure Granger causes CSI: fail to reject null hypothesis
x = PCEDG_GR;
OLSmdl = fitlm([lagmatrix(x,1:q) lagmatrix(UMCSENT(3:end),1:p)],UMCSENT(3:end));
[EstCov,se,coeff]=hac(OLSmdl,'display','off',Type="HC");
R=zeros(q,1+p+q); R(1:q,2:q+1)=eye(q);
EstCov = 0.5*(EstCov+EstCov');
[h,pValue,stat,cValue]=waldtest(coeff(2:q+1,1),R,EstCov);

disp('Consumption Expenditure');
fprintf('pvalue: %0.3f\n', pValue);
% fprintf('AIC: %0.2f\n', OLSmdl.ModelCriterion.AIC);
% fprintf('BIC: %0.2f\n', OLSmdl.ModelCriterion.BIC);
disp(' ');



%% Model Selection with AIC 1: CSI and Unemployment rate

AIC_matrix = zeros(12, 13);

x_dl=UNRATE;

min_p = 0;
min_q = 0;
min_AIC = Inf;

% Loop over different lags for AR model
for p = 1:12
    % Loop over different lags for distributed lag model
    for q = 0:12
        % Construct the regressors matrix

        AR = lagmatrix(UMCSENT, 1:p);
        DL = lagmatrix(x_dl, 1:q);
        
        X = [AR, DL];
        
        % Fit the model (example using linear regression)
        mdl = fitlm(X(13:end, :), UMCSENT(13:end));
        
        % Calculate AIC
        AIC = mdl.ModelCriterion.AIC;
        
        % Store AIC score in the matrix
        AIC_matrix(p, q+1) = AIC;

        if AIC < min_AIC
            min_AIC = AIC;
            min_p = p;
            min_q = q;
        end
    end
end

% Convert matrix to table
AIC_1 = array2table(AIC_matrix);

% Write the table to a CSV file
writetable(AIC_1, 'AIC_1.csv');

% Display or use the AIC matrix as needed
disp(AIC_matrix);

% Display the minimum AIC and corresponding lag values
fprintf('Minimum AIC: %0.2f\n', min_AIC);
fprintf('Number of AR lags (p): %d\n', min_p);
fprintf('Number of DL lags (q): %d\n', min_q);




%% Model Selection with AIC 2: CSI and Inflation rate

AIC_matrix = zeros(12, 13);

x_dl=INFR;

min_p = 0;
min_q = 0;
min_AIC = Inf;

% Loop over different lags for AR model
for p = 1:12
    % Loop over different lags for distributed lag model
    for q = 0:12
        % Construct the regressors matrix

        AR = lagmatrix(UMCSENT, 1:p);
        DL = lagmatrix(x_dl, 1:q);
        
        X = [AR, DL];
        
        % Fit the model (example using linear regression)
        mdl = fitlm(X(13:end, :), UMCSENT(13:end));
        
        % Calculate AIC
        AIC = mdl.ModelCriterion.AIC;
        
        % Store AIC score in the matrix
        AIC_matrix(p, q+1) = AIC;

        if AIC < min_AIC
            min_AIC = AIC;
            min_p = p;
            min_q = q;
        end
    end
end

% Convert matrix to table
AIC_2 = array2table(AIC_matrix);

% Write the table to a CSV file
writetable(AIC_2, 'AIC_2.csv');

% Display or use the AIC matrix as needed
disp(AIC_matrix);

% Display the minimum AIC and corresponding lag values
fprintf('Minimum AIC: %0.2f\n', min_AIC);
fprintf('Number of AR lags (p): %d\n', min_p);
fprintf('Number of DL lags (q): %d\n', min_q);




%% Model Selection with AIC 3: CSI and 10-year Tresury bill spread

AIC_matrix = zeros(12, 13);

x_dl=ISPREAD10;

min_p = 0;
min_q = 0;
min_AIC = Inf;

% Loop over different lags for AR model
for p = 1:12
    % Loop over different lags for distributed lag model
    for q = 0:12
        % Construct the regressors matrix

        AR = lagmatrix(UMCSENT, 1:p);
        DL = lagmatrix(x_dl, 1:q);
        
        X = [AR, DL];
        
        % Fit the model (example using linear regression)
        mdl = fitlm(X(13:end, :), UMCSENT(13:end));
        
        % Calculate AIC
        AIC = mdl.ModelCriterion.AIC;
        
        % Store AIC score in the matrix
        AIC_matrix(p, q+1) = AIC;

        if AIC < min_AIC
            min_AIC = AIC;
            min_p = p;
            min_q = q;
        end
    end
end

% Convert matrix to table
AIC_3 = array2table(AIC_matrix);

% Write the table to a CSV file
writetable(AIC_3, 'AIC_3.csv');


% Display or use the AIC matrix as needed
disp(AIC_matrix);

% Display the minimum AIC and corresponding lag values
fprintf('Minimum AIC: %0.2f\n', min_AIC);
fprintf('Number of AR lags (p): %d\n', min_p);
fprintf('Number of DL lags (q): %d\n', min_q);




%% Model Selection with AIC 4: CSI and Junk bond spread

AIC_matrix = zeros(12, 13);

x_dl=JSPREAD;

min_p = 0;
min_q = 0;
min_AIC = Inf;

% Loop over different lags for AR model
for p = 1:12
    % Loop over different lags for distributed lag model
    for q = 0:12
        % Construct the regressors matrix

        AR = lagmatrix(UMCSENT, 1:p);
        DL = lagmatrix(x_dl, 1:q);
        
        X = [AR, DL];
        
        % Fit the model (example using linear regression)
        mdl = fitlm(X(13:end, :), UMCSENT(13:end));
        
        % Calculate AIC
        AIC = mdl.ModelCriterion.AIC;
        
        % Store AIC score in the matrix
        AIC_matrix(p, q+1) = AIC;

        if AIC < min_AIC
            min_AIC = AIC;
            min_p = p;
            min_q = q;
        end
    end
end

% Convert matrix to table
AIC_4 = array2table(AIC_matrix);

% Write the table to a CSV file
writetable(AIC_4, 'AIC_4.csv');

% Display or use the AIC matrix as needed
disp(AIC_matrix);

% Display the minimum AIC and corresponding lag values
fprintf('Minimum AIC: %0.2f\n', min_AIC);
fprintf('Number of AR lags (p): %d\n', min_p);
fprintf('Number of DL lags (q): %d\n', min_q);



%% Model Selection with AIC 5: CSI and Personal Income

%AIC_matrix = zeros(12, 12);

%x_dl=RDPIPCA_GR

%min_p = 0;
%min_q = 0;
%min_AIC = Inf;

% Loop over different lags for AR model
%for p = 1:12
    % Loop over different lags for distributed lag model
    %for q = 1:12
        % Construct the regressors matrix

        %AR = lagmatrix(UMCSENT, 1:p);
        %DL = lagmatrix(x_dl, 1:q);
        
        %DL = DL(1:end-1, :)
        %AR = AR(2:end, :)

        %X = [AR, DL];
        
        % Fit the model (example using linear regression)
        %mdl = fitlm(X(14:end, :), UMCSENT(14:end));
        
        % Calculate AIC
        %AIC = mdl.ModelCriterion.AIC;
        
        % Store AIC score in the matrix
        %AIC_matrix(p, q) = AIC;

        %if AIC < min_AIC
            %min_AIC = AIC;
            %min_p = p;
            %min_q = q;
        %end
    %end
%end

% Display or use the AIC matrix as needed
%disp(AIC_matrix);

% Display the minimum AIC and corresponding lag values
%fprintf('Minimum AIC: %0.2f\n', min_AIC);
%fprintf('Number of AR lags (p): %d\n', min_p);
%fprintf('Number of DL lags (q): %d\n', min_q);



%%Baseline AR model for Consument Sentiment Index

AR_AIC_BIC = zeros(13, 2);

% Loop over different lags for AR model
for p = 0:12
   
        % Construct the regressors matrix
    AR = lagmatrix(UMCSENT, 1:p);
        % Fit the model (example using linear regression)
    mdl = fitlm(AR(13:end, :), UMCSENT(13:end));
        
        % Calculate AIC
    AIC = mdl.ModelCriterion.AIC;
    BIC = mdl.ModelCriterion.BIC;
        
        % Store AIC score in the matrix
    AR_AIC_BIC(p+1, 1) = AIC;
    AR_AIC_BIC(p+1, 2) = BIC;

end


% Convert matrix to table
AR_AIC_BIC = array2table(AR_AIC_BIC);

% Write the table to a CSV file
writetable(AR_AIC_BIC, 'AR_AIC_BIC.csv');

%% Stepwise selection

X_DL = [UNRATE,INFR,JSPREAD,ISPREAD10];% logPCEDG,logRDPIPCA,PDEgr,PDIgr

AR = lagmatrix(UMCSENT, 1:12);
DL = lagmatrix(X_DL, 1:12);

X = [AR, DL];

mdl = stepwiselm(X(13:end, :),UMCSENT(13:end, :));



%% Baseline model estimation 
% AR(6) model estimate

AR = lagmatrix(UMCSENT, 1:6);
% Fit the model 
mdl = fitlm(AR(13:end, :), UMCSENT(13:end));
display(mdl);


%% AR(3) model estimate

AR = lagmatrix(UMCSENT, 1:3);
% Fit the model 
mdl = fitlm(AR(13:end, :), UMCSENT(13:end));
display(mdl);




%% Stepwise selection: verify the model selection

%X_DL = [UNRATE,INFR,JSPREAD,ISPREAD10];% logPCEDG,logRDPIPCA,PDEgr,PDIgr

% Full model

% p,q 12lags AIC &BIC
AR = lagmatrix(UMCSENT, 1:12);
DL_1 = lagmatrix(UNRATE, 1:12);
DL_2 = lagmatrix(INFR, 1:12);
DL_3 = lagmatrix(JSPREAD, 1:12);
DL_4 = lagmatrix(ISPREAD10, 1:12);

X = [AR, DL_1, DL_2, DL_3, DL_4];

mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :), 'Criterion', 'AIC');



AR = lagmatrix(UMCSENT, 1:12);
DL_1 = lagmatrix(UNRATE, 1:12);
DL_2 = lagmatrix(INFR, 1:12);
DL_3 = lagmatrix(JSPREAD, 1:12);
DL_4 = lagmatrix(ISPREAD10, 1:12);

X = [AR, DL_1, DL_2, DL_3, DL_4];

mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :), 'Criterion', 'BIC');



% AR = lagmatrix(UMCSENT, 1:12);
% DL_1 = lagmatrix(UNRATE, 1:12);
% DL_2 = lagmatrix(INFR, 1:12);
% DL_3 = lagmatrix(JSPREAD, 1:12);
% DL_4 = lagmatrix(ISPREAD10, 1:12);
% 
% X = [AR, DL_1, DL_2, DL_3, DL_4];
% 
% mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :));






% p, q AIC combined model with all variables
AR = lagmatrix(UMCSENT, 1:6);
DL_1 = lagmatrix(UNRATE, 1:2);
DL_2 = lagmatrix(INFR, 1:1);
DL_3 = lagmatrix(JSPREAD, 1:5);
DL_4 = lagmatrix(ISPREAD10, 1:1);

X = [AR, DL_1, DL_2, DL_3, DL_4];

mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :), 'Criterion', 'AIC');
mdl = fitlm(X(13:end, :), UMCSENT(13:end, :));
mdl.ModelCriterion.AIC


%% Model selection from the shortlisted models 

% p, q AIC
AR = lagmatrix(UMCSENT, 1:6);
DL_1 = lagmatrix(UNRATE, 1:2);
DL_2 = lagmatrix(INFR, 1:1);
DL_3 = lagmatrix(JSPREAD, 1:5);
DL_4 = lagmatrix(ISPREAD10, 1:1);

X = [AR];

mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :), 'Criterion', 'AIC');

% p, q AIC
AR = lagmatrix(UMCSENT, 1:6);
DL_1 = lagmatrix(UNRATE, 1:2);
DL_2 = lagmatrix(INFR, 1:1);
DL_3 = lagmatrix(JSPREAD, 1:5);
DL_4 = lagmatrix(ISPREAD10, 1:1);

X = [AR, DL_1];

mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :), 'Criterion', 'AIC');

% p, q AIC
AR = lagmatrix(UMCSENT, 1:6);
DL_1 = lagmatrix(UNRATE, 1:2);
DL_2 = lagmatrix(INFR, 1:1);
DL_3 = lagmatrix(JSPREAD, 1:5);
DL_4 = lagmatrix(ISPREAD10, 1:1);

X = [AR, DL_1, DL_2];

mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :), 'Criterion', 'AIC');


% p, q AIC
AR = lagmatrix(UMCSENT, 1:6);
DL_1 = lagmatrix(UNRATE, 1:2);
DL_2 = lagmatrix(INFR, 1:1);
DL_3 = lagmatrix(JSPREAD, 1:5);
DL_4 = lagmatrix(ISPREAD10, 1:1);

X = [AR, DL_1, DL_2, DL_3];

mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :), 'Criterion', 'AIC');


% p, q AIC
AR = lagmatrix(UMCSENT, 1:6);
DL_1 = lagmatrix(UNRATE, 1:2);
DL_2 = lagmatrix(INFR, 1:1);
DL_3 = lagmatrix(JSPREAD, 1:5);
DL_4 = lagmatrix(ISPREAD10, 1:1);

X = [AR, DL_1, DL_2, DL_3, DL_4];

mdl = stepwiselm(X(13:end, :), UMCSENT(13:end, :), 'Criterion', 'AIC');



%% Final Combined model


AR = lagmatrix(UMCSENT, 1:6);
DL_1 = lagmatrix(UNRATE, 1:2);
DL_2 = lagmatrix(INFR, 1:1);
DL_3 = lagmatrix(JSPREAD, 1:5);
DL_4 = lagmatrix(ISPREAD10, 1:1);

X = [AR, DL_2, DL_3];
mdl_final = fitlm(X(13:end, :), UMCSENT(13:end, :));
disp(mdl_final)


%% Forecast

est = (date_2 >= datetime(1978,1,1));
T=length(UMCSENT(est));

UMCSENT_f=zeros(12,1); UMCSENT_fi=zeros(12,2);
for h=1:12;
    AR = lagmatrix(UMCSENT, h:h+5);
    DL_2 = lagmatrix(INFR, h:h);
    DL_3 = lagmatrix(JSPREAD, h:h+4);

    X = [AR, DL_2, DL_3];

    mdl=fitlm([X(est,:)],UMCSENT(est));
    [UMCSENT_p, UMCSENT_pi_50] = predict(mdl, [fliplr(UMCSENT(T-6+1:T)'), fliplr(INFR(T-1+1:T)'), fliplr(JSPREAD(T-5+1:T)')], 'Prediction', 'observation', 'Alpha', 0.5); % 50% forecast interval
    [UMCSENT_p, UMCSENT_pi_95] = predict(mdl, [fliplr(UMCSENT(T-6+1:T)'), fliplr(INFR(T-1+1:T)'), fliplr(JSPREAD(T-5+1:T)')], 'Prediction', 'observation', 'Alpha', 0.05); % 95% forecast interval
    UMCSENT_f(h,1) = UMCSENT_p;
    UMCSENT_fi_50(h,:) = UMCSENT_pi_50;
    UMCSENT_fi_95(h,:) = UMCSENT_pi_95;
end

%% Forecast plots

figure(20);
plot(date_2(date_2>= datetime(2018,1,1)),UMCSENT(date_2>= datetime(2018,1,1)));
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_f, 'LineWidth', 2);
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_fi_50, ':', 'Color', [0.5 0.5 0.5],'LineWidth', 0.3,'LineWidth', 1.5);
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_fi_95, '--','Color', [0.5 0.5 0.5], 'LineWidth', 0.3);
legend('Consumer Sentiment Index','Direct forecast','5% Forecast interval', '25% Forecast interval', '75% Forecast interval', '95% Forecast interval', 'Location', 'northwest');
ylim([0, 130]);



figure(21);
plot(date_2(date_2>= datetime(2020,1,1)),UMCSENT(date_2>= datetime(2020,1,1)));
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_f, 'LineWidth', 1.5);
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_fi_50, ':', 'Color', [0.5 0.5 0.5],'LineWidth', 0.3,'LineWidth', 1.5);
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_fi_95, '--','Color', [0.5 0.5 0.5], 'LineWidth', 0.3);
legend('Consumer Sentiment Index','Direct forecast','5% Forecast interval', '25% Forecast interval', '75% Forecast interval', '95% Forecast interval', 'Location', 'northwest');
ylim([0, 130]);


figure(22);
plot(date_2(date_2>= datetime(1978,1,1)),UMCSENT(date_2>= datetime(1978,1,1)));
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_f, 'LineWidth', 2);
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_fi_50, ':', 'Color', [0.5 0.5 0.5],'LineWidth', 0.3,'LineWidth', 1.5);
hold on;
plot(date_2(T) + calmonths(1:12), UMCSENT_fi_95, '--','Color', [0.5 0.5 0.5], 'LineWidth', 0.3);
legend('Consumer Sentiment Index','Direct forecast','5% Forecast interval', '25% Forecast interval', '75% Forecast interval', '95% Forecast interval', 'Location', 'northwest');
ylim([0, 130]);




