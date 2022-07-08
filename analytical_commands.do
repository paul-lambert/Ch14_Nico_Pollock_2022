

** Analysis behind outputs for the paper: 

** "Optimising the use of measures of social stratification in research with intersectional 
*    and longitudinal analytical priorities" (Paul Lambert and Camilla Barnett)

** DOI: 10.4324/9780429470059-18

** Published "International Handbook of Inequalities and the Life Course"

** Code used in generating tables of outputs within the paper 

** Last updated: 15 Aug 2019, Paul Lambert & Camilla Barnett, University of Stirling 




*************************************************
** Paths for file access (replication would require applications to access relevant microdata from UK Data Service) 
global path1a "[insert path]" /* UKHLS a-e, with detailed occupational records */
dir $path1a\*.dta
global path1b "[insert path]" /* Regular UKHLS, a-h */
global path1c "[insert path]" /* BHPS */

global path2a "[insert path]" /* derived data */
global path2b "[insert path]" /* outputs from analysis */
global path2c "[insert path]" /* do files and sub files*/ 
global path2d "[insert path]\" /* macros */


global file5a "[insert path]\gb91soc2000.dta" /* SOC2000 to CAMSIS from www.camsis.stir.ac.uk */
global file5b "[insert path]\isco88_isei.dta" /* ISCO88 to ISEI from www.geode.stir.ac.uk */
global file5c [insert path]\gb91soc90.dta" /* SOC90 to CAMSIS from www.camsis.stir.ac.uk */

global path9 "[insert path]"   

************************************************



************************************************

** Derive stratification measures on the UKHLS (analysis: wave e) 

/*
do $path2c\ukhls_prep_1.do 
*/
de using $path2a\ukhls_occs_a2e_1.dta

*********************

** Derive stratification measrues on the BHPS (analysis: wave a) 

/*
do $path2c\bhps_prep_1.do 
*/
de using $path2a\bhps_occs_a2r_1.dta


**************************************************************************







***
**************************************************************************
**************************************************************************


** Table 1: UKHLS, wave 5 (2013), 6 stratification measures 


de e_hidp e_tenure_dv e_fihhmngrs_dv e_hhsize e_ieqmoecd_dv ///
     using $path1b\e_hhresp.dta 

de pidp e_hidp   e_sex e_dvage e_fimngrs_dv e_*qfhigh_dv ///
           e_scghq1_dv e_scsf1 e_arts2freq using $path1b\e_indresp.dta 

use e_hidp e_tenure_dv e_fihhmngrs_dv e_hhsize e_ieqmoecd_dv ///
     using $path1b\e_hhresp.dta , clear 
renpfix e_
sort hidp
sav $path9\m1.dta, replace
use pidp e_hidp   e_sex e_dvage e_fimngrs_dv e_*qfhigh_dv ///
           e_scghq1_dv e_scsf1 e_arts2freq using $path1b\e_indresp.dta 
renpfix e_
sort hidp
merge m:1 hidp using $path9\m1.dta 
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
capture drop year 
gen year=2013
sort pidp year
isid pidp year
merge 1:1 pidp year using $path2a\ukhls_occs_a2e_1.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
numlabel _all, add 

tab tenure_dv 
capture drop ten3 
gen ten3=tenure_dv
recode ten3 1/2=1 3/4=3 5/7=2 *=.m 
capture label drop ten3l
label define ten3l 1 "Owner-occupier" 2 "Private rented" 3 "Social rented"
label values ten3 ten3l
tab ten3 


sum fihhmngrs_dv hhsize ieqmoecd_dv
de fihhmngrs_dv hhsize ieqmoecd_dv
graph matrix fihhmngrs_dv ieqmoecd_dv hhsize if ieqmoecd_dv >= 1 & fihhmngrs_dv > 0 & fihhmngrs_dv < 50000 
capture drop hh_ln_eqinc 
gen hh_ln_eqinc = ln(fihhmngrs_dv / ieqmoecd_dv) if (ieqmoecd_dv >= 1 & fihhmngrs_dv > 0 & fihhmngrs_dv < 50000)

tab scsf1 
capture drop poor_hlth
gen poor_hlth=(scsf1==4 | scsf1==5) if (scsf1 >= 1 & scsf1 <= 5) 
correlate poor_hlth scghq1_dv if scghq1_dv >= 0 

tab arts2freq, missing
capture drop arts2_2
clonevar arts2_2=arts2freq 
recode arts2_2 -8=6 -7 -1=.m
tab arts2_2

* Outcomes: 
codebook hh_ln_eqinc poor_hlth arts2_2, compact

* Strat measures: 
codebook  pid *mcam *isei hh_ln_eqinc  *ns_sec *rgsc ten3, compact 
* (See varying levels of coverage for occupation-based measures, contingent upon if 
*    use individual, household, last job information) 

**


***** Table 1 statistics: 

summarize pid
scalar Ncases=r(N)


** CAMSIS
foreach var in mcamsis jl_mcam h_jl_mcam {
  summarize `var'
  di "Percent valid for `var' " = round(100*(r(N)/Ncases), 0.1) 
    }
foreach var in mcamsis jl_mcam h_jl_mcam  {
 di "`var'" 
 pwcorr `var' hh_ln_eqinc poor_hlth arts2_2 
  }
*
** ISEI  
foreach var in isei jl_isei h_jl_isei {
  summarize `var'
  di "Percent valid for `var' " = round(100*(r(N)/Ncases), 0.1) 
    }
foreach var in isei jl_isei h_jl_isei  {
 di "`var'" 
 pwcorr `var' hh_ln_eqinc poor_hlth arts2_2 
  }
** Household equivalised income
foreach var in hh_ln_eqinc {
  summarize `var'
  di "Percent valid for `var' " = round(100*(r(N)/Ncases), 0.1) 
    }
foreach var in hh_ln_eqinc  {
 di "`var'" 
 pwcorr `var' hh_ln_eqinc poor_hlth arts2_2 
  }

** NS-SeC
foreach var in ns_sec jl_ns_sec h_jl_ns_sec {
  summarize `var'
  di "Percent valid for `var' " = round(100*(r(N)/Ncases), 0.1) 
    }
foreach var in ns_sec jl_ns_sec h_jl_ns_sec  {
 di "`var'" 
  capture drop var_t
  gen var_t = `var'*10 
  quietly regress hh_ln_eqinc ib2.var_t 
  di "R with hh_ln_eqinc = " sqrt(e(r2)) 
  quietly logit poor_hlth ib2.var_t 
  di "R with poor_hlth = " sqrt(e(r2_p)) 
  quietly  ologit arts2_2 ib2.var_t
  di "R with arts2_2 = " sqrt(e(r2_p)) 
  }

** RGSC
foreach var in rgsc jl_rgsc h_jl_rgsc {
  summarize `var'
  di "Percent valid for `var' " = round(100*(r(N)/Ncases), 0.1) 
    }
foreach var in rgsc jl_rgsc h_jl_rgsc  {
 di "`var'" 
  capture drop var_t
  gen var_t = `var'*10 
  quietly regress hh_ln_eqinc ib2.var_t 
  di "R with hh_ln_eqinc = " sqrt(e(r2)) 
  quietly logit poor_hlth ib2.var_t 
  di "R with poor_hlth = " sqrt(e(r2_p)) 
  quietly  ologit arts2_2 ib2.var_t
  di "R with arts2_2 = " sqrt(e(r2_p)) 
  }

** Housing tenure 

foreach var in ten3 {
  summarize `var'
  di "Percent valid for `var' " = round(100*(r(N)/Ncases), 0.1) 
    }
