
/* Code for Assignment 2.6 (1)*/
DATA Convicts;
INPUT ConvRace $ VictRace $ DeathPenalty $ N;
DATALINES;
W W Y 19
W W N 132
W B Y 0
W B N 9
B W Y 11
B W N 52
B B Y 6
B B N 97
;
RUN;

/* Code for Assignment 2.6 (2)*/
PROC FREQ DATA=Convicts;
	TABLE DeathPenalty / Binomial(Level=2 Wald Wilson Exact);
	WEIGHT N;
RUN;

/* Code for Assignment 2.6 (3)*/
PROC FREQ DATA=Convicts;
	TABLE DeathPenalty / Binomial(Level=2 p=0.08);
	WEIGHT N;
	EXACT Binomial;
RUN;

/* Code for Assignment 2.6 (4)*/
/* two tests can be used: two sample z-test or the Pearson's chi-squared test */
PROC FREQ DATA=Convicts;
	TABLE ConvRace * DeathPenalty / RISKDIFF(EQUAL NORISKS COLUMN=2) ALPHA=0.1;
	WEIGHT N;
RUN;

PROC FREQ DATA=Convicts;
	TABLE ConvRace*DeathPenalty / CHISQ ALPHA=0.1;
	WEIGHT N;
RUN;

/* Code for Assignment 2.6 (5)*/
/* two tests can be used: two sample z-test or the Pearson's chi-squared test */
PROC FREQ DATA=Convicts;
	TABLE VictRace * DeathPenalty / RISKDIFF(EQUAL CL=WALD NORISKS COLUMN=2) ALPHA=0.01;
	WEIGHT N;
RUN;

PROC FREQ DATA=Convicts;
	TABLE VictRace * DeathPenalty / CHISQ ALPHA=0.01;
	EXACT Barnard;
	WEIGHT N;
RUN;

/* two sample z-test by raw SAS programming */
DATA _NULL_;
alpha = 0.01;
nvwhite = 19 + 132 + 11 + 52; nvwhite1 = 19 + 11; nvblack = 0 + 9 + 6 + 97; nvblack1 = 0 + 6;
p1hat = nvblack1 / nvblack; p2hat = nvwhite1 / nvwhite;
phat = (nvblack1 + nvwhite1) / (nvblack + nvwhite);
se0 = sqrt(phat * (1 - phat) * (1 / nvblack + 1 / nvwhite)); PUT "SE0 = " se0;
z = (p1hat - p2hat) / se0; PUT "Test statistic = " z;
sehat = sqrt(p1hat * (1 - p1hat) / nvblack + p2hat * (1 - p2hat) / nvwhite); PUT "SEhat = " sehat;
z2 = (p1hat - p2hat) / sehat; PUT "Test statistic using sehat = " z2;
pdiff = p1hat - p2hat; PUT "Difference in proportion = " pdiff;
za = QUANTILE("Normal", 1 - alpha / 2); PUT "za = " za;
CIlower = pdiff - za * sehat; CIupper = pdiff + za * sehat;
PUT"CI IS " CIlower CIupper;
pvalue = 2 * CDF("Normal", z); PUT "P-value = " pvalue;
pvalue2 = 2 * CDF("Normal", z2); PUT "P-value using sehat = " pvalue2;
RUN;

/* With the VAR=NULL option, the test statistic is computed using the pooled proportion */
PROC FREQ DATA=Convicts;
	TABLE VictRace * DeathPenalty / RISKDIFF(EQUAL VAR=NULL CL=WALD NORISKS COLUMN=2) ALPHA=0.01;
	WEIGHT N;
RUN;
