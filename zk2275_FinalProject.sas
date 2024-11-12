
*****************************************
* P6110: Statistical Computing with SAS *
*                                       *
* Final Project                         *
* 04/22/2024                            *
* Name: Zhuodiao Kuang                  *
* UNI:  zk2275                          *
*****************************************;


*I used Midterm Template - Report.sas to generate my report;
/* Prompt Two---Sex and Genetic Risk Factors for Cognitive Impairment in Late 
Middle-Aged Adults  */

* Data Importing;

proc import out=cognition
	datafile="/home/u63668108/SAShomework/cognition.xlsx"
	dbms=xlsx replace;
run;
**********************************************************************************
* 1. Primary Aim: Are there differences in mean Aβ levels between APOE-ε4 carrier 
statuses or sexes;
**********************************************************************************;

** Mean Aβ burden should be derived as the average of these measures;
data cognition1;
	set cognition;
	global_mean_ab = (temporal_l_lobe+temporal_r_lobe+
	                  parietal_l_lobe+parietal_r_lobe+
	                  cingulate_l_lobe+cingulate_r_lobe+
	                  frontal_l_lobe+frontal_r_lobe)/8;
	if  rs429358 = "T:T" & rs7412 = "C:T"	 then APOEgeno = "0";
		else if  rs429358 = "C:T" & rs7412 = "C:T"   then APOEgeno = "1";
		else if  rs429358 = "T:T" & rs7412 = "C:C"   then APOEgeno = "0";
		else if  rs429358 = "C:T" & rs7412 = "C:C"   then APOEgeno = "1";
		else if  rs429358 = "C:C" & rs7412 = "C:C"   then APOEgeno = "2";
	keep global_mean_ab sex APOEgeno;
;
run;

/* Visualization */
/* APOEgeno and mean Abeta levels */

proc sgplot data=cognition1;
    vbox global_mean_ab / category=APOEgeno
        fillattrs=(color=skyblue) /* Set the color of the boxes to sky blue */
        lineattrs=(color=navy thickness=3) /* Outline color and thickness of the boxes */
        whiskerattrs=(color=blue thickness=3) /* Customize the color and thickness of the whiskers */
        boxwidth=0.5 /* Adjust the width of the boxes */
        transparency=0.2 /* Slight transparency for aesthetic effect */
        outlierattrs=(color=red size=7 ); /* Customize outlier appearance */
    xaxis label="APOE-ε4 carrier statuses" /* Customize the X-axis label */
          discreteorder=data /* Maintain the order of data as it appears in the dataset */
          grid /* Display grid lines on the X-axis */
          labelattrs=(weight=bold color=black); /* Customize label attributes */
    yaxis label="Global Mean Antibody Levels" /* Customize the Y-axis label */
          grid /* Include grid lines for easier interpretation */
          labelattrs=(weight=bold color=black); /* Customize label attributes */
    title "Box Plot of Global Mean Amyloid Beta(β) Levels by APOE-ε4 Carrier Statuses";
    title2 "Based on Comprehensive Cognitive Health Dataset";
    ;
run;
quit;



/* variance; mean; extreme dots */

proc univariate data=cognition1 normal;
	class APOEgeno;
	var global_mean_ab;
	histogram global_mean_ab;
	qqplot global_mean_ab;
run;

proc anova data=cognition1;
	class APOEgeno;
	model global_mean_ab = APOEgeno;
	* Equality of variances test: hovtest=BF;
	* Pairwise comparisons: Dunnett (0 as reference value);
	means APOEgeno / hovtest=bf dunnett("0");
run; 

* CLARIFY HYPOTHESES *
H0: mu.0 = mu.1 = mu.2
	v. 
H1: not H0 (at least one pair has a different mean) 

* CHECK NORMALITY *
- Shapiro-Wilk results for...
	0:	 p = 0.1613
	1:	 p < 0.0001
	2:	 p < 0.0001 (sample size = 8)
- QQ plots look skewed for "1" and "2" groups.
- Note: There are relatively small sample sizes in group "2".
 Results should be interpreted with caution.


* EQUALITY OF VARIANCES (BROWN-FORSYTHE) *
- p-value = 0.3958 ... Fail to reject H0 (variances are the same)
	... Therefore, equal variances assumption is appropriate.

ANOVA has a tolerance of non-normality, we can try first and use 
nonparametric tests alternatively. */

** CONDUCT TEST **
* ANOVA *