foreach var in ten3  {
 di "`var'" 
  capture drop var_t
  gen var_t = `var'*10 
  quietly regress hh_ln_eqinc ib2.var_t 
  di "R with hh_ln_eqinc = " sqrt(e(r2)) 
  quietly logit poor_hlth ib2.var_t 
  di "R with poor_hlth = " sqrt(e(r2_p)) 
  quietly  ologit arts2_2 ib2.var_t
  di "R with arts2_2 = " sqrt(e(r2_p)) 
  }

**************************************************************************

**************************************************************************
**************************************************************************
















**************************************************************************
*** Table 2: Stratification-health relationships in different longitudinal contexts



** Preparatory: 
/*
do $path2c\table2_dataprep_3.do 
*/
* Generates two temporary datasets (for 1995 and 2013)
de using $path9\bhps_1.dta
de using $path9\ukhls_1.dta
* And two more datasets that include up to 4 previous years of stratification measures: 
de using $path9\bhps_2.dta
de using $path9\ukhls_2.dta
**



*************************************
** Task: Looking at social relationships with different levels of control for time

** Context: we have two similar data extracts, from 1995 (BHPS, wave E) and 2013 (UKHLS, wave E)
de using $path9\bhps_1.dta
de using $path9\ukhls_1.dta
* (mostly the same measures, with largely the same or similar variable names and operationalisations)

** To provide a case study, we'll look at the relationship between a health measure and a 
*   stratification measure (and how it has changed over time)

************************************




*************************************
** 2i) No adjustment for longitudinal context in any way 

* Pool the datasets: 
use pid hid age sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth using $path9\bhps_1.dta, clear
gen year=1995
sav $path9\m1.dta, replace
use pid hid dvage sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth using $path9\ukhls_1.dta, clear
tab poor_hlth 
rename dvage age 
gen year=2013
append using $path9\m1.dta
tab year 
*
tab poor_hlth 
sum age sex
tab1 h_jl_rgsc h_jl_ns_sec
gen h_jl_rgsc10 = h_jl_rgsc*10 if h_jl_rgsc > 0 /* device for analysis: ns_sec, rgsc are categorical but with non-int values */
gen h_jl_ns_sec10 = h_jl_ns_sec*10 
codebook h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3, compact
capture drop nmiss
egen nmiss=rmiss(h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3)
tab nmiss /* to avoid any conflation with missing data, restrict analysis to non-missing on all measures*/
sum age 
keep if age >= 25 & age <= 60


* 1995 stats: Extract relevant stats for each of the six stratification measures: 
logit poor_hlth h_jl_mcam if nmiss==0 & year==1995
scalar s1 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth h_jl_isei if nmiss==0 & year==1995
scalar s2 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth hh_ln_eqinc  if nmiss==0 & year==1995
scalar s3 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth ib11.h_jl_ns_sec10 if nmiss==0 & year==1995
scalar s4 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth ib10.h_jl_rgsc10 if nmiss==0 & year==1995
scalar s5 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth ib1.ten3 if nmiss==0 & year==1995
scalar s6 = round(sqrt(e(r2_p)), 0.0001)   
matrix define stats1995 = [s1 \ s2 \ s3 \ s4 \ s5 \ s6 ]
matrix list stats1995

* 2013 stats
logit poor_hlth h_jl_mcam if nmiss==0 & year==2013
scalar s1 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth h_jl_isei if nmiss==0 & year==2013
scalar s2 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth hh_ln_eqinc  if nmiss==0 & year==2013
scalar s3 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth ib11.h_jl_ns_sec10 if nmiss==0 & year==2013
scalar s4 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth ib10.h_jl_rgsc10 if nmiss==0 & year==2013
scalar s5 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth ib1.ten3 if nmiss==0 & year==2013
scalar s6 = round(sqrt(e(r2_p)), 0.0001)   
matrix define stats2013 = [s1 \ s2 \ s3 \ s4 \ s5 \ s6 ]
matrix list stats2013

* Interaction parameters (for a selected term): 
*
logit poor_hlth i.year##c.h_jl_mcam if nmiss==0 
global modterm "2013.year#c.h_jl_mcam"
scalar s1 = _b[$modterm] /* beta parameter */ 
scalar s1b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s1c = _b[h_jl_mcam] /* main effect parameter */
logit poor_hlth i.year##c.h_jl_isei if nmiss==0 
global modterm "2013.year#c.h_jl_isei"
scalar s2 = _b[$modterm] /* beta parameter */ 
scalar s2b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s2c = _b[h_jl_isei] /* main effect parameter */
logit poor_hlth i.year##c.hh_ln_eqinc  if nmiss==0 
global modterm "2013.year#c.hh_ln_eqinc"
scalar s3 = _b[$modterm] /* beta parameter */ 
scalar s3b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s3c = _b[hh_ln_eqinc] /* main effect parameter */
*
logit poor_hlth i.year##ib70.h_jl_ns_sec10 if nmiss==0 
global modterm "2013.year#12.h_jl_ns_sec10"
scalar s4 = _b[$modterm] /* beta parameter */ 
scalar s4b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s4c = _b[12.h_jl_ns_sec10] /* main effect parameter */
logit poor_hlth i.year##ib40.h_jl_rgsc10 if nmiss==0 
global modterm "2013.year#20.h_jl_rgsc10"
scalar s5 = _b[$modterm] /* beta parameter */ 
scalar s5b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s5c = _b[20.h_jl_rgsc10] /* main effect parameter */
logit poor_hlth i.year##ib3.ten3 if nmiss==0 
global modterm "2013.year#1.ten3"
scalar s6 = _b[$modterm] /* beta parameter */ 
scalar s6b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s6c = _b[1.ten3] /* main effect parameter */
*
matrix define stats_int = [s1 \ s2 \ s3 \ s4 \ s5 \ s6 ]
matrix define stats_pval = [s1b \ s2b \ s3b \ s4b \ s5b \ s6b ]
matrix define stats_meff = [s1c \ s2c \ s3c \ s4c \ s5c \ s6c ]
matrix list stats_int
matrix list stats_pval



* Combined results, method 2i: 
matrix define statsdif = stats2013 - stats1995 
matrix pctchn = J(6, 1, 0) /* code follows to divide elements systematically [from Stata website] */
forvalues i=1/6 { 
  matrix pctchn[`i', 1] = 100*round((statsdif[`i', 1] / stats1995[`i', 1]), 0.001)
  }
matrix list pctchn

matrix intdif = J(6, 1, 0) /*  */
forvalues i=1/6 { 
  matrix intdif[`i', 1] = 100*round((stats_int[`i', 1] / stats_meff[`i', 1]), 0.001)
  }
matrix list intdif /* i.e. percent increase in 2013 parameter compared to 1995 */


matrix define stats_2i = [stats1995 , stats2013 , statsdif, pctchn, stats_meff, stats_int , stats_pval, intdif ]
matrix colnames stats_2i = 1995 2013 dif pctchn meffpar intpar intpval intpct
matrix rownames stats_2i = mcam isei lninc ns_sec rgsc ten3

matrix list stats_2i
* Cols 1-4  show absolute association (not necessarily direction)
****************************************
****





*************************************
** 2ii) Adjustment for longitudinal context by standardisation within time period

** Comment: arithmetic standardisation requires an estimate for a reasonable population mean and sd estimate
*    This might best come from an external source, or, in this example, from sample weighted data 

* For arithmetic mean standardisation, the categorical variables are also scaled in an effect proportional scaling
*   strategy

** Pool the datasets: 
** 1995 
use pid hid xrwght age sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth ///
      using $path9\bhps_1.dta, clear
gen year=1995
sav $path9\m1.dta, replace
use pid hid indinub_xw dvage sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth using $path9\ukhls_1.dta, clear
tab poor_hlth 
rename dvage age 
rename indinub_xw xrwght /* approximation: analysis will treat this weight as like BHPS 'xwght' */
gen year=2013
append using $path9\m1.dta
tab year 

tab poor_hlth 
sum age sex
tab1 h_jl_rgsc h_jl_ns_sec
gen h_jl_rgsc10 = h_jl_rgsc*10 if h_jl_rgsc > 0 /* device for analysis: ns_sec, rgsc are categorical but with non-int values */
gen h_jl_ns_sec10 = h_jl_ns_sec*10 
codebook h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3, compact
capture drop nmiss
egen nmiss=rmiss(h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3)
tab nmiss /* to avoid any conflation with missing data, restrict analysis to non-missing on all measures*/
sum age 
keep if age >= 25 & age <= 60


* Effect proportional scaling for the categorical measures, within years: 
foreach var in h_jl_ns_sec10 h_jl_rgsc10 ten3 { 
 capture drop s_`var'  
 egen s_`var'= mean(poor_hlth) if nmiss==0, by(`var' year )
 replace s_`var' = 1 - s_`var' /* for convenience: rescale to positive correlation with linear measures */ 
 tab s_`var' `var' 
 }
* (i.e. s_ten3 is a scale score for ten3 categories based on mean health within appropriate year)
correlate h_jl_mcam h_jl_isei hh_ln_eqinc s_h_jl_ns_sec10 s_h_jl_rgsc10 s_ten3


* Calculate the relevant year-specific means and standard deviations
foreach var in h_jl_mcam h_jl_isei hh_ln_eqinc s_h_jl_ns_sec s_h_jl_rgsc s_ten3 { 
  sum `var' if nmiss==0 & year==1995 [aw=xrwght]
  scalar m1991_`var'=r(mean)
  scalar sd1991_`var'=r(sd) 
  sum `var' if nmiss==0 & year==2013 [aw=xrwght]
  scalar m2013_`var'=r(mean)
  scalar sd2013_`var'=r(sd) 
  }
