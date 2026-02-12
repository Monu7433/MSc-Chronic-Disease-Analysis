/********************************************************************/
/* PROJECT: Chronic Disease Analysis                                */
/* OBJECTIVE: Frequency Analysis → Visualization → Statistical Test */
/*            → Logistic Regression Modeling                        */
/********************************************************************/


/********************************************************************/
/* SECTION 1: DATA IMPORT                                           */
/********************************************************************/

/* Generated Code (IMPORT) */
/* Source File: 2response_labl.sav */

%web_drop_table(WORK.IMPORT);

FILENAME REFFILE '/home/u64108899/monu/Project_data.sav';

PROC IMPORT DATAFILE=REFFILE
    DBMS=SAV
    OUT=WORK.IMPORT;
RUN;

/* Check dataset structure */
PROC CONTENTS DATA=WORK.IMPORT;
RUN;

/* View first 10 observations */
PROC PRINT DATA=WORK.IMPORT (OBS=10);
RUN;



/********************************************************************/
/* SECTION 2: DESCRIPTIVE ANALYSIS – FREQUENCY DISTRIBUTION         */
/********************************************************************/

PROC FREQ DATA=WORK.IMPORT;
    TABLE Diabetes Hypertension Heart Cancer Kidney 
          age_5_years Cigarettes alcohol / NOCOL;
RUN;



/********************************************************************/
/* SECTION 3: DATA VISUALIZATION – BAR PLOTS WITH FREQUENCY         */
/********************************************************************/

/* Macro to generate frequency table + bar plot */

%macro plot_freq(var);

    /* Generate frequency table */
    PROC FREQ DATA=WORK.IMPORT NOPRINT;
        TABLES &var / OUT=freq_out;
    RUN;

    /* Print frequency table */
    PROC PRINT DATA=freq_out NOOBS;
        TITLE "Frequency Table for &var";
    RUN;

    /* Bar Plot */
    PROC SGPLOT DATA=freq_out;
        STYLEATTRS DATACOLORS=(red green);
        VBAR &var / RESPONSE=Count GROUP=&var GROUPDISPLAY=cluster;
        TITLE "Distribution of &var";
    RUN;

%mend;


/* Apply macro to variables */

%plot_freq(Diabetes);
%plot_freq(Hypertension);
%plot_freq(Heart);
%plot_freq(Cancer);
%plot_freq(Kidney);
%plot_freq(age_5_years);
%plot_freq(Cigarettes);
%plot_freq(alcohol);



/********************************************************************/
/* SECTION 4: STATISTICAL ANALYSIS – CHI-SQUARE TEST                */
/* Association between chronic diseases                             */
/********************************************************************/

%LET DISEASE_PAIRS =
    Diabetes*Hypertension Diabetes*Heart Diabetes*Cancer Diabetes*Kidney
    Hypertension*Heart Hypertension*Cancer Hypertension*Kidney
    Heart*Cancer Heart*Kidney Cancer*Kidney;

PROC FREQ DATA=WORK.IMPORT;
    TABLES &DISEASE_PAIRS / CHISQ;
    ODS OUTPUT ChiSq=ChiSqResults;
RUN;


/* Extract Chi-Square and Cramer's V */

DATA FilteredResults;
    SET ChiSqResults;
    WHERE Statistic IN ("Chi-Square", "Cramer's V");
    KEEP Table Statistic Value Prob;
RUN;


/* Display results */

PROC PRINT DATA=FilteredResults NOOBS LABEL;
    LABEL Table="Disease Pair"
          Statistic="Statistic"
          Value="Value"
          Prob="P-Value";
RUN;



/********************************************************************/
/* SECTION 5: BINARY LOGISTIC REGRESSION MODELING                   */
/********************************************************************/

/* Diabetes Model */

PROC LOGISTIC DATA=WORK.IMPORT DESCENDING;
    MODEL diabetes = current_age cigarettes alcohol 
                     hypertension kidney cancer heart / LINK=LOGIT;
RUN;

/* Diabetes Stepwise Selection */

PROC LOGISTIC DATA=WORK.IMPORT DESCENDING;
    MODEL diabetes = current_age cigarettes alcohol 
                     hypertension kidney cancer heart
                     / LINK=LOGIT SELECTION=STEPWISE
                       SLENTRY=0.05 SLSTAY=0.05;
RUN;


/* Hypertension Model */

PROC LOGISTIC DATA=WORK.IMPORT DESCENDING;
    MODEL hypertension = current_age cigarettes alcohol 
                         diabetes kidney cancer heart / LINK=LOGIT;
RUN;


/* Hypertension Stepwise Selection */

PROC LOGISTIC DATA=WORK.IMPORT DESCENDING;
    MODEL hypertension = current_age cigarettes alcohol 
                         diabetes kidney cancer heart
                         / LINK=LOGIT SELECTION=STEPWISE
                           SLENTRY=0.05 SLSTAY=0.05;
RUN;


/* Kidney Disease Model */

PROC LOGISTIC DATA=WORK.IMPORT DESCENDING;
    MODEL kidney = current_age cigarettes alcohol 
                   hypertension diabetes cancer heart
                   / LINK=LOGIT SELECTION=STEPWISE
                     SLENTRY=0.05 SLSTAY=0.05;
RUN;


/********************************************************************/
/* END OF ANALYSIS                                                  */
/********************************************************************/
