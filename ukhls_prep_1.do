


** Called by 'analytical_commands*.do'

** Derive stratification measures on the UKHLS (analysis: wave e) 

**



** Prep: Job files
de using $file5a /* features CAMSIS, NS-SEC, RGSC */
de using $file5b

use $file5a, clear
rename ukempst jbes2000 
rename soc2000 jbsoc00
keep jbsoc00 jbes2000 mcamsis fcamsis ns_sec rgsc 
isid  jbsoc00 jbes2000
sort  jbsoc00 jbes2000
saveold $path9\m1.dta, replace
rename jbsoc00 jlsoc00 
rename mcamsis jl_mcam
rename fcamsis jl_fcam
rename ns_sec jl_ns_sec
rename rgsc jl_rgsc
rename jbes2000 jles2000
sort jlsoc00 jles2000 
saveold $path9\m2.dta, replace 

use $file5b, clear
rename isco88 jbisco88
isid jbisco88
sort jbisco88
saveold $path9\m3.dta, replace
rename jbisco88 jlisco88
sort jlisco88
rename isei jl_isei 
saveold $path9\m4.dta, replace

*


** Prelim: Get last job data from earlier UKHLS waves (and from bhps if necessary)
* UKHLS last job data: 
foreach wav in a b c d e { 
 use pid* `wav'_jbisco88 `wav'_jlisco88 `wav'_jbsoc00 `wav'_jlsoc00 `wav'_jbes2000 ///
       using $path1a\`wav'_indresp_protect.dta, clear 
 renpfix `wav'_
 capture gen long pid = .m /* for wave 1 only, makes BHPS pid as missing */
 replace jlisco88 = jbisco88 if (jlisco88 < 0 | missing(jlisco88)) & jbisco88 >= 1 & jbisco88 <= 10000
 replace jlsoc00 = jbsoc00 if (jlsoc00 < 0 | missing(jlsoc00)) & jbsoc00 >= 1 & jbsoc00 <= 10000 
 rename jbes2000 jles2000 
 recode jles2000 -9/0=0 
 gen wave="`wav'" 
 keep pidp pid wave jlisco88 jlsoc00 jles2000 /* contains current or last job in this wave */
 saveold $path9\m_`wav'.dta, replace
 }

* BHPS, last job data (only for waves when when soc 2000 is available): 
foreach wav in k l m n o p q r { 
  use pid `wav'jbsoc00 `wav'jlsoc00  `wav'jbisco `wav'mrjisco   using $path1c\`wav'indresp.dta, clear
 renpfix `wav'
 capture rename id pid 
 do $path2d\casoc_isco_2.do
 rename mrjisco jlisco88
 iscoca, isco(jlisco88)
 destring jlisco88, replace
 rename jbisco jbisco88
 iscoca, isco(jbisco88)
 destring jbisco88, replace
 replace jlisco88 = jbisco88 if (jlisco88 < 0 | missing(jlisco88)) & jbisco88 >= 1 & jbisco88 <= 10000
 replace jlsoc00 = jbsoc00 if (jlsoc00 < 0 | missing(jlsoc00)) & jbsoc00 >= 1 & jbsoc00 <= 10000 
 do $path2d\ukempst_generator.do /* file also from www.geode.stir.ac.uk */ 
 get_ukempst_2 `wav' jles2000 ${path1c} /* emp status for most recent job */ 
 gen wave="b_`wav'" 
 keep pid wave jlisco88 jlsoc00 jles2000 /* contains current or last job in this wave */
 saveold $path9\bh_`wav'.dta, replace
  }


use $path9\m_a.dta, clear
foreach wav in b c d e { 
 append using $path9\m_`wav'.dta
  } 