* (as discussed, these might also be derived from an external data source such as a larger sample)   

* construct the mean standardised measures, based on suitable means and standard deviations: 
foreach var in h_jl_mcam h_jl_isei hh_ln_eqinc s_h_jl_ns_sec s_h_jl_rgsc s_ten3 { 
  capture drop z_`var'
  gen z_`var' = (`var' - m1991_`var') / sd1991_`var'  if year==1995
  replace z_`var' = (`var' - m2013_`var') / sd2013_`var'  if year==2013
   }
   

* Association statistics based upon mean standardised stratification measures: 
logit poor_hlth z_h_jl_mcam if nmiss==0 & year==1995
scalar s1 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth z_h_jl_isei if nmiss==0 & year==1995
scalar s2 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth z_hh_ln_eqinc  if nmiss==0 & year==1995
scalar s3 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth z_s_h_jl_ns_sec if nmiss==0 & year==1995
scalar s4 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth z_s_h_jl_rgsc if nmiss==0 & year==1995
scalar s5 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth z_s_ten3 if nmiss==0 & year==1995
scalar s6 = round(sqrt(e(r2_p)), 0.0001)  
matrix define stats1995 = [s1 \ s2 \ s3 \ s4 \ s5 \ s6 ]
matrix list stats1995


* 2013 stats
logit poor_hlth z_h_jl_mcam if nmiss==0 & year==2013
scalar s1 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth z_h_jl_isei if nmiss==0 & year==2013
scalar s2 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth z_hh_ln_eqinc  if nmiss==0 & year==2013
scalar s3 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth z_s_h_jl_ns_sec if nmiss==0 & year==2013
scalar s4 = round(sqrt(e(r2_p)), 0.0001)   
logit poor_hlth z_s_h_jl_rgsc if nmiss==0 & year==2013
scalar s5 = round(sqrt(e(r2_p)), 0.0001)  
logit poor_hlth z_s_ten3 if nmiss==0 & year==2013
scalar s6 = round(sqrt(e(r2_p)), 0.0001)  
matrix define stats2013 = [s1 \ s2 \ s3 \ s4 \ s5 \ s6 ]
matrix list stats2013


* Interaction parameters (for a selected term): 
logit poor_hlth i.year##c.z_h_jl_mcam  if nmiss==0 
global modterm "2013.year#c.z_h_jl_mcam"
scalar s1 = _b[$modterm] /* beta parameter */ 
scalar s1b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s1c = _b[z_h_jl_mcam] /* main effect parameter */
logit poor_hlth i.year##c.z_h_jl_isei if nmiss==0 
global modterm "2013.year#c.z_h_jl_isei"
scalar s2 = _b[$modterm] /* beta parameter */ 
scalar s2b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s2c = _b[z_h_jl_isei] /* main effect parameter */
logit poor_hlth i.year##c.z_hh_ln_eqinc  if nmiss==0 
global modterm "2013.year#c.z_hh_ln_eqinc"
scalar s3 = _b[$modterm] /* beta parameter */ 
scalar s3b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s3c = _b[z_hh_ln_eqinc] /* main effect parameter */
*
logit poor_hlth i.year##c.z_s_h_jl_ns_sec if nmiss==0 
global modterm "2013.year#c.z_s_h_jl_ns_sec"
scalar s4 = _b[$modterm] /* beta parameter */ 
scalar s4b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s4c = _b[z_s_h_jl_ns_sec] /* main effect parameter */
logit poor_hlth i.year##c.z_s_h_jl_rgsc if nmiss==0 
global modterm "2013.year#c.z_s_h_jl_rgsc"
scalar s5 = _b[$modterm] /* beta parameter */ 
scalar s5b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s5c = _b[z_s_h_jl_rgsc] /* main effect parameter */
logit poor_hlth i.year##c.z_s_ten3 if nmiss==0 
global modterm "2013.year#c.z_s_ten3"
scalar s6 = _b[$modterm] /* beta parameter */ 
scalar s6b = (2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))) /* p-value */ 
scalar s6c = _b[z_s_ten3] /* main effect parameter */
*
matrix define stats_int = [s1 \ s2 \ s3 \ s4 \ s5 \ s6 ]
matrix define stats_pval = [s1b \ s2b \ s3b \ s4b \ s5b \ s6b ]
matrix define stats_meff = [s1c \ s2c \ s3c \ s4c \ s5c \ s6c ]
matrix list stats_int
matrix list stats_pval



* Combined results, method 2ii: 
matrix define statsdif = stats2013 - stats1995 
matrix pctchn = J(6, 1, 0) /* code follows to divide elements systematically [from Stata website] */
forvalues i=1/6 { 
  matrix pctchn[`i', 1] = 100*round((statsdif[`i', 1] / stats1995[`i', 1]), 0.001)
  }
matrix list pctchn

matrix intdif = J(6, 1, 0) /*  */
forvalues i=1/6 { 
  matrix intdif[`i', 1] = 100*round((stats_int[`i', 1] / stats_meff[`i', 1]), 0.001)
  }
matrix list intdif /* i.e. percent increase in 2013 parameter compared to 1995 */


matrix define stats_2ii = [stats1995 , stats2013 , statsdif, pctchn, stats_meff, stats_int , stats_pval, intdif ]
matrix colnames stats_2ii = 1995 2013 dif pctchn meffpar intpar intpval intpct
matrix rownames stats_2ii = mcam isei lninc ns_sec rgsc ten3
matrix list stats_2ii
matrix list stats_2i
* Without controls, mean standardised results are just linear transformations so should lead to equal stats
* Consider controls for other measures, or other forms of standardisation...? 
* And do get difference with interactions or when other variables are involved... 



/*
logit poor_hlth h_jl_mcam if nmiss==0
logit poor_hlth z_h_jl_mcam if nmiss==0
* Different results (different constraints being imposed on functional form)
logit poor_hlth c.h_jl_mcam##i.year if nmiss==0
logit poor_hlth c.z_h_jl_mcam##i.year if nmiss==0
* same model fit, but noticeably different parameters (from positive to negative interaction) 
*
logit poor_hlth c.h_jl_isei##i.year if nmiss==0
logit poor_hlth c.z_h_jl_isei##i.year if nmiss==0
*
logit poor_hlth c.hh_ln_eqinc if nmiss==0
logit poor_hlth c.z_hh_ln_eqinc if nmiss==0
logit poor_hlth c.hh_ln_eqinc##i.year if nmiss==0
logit poor_hlth c.z_hh_ln_eqinc##i.year if nmiss==0
**
* (?) add to text?
* Because standardisation is a linear transformation of a variable, it does not necessarily change
*   summmary analytical statistics. In the case of longitudinal data, temporal contextual standardisation
*   will have no impact on sophisticated statistical results (that allow interactions with time)
*    but it will have an impact upon commonly used statistical results that assume consistency 
*    over time in the influence of measures  (?)
*   (or when other variables are involved in the model?)
*/



*****************************************************************






*************************************
** 2iii) Adjustment for longitudinal context by fully controlling for 
*         life-course context (with mean standardisation included)



** Pool the datasets: 
** 1995 
use pid hid xrwght age sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth ///
      nkids mastat hgfno hgmno  using $path9\bhps_1.dta, clear
tab1 hgfno hgmno nkids mastat
capture drop notpars 
gen notpars=(hgfno==0 & hgmno==0) 
drop hgfno hgmno
capture drop kids
gen kids=(nkids >= 1) 
drop nkids
capture drop cohab
gen cohab=(mastat==1 | mastat==2) 
drop mastat 
gen year=1995
sav $path9\m1.dta, replace
**
use pid hid indinub_xw dvage sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth ///
    nkids_dv mastat_dv hgbiof hgbiom using $path9\ukhls_1.dta, clear
tab poor_hlth 
rename dvage age 
rename indinub_xw xrwght /* approximation: analysis will treat this weight as like BHPS 'xwght' */
tab1 nkids_dv mastat_dv hgbiof hgbiom
capture drop notpars 
gen notpars=(hgbiof==0 & hgbiom==0) 
drop hgbiof  hgbiom
capture drop kids
gen kids=(nkids_dv >= 1) 
drop nkids_dv
capture drop cohab
gen cohab=(mastat_dv==2 | mastat_dv==3 | mastat_dv==10) 
drop mastat_dv  
gen year=2013
append using $path9\m1.dta
tab year 
capture drop fem
gen fem=(sex==2) 
tab poor_hlth 
sum age sex
keep if age >= 25 & age <= 60 
tab1 h_jl_rgsc h_jl_ns_sec
gen h_jl_rgsc10 = h_jl_rgsc*10 if h_jl_rgsc > 0 /* device for analysis: ns_sec, rgsc are categorical but with non-int values */
gen h_jl_ns_sec10 = h_jl_ns_sec*10 
codebook h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3, compact
capture drop nmiss
egen nmiss=rmiss(h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3)
tab nmiss /* to avoid any conflation with missing data, restrict analysis to non-missing on all measures*/

* Effect proportional scaling for the categorical measures, within years: 
foreach var in h_jl_ns_sec10 h_jl_rgsc10 ten3 { 
 capture drop s_`var'  
 egen s_`var'= mean(poor_hlth) if nmiss==0, by(`var' year )
 replace s_`var' = 1 - s_`var' /* for convenience: rescale to positive correlation with linear measures */ 
 tab s_`var' `var' 
 }
