proc import datafile="C:/Users/ntlmp/Desktop/STAT410 Regression Analysis/STAT410 Project/insurance.csv"
out=healthinsurance
dbms=csv;
run;

data healthinsurance;
set healthinsurance;
chargesK = charges/1000; * rescaling costs;
run;

proc genmod;
class sex(ref="female") smoker(ref="no") region(ref="southeast");
model chargesK = age sex bmi children smoker region /
	dist=gamma link=log;
run;
/* Log Likelihood: -275.9746 */

/* checking goodness of fit */
proc genmod;
model chargesK = / dist=gamma link=log;
run;
/* Log Likelihood: -366.4021 */

data deviance_test;
deviance = -2*(-366.4021 - (-275.9746));
pvalue = 1 - probchi(deviance, 8);
run;
proc print noobs;
run;

*--------------------------------------------------------------------;
/* using fitted model for prediction */
data prediction;
input age sex$ 4-7 bmi children smoker$ 16-17 region$ 19-27;
cards;
22 male 23.3 0 no southwest
;

data healthinsurance;
set healthinsurance prediction;
run;

proc genmod;
class sex(ref="female") smoker(ref="no") region(ref="southeast");
model chargesK = age sex bmi children smoker region
/dist=gamma link=log;
output out=outdata p=pchargesK;
run;

data outdata;
set outdata;
pred_charges= 1000*pchargesK;
run;

proc print data=outdata(firstobs=101) noobs;
var pred_charges;
run;
