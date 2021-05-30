************************************************************************;
*********************** Code for Problem 5.4 ***************************;
************************************************************************;

PROC IMPORT 
	DATAFILE = "/home/u44964922/LectureNotesData/HRdata.csv" 
	OUT=HRdata DBMS=CSV REPLACE;
RUN;

/* Fit the original logistic regression */
PROC LOGISTIC DATA = HRdata DESCENDING PLOTS(ONLY) = ROC;
	CLASS work_accident (REF = first) promotion_last_5years (REF = first) 
		  salary (REF = 'low') / PARAM = REF;
	MODEL left = satisfaction_level last_evaluation number_project average_monthly_hours 
		  time_spent_company work_accident promotion_last_5years salary;
RUN;

/* Histogram of four continuous variables */
PROC SGPLOT DATA = HRdata;
	HISTOGRAM satisfaction_level / GROUP = left TRANSPARENCY = 0.5 SCALE = COUNT;
RUN;

PROC SGPLOT DATA = HRdata;
	HISTOGRAM last_evaluation / GROUP = left TRANSPARENCY = 0.5 SCALE = COUNT;
RUN;


PROC SGPLOT DATA = HRdata;
	HISTOGRAM average_monthly_hours / GROUP = left TRANSPARENCY = 0.5 SCALE = COUNT;
RUN;

PROC SGPLOT DATA = HRdata;
	VBAR time_spent_company / GROUP = left GROUPDISPLAY = CLUSTER;
RUN;

/* Discretize the four continuous variables */
DATA HRdata2 (DROP = satisfaction_level last_evaluation average_monthly_hours time_spent_company);
	SET HRdata;
	LENGTH SatLevel $6 Performance $6 WorkLoad $7 WorkYear $11;
	IF satisfaction_level < 0.4 THEN SatLevel = 'low';
	ELSE IF satisfaction_level < 0.7 THEN SatLevel = 'medium';
	ELSE SatLevel = 'high';
	IF last_evaluation < 0.6 THEN Performance = 'low';
	ELSE IF last_evaluation < 0.78 THEN Performance = 'medium';
	ELSE Performance = 'high';
	IF average_monthly_hours < 165 THEN WorkLoad = 'low';
	ELSE IF average_monthly_hours <= 220 THEN WorkLoad = 'normal';
	ELSE IF average_monthly_hours <= 275 THEN WorkLoad = 'high';
	ELSE WorkLoad = 'toohigh';
	IF time_spent_company = 2 THEN WorkYear = 'short';
	IF 3 <= time_spent_company <= 6 THEN WorkYear = 'medium';
	ELSE WorkYear = 'long';
RUN;

/* Refit the logistic regression with the discretized variables */
PROC LOGISTIC DATA = HRdata2 DESCENDING PLOTS(ONLY) = ROC;
	CLASS work_accident (REF = first) promotion_last_5years (REF = first) 
		  salary (REF = 'low') SatLevel (REF = 'low') Performance (REF = 'low') WorkLoad (REF = 'low') 
		  number_project (REF = first) WorkYear (REF = 'medium') / PARAM = REF;
	MODEL left = SatLevel Performance number_project WorkLoad
		  WorkYear work_accident promotion_last_5years salary;
RUN;


************************************************************************;
*********************** Code for Problem 5.5 ***************************;
************************************************************************;

DATA Claim;
INPUT car age dist y n @@;
nLog = LOG(n);
DATALINES;
1 1 0  65  317  1 1 1   2  20
1 2 0  65  476  1 2 1   5  33
1 3 0  52  486  1 3 1   4  40
1 4 0 310 3259  1 4 1  36 316
2 1 0  98  486  2 1 1   7  31
2 2 0 159 1004  2 2 1  10  81
2 3 0 175 1355  2 3 1  22 122
2 4 0 877 7660  2 4 1 102 724
3 1 0  41  223  3 1 1   5  18
3 2 0 117  539  3 2 1   7  39
3 3 0 137  697  3 3 1  16  68
3 4 0 477 3442  3 4 1  63 344
4 1 0  11   40  4 1 1   0   3
4 2 0  35  148  4 2 1   6  16
4 3 0  39  214  4 3 1   8  25
4 4 0 167 1019  4 4 1  33 114
;
RUN;

PROC GENMOD DATA = Claim;
	CLASS car (REF = '1') age (REF = '1') dist (REF = '0') / PARAM = REF;
	MODEL y = car age dist / DIST = POISSON LINK = LOG OFFSET = nLog;
RUN;

PROC GENMOD DATA = Claim;
	CLASS car (REF = '1') age (REF = '1') dist (REF = '0') / PARAM = REF;
	MODEL y = car age dist / DIST = NEGBIN OFFSET = nLog TYPE3;
RUN;


************************************************************************;
*********************** Code for Problem 5.6 ***************************;
************************************************************************;

DATA Respire;
INPUT air $ exposure $ smoking $ level count @@;
DATALINES;
 low  no non 1 158  low  no non 2   9
 low  no  ex 1 167  low  no  ex 2  19
 low  no cur 1 307  low  no cur 2 102
 low yes non 1  26  low yes non 2   5
 low yes  ex 1  38  low yes  ex 2  12
 low yes cur 1  94  low yes cur 2  48
high  no non 1  94 high  no non 2   7
high  no  ex 1  67 high  no  ex 2   8
high  no cur 1 184 high  no cur 2  65
high yes non 1  32 high yes non 2   3
high yes  ex 1  39 high yes  ex 2  11
high yes cur 1  77 high yes cur 2  48
 low  no non 3   5  low  no non 4   0
 low  no  ex 3   5  low  no  ex 4   3
 low  no cur 3  83  low  no cur 4  68
 low yes non 3   5  low yes non 4   1
 low yes  ex 3   4  low yes  ex 4   4
 low yes cur 3  46  low yes cur 4  60
high  no non 3   5 high  no non 4   1
high  no  ex 3   4 high  no  ex 4   3
high  no cur 3  33 high  no cur 4  36
high yes non 3   6 high yes non 4   1
high yes  ex 3   4 high yes  ex 4   2
high yes cur 3  39 high yes cur 4  51
;
RUN;

PROC LOGISTIC DATA = Respire ORDER = DATA PLOTS = EFFECT(POLYBAR x = air*exposure*smoking);
	FREQ count;
	CLASS air (REF = 'low') exposure (REF = 'no') smoking (REF = 'non') / PARAM = REF;
	MODEL level = air exposure smoking / SCALE = NONE AGGREGATE;
RUN;