* (i.e. s_ten3 is a scale score for ten3 categories based on mean health within appropriate year)
correlate h_jl_mcam h_jl_isei hh_ln_eqinc s_h_jl_ns_sec10 s_h_jl_rgsc10 s_ten3
 
* Calculate the relevant year-specific means and standard deviations
foreach var in h_jl_mcam h_jl_isei hh_ln_eqinc s_h_jl_ns_sec s_h_jl_rgsc s_ten3 { 
  sum `var' if nmiss==0 & year==1995 [aw=xrwght]
  scalar m1995_`var'=r(mean)
  scalar sd1995_`var'=r(sd) 
  sum `var' if nmiss==0 & year==2013 [aw=xrwght]
  scalar m2013_`var'=r(mean)
  scalar sd2013_`var'=r(sd) 
  }
* (as discussed, these might also be derived from an external data source such as a larger sample)   

* construct the mean standardised measures, based on suitable means and standard deviations: 
foreach var in h_jl_mcam h_jl_isei hh_ln_eqinc s_h_jl_ns_sec s_h_jl_rgsc s_ten3 { 
  capture drop z_`var'
  gen z_`var' = (`var' - m1995_`var') / sd1995_`var'  if year==1995
  replace z_`var' = (`var' - m2013_`var') / sd2013_`var'  if year==2013
   }
codebook z_* age fem cohab notpars kids , compact   

* 1995 partial association statistics based upon mean standardised stratification measures: 
logit poor_hlth fem age cohab notpars kids if nmiss==0 & year==1995
scalar a_null= sqrt(e(r2_p)) 
foreach var in z_h_jl_mcam z_h_jl_isei z_hh_ln_eqinc z_s_h_jl_ns_sec z_s_h_jl_rgsc z_s_ten3  { 
  logit poor_hlth `var' fem age cohab notpars kids if nmiss==0 & year==1995 
  scalar s_`var'  = round(sqrt(e(r2_p)) - a_null, 0.0001) 
  }
matrix define stats1995 = [s_z_h_jl_mcam \ s_z_h_jl_isei \ s_z_hh_ln_eqinc \ s_z_s_h_jl_ns_sec \ s_z_s_h_jl_rgsc \ s_z_s_ten3  ]
matrix list stats1995

* 2013 partial association statistics based upon mean standardised stratification measures:
logit poor_hlth fem age cohab notpars kids if nmiss==0 & year==2013
scalar a_null= sqrt(e(r2_p)) 
foreach var in z_h_jl_mcam z_h_jl_isei z_hh_ln_eqinc z_s_h_jl_ns_sec z_s_h_jl_rgsc z_s_ten3  { 
  logit poor_hlth `var' fem age cohab notpars kids if nmiss==0 & year==2013
  scalar s_`var'  = round(sqrt(e(r2_p)) - a_null, 0.0001) 
  }
matrix define stats2013 = [s_z_h_jl_mcam \ s_z_h_jl_isei \ s_z_hh_ln_eqinc \ s_z_s_h_jl_ns_sec \ s_z_s_h_jl_rgsc \ s_z_s_ten3  ]
matrix list stats2013


* Interaction parameters (for a selected term): 
foreach var in z_h_jl_mcam z_h_jl_isei z_hh_ln_eqinc z_s_h_jl_ns_sec z_s_h_jl_rgsc z_s_ten3  { 
  logit poor_hlth fem age cohab notpars kids i.year##c.`var' if nmiss==0 
  global modterm "2013.year#c.`var'" 
 scalar s_`var' = _b[$modterm] /* beta parameter */ 
 scalar s2_`var' = round((2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))),0.001) /* p-value */
 scalar s3_`var' = _b[`var']
  }
matrix define stats_int = [s_z_h_jl_mcam \ s_z_h_jl_isei \ s_z_hh_ln_eqinc \ s_z_s_h_jl_ns_sec \ s_z_s_h_jl_rgsc \ s_z_s_ten3 ]
matrix define stats_pval = [s2_z_h_jl_mcam \ s2_z_h_jl_isei \ s2_z_hh_ln_eqinc \ s2_z_s_h_jl_ns_sec \ s2_z_s_h_jl_rgsc \ s2_z_s_ten3 ]
matrix define stats_meff = [s3_z_h_jl_mcam \ s3_z_h_jl_isei \ s3_z_hh_ln_eqinc \ s3_z_s_h_jl_ns_sec \ s3_z_s_h_jl_rgsc \ s3_z_s_ten3 ]
matrix list stats_int
matrix list stats_pval


* Combined results, method 2iii: 
matrix define statsdif = stats2013 - stats1995 
matrix pctchn = J(6, 1, 0) /* code follows to divide elements systematically [from Stata website] */
forvalues i=1/6 { 
  matrix pctchn[`i', 1] = 100*round((statsdif[`i', 1] / stats1995[`i', 1]), 0.001)
  }
matrix list pctchn

matrix intdif = J(6, 1, 0) /*  */
forvalues i=1/6 { 
  matrix intdif[`i', 1] = 100*round((stats_int[`i', 1] / stats_meff[`i', 1]), 0.001)
  }
matrix list intdif /* i.e. percent increase in 2013 parameter compared to 1995 */


matrix define stats_2iii = [stats1995 , stats2013 , statsdif, pctchn, stats_meff, stats_int , stats_pval, intdif ]
matrix colnames stats_2iii = 1995 2013 dif pctchn meffpar intpar intpval intpct
matrix rownames stats_2iii = mcam isei lninc ns_sec rgsc ten3

matrix list stats_2iii
matrix list stats_2ii
matrix list stats_2i


**

****************************************************************






************************************************************
*** Trajectory based summary of stratification position

** For this example, focus upon BHPS w5, UKHLS w5, and draw upon up to 4 previous years of data




** Pool the datasets: 
** 1995
use pid hid xrwght age sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth ///
      nkids mastat hgfno hgmno  ///
    *_h_jl_mcam *_h_jl_isei *_hh_ln_eqinc *_h_jl_ns_sec *_h_jl_rgsc *_ten3 ///  
     using $path9\bhps_2.dta, clear
tab1 hgfno hgmno nkids mastat
capture drop notpars 
gen notpars=(hgfno==0 & hgmno==0) 
drop hgfno hgmno
capture drop kids
gen kids=(nkids >= 1) 
drop nkids
capture drop cohab
gen cohab=(mastat==1 | mastat==2) 
drop mastat 
gen year=1995
sav $path9\m1.dta, replace




use pid hid indinub_xw dvage sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth ///
    nkids_dv mastat_dv hgbiof hgbiom ///
    *_h_jl_mcam *_h_jl_isei *_hh_ln_eqinc *_h_jl_ns_sec *_h_jl_rgsc *_ten3 /// 
          using $path9\ukhls_2.dta, clear
tab poor_hlth 
rename dvage age 
rename indinub_xw xrwght /* approximation: analysis will treat this weight as like BHPS 'xwght' */
tab1 nkids_dv mastat_dv hgbiof hgbiom
capture drop notpars 
gen notpars=(hgbiof==0 & hgbiom==0) 
drop hgbiof  hgbiom
capture drop kids
gen kids=(nkids_dv >= 1) 
drop nkids_dv
capture drop cohab
gen cohab=(mastat_dv==2 | mastat_dv==3 | mastat_dv==10) 
drop mastat_dv  
gen year=2013
append using $path9\m1.dta
tab year 
capture drop fem
gen fem=(sex==2) 
tab poor_hlth 
sum age sex
keep if age >= 25 & age <= 60 
tab1 h_jl_rgsc h_jl_ns_sec
foreach pref in h_ a_h_ b_h_ c_h_ d_h_ {
  gen `pref'jl_rgsc10 = `pref'jl_rgsc*10 if `pref'jl_rgsc > 0
  gen `pref'jl_ns_sec10 = `pref'jl_ns_sec*10 
  } /* (device for analysis: ns_sec, rgsc are categorical but with non-int values) */