- p-value <0.0001 ... Reject H0
___________________________________

- Strong evidence to support that, depending on APOEgeno epsilon-4 type, the mean Abeta level
 is significantly different. 
  
  * Pairwise comparisons: Dunnett 
Comparisons significant at the 0.05 level are indicated by ***.
APOEgeno
Comparison	Difference Between Means	
Simultaneous 95% Confidence Limits	 
2 - 0	0.066819	0.031229	0.102408	***
1 - 0	0.021397	0.008320	0.034473	***

/* Abeta and sex ;
* check normality;
proc univariate data=cognition1 normal plots;
	class sex;
	var global_mean_ab;
	histogram global_mean_ab;
	qqplot global_mean_ab;
run;

* One-way ANOVA (nonparametric): Kruskal-Wallis test;
proc npar1way data=cognition1 wilcoxon;
	class sex;
	var global_mean_ab;
run;

* Corresponding ANOVA result;
proc anova data=cognition1;
	class sex;
	model global_mean_ab = sex;
	means sex / hovtest= bf;
run; quit;

/* 
* CLARIFY HYPOTHESES *
H0: mu.male = mu.female
	vs 
H1: mu.male =/= mu.female 

* CHECK NORMALITY *
- Shapiro-Wilk results for...
	Male:			p = 0.2231
	Female:			p < 0.0001

- QQ plots look skewed for female
... Reject H0, therefore normality assumption is not appropriate.

** CONDUCT TEST **
* Wilcoxon Two-Sample Test *
- p-value <0.0001 ... Reject H0
* KRUSKAL-WALLIS TEST *
- p-value <0.0001 ... Reject H0
___________________________________

* EQUALITY OF VARIANCES (BROWN-FORSYTHE) *
- p-value = 0.8453 ... Fail to reject H0 (variances are the same)
	... Therefore, equal variances assumption is appropriate.

- Strong evidence to support that, depending on sexes, 
  mean Aβ levels are significantly different. 
- Note: ANOVA may be robust to skewed distribution, and results suggest
		the same difference in mean Aβ levels (p <0.0001). 
*/

**********************************************************************************
/* 2. Clinically, Aβ SUVR is often used to determine Aβ positivity (Aβ >1.15). Is  
/* diabetes associated with Aβ positivity?  */
********************************************************************************** */
;
data cognition2;
	set cognition;
	global_mean_ab = (temporal_l_lobe+temporal_r_lobe+
	                  parietal_l_lobe+parietal_r_lobe+
	                  cingulate_l_lobe+cingulate_r_lobe+
	                  frontal_l_lobe+frontal_r_lobe)/8;
	if  global_mean_ab > 1.15 then Abeta_pos = "1";
		else  Abeta_pos = "0";
	keep global_mean_ab Abeta_pos diabetes;
run;

/* 
* CLARIFY HYPOTHESES *
H0: These variables are indepented v. H1: They are associated 

** CONDUCT TEST **
* CHI-SQUARED TEST *

- p-value = 0.2888 ... Don't Reject H0
___________________________________

- No significant evidence to support that diabetes and Aβ positivity are 
  associated.
- Note: Fisher's exact test is unnecessary in this situation but would
		provide the same conclusion.
*/

* SUPPORTING CODE;
* conduct test;
;
proc freq data=cognition2;
	table Abeta_pos*diabetes / chisq fisher;
run;


************************************************************************************
/* 3. Are there differences in physical neurodegeneration (as outlined above) between 
/* APOE-ε4 carrier statuses or sexes?  */
**********************************************************************************


** Physical neurodegeneration should be derived as the average of these measures;
data cognition3;
	set cognition;
	neurodegeneration = (infpar_lh+
	infpar_rh+
	inftemp_lh+
	inftemp_rh+
	precuneus_lh+
	precuneus_rh+
	supfront_lh+
	supfront_rh+
	suppar_lh+
	suppar_rh+
	supramarginal_lh+
	supramarginal_rh+
	temporalpole_lh+
	temporalpole_rh+
	entorhinal_lh+
	entorhinal_rh+
	parahippo_lh+
	parahippo_rh+
	parsopercularis_lh+
	parsopercularis_rh+
	parsorbitalis_lh+
	parsorbitalis_rh+
	parstriangularis_lh+
	parstriangularis_rh)/24;
	if  rs429358 = "T:T" & rs7412 = "C:T"	 then APOEgeno = "0";
		else if  rs429358 = "C:T" & rs7412 = "C:T"   then APOEgeno = "1";
		else if  rs429358 = "T:T" & rs7412 = "C:C"   then APOEgeno = "0";
		else if  rs429358 = "C:T" & rs7412 = "C:C"   then APOEgeno = "1";
		else if  rs429358 = "C:C" & rs7412 = "C:C"   then APOEgeno = "2";
	keep neurodegeneration sex APOEgeno;
