/* creating dummy variables for levels for categorical variables*/
data healthinsurance;
set healthinsurance;
male=(sex="male");
female=(sex="female");
smokerno=(smoker="no");
smokeryes=(smoker="yes");
northwest=(region="northwest");
northeast=(region="northeast");
southwest=(region="southwest");
southeast=(region="southeast");
chargesK = charges/1000;
run;

/* running normality check of response variable */
proc univariate;
var chargesK;
histogram/normal;
run;

/* finding optimal lambda for Box-Cox transformation*/
proc transreg;
model BoxCox(chargesK) = 
	identity(age male female bmi children smokerno smokeryes northwest northeast southwest southeast);
run;

/* applying Box-Cox transformation with lambda=0.5*/
/* square root transformation */
data healthinsurance;
set healthinsurance;
tr_chargesK = 2 * (sqrt(chargesK) - 1);
run;

/* running normality check of transformed response*/
proc univariate;
var tr_chargesK;
histogram/normal;
run;

/* fitting general linear model to transformed response */
proc genmod;
class sex(ref="female") smoker(ref="no") region(ref="southeast");
model tr_chargesK = age sex bmi children smoker region
	/ dist=normal link=identity;
run;
/* Log Likelihood: -164.1056 */

/* checking model fit */
proc genmod;
model tr_chargesK = / dist=normal link=identity;
run;
* Log Likelihood: -261.6025;

data deviance_test;
deviance = -2*(-261.6025 - (-164.1056));
pvalue = 1 - probchi(deviance,8);
run;
proc print noobs;
run;

*------------------------------------------------------------------------------------------------------;
/* using fitted model for prediction */
data predict;
input age male bmi children smokeryes southwest;
datalines;
22 1 23.3 0 0 1
;
data healthinsurance;
set healthinsurance predict;
run;
proc genmod data=healthinsurance;
model tr_chargesK = age male bmi children smokeryes southwest / dist=normal link=identity;
output out=outdata p=ptr_chargesK;
run;
data outdata;
set outdata;
pchargesK = ((((ptr_chargesK + 1)**2) / 2) * 1000);
run;
proc print data=outdata (firstobs=101) noobs;
var pchargesK;
run;