codebook h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3, compact
codebook *_h_jl_mcam *_h_jl_isei *_hh_ln_eqinc *_h_jl_ns_sec10 *_h_jl_rgsc10 *_ten3, compact
* Effect proportional scaling for the categorical measures, within reference years: 
sav $path9\temp.dta, replace 
foreach var in h_jl_ns_sec10 h_jl_rgsc10 ten3 { 
 use $path9\temp.dta , clear
 collapse (mean) s_`var'=poor_hlth, by(`var' year) 
 replace s_`var' = 1 - s_`var' /* rescale so that a positive score is positive */
 sav $path9\s_`var'.dta, replace
 foreach wav in a b c d {   
   use $path9\s_`var'.dta, clear 
   rename s_`var' `wav'_s_`var' 
   rename `var' `wav'_`var' 
   sav $path9\`wav'_s_`var'.dta, replace
   }
  } 
use $path9\temp.dta , clear
foreach var in h_jl_ns_sec10 h_jl_rgsc10 ten3 { 
  sort `var' year 
  merge m:1 `var' year using $path9\s_`var'.dta
  keep if _merge==1 | _merge==3
  drop _merge 
  foreach wav in a b c d { 
    sort `wav'_`var' year 
    merge m:1 `wav'_`var' year using $path9\`wav'_s_`var'.dta
    keep if _merge==1 | _merge==3
    drop _merge 
    } 
   }
* i.e. we've attached scale values (from 1995/2013 data) to all preceding codes in 4 preceding years



* => Make a cumulative score for each variable, based on weighted average of lag0-4 measures: 

sum *h_jl_mcam *h_jl_isei *hh_ln_eqinc *s_h_jl_ns_sec10 *s_h_jl_rgsc10 *s_ten3


foreach var in h_jl_mcam h_jl_isei hh_ln_eqinc s_h_jl_ns_sec10 s_h_jl_rgsc10 s_ten3 { 
 capture drop minscore
 egen minscore = rowmin(*`var') 
 sum minscore
 capture drop y_`var'
 gen y_`var' = `var' 
 replace y_`var'=y_`var' + 0.8*d_`var' if ~missing(d_`var')
 replace y_`var'=y_`var' + 0.8*minscore if missing(d_`var')
 replace y_`var'=y_`var' + 0.6*c_`var' if ~missing(c_`var')
 replace y_`var'=y_`var' + 0.6*minscore if missing(c_`var')
 replace y_`var'=y_`var' + 0.4*b_`var' if ~missing(b_`var')
 replace y_`var'=y_`var' + 0.4*minscore if missing(b_`var')
 replace y_`var'=y_`var' + 0.2*a_`var' if ~missing(a_`var')
 replace y_`var'=y_`var' + 0.2*minscore if missing(a_`var')
 pwcorr y_`var' `var' poor_hlth
 }
* Logic: Give higher positive scores for cumulative higher outcomes 

list *h_jl_mcam in 1/10
graph twoway scatter (h_jl_mcam y_h_jl_mcam), scheme(s1mono) 



capture drop nmiss
egen nmiss=rmiss(y_h_jl_mcam y_h_jl_isei y_hh_ln_eqinc y_s_h_jl_ns_sec10 y_s_h_jl_rgsc10 y_s_ten3)
tab nmiss /* to avoid any conflation with missing data, restrict analysis to non-missing on all measures*/


* Calculate the relevant year-specific means and standard deviations
foreach var in y_h_jl_mcam y_h_jl_isei y_hh_ln_eqinc y_s_h_jl_ns_sec10 y_s_h_jl_rgsc10 y_s_ten3 { 
  sum `var' if nmiss==0 & year==1995 [aw=xrwght]
  scalar m1995_`var'=r(mean)
  scalar sd1995_`var'=r(sd) 
  sum `var' if nmiss==0 & year==2013 [aw=xrwght]
  scalar m2013_`var'=r(mean)
  scalar sd2013_`var'=r(sd) 
  }
* (as discussed, these might also be derived from an external data source such as a larger sample)   

* construct the mean standardised measures, based on suitable means and standard deviations: 
foreach var in y_h_jl_mcam y_h_jl_isei y_hh_ln_eqinc y_s_h_jl_ns_sec10 y_s_h_jl_rgsc10 y_s_ten3 { 
  capture drop z_`var'
  gen z_`var' = (`var' - m1995_`var') / sd1995_`var'  if year==1995
  replace z_`var' = (`var' - m2013_`var') / sd2013_`var'  if year==2013
   }
codebook z_* age fem cohab notpars kids , compact   



* 1995 partial association statistics based upon mean standardised stratification measures: 
logit poor_hlth fem age cohab notpars kids if nmiss==0 & year==1995
scalar a_null= sqrt(e(r2_p)) 
foreach var in z_y_h_jl_mcam z_y_h_jl_isei z_y_hh_ln_eqinc z_y_s_h_jl_ns_sec10 z_y_s_h_jl_rgsc10 z_y_s_ten3  { 
  logit poor_hlth `var' fem age cohab notpars kids if nmiss==0 & year==1995 
  scalar s_`var'  = sqrt(e(r2_p)) - a_null
  }
matrix define stats1995 = [s_z_y_h_jl_mcam \ s_z_y_h_jl_isei \ s_z_y_hh_ln_eqinc \ s_z_y_s_h_jl_ns_sec10 \ s_z_y_s_h_jl_rgsc10 \ s_z_y_s_ten3 ] 

* 2013 partial association statistics based upon mean standardised stratification measures:
logit poor_hlth fem age cohab notpars kids if nmiss==0 & year==2013
scalar a_null= sqrt(e(r2_p)) 
foreach var in z_y_h_jl_mcam z_y_h_jl_isei z_y_hh_ln_eqinc z_y_s_h_jl_ns_sec10 z_y_s_h_jl_rgsc10 z_y_s_ten3  { 
  logit poor_hlth `var' fem age cohab notpars kids if nmiss==0 & year==2013
  scalar s_`var'  = sqrt(e(r2_p)) - a_null
  }
matrix define stats2013 = [s_z_y_h_jl_mcam \ s_z_y_h_jl_isei \ s_z_y_hh_ln_eqinc \ s_z_y_s_h_jl_ns_sec10 \ s_z_y_s_h_jl_rgsc10 \ s_z_y_s_ten3 ] 
matrix list stats2013


* Interaction parameters (for a selected term): 
foreach var in z_y_h_jl_mcam z_y_h_jl_isei z_y_hh_ln_eqinc z_y_s_h_jl_ns_sec10 z_y_s_h_jl_rgsc10 z_y_s_ten3  { 
  logit poor_hlth fem age cohab notpars kids i.year##c.`var' if nmiss==0 
  global modterm "2013.year#c.`var'" 
  scalar s_`var' = _b[$modterm] /* beta parameter */ 
  scalar s2_`var' = round((2 * ttail(e(N), abs(_b[$modterm] / _se[$modterm]))),0.001) /* p-value */
  scalar s3_`var' = round(_b[`var'], 0.0001) /* main effect */ 
 }
matrix define stats_int = [ s_z_y_h_jl_mcam \ s_z_y_h_jl_isei \ s_z_y_hh_ln_eqinc \ s_z_y_s_h_jl_ns_sec10 \ s_z_y_s_h_jl_rgsc10 \ s_z_y_s_ten3 ] 
matrix define stats_pval = [ s2_z_y_h_jl_mcam \ s2_z_y_h_jl_isei \ s2_z_y_hh_ln_eqinc \ s2_z_y_s_h_jl_ns_sec10 \ s2_z_y_s_h_jl_rgsc10 \ s2_z_y_s_ten3 ]
matrix define stats_meff = [ s3_z_y_h_jl_mcam \ s3_z_y_h_jl_isei \ s3_z_y_hh_ln_eqinc \ s3_z_y_s_h_jl_ns_sec10 \ s3_z_y_s_h_jl_rgsc10 \ s3_z_y_s_ten3 ]
matrix list stats_int
matrix list stats_pval


matrix define statsdif = stats2013 - stats1995 
matrix pctchn = J(6, 1, 0) /* code follows to divide elements systematically [from Stata website] */
forvalues i=1/6 { 
  matrix pctchn[`i', 1] = 100*round((statsdif[`i', 1] / stats1995[`i', 1]), 0.001)
  }
matrix list pctchn