;
run;

/* Visualization */
/* APOEgeno and mean Abeta levels */
proc sgplot data=cognition3;
    vbox neurodegeneration / category=APOEgeno
              fillattrs=(color=skyblue) /* Set the color of the boxes */
              lineattrs=(color=navy) /* Outline color of the boxes */
              whiskerattrs=(thickness=2 color=blue); /* Customize whiskers */
    xaxis label="APOE Genotype" /* X-axis label */
          discreteorder=data; /* Order by the data as it appears in the dataset */
    yaxis label="Cortical thickness" /* Y-axis label */
          grid; /* Include grid lines for easier interpretation */
    title "Box Plot of Cortical thickness in Alzheimer's disease signature regions by APOE Genotype"; /* Chart title */
run;
quit;

/* variance; mean; extreme dots */

proc univariate data=cognition3 normal;
	class APOEgeno;
	var neurodegeneration;
	histogram neurodegeneration;
	qqplot neurodegeneration;
run;

proc anova data=cognition3;
	class APOEgeno;
	model neurodegeneration = APOEgeno;
	* Equality of variances test: hovtest=BF;
	* Pairwise comparisons: Dunnett (0 as reference value);
	means APOEgeno / hovtest=bf dunnett("0");
run; 

* CLARIFY HYPOTHESES *
H0: mu.0 = mu.1 = mu.2
	vs
H1: not H0 (at least one pair has a different mean) 

* CHECK NORMALITY *
- Shapiro-Wilk results for...
	0:	 p = 0.1962
	1:	 p = 0.0346
	2:	 p = 0.1479
- QQ plots look normal for almost all three types
- Note: There are relatively small sample sizes in some groups.
 Results should be interpreted with caution.

* EQUALITY OF VARIANCES (BROWN-FORSYTHE) *
- p-value = 0.4161 ... Fail to reject H0 (variances are the same)
	... Therefore, equal variances assumption is appropriate.

ANOVA has a tolerance of non-normality, we can try first and use 
nonparametric tests alternatively. */

** CONDUCT TEST **
* ANOVA *

- p-value =0.6162 ... Do not reject H0
___________________________________

- There is no strong evidence to support that, depending on APOEgeno epsilon-4 type, the cortical thickness
 is significantly different. 
  
Comparisons significant at the 0.05 level are indicated by ***.
APOEgeno
Comparison	Difference
Between
Means	Simultaneous 95% Confidence Limits	 
1 - 0	0.011929	-0.015570	0.039428	  Not Significant
2 - 0	-0.000710	-0.075550	0.074130      Not Significant

/* Neurodegeneration and sex ;
* check normality;
proc univariate data=cognition3 normal plots;
	class sex;
	var neurodegeneration;
	histogram neurodegeneration;
	qqplot neurodegeneration;
run;


proc anova data=cognition3;
	class sex;
	model neurodegeneration  = sex;
	means sex / hovtest= bf;
run; quit;

/* 
* CLARIFY HYPOTHESES *
H0: mu.male = mu.female
	vs 
H1: mu.male =/= mu.female 

* CHECK NORMALITY *
- Shapiro-Wilk results for...
	Male:			p = 0.1296
	Female:			p = 0.2061

- QQ plots also look normal for both. 
... Do Not Reject H0, normality assumption is appropriate.

* EQUALITY OF VARIANCES (BROWN-FORSYTHE) *
- p-value = 0.2140 ... Fail to reject H0 (variances are the same)
	... Therefore, equal variances assumption is appropriate.

** CONDUCT TEST **
* One-way ANOVA TEST *
- p-value = 0.0012 ... Reject H0
___________________________________

- Strong evidence to support that, depending on sexes, 
  cortical thickness are significantly different. 

*/

/*proc freq data=work.cognition;
    tables Sex*APOE_E4 / chisq;
    title "Distribution of APOE-ε4 by Sex";
run;
*/

