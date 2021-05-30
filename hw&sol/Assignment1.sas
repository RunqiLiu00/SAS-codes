/* Code for Assignment 1.5 (1)*/
PROC MEANS DATA=SASHELP.HEART MAXDEC=4 N NMISS MEAN MEDIAN STD SKEW KURT;
	CLASS Sex Smoking_Status;
	VAR AgeAtDeath;
RUN;


/* Code for Assignment 1.5 (2)*/
PROC TABULATE DATA=SASHELP.Heart;
	CLASS Sex Smoking_Status Weight_Status;
	VAR AgeAtDeath;
	TABLE Smoking_Status*Weight_Status, (Sex ALL)*AgeAtDeath*(N MEAN MEDIAN);
RUN;


/* Code for Assignment 1.5 (3)*/
PROC SQL;
	SELECT Sex, Smoking_Status, Weight_Status, COUNT(AgeAtDeath) AS N, MEAN(AgeAtDeath) AS mAgeAtDeath
	FROM SASHELP.Heart
	GROUP BY Sex, Smoking_Status, Weight_Status
	HAVING Sex IS NOT NULL AND Smoking_Status IS NOT NULL 
		   AND Weight_Status IS NOT NULL AND N > 20
	ORDER BY mAgeAtDeath DESC;
QUIT;


/* Code for Assignment 1.5 (4)*/
DATA Heart2 (KEEP=AgeAtDeath Sex Smoking_Status);
	SET SASHELP.HEART;
	WHERE Sex = "Male" AND Smoking_Status IN ("Non-smoker", "Very Heavy (> 25)")
		  AND NOT MISSING(AgeAtDeath); /* it's ok to remove NOT MISSING(AgeAtDeath)*/
RUN;

PROC SGPLOT DATA=Heart2;
	HISTOGRAM AgeAtDeath / GROUP=Smoking_Status TRANSPARENCY=0.5;
	DENSITY AgeATDeath / GROUP=Smoking_Status TYPE=Kernel;
	TITLE "Age at Death By Smoking Status for Male";
RUN;

/* Alternative way */
PROC SGPLOT DATA=SASHELP.Heart;
	WHERE Sex = "Male" AND Smoking_Status IN ("Non-smoker", "Very Heavy (> 25)");
	HISTOGRAM AgeAtDeath / GROUP=Smoking_Status TRANSPARENCY=0.5;
	DENSITY AgeATDeath / GROUP=Smoking_Status TYPE=Kernel;
	TITLE "Age at Death By Smoking Status for Male";
RUN;



/* Code for Assignment 1.5 (5)*/
/* Plot1 macro below using Datatyp is not correct */
/* Plot2 macro below using Vartype is correct */

%MACRO Plot1(plotData=, plotVar=);
%let type = %Datatyp(&plotVar);
%put &type;
	%IF %Datatyp(&plotVar)=CHAR %THEN %DO;
		PROC SGPLOT DATA=&plotData;
			VBAR &plotVar;
			TITLE "Bar chart of &plotVar";
		RUN;
	%END;
	%ELSE %IF %Datatyp(&plotVar)=NUMERIC %THEN %DO;
		PROC SGPLOT DATA=&plotData;
			HISTOGRAM &plotVar;
			TITLE "Histogram of &plotData";
		RUN;
	%END;
%MEND;

%Plot1(plotData=SASHELP.Heart, plotVar=AgeAtDeath);
%Plot1(plotData=SASHELP.Heart, plotVar=DeathCause);


%MACRO Plot2(plotData=, plotVar=);
	%LET dataID = %SYSFUNC(OPEN(&plotData, I));
	%LET varID = %SYSFUNC(VARNUM(&dataID, &plotVar));
	%IF %SYSFUNC(VARTYPE(&dataID, &varID)) = N %THEN %DO;
		PROC SGPLOT DATA=&plotData;
			HISTOGRAM &plotVar;
			TITLE "Histogram of &plotVar";
		RUN;
	%END;
	%ELSE %DO;
		PROC SGPLOT DATA=&plotData;
			VBAR &plotVar;
			TITLE "Bar chart of &plotVar";
		RUN;
	%END;
%MEND;

%Plot2(plotData=SASHELP.Heart, plotVar=AgeAtDeath);
%Plot2(plotData=SASHELP.Heart, plotVar=DeathCause);
                                                                                                               
                                                                                                                                        