matrix intdif = J(6, 1, 0) /*  */
forvalues i=1/6 { 
  matrix intdif[`i', 1] = 100*round((stats_int[`i', 1] / stats_meff[`i', 1]), 0.001)
  }
matrix list intdif /* i.e. percent increase in 2013 parameter compared to 1995 */


matrix define stats_2iv = [stats1995 , stats2013 , statsdif, pctchn, stats_meff, stats_int , stats_pval, intdif ]
matrix colnames stats_2iv = 1995 2013 dif pctchn meffpar intpar intpval intpct
matrix rownames stats_2iv = mcam isei lninc ns_sec rgsc ten3

matrix list stats_2iv
matrix list stats_2iii
matrix list stats_2ii
matrix list stats_2i


**

****************************************************************
***************************************************************************************
***************************************************************************************













**


***************************************************************************************
***************************************************************************************

** Table 3: Intersectional inequalities


** UKHLS, consider life-course stage, gender and ethnic group 

** (?Limit to household CAMSIS only) 


** Data prep: 

de *eth* using $path1b\xwavedat.dta

use pidp ethn_dv using $path1b\xwavedat.dta, clear
sort pidp
sav $path9\m1.dta, replace
use $path9\ukhls_2.dta, clear
isid pidp
sort pidp
merge 1:1 pidp using $path9\m1.dta
tab _merge
keep if _merge==1 | _merge==3 
numlabel _all, add
tab ethn_dv 
clonevar ethn2=ethn_dv if ethn_dv >= 1
recode ethn2 3=2 6=5 16=97 /* recodes for the smallest ethnic groups */
tab ethn2 
tab1 dvage nkids_dv mastat_dv hgbiof hgbiom
capture drop notpars 
gen notpars=(hgbiof==0 & hgbiom==0) 
drop hgbiof  hgbiom
capture drop kids
gen kids=(nkids_dv >= 1) 
drop nkids_dv
capture drop cohab
gen cohab=(mastat_dv==2 | mastat_dv==3 | mastat_dv==10) 
drop mastat_dv  
capture drop life3
gen life3=1 
replace life3=2 if (dvage > 20 & notpars==1 & (cohab==1 | kids==1)) ///
                       | (dvage > 28 & notpars==1) 
replace life3=3 if (dvage > 50) 
capture label drop life3 
label define life3 1 "Young and/or living with parents" 2 "Independent, with family or > 28" ///
                   3 "Aged 50+"
label values life3 life3 
tab life3 


* Analysis will explore these intersectional groups: 
tab1 sex life3 ethn2 
keep if ~missing(sex) & ~missing(life3) & ~missing(ethn2)
capture drop intid
egen intid = group(sex life3 ethn2) 
codebook sex life3 ethn2 intid , compact /* intid has 90 different categories */

**



*****
* Summarise the stratification effect on health, controlling in some ways for intersectionality..
  
foreach pref in h_  {
  gen `pref'jl_rgsc10 = `pref'jl_rgsc*10 if `pref'jl_rgsc > 0
  gen `pref'jl_ns_sec10 = `pref'jl_ns_sec*10 
  } /* (device for analysis: ns_sec, rgsc are categorical but with non-int values) */
codebook h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3, compact

capture drop nmiss
egen nmiss=rmiss(h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec10 h_jl_rgsc10 ten3)
tab nmiss /* to avoid any conflation with missing data, restrict analysis to non-missing on all measures*/


logit poor_hlth  if nmiss==0 & year==2013
scalar a_null= sqrt(e(r2_p)) 
logit poor_hlth h_jl_mcam if nmiss==0 & year==2013
di ( e(ll_0) - e(ll) ) / e(ll_0)  /* i.e. this is r2_p */


capture program drop margeff
program define margeff
 /* device to calculate marginal effect at camscore = 50 and 75 for 2 types of person given logit model */
 capture drop tempvar
 gen tempvar=h_jl_mcam 
 replace h_jl_mcam=50
 capture drop pred_pr
 predict pred_pr, fitted
 replace pred_pr = exp(pred_pr) / (1 + exp(pred_pr)) 
 sum pred_pr if sex==1 & dvage >= 30 & dvage <= 35 & ethn2==1  
 scalar b = r(mean) 
 sum pred_pr if sex==2 & dvage >= 45 & dvage <= 60 & ethn2==15
 scalar c = r(mean) 
 replace h_jl_mcam=75
 capture drop pred_pr
 predict pred_pr, fitted
 replace pred_pr = exp(pred_pr) / (1 + exp(pred_pr)) 
 sum pred_pr if sex==1 & dvage >= 30 & dvage <= 35 & ethn2==1  
 scalar d = r(mean) 
 sum pred_pr if sex==2 & dvage >= 45 & dvage <= 60 & ethn2==15
 scalar e = r(mean) 
 replace h_jl_mcam=tempvar
 drop tempvar 

end 


** Run the models: 

* 2013 cross-sectional: Partial r2 for each permutation: 
* No action 
melogit poor_hlth  if nmiss==0 & year==2013
scalar null = e(ll) 
melogit poor_hlth h_jl_mcam if nmiss==0 & year==2013
scalar s1= (null - e(ll) ) / null 
margeff
scalar s1b=b
scalar s1c=c 
scalar s1d=d
scalar s1e=e 

* Main effects 
melogit poor_hlth i.sex i.life3 i.ethn2 if nmiss==0 & year==2013
scalar null = e(ll) 
melogit poor_hlth i.sex i.life3 i.ethn2 h_jl_mcam if nmiss==0 & year==2013
scalar s2= (null - e(ll) ) / null
margeff
scalar s2b=b
scalar s2c=c 
scalar s2d=d
scalar s2e=e  

* Main effects plus 2-way interactions
melogit poor_hlth i.sex i.life3 i.ethn2 if nmiss==0 & year==2013
scalar null = e(ll) 
melogit poor_hlth i.sex##c.h_jl_mcam i.life3##c.h_jl_mcam i.ethn2##c.h_jl_mcam  if nmiss==0 & year==2013
scalar s3= (null - e(ll) ) / null
margeff
scalar s3b=b
scalar s3c=c 
scalar s3d=d
scalar s3e=e 


* Category random effects
melogit poor_hlth  if nmiss==0 & year==2013 ||intid:, 
scalar null = e(ll) 
melogit poor_hlth h_jl_mcam if nmiss==0 & year==2013 ||intid:, 
scalar s4= (null - e(ll) ) / null 
margeff
scalar s4b=b
scalar s4c=c 
scalar s4d=d
scalar s4e=e  

* Category random effect plus fixed part main effects and 2-way interactions
melogit poor_hlth i.sex i.life3 i.ethn2 if nmiss==0 & year==2013 ||intid:, 
scalar null = e(ll) 
melogit poor_hlth i.sex##c.h_jl_mcam i.life3##c.h_jl_mcam i.ethn2##c.h_jl_mcam  ///
       if nmiss==0 & year==2013   ||intid:, 
scalar s5= (null - e(ll) ) / null
margeff
scalar s5b=b
scalar s5c=c 
scalar s5d=d
scalar s5e=e 


* Within category standardisation 
capture drop strat_mean
capture drop strat_sd
capture drop z_h_jl_mcam
egen strat_mean=mean(h_jl_mcam), by(intid) 
egen strat_sd=sd(h_jl_mcam), by(intid) 
gen z_h_jl_mcam = ((h_jl_mcam - strat_mean) / strat_sd)*15  + 50 
* (Additional code swapping z and h scores, to ensure 'margeff' applies to the z score)
capture drop altvar
rename h_jl_mcam altvar
rename z_h_jl_mcam h_jl_mcam
melogit poor_hlth  if nmiss==0 & year==2013
scalar null = e(ll) 
melogit poor_hlth h_jl_mcam if nmiss==0 & year==2013
scalar s6 = (null - e(ll) ) / null 
margeff
scalar s6b=b
scalar s6c=c 
scalar s6d=d
scalar s6e=e 
rename h_jl_mcam z_h_jl_mcam
rename altvar h_jl_mcam 



matrix define stats2013 = [ s1 \ s2 \ s3 \ s4 \ s5 \ s6]
matrix define pr50_wm3035 = [ s1b \ s2b \ s3b \ s4b \ s5b \ s6b]
matrix define pr50_aw4560 = [ s1c \ s2c \ s3c \ s4c \ s5c \ s6c]
matrix define pr75_wm3035 = [ s1d \ s2d \ s3d \ s4d \ s5d \ s6d]
matrix define pr75_aw4560 = [ s1e \ s2e \ s3e \ s4e \ s5e \ s6e]