/* Problem4 */
data cognition4;
	set cognition;
	neurodegeneration = (infpar_lh+
	infpar_rh+
	inftemp_lh+
	inftemp_rh+
	precuneus_lh+
	precuneus_rh+
	supfront_lh+
	supfront_rh+
	suppar_lh+
	suppar_rh+
	supramarginal_lh+
	supramarginal_rh+
	temporalpole_lh+
	temporalpole_rh+
	entorhinal_lh+
	entorhinal_rh+
	parahippo_lh+
	parahippo_rh+
	parsopercularis_lh+
	parsopercularis_rh+
	parsorbitalis_lh+
	parsorbitalis_rh+
	parstriangularis_lh+
	parstriangularis_rh)/24;
	global_mean_ab = (temporal_l_lobe+temporal_r_lobe+
	                  parietal_l_lobe+parietal_r_lobe+
	                  cingulate_l_lobe+cingulate_r_lobe+
	                  frontal_l_lobe+frontal_r_lobe)/8;
	if  rs429358 = "T:T" & rs7412 = "C:T"	 then APOEgeno = "0";
		else if  rs429358 = "C:T" & rs7412 = "C:T"   then APOEgeno = "1";
		else if  rs429358 = "T:T" & rs7412 = "C:C"   then APOEgeno = "0";
		else if  rs429358 = "C:T" & rs7412 = "C:C"   then APOEgeno = "1";
		else if  rs429358 = "C:C" & rs7412 = "C:C"   then APOEgeno = "2";
	keep neurodegeneration sex APOEgeno global_mean_ab;
;
run;
/* What is the distribution of APOE-ε4 between sexes?*/

proc freq data=cognition4;
    tables sex*APOEgeno / chisq;
    title "Distribution of APOE-ε4 by Sex";
run;

/* Statistics for Table of sex by APOEgeno */
/*  */
/* Statistic	DF	Value	Prob */
/* Chi-Square	2	0.8726	0.6464 */
/* There is no significant difference. */

/* Do genetic risk factors for your outcomes behave differently between sexes? */
 
/* 4.1 global_mean_ab  */
proc glm data=cognition4;
    class sex(ref= "1" ) APOEgeno(ref='0');
    model global_mean_ab = APOEgeno |sex;
    title "Interaction Effects of Sex and APOE-ε4 on Cognitive Outcomes(Brain amyloid plaques)";
run;



/* Source	DF	Type I SS	Mean Square	F Value	Pr > F */
/* APOEgeno	2	0.05373214	0.02686607	16.40	<.0001 */
/* sex	1	0.07758858	0.07758858	47.36	<.0001 */
/* sex*APOEgeno	2	0.00078161	0.00039081	0.24	0.7879 */
/* Source	DF	Type III SS	Mean Square	F Value	Pr > F */
/* APOEgeno	2	0.04888731	0.02444365	14.92	<.0001 */
/* sex	1	0.01468484	0.01468484	8.96	0.0030 */
/* sex*APOEgeno	2	0.00078161	0.00039081	0.24	0.7879 */

/* 4.2 neurodegeneration */
proc glm data=cognition4;
    class sex(ref= "1" ) APOEgeno(ref='0');
    model neurodegeneration = APOEgeno |sex;
    title "Interaction Effects of Sex and APOE-ε4 on Cognitive Outcomes(Neurodegeneration)";
run;
 

/* Source	DF	Type I SS	Mean Square	F Value	Pr > F */
/* APOEgeno	2	0.00822521	0.00411261	0.50	0.6060 */
/* sex	1	0.08513727	0.08513727	10.39	0.0014 
which is corresponded to question3*/
/* sex*APOEgeno	2	0.01440502	0.00720251	0.88	0.4164 */
/* Source	DF	Type III SS	Mean Square	F Value	Pr > F */
/* APOEgeno	2	0.00910743	0.00455371	0.56	0.5743 */
/* sex	1	0.00276029	0.00276029	0.34	0.5621 */
/* sex*APOEgeno	2	0.01440502	0.00720251	0.88	0.4164 */


/*  */
/* To address Question 5 from Prompt Two, which involves adjusting for potential confounders in the analysis, */
/*  we will extend the linear regression model to include covariates that may affect the relationship between sex, */
/*  APOE-ε4, and cognitive outcomes. These covariates can include age, depression, physical activity, and adiposity, */
/*  as they are commonly recognized risk factors for dementia and cognitive decline. */
/*  */