foreach wav in k l m n o p q r { 
 append using $path9\bh_`wav'.dta
  } 
tab wave 
gen year = wave 
global inputvar "year"
do $path2d\letters2numbers_ukhls_bhps_1.do
destring $inputvar, replace
tab year 
sum pidp pid /* cases from the BHPS have pid but not pidp */
sav $path9\m_1.dta, replace
keep if ~missing(pid) & pid ~= -8  
collapse (min) pidp_d=pidp, by(pid) 
sort pid 
sav $path9\m_2.dta, replace
use $path9\m_1.dta, clear
sort pid 
merge m:1 pid using $path9\m_2.dta
tab _merge /* i.e. distributes ukhls pidps across all available BHPS pids */
sum pidp pid pidp_d 
replace pidp=pidp_d if missing(pidp) /* for BHPS-origin cases who are in UKHLS, assigns the appropriate pidp */
replace pidp=pid*1000 if missing(pidp) /* for BHPS cases who are not in UKHLS, substitutes pidp with pid*1000 (multiply by 1000 to avoid equal values)  */
sort pidp year 
list year pidp pid pidp_d in 1/50 
list year pidp pid pidp_d in 100000/100050 
list year pidp pid pidp_d in 300000/300050 
isid pidp year

gsort  +pidp +year 
* Code to impute a previous occ value, if a current value of last occ is missing
*    but a previous valid occ value exists
list pidp year jlsoc00  in 1/50
sum jlsoc00 
gen jlsoc00_orig = jlsoc00
forvalues val = 1(1)20 {  
    replace jlsoc00 = jlsoc00[_n - `val']     if pidp==pidp[_n - `val'] &   ///
           (jlsoc00 < 0 | jlsoc00==9999) & (jlsoc00[_n - `val'] > 0 & jlsoc00[_n - `val'] < 9999  ) 
 }
sum jlsoc00_orig  jlsoc00
list pidp year jlsoc00 jlsoc00_orig in 600/700 /* e.g. cases 639-43 illustrate intended behaviour */
* Repeat for ISCO 
gen jlisco88_orig = jlisco88
forvalues val = 1(1)20 {  
    replace jlisco88 = jlisco88[_n - `val']     if pidp==pidp[_n - `val'] &   ///
           (jlisco88 < 0 | jlisco88==9999) & (jlisco88[_n - `val'] > 0 & jlisco88[_n - `val'] < 9999  ) 
 }
sum jlisco88_orig  jlisco88
list pidp year jlisco88 jlisco88_orig in 600/700 /* e.g. cases 639-43 illustrate intended behaviour */


*
gsort  +pidp -year 
capture drop first 
capture drop valocc
gen valocc=jlsoc00 >= 1 & jlsoc00 <= 10000 /* indicates if a valid code in jlsoc00 */
gen first=valocc 
replace first=0 if pidp==pidp[_n-1] & valocc[_n-1]==1
list pidp year jlsoc00 valocc first in 1/50 /* 'first' indicates more recent record with valid occ */
keep pidp year jlsoc00 jlisco88 jles2000  first 
sort pidp year
isid pidp year
codebook, compact 
saveold $path9\m_jl_all.dta, replace /* last job, by pidp and year */
keep if first==1
summarize
keep pidp year jlsoc00 jlisco88 jles2000  
saveold $path9\m_jl_ab.dta, replace  /* last job, up to as far as the current wave */
**




************
* Use wave a-e data: 

foreach wav in a b c d e { 
de pidp `wav'_hidp   `wav'_sex `wav'_dvage ///
    `wav'_jbisco88 `wav'_jlisco88 `wav'_jbsoc00 `wav'_jlsoc00 `wav'_jbes2000 ///
    `wav'_jbnssec8_dv `wav'_jbhrs `wav'_jshrs ///
        `wav'_scghq1_dv   using $path1a\`wav'_indresp_protect.dta
 }


foreach wav in a b c d e { 
 use pidp `wav'_hidp  `wav'_sex `wav'_dvage ///
    `wav'_jbisco88  `wav'_jbsoc00 `wav'_jlsoc00  `wav'_jbes2000 `wav'_jbnssec8_dv `wav'_jbhrs `wav'_jshrs ///
        `wav'_scghq1_dv    using $path1a\`wav'_indresp_protect.dta, clear
 summarize 
 renpfix `wav'_
 numlabel _all, add
 summarize
 tab jbes2000
 recode jbes2000 -9/-1=0 
 rename jlsoc00 jlsoc00_w /* this will be the wave specific value for jlsoc00 */
 gen wave="`wav'"
 sav $path9\m_`wav'.dta, replace
 }
use $path9\m_a.dta, clear
foreach wav in b c d e { 
  append using $path9\m_`wav'.dta
   }
tab wave
*
gen year = wave 
global inputvar "year"
do $path2d\letters2numbers_ukhls_bhps_1.do
destring $inputvar, replace
tab year /* modal year for this wave */
sort pidp year 
merge 1:1 pidp year using $path9\m_jl_all.dta /* bring in last job data from prep file */
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
sum jbsoc00 if jbsoc00 > 0 /* 139k (31k in b) with valid current job */
sum jlsoc00 if jlsoc00 > 0 /* 214k (47k in b) with a valid last job, based on cumulative files */
sum jbisco88 if jbisco88 > 0 /* 137k (30k in b) with valid current job ISCO88 */
sum jlisco88 if jlisco88 > 0 /* 215k (47k in b) with valid last job ISCO88, based on cumulative files */
sum jlsoc00_w if jlsoc00_w > 0 /* 18k (751 in b) valid last jobs (SOC) in year specific files */
graph twoway (scatter jbsoc00 jlsoc00 if jlsoc00 > 0, mcolor(red*0.5%25) jitter(1) ) ///
   (scatter jbisco88 jlisco88 if jlisco88 > 0, mcolor(green*0.3%20) jitter(1)) ///
    , scheme(s1mono) legend(order(1 2) label(1 "SOC00") label(2 "ISCO88")) 
 /* OK: all last occs are either the same value as current, or have current as missing */
*
* Bring in occupation-based derived measures: 
sort jbsoc00 jbes2000 
merge m:1 jbsoc00 jbes2000 using $path9\m1.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
sort jlsoc00 jles2000 
merge m:1 jlsoc00 jles2000 using $path9\m2.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
sort jbisco88 
merge m:1 jbisco88 using $path9\m3.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
sort jlisco88 
merge m:1 jlisco88 using $path9\m4.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
*

codebook, compact
correlate mcamsis fcamsis isei 
tab ns_sec rgsc, V
tab ns_sec jbnssec8, V /* data corresponds (!) */
tab jl_ns_sec jl_rgsc, V
pwcorr mcamsis fcamsis isei jl_mcam jl_fcam jl_isei rgsc jl_rgsc, obs 
* 30k with current job; 44k with current or last job 


** Household measures (use dominance criteria prioritising working time): 
capture drop wk_hrs
gen wk_hrs = jbhrs 
replace wk_hrs = jshrs if jbhrs <= 0 & jshrs >= 0 
tab wk_hrs
gsort +year +hidp +pidp 
foreach var in jlsoc00 jbsoc00 jlisco88 jbisco88 mcamsis fcamsis isei jl_mcam jl_fcam jl_isei rgsc jl_rgsc ns_sec jl_ns_sec  { 
  capture drop h_`var' 
  capture drop h_nmis 
  gen h_nmiss=`var' >= 1 & `var' <= 10000 /* (by chance, these codes demarcate valid for all vars)  */
  gsort +year +hidp -h_nmiss -wk_hrs -mcamsis
  capture drop ht_`var' 
  bysort year hidp: gen ht_`var' = `var' if _n==1 
  egen h_`var'=max(ht_`var'), by(year hidp) 
  drop ht_`var'
  drop h_nmis
  }

list hidp pidp wk_hrs jbsoc00 h_jbsoc00 ns_sec h_ns_sec in 1/50  

*
pwcorr h_mcamsis h_isei h_jl_mcam h_jl_isei h_rgsc h_jl_rgsc, obs 

list hidp pidp wk_hrs isei h_isei jl_isei h_jl_isei jlsoc00 h_jlsoc00 in 1/50  

tab h_jl_ns_sec, missing /* typically hhld level plus last job info gives near complete coverage */
**  

* This file has full set of indv and hhld level UKHLS occupation-based measures (waves A-E) 

de
sort pidp year 
isid pidp year
saveold $path2a\ukhls_occs_a2e_1.dta, replace 

**

de using $path2a\ukhls_occs_a2e_1.dta

***


*********************************************************