matrix define statsdif1 = pr50_wm3035  - pr75_wm3035 
matrix pctchn1 = J(6, 1, 0) /* code follows to divide elements systematically [from Stata website] */
forvalues i=1/6 { 
  matrix pctchn1[`i', 1] = 100*round((statsdif1[`i', 1] / pr50_wm3035[`i', 1]), 0.001)
  }
matrix list pctchn1

matrix define statsdif2 = pr50_aw4560  - pr75_aw4560 
matrix pctchn2 = J(6, 1, 0) /* code follows to divide elements systematically [from Stata website] */
forvalues i=1/6 { 
  matrix pctchn2[`i', 1] = 100*round((statsdif2[`i', 1] / pr50_aw4560[`i', 1]), 0.001)
  }
matrix list pctchn2

matrix define stats_3i = [stats2013 , pr50_wm3035 , pr75_wm3035, pr50_aw4560, pr75_aw4560 ,  pctchn1, pctchn2 ]
matrix colnames stats_3i = partr_2013 pr50_a pr75_a pr50_b pr75_b pctchn_a pctchn_b 
matrix rownames stats_3i = noint main main_int reffs reffs_int zscores

matrix list stats_3i

** 
 

************************






**************************************************

** 3ii) Longitudinal adaptation: repeating the analyses for (ii) and for (iv) as per table 2, 
*    but adding in intersectional controls as above: 




** Data prep: 

* BHPS 
de *rac* using $path1c\xwavedat.dta
use pid race using $path1c\xwavedat.dta, clear
sort pid 
sav $path9\m1.dta, replace 
use pid hid xrwght age sex h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 poor_hlth ///
      nkids mastat hgfno hgmno  ///
    *_h_jl_mcam *_h_jl_isei *_hh_ln_eqinc *_h_jl_ns_sec *_h_jl_rgsc *_ten3 ///  
     using $path9\bhps_2.dta, clear
sort pid
merge 1:1 pid using $path9\m1.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
tab1 hgfno hgmno nkids mastat
capture drop notpars 
gen notpars=(hgfno==0 & hgmno==0) 
drop hgfno hgmno
capture drop kids
gen kids=(nkids >= 1) 
drop nkids
capture drop cohab
gen cohab=(mastat==1 | mastat==2) 
drop mastat 
gen year=1995
numlabel _all, add
tab race
clonevar ethn2=race if race >= 1
recode ethn2 1=1 2/9=97  /* recode the BHPS minority groups to UKHLS code 97 ('any other') */
tab ethn2 
capture drop life3
gen life3=1 
replace life3=2 if (age > 20 & notpars==1 & (cohab==1 | kids==1)) ///
                       | (age > 28 & notpars==1) 
replace life3=3 if (age > 50) 
sav $path9\bh1.dta, replace
* UKHLS 
de *eth* using $path1b\xwavedat.dta
use pidp ethn_dv using $path1b\xwavedat.dta, clear
sort pidp
sav $path9\m1.dta, replace
use $path9\ukhls_2.dta, clear
isid pidp
sort pidp
merge 1:1 pidp using $path9\m1.dta
tab _merge
keep if _merge==1 | _merge==3 
numlabel _all, add
rename indinub_xw xrwght /* approximation: analysis will treat this weight as like BHPS 'xwght' */
tab ethn_dv 
clonevar ethn2=ethn_dv if ethn_dv >= 1
recode ethn2 3=2 6=5 16=97 /* recodes for the smallest ethnic groups */
tab ethn2 
tab1 dvage nkids_dv mastat_dv hgbiof hgbiom
capture drop notpars 
gen notpars=(hgbiof==0 & hgbiom==0) 
drop hgbiof  hgbiom
capture drop kids
gen kids=(nkids_dv >= 1) 
drop nkids_dv
capture drop cohab
gen cohab=(mastat_dv==2 | mastat_dv==3 | mastat_dv==10) 
drop mastat_dv  
capture drop life3
gen life3=1 
replace life3=2 if (dvage > 20 & notpars==1 & (cohab==1 | kids==1)) ///
                       | (dvage > 28 & notpars==1) 
replace life3=3 if (dvage > 50) 
capture label drop life3 
label define life3 1 "Young and/or living with parents" 2 "Independent, with family or > 28" ///
                   3 "Aged 50+"
label values life3 life3 
tab life3 
* Add BHPS
append using $path9\bh1.dta
tab year 
* Analysis will explore these intersectional groups: 
tab1 sex life3 ethn2 
keep if ~missing(sex) & ~missing(life3) & ~missing(ethn2)
capture drop intid
egen intid = group(sex life3 ethn2) 
codebook sex life3 ethn2 intid , compact /* intid has 90 different categories */
**


* => Make a cumulative longitudinal score for the stratification measures (linear) 
*   based on weighted average of lag0-4 measures: 

sum *h_jl_mcam *h_jl_isei *hh_ln_eqinc 


foreach var in h_jl_mcam h_jl_isei hh_ln_eqinc  { 
 capture drop minscore
 egen minscore = rowmin(*`var') 
 sum minscore
 capture drop y_`var'
 gen y_`var' = `var' 
 replace y_`var'=y_`var' + 0.8*d_`var' if ~missing(d_`var')
 replace y_`var'=y_`var' + 0.8*minscore if missing(d_`var')
 replace y_`var'=y_`var' + 0.6*c_`var' if ~missing(c_`var')
 replace y_`var'=y_`var' + 0.6*minscore if missing(c_`var')
 replace y_`var'=y_`var' + 0.4*b_`var' if ~missing(b_`var')
 replace y_`var'=y_`var' + 0.4*minscore if missing(b_`var')
 replace y_`var'=y_`var' + 0.2*a_`var' if ~missing(a_`var')
 replace y_`var'=y_`var' + 0.2*minscore if missing(a_`var')
 pwcorr y_`var' `var' poor_hlth
 }
* Logic: Give higher positive scores for cumulative higher outcomes 

list *h_jl_mcam in 1/10
graph twoway scatter (h_jl_mcam y_h_jl_mcam), scheme(s1mono) 


*****
capture drop nmiss
egen nmiss=rmiss(h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3)
tab nmiss /* to avoid any conflation with missing data, restrict analysis to non-missing on all measures*/

************
* Exercise: Summarise the stratification effect on health, controlling in some ways for intersectionality..




********************
** 3iia) No longitudinal adjustment (looking at strat*year interaction parameters) 

global modterm "h_jl_mcam"

* intersectionaly: no action 
melogit poor_hlth i.year##c.h_jl_mcam  if nmiss==0 
scalar s1 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s1b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s1c = _b[$modterm] /* main effect parameter */

* Main effects 
melogit poor_hlth i.sex i.life3 i.ethn2 i.year##c.h_jl_mcam if nmiss==0 
scalar s2 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s2b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s2c = _b[$modterm] /* main effect parameter */

* Main effects plus 2-way interactions
melogit poor_hlth i.sex##c.h_jl_mcam i.life3##c.h_jl_mcam i.ethn2##c.h_jl_mcam  ///
                  i.year##c.h_jl_mcam   if nmiss==0 
scalar s3 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s3b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s3c = _b[$modterm] /* main effect parameter */

* Category random effects
melogit poor_hlth i.year##c.h_jl_mcam if nmiss==0  ||intid:, 
scalar s4 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s4b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s4c = _b[$modterm] /* main effect parameter */  

* Category random effect plus fixed part main effects and 2-way interactions
melogit poor_hlth i.sex##c.h_jl_mcam i.life3##c.h_jl_mcam i.ethn2##c.h_jl_mcam  ///
       i.year##c.h_jl_mcam if nmiss==0    ||intid:, 
scalar s5 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s5b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s5c = _b[$modterm] /* main effect parameter */ 


* Within category standardisation 
capture drop strat_mean
capture drop strat_sd
capture drop z_h_jl_mcam
egen strat_mean=mean(h_jl_mcam), by(intid) 
egen strat_sd=sd(h_jl_mcam), by(intid) 
gen z_h_jl_mcam = ((h_jl_mcam - strat_mean) / strat_sd)*15  + 50 
melogit poor_hlth i.year##c.z_h_jl_mcam  if nmiss==0 
global modterm "z_h_jl_mcam"
scalar s6 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s6b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s6c = _b[$modterm] /* main effect parameter */


matrix define stats_int = [s1 \ s2 \ s3 \ s4 \ s5 \ s6  ]
matrix define stats_pval = [ s1b \ s2b \ s3b \ s4b \ s5b \ s6b  ]
matrix define stats_meff = [s1c \ s2c \ s3c \ s4c \ s5c \ s6c  ]
matrix list stats_int
matrix list stats_pval

matrix intdif = J(6, 1, 0) /*  */
forvalues i=1/6 { 
  matrix intdif[`i', 1] = 100*round((stats_int[`i', 1] / stats_meff[`i', 1]), 0.001)
  }
matrix list intdif /* i.e. percent increase in 2013 parameter compared to 1995 */


matrix define stats_3iia = [stats_meff, stats_int , stats_pval, intdif ]
matrix colnames stats_3iia = stats_meff stats_int  stats_pval intdif
matrix rownames stats_3iia = noint main main_int reffs reffs_int zscores

matrix list stats_3iia
matrix list stats_3i 



** 



*************************************
** 3iib) Adjustment for longitudinal context by standardisation within time period


* (Continuation on dataset above) 

* Calculate the relevant year-specific means and standard deviations
foreach var in h_jl_mcam  { 
  sum `var' if nmiss==0 & year==1995 [aw=xrwght]
  scalar m1995_`var'=r(mean)
  scalar sd1995_`var'=r(sd) 
  sum `var' if nmiss==0 & year==2013 [aw=xrwght]
  scalar m2013_`var'=r(mean)
  scalar sd2013_`var'=r(sd) 
  }
* (as discussed, these might also be derived from an external data source such as a larger sample)   
* construct the mean standardised measures, based on suitable means and standard deviations: 
foreach var in h_jl_mcam { 
  capture drop z_`var'
  gen z_`var' = (`var' - m1995_`var') / sd1995_`var'  if year==1995
  replace z_`var' = (`var' - m2013_`var') / sd2013_`var'  if year==2013
   }
   

** Derive statistics using these mean-standardised measures: 


global modterm "z_h_jl_mcam"

* intersectionaly: no action 
melogit poor_hlth i.year##c.$modterm  if nmiss==0 
scalar s1 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s1b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s1c = _b[$modterm] /* main effect parameter */

* Main effects 
melogit poor_hlth i.sex i.life3 i.ethn2 i.year##c.$modterm if nmiss==0 
scalar s2 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s2b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s2c = _b[$modterm] /* main effect parameter */

* Main effects plus 2-way interactions
melogit poor_hlth i.sex##c.$modterm i.life3##c.$modterm i.ethn2##c.$modterm  ///
                  i.year##c.$modterm   if nmiss==0 
scalar s3 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s3b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s3c = _b[$modterm] /* main effect parameter */

* Category random effects
melogit poor_hlth i.year##c.$modterm if nmiss==0  ||intid:, 
scalar s4 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s4b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s4c = _b[$modterm] /* main effect parameter */  

* Category random effect plus fixed part main effects and 2-way interactions
melogit poor_hlth i.sex##c.$modterm i.life3##c.$modterm i.ethn2##c.$modterm  ///
       i.year##c.$modterm if nmiss==0    ||intid:, 
scalar s5 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s5b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s5c = _b[$modterm] /* main effect parameter */ 


* Within category standardisation 
capture drop strat_mean
capture drop strat_sd
capture drop z_$modterm
egen strat_mean=mean($modterm), by(intid) 
egen strat_sd=sd($modterm), by(intid) 
gen z_$modterm = (($modterm - strat_mean) / strat_sd)*15  + 50 
melogit poor_hlth i.year##c.z_$modterm  if nmiss==0 
scalar s6 = _b[2013.year#c.z_$modterm] /* beta parameter */ 
scalar s6b = (2 * ttail(e(N), abs(_b[2013.year#c.z_$modterm] / _se[2013.year#c.z_$modterm]))) /* p-value */ 
scalar s6c = _b[z_$modterm] /* main effect parameter */


matrix define stats_int = [s1 \ s2 \ s3 \ s4 \ s5 \ s6  ]
matrix define stats_pval = [ s1b \ s2b \ s3b \ s4b \ s5b \ s6b  ]
matrix define stats_meff = [s1c \ s2c \ s3c \ s4c \ s5c \ s6c  ]
matrix list stats_int
matrix list stats_pval

matrix intdif = J(6, 1, 0) /*  */
forvalues i=1/6 { 
  matrix intdif[`i', 1] = 100*round((stats_int[`i', 1] / stats_meff[`i', 1]), 0.001)
  }
matrix list intdif /* i.e. percent increase in 2013 parameter compared to 1995 */


matrix define stats_3iib = [stats_meff, stats_int , stats_pval, intdif ]
matrix colnames stats_3iib = stats_meff stats_int  stats_pval intdif
matrix rownames stats_3iib = noint main main_int reffs reffs_int zscores

matrix list stats_3iib
matrix list stats_3iia
matrix list stats_3i 









************************************************************
*** 3iic) Trajectory based summary of stratification position

** Derive statistics, using the cumulative statification score: 

bysort year: summarize h_jl_mcam y_h_jl_mcam 
* For consistency, should make a within-time standardisation here: 
capture drop z_y_jl_mcam 
summarize h_jl_mcam [aweight=xrwght] if year==1995
scalar ym_1995=r(mean) 
scalar ysd_1995=r(sd) 
summarize h_jl_mcam [aweight=xrwght] if year==2013
scalar ym_2013=r(mean) 
scalar ysd_2013=r(sd) 
gen z_y_jl_mcam = (h_jl_mcam - ym_1995) / ysd_1995 if year==1995
replace z_y_jl_mcam = (h_jl_mcam - ym_2013) / ysd_2013 if year==2013
bysort year: summarize h_jl_mcam y_h_jl_mcam z_y_jl_mcam



global modterm "z_y_h_jl_mcam"

* intersectionaly: no action 
melogit poor_hlth i.year##c.$modterm  if nmiss==0 
scalar s1 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s1b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s1c = _b[$modterm] /* main effect parameter */

* Main effects 
melogit poor_hlth i.sex i.life3 i.ethn2 i.year##c.$modterm if nmiss==0 
scalar s2 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s2b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s2c = _b[$modterm] /* main effect parameter */

* Main effects plus 2-way interactions
melogit poor_hlth i.sex##c.$modterm i.life3##c.$modterm i.ethn2##c.$modterm  ///
                  i.year##c.$modterm   if nmiss==0 
scalar s3 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s3b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s3c = _b[$modterm] /* main effect parameter */

* Category random effects
melogit poor_hlth i.year##c.$modterm if nmiss==0  ||intid:, 
scalar s4 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s4b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s4c = _b[$modterm] /* main effect parameter */  

* Category random effect plus fixed part main effects and 2-way interactions
melogit poor_hlth i.sex##c.$modterm i.life3##c.$modterm i.ethn2##c.$modterm  ///
       i.year##c.$modterm if nmiss==0    ||intid:, 
scalar s5 = _b[2013.year#c.$modterm] /* beta parameter */ 
scalar s5b = (2 * ttail(e(N), abs(_b[2013.year#c.$modterm] / _se[2013.year#c.$modterm]))) /* p-value */ 
scalar s5c = _b[$modterm] /* main effect parameter */ 


* Within category standardisation 
capture drop strat_mean
capture drop strat_sd
capture drop z_$modterm
egen strat_mean=mean($modterm), by(intid) 
egen strat_sd=sd($modterm), by(intid) 
gen z_$modterm = (($modterm - strat_mean) / strat_sd)*15  + 50 
melogit poor_hlth i.year##c.z_$modterm  if nmiss==0 
scalar s6 = _b[2013.year#c.z_$modterm] /* beta parameter */ 
scalar s6b = (2 * ttail(e(N), abs(_b[2013.year#c.z_$modterm] / _se[2013.year#c.z_$modterm]))) /* p-value */ 
scalar s6c = _b[z_$modterm] /* main effect parameter */


matrix define stats_int = [s1 \ s2 \ s3 \ s4 \ s5 \ s6  ]
matrix define stats_pval = [ s1b \ s2b \ s3b \ s4b \ s5b \ s6b  ]
matrix define stats_meff = [s1c \ s2c \ s3c \ s4c \ s5c \ s6c  ]
matrix list stats_int
matrix list stats_pval

matrix intdif = J(6, 1, 0) /*  */
forvalues i=1/6 { 
  matrix intdif[`i', 1] = 100*round((stats_int[`i', 1] / stats_meff[`i', 1]), 0.001)
  }
matrix list intdif /* i.e. percent increase in 2013 parameter compared to 1995 */


matrix define stats_3iic = [stats_meff, stats_int , stats_pval, intdif ]
matrix colnames stats_3iic = stats_meff stats_int  stats_pval intdif
matrix rownames stats_3iic = noint main main_int reffs reffs_int zscores

matrix list stats_3iic
matrix list stats_3iib
matrix list stats_3iia
matrix list stats_3i 



*********************************************************************
****************************************************************