data cognition5;
    set cognition;

    /* Calculate neurodegeneration index as an average of 24 brain regions */
    neurodegeneration = (infpar_lh+
	infpar_rh+
	inftemp_lh+
	inftemp_rh+
	precuneus_lh+
	precuneus_rh+
	supfront_lh+
	supfront_rh+
	suppar_lh+
	suppar_rh+
	supramarginal_lh+
	supramarginal_rh+
	temporalpole_lh+
	temporalpole_rh+
	entorhinal_lh+
	entorhinal_rh+
	parahippo_lh+
	parahippo_rh+
	parsopercularis_lh+
	parsopercularis_rh+
	parsorbitalis_lh+
	parsorbitalis_rh+
	parstriangularis_lh+
	parstriangularis_rh)/24;

    /* Calculate global mean amyloid beta burden across 8 lobes */
    global_mean_ab = (temporal_l_lobe + temporal_r_lobe +
                      parietal_l_lobe + parietal_r_lobe +
                      cingulate_l_lobe + cingulate_r_lobe +
                      frontal_l_lobe + frontal_r_lobe) / 8;

    /* Recoding SNP data into APOE genotype */
	if  rs429358 = "T:T" & rs7412 = "C:T"	 then APOEgeno = "0";
		else if  rs429358 = "C:T" & rs7412 = "C:T"   then APOEgeno = "1";
		else if  rs429358 = "T:T" & rs7412 = "C:C"   then APOEgeno = "0";
		else if  rs429358 = "C:T" & rs7412 = "C:C"   then APOEgeno = "1";
		else if  rs429358 = "C:C" & rs7412 = "C:C"   then APOEgeno = "2";
run;

/* This line excludes observations where IPAQcat is missing */
data cognition5;
    set cognition5;
    if IPAQcat ^= '.'; 
run;

proc corr data=cognition5 plots(maxpoints=1000)=matrix(nvar=10);
	var global_mean_ab age waist neurodegeneration ;
run;
/* age and waist are correlated(p-value = 0.1051) but not so significant */
/* They are both highly correlated with neurodegeneration */



/* 5.1 When we treat global_mean_ab as the response variable*/

proc glmselect data=cognition5;
	class sex APOEgeno IPAQcat phq9;
	model global_mean_ab = APOEgeno sex -- waist;
run; quit;


/* Even though the selected model only includes APOEgeno and sex as variables, */
/* we are still interested in other covariates that could contribute to the outcomes. */

proc glm data=cognition5;
	class sex APOEgeno IPAQcat phq9;
	model global_mean_ab = sex APOEgeno age IPAQcat phq9 waist;
run; quit;

proc glm data=cognition5;
	class sex APOEgeno IPAQcat phq9;
	model global_mean_ab = sex age IPAQcat phq9 waist;
run; quit;

/*model2*/
data cognition5;
	set cognition5;
	log_global_mean_ab = log(global_mean_ab);
run;

* create final model;
proc glm data=cognition5;
	class sex APOEgeno IPAQcat phq9;
	model log_global_mean_ab= sex APOEgeno age IPAQcat phq9 waist  / solution;
	output out=regout p=yhat r=resid;
run; quit;

* check residuals of this model;
proc univariate data=regout normal;
	var resid;
	histogram resid;
	qqplot resid;
run;

/*
This model may be slightly improved from a diagnostics standpoint (some evidence
of normality in residuals), though interpretation becomes harder now. This is 
a common tradeoff to consider: prediction power vs interpretability.
*/




/* 5.2 When we treat neurodegeneration as the response variable*/


proc glmselect data=cognition5;
	class sex APOEgeno IPAQcat phq9;
	model neurodegeneration = APOEgeno sex -- waist;
run; quit;


/* Even though the selected model only includes age and sex as variables, */
/* we are still interested in other covariates that could contribute to the outcomes. */



/*model1*/
* create final model;
proc glm data=cognition5;
	class sex;
	model neurodegeneration= sex age / solution;
	output out=regout p=yhat r=resid;
run; quit;

* check residuals of this model;
proc univariate data=regout normal;
	var resid;
	histogram resid;
	qqplot resid;
run;

/*model2*/
* create final model;
proc glm data=cognition5;
	class sex APOEgeno IPAQcat phq9;
	model neurodegeneration= sex APOEgeno age IPAQcat phq9 waist / solution;
	output out=regout p=yhat r=resid;
run; quit;

* check residuals of this model;
proc univariate data=regout normal;
	var resid;
	histogram resid;
	qqplot resid;
run;





 