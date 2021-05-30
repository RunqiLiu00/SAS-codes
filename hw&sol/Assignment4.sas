************************************************************************;
*********************** Code for Problem 4.3 ***************************;
************************************************************************;

/* Input data */
DATA GlassWare;
INPUT worker tool $ output @@;
DATALINES;
1 A 14  1 A 10  1 A 12  1 B 9  1 B 7  1 C 5  1 C 11  1 C 8
2 A 11  2 A 11  2 A 10  2 B 10  2 B 8  2 B 9  2 C 13  2 C 14  2 C 11
3 A 13  3 A 19  3 B 7  3 B 8  3 B 11  3 C 12  3 C 13 
4 A 10  4 A 12  4 B 6  4 C 14  4 C 10  4 C 12
;
RUN;

/* Fit one-way ANOVA with worker */
PROC GLM DATA = GlassWare;
	CLASS worker;
	MODEL output = worker;
RUN;

/* Fit two-way ANOVA with tool */
PROC GLM DATA = GlassWare;
	CLASS tool;
	MODEL output = tool;
	MEANS tool / CLDIFF ALPHA = 0.1 TUKEY DUNNETT("B");
RUN;

/* Fit two-way ANOVA with worker, tool, and the interaction effect */
PROC GLM DATA = GlassWare;
	CLASS worker tool;
	MODEL output = worker | tool;
	OUTPUT OUT=GlassWareOut PREDICTED = pred RESIDUAL = resid;
RUN;

/* Test whether the residuals are normally distributed */
PROC UNIVARIATE DATA = GlassWareOut NORMAL;
	VAR resid;
RUN;


************************************************************************;
*********************** Code for Problem 4.4 ***************************;
************************************************************************;
PROC IMPORT 
	DATAFILE = "/home/u44964922/LectureNotesData/HRdata.csv" 
	OUT=HRdata DBMS=CSV REPLACE;
RUN;

PROC SGPLOT DATA = HRdata;
	VBOX satisfaction_level / CATEGORY = left;
	TITLE "Boxplot of satisfaction_level by left";
RUN;

PROC SGPLOT DATA = HRdata;
	VBOX last_evaluation / CATEGORY = left;
	TITLE "Boxplot of last_evaluation by left";
RUN;

PROC SGPLOT DATA = HRdata;
	VBOX number_project / CATEGORY = left;
	TITLE "Boxplot of number_project by left";
RUN;

PROC SGPLOT DATA = HRdata;
	VBAR number_project / GROUP = left GROUPDISPLAY = CLUSTER;
	TITLE "Barplot of number_project by left";
RUN;

PROC SGPLOT DATA = HRdata;
	VBOX average_monthly_hours / CATEGORY = left;
	TITLE "Boxplot of average_monthly_hours by left";
RUN;

PROC SGPLOT DATA = HRdata;
	VBOX time_spent_company / CATEGORY = left;
	TITLE "Boxplot of time_spent_company by left";
RUN;

PROC FREQ DATA = HRdata order=freq;
	TABLES work_accident * left / NOPERCENT NOROW NOFREQ plots=freqplot(twoway=stacked scale=grouppct); 
	TABLES promotion_last_5years * left / NOPERCENT NOROW NOFREQ plots=freqplot(twoway=stacked scale=grouppct); 
	TABLES salary * left / NOPERCENT NOROW NOFREQ plots=freqplot(twoway=stacked scale=grouppct); 
RUN;

/* Fit the logistic regression model */
PROC LOGISTIC DATA = HRdata DESCENDING PLOTS(ONLY) = ROC;
	CLASS work_accident (REF = first) promotion_last_5years (REF = first) 
		  salary (REF = 'low') / PARAM = REF;
	MODEL left = satisfaction_level last_evaluation number_project average_monthly_hours 
		  time_spent_company work_accident promotion_last_5years salary / CTABLE;
RUN;


************************************************************************;
*********************** Code for Problem 4.2 ***************************;
************************************************************************;

/* Used to verify the correctness of hand calculation */
DATA Factory;
INPUT factory $ output @@;
DATALINES;
A 40 A 47 A 38 A 42 A 45 A 46
B 26 B 34 B 30 B 28 B 32 B 33
C 39 C 40 C 48 C 50 C 49 C 32
;
RUN;

PROC GLM DATA = Factory;
	CLASS Factory;
	MODEL output = Factory;
	MEANS factory / HOVTEST = LEVENE (TYPE = ABS);
RUN;

PROC NPAR1WAY DATA = Factory WILCOXON ANOVA DSCF;
	CLASS factory;
	VAR output;
RUN;