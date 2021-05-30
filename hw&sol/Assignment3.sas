
/* Code for Assignment 3.2 (1) and (4) */
DATA _NULL_;
	pf = (1 - CDF("F", 22.9782, 4, 88)); PUT "pf = " pf;
	pt1 = (1 - CDF("T", 10.7610, 88)) * 2; PUT "pt1 = " pt1;
	pt2 = (1 - CDF("T", 6.1333, 88)) * 2; PUT "pt2 = " pt2;
	pt3 = (1 - CDF("T", 3.6460, 88)) * 2; PUT "pt3 = " pt3;
	pt4 = (1 - CDF("T", 2.1593, 88)) * 2; PUT "pt4 = " pt4;
	pt5 = (1 - CDF("T", 4.5003, 88)) * 2; PUT "pt5 = " pt5;
	
	pf2 = (1 - CDF("F", 20.4586, 3, 88)); PUT "pf2 = " pf2;
RUN;



/* Code for Assignment 3.3 */
PROC IMPORT 
	DATAFILE = "/folders/myfolders/MA409/OtherDataProgram/Assignments/EducationExpenditure.xlsx" 
	OUT=EduExpend DBMS=XLSX REPLACE;
RUN;

/* Plot response against each explanatory variable to check linearity */
%MACRO Scatter(plotData=, varY=, varX=);
	PROC SGPLOT DATA=&plotData;
		STYLEATTRS WALLCOLOR=WhiteSmoke;
		SCATTER X=&varX Y=&varY / 
			MARKERATTRS=(symbol=CircleFilled color=LightSkyBlue);
		LOESS X=&varX Y=&varY;
		XAXIS GRID DISPLAY=(noline);
		YAXIS GRID DISPLAY=(noline);  
	RUN;
%MEND;

%Scatter(plotData=EduExpend, varY=Y, varX=X1);
%Scatter(plotData=EduExpend, varY=Y, varX=X2);
%Scatter(plotData=EduExpend, varY=Y, varX=X3);

/* Use PROC GLM to obtain the diagnostic plots*/
PROC GLM DATA = EduExpend PLOTS = DIAGNOSTICS(UNPACK);
	MODEL Y = X1 X2 X3;
	OUTPUT OUT = EduExpend_fitted (keep = State Y X1 X2 X3 resid rstu lev cd) 
				 Residual=resid Rstudent=rstu h=lev CookD=cd;
RUN;

/* Test heterocedasticity with the White and Breusch-Pagan tests */
/* Can be run with SAS OnDemand for Academics, not the SAS University Edition */
PROC MODEL DATA = EduExpend;
	PARMS b0 b1 b2 b3;
	Y = b0 + b1 * X1 + b2 * X2 + b3 * X3;
	FIT Y / WHITE PAGAN=(1 X1 X2 X3);
RUN;

/* Test normality with the Shapiro-Wilk test */
PROC UNIVARIATE DATA = EduExpend_fitted NORMAL;
	VAR resid;
RUN;

/* Filter the possible unusual observations */
PROC PRINT DATA = EduExpend_fitted;
	WHERE ABS(rstu) > 2 OR lev > 8/50 OR cd > 4 / 50;
RUN;

/* Fit the model by removing the unusual observation */
PROC GLM DATA = EduExpend PLOTS=DIAGNOSTICS(UNPACK);
	MODEL Y = X1 X2 X3;
	WHERE state ne "AK";
	OUTPUT OUT = EduExpend_fitted2 (keep = State Y X1 X2 X3 resid rstu lev cd) 
				 Residual=resid Rstudent=rstu h=lev CookD=cd;
RUN;

/* Test heterocedasticity again after removing the observation for "AK" */
/* Can be run with SAS OnDemand for Academics, not the SAS University Edition */
PROC MODEL DATA = EduExpend;
	PARMS b0 b1 b2 b3;
	Y = b0 + b1 * X1 + b2 * X2 + b3 * X3;
	FIT Y / WHITE PAGAN=(1 X1 X2 X3);
	WHERE state ne "AK";
RUN;

/* Fit the model again by removing X3 from the model */
PROC GLM DATA = EduExpend PLOTS=DIAGNOSTICS(UNPACK);
	MODEL Y = X1 X2;
	WHERE state ne "AK";
RUN;



/* Code for Assignment 3.4 */
PROC IMPORT 
	DATAFILE = "/folders/myfolders/MA409/OtherDataProgram/Assignments/AirPollution.xlsx" 
	OUT=AirPollution DBMS=XLSX REPLACE;
RUN;

/* Check the pairwise Pearson correlation coefficients */
PROC CORR DATA = AirPollution NOPROB NOSIMPLE RANK;
	VAR Y X1-X15;
RUN;

/* Check for multicollinearity by checking if Type II Tolerance is less than 0.1 */
PROC GLM DATA = AirPollution PLOTS=DIAGNOSTICS(UNPACK);
	MODEL Y = X1-X15 / TOLERANCE;
RUN;

/* Another way to check for multicollinearity */
PROC REG DATA = AirPollution;
	MODEL Y = X1-X15 / TOL VIF;
RUN;

/* Perform model selection */
PROC GLMSELECT DATA = AirPollution PLOTS=(CriterionPanel);
	MODEL Y = X1-X15 / SELECTION=STEPWISE(SELECT=SBC CHOOSE=SBC) STATS=(ADJRSQ CP AIC SBC);
RUN;

/* Standardize the response and explanatory variables */
PROC STANDARD DATA=AirPollution MEAN=0 STD=1 OUT=AirPollution2;
	VAR Y X1-X15;
RUN;

/* Fit ridge regression */
PROC REG DATA = AirPollution2 RIDGE = 0 to 1 by 0.05 OUTEST = RidgeEst;
	MODEL Y = X1-X15 / NOINT;
RUN;

/* Plot parameter estimates against lambda */
PROC SGPLOT DATA = RidgeEst;
	SERIES x = _RIDGE_ y = X1;
	SERIES x = _RIDGE_ y = X2;
	SERIES x = _RIDGE_ y = X6;
	SERIES x = _RIDGE_ y = X9;
	SERIES x = _RIDGE_ y = X12;
	SERIES x = _RIDGE_ y = X13;
	SERIES x = _RIDGE_ y = X14;
	YAXIS VALUES=(-1 to 1 by 0.1);
RUN;
