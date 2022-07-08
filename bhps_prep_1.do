


** Called by 'analytical_commands*.do'

** Derive stratification measures on the BHPS (analysis: wave e) 

**



** Prep: Job files
de using $file5c /* features CAMSIS, NS-SEC, RGSC to soc90 */
de using $file5b /*isco88 and isei */

use $file5c, clear
rename soc90 jbsoc
keep jbsoc ukempst mcamsis fcamsis ns_sec rgsc 
isid  jbsoc ukempst
sort  jbsoc ukempst
saveold $path9\m1.dta, replace
rename jbsoc jlsoc 
rename mcamsis jl_mcam
rename fcamsis jl_fcam
rename ns_sec jl_ns_sec
rename rgsc jl_rgsc
sort jlsoc ukempst 
saveold $path9\m2.dta, replace 

use $file5b, clear
rename isco88 jbisco
isid jbisco
sort jbisco
saveold $path9\m3.dta, replace
rename jbisco jlisco
sort jlisco
rename isei jl_isei 
saveold $path9\m4.dta, replace

****




** Compile the BHPS occupational data: 
********

foreach wav in a b c d e f g h i j k l m n o p q r { 
de pid `wav'hid   `wav'sex `wav'age ///
    `wav'jbisco `wav'mrjisco `wav'jbsoc `wav'mrjsoc  ///
    `wav'jbhrs `wav'jshrs ///
        `wav'hlghq1   using $path1c\`wav'indresp.dta
 }


foreach wav in a b c d e f g h i j k l m n o p q r  { 
 use pid `wav'hid   `wav'sex `wav'age ///
    `wav'jbisco `wav'mrjisco `wav'jbsoc `wav'mrjsoc  ///
    `wav'jbhrs `wav'jshrs ///
        `wav'hlghq1     using $path1c\`wav'indresp.dta, clear
 summarize 
 renpfix `wav'
 capture rename id pid 
 do $path2d\casoc_isco_2.do
 rename mrjisco jlisco88
 rename mrjsoc jlsoc
 iscoca, isco(jlisco88)
 destring jlisco88, replace
 rename jbisco jbisco88
 iscoca, isco(jbisco88)
 destring jbisco88, replace
 replace jlisco88 = jbisco88 if (jlisco88 < 0 | missing(jlisco88)) & jbisco88 >= 1 & jbisco88 <= 10000
 replace jlsoc = jbsoc if (jlsoc < 0 | missing(jlsoc)) & jbsoc >= 1 & jbsoc <= 10000 
 do $path2d\ukempst_generator.do /* file also from www.geode.stir.ac.uk */ 
 get_ukempst_2 `wav' ukempst ${path1c} /* emp status for most recent job */ 
 gen wave="`wav'" 
 keep pid wave jlisco88 jlsoc ukempst /* contains current or last job in this wave */
 saveold $path9\bh_`wav'.dta, replace
  }


use $path9\bh_a.dta, clear
foreach wav in b c d e f g h i j k l m n o p q r { 
 append using $path9\bh_`wav'.dta
  } 
tab wave 
gen year = wave 
global inputvar "year"
do $path2d\letters2numbers_1.do
destring $inputvar, replace
tab year 


gsort  +pid +year 
* Code to impute a previous occ value, if a current value of last occ is missing
*    but a previous valid occ value exists
list pid year jlsoc  in 1/50
sum jlsoc
gen jlsoc_orig = jlsoc
forvalues val = 1(1)20 {  
    replace jlsoc = jlsoc[_n - `val']     if pid==pid[_n - `val'] &   ///
           (jlsoc < 0 | jlsoc==9999) & (jlsoc[_n - `val'] > 0 & jlsoc[_n - `val'] < 9999  ) 
 }
sum jlsoc_orig  jlsoc
list pid year jlsoc jlsoc_orig in 600/700 
* Repeat for ISCO 
gen jlisco88_orig = jlisco88
forvalues val = 1(1)20 {  
    replace jlisco88 = jlisco88[_n - `val']     if pid==pid[_n - `val'] &   ///
           (jlisco88 < 0 | jlisco88==9999) & (jlisco88[_n - `val'] > 0 & jlisco88[_n - `val'] < 9999  ) 
 }
sum jlisco88_orig  jlisco88
list pid year jlisco88 jlisco88_orig in 600/700 


*
gsort  +pid -year 
capture drop first 
capture drop valocc
gen valocc=jlsoc >= 1 & jlsoc <= 10000 /* indicates if a valid code in jlsoc */
gen first=valocc 
replace first=0 if pid==pid[_n-1] & valocc[_n-1]==1
list pid year jlsoc valocc first in 1/50 /* 'first' indicates more recent record with valid occ */
keep pid year jlsoc jlisco88 ukempst  first 
sort pid year
isid pid year
codebook, compact 
saveold $path9\m_jl_all.dta, replace /* last job, by pidp and year */

***********




************
* Use wave a-r data (for wave-specific individual level data): 

foreach wav in a b c d e f g h i j k l m n o p q r { 
de pid `wav'hid   `wav'sex `wav'age ///
    `wav'jbisco `wav'mrjisco `wav'jbsoc `wav'mrjsoc  ///
    `wav'jbgold `wav'jbhrs `wav'jshrs ///
        `wav'hlghq1   using $path1c\`wav'indresp.dta
 }


foreach wav in a b c d e f g h i j k l m n o p q r { 
 use pid `wav'hid   `wav'sex `wav'age ///
    `wav'jbisco `wav'mrjisco `wav'jbsoc `wav'mrjsoc  ///
    `wav'jbgold `wav'jbhrs `wav'jshrs ///
        `wav'hlghq1   using $path1c\`wav'indresp.dta, clear
 summarize 
 renpfix `wav'
 capture rename id pid 
 do $path2d\casoc_isco_2.do
 rename mrjsoc jlsoc
 rename mrjisco jlisco
 iscoca, isco(jlisco)
 destring jlisco, replace
 iscoca, isco(jbisco)
 destring jbisco, replace
 numlabel _all, add
 summarize
 gen wave="`wav'"
 sav $path9\m_`wav'.dta, replace
 }
use $path9\m_a.dta, clear
foreach wav in b c d e f g h i j k l m n o p q r { 
  append using $path9\m_`wav'.dta
   }
tab wave
*
gen year = wave 
global inputvar "year"
do $path2d\letters2numbers_1.do
destring $inputvar, replace
tab year /* modal year (-1990) for this wave */
sort pid year 
merge 1:1 pid year using $path9\m_jl_all.dta /* bring in last job data from prep file */
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
sum jbsoc if jbsoc > 0 /* 132k with valid current job */
sum jlsoc if jlsoc > 0 /* 201k  with a valid last job, based on cumulative files */
sum jbisco if jbisco > 0 /* 135k with valid current job ISCO88 */
sum jlisco if jlisco > 0 /* 203k with valid last job ISCO88, based on cumulative files */
graph twoway (scatter jbsoc jlsoc if jlsoc > 0, mcolor(red*0.5%25) jitter(1) ) ///
   (scatter jbisco jlisco if jlisco > 0, mcolor(green*0.3%20) jitter(1)) ///
    , scheme(s1mono) legend(order(1 2) label(1 "SOC00") label(2 "ISCO88")) 
 /* OK: all last occs are either the same value as current, or have current as missing */
*
* Bring in occupation-based derived measures: 
sort jbsoc ukempst 
merge m:1 jbsoc ukempst using $path9\m1.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
sort jlsoc ukempst 
merge m:1 jlsoc ukempst using $path9\m2.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
sort jbisco 
merge m:1 jbisco using $path9\m3.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
sort jlisco 
merge m:1 jlisco using $path9\m4.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
*

codebook, compact
correlate mcamsis fcamsis isei 
tab ns_sec rgsc, V
tab ns_sec jbgold, V /* fair overlap, but not particularly consistent */
tab jl_ns_sec jl_rgsc, V
pwcorr mcamsis fcamsis isei jl_mcam jl_fcam jl_isei rgsc jl_rgsc, obs 
*  


** Household measures (use dominance criteria prioritising working time): 
capture drop wk_hrs
gen wk_hrs = jbhrs 
replace wk_hrs = jshrs if jbhrs <= 0 & jshrs >= 0 
tab wk_hrs
gsort +year +hid +pid 
foreach var in jlsoc jbsoc jlisco jbisco mcamsis fcamsis isei jl_mcam jl_fcam jl_isei rgsc jl_rgsc ns_sec jl_ns_sec  { 
  capture drop h_`var' 
  capture drop h_nmis 
  gen h_nmiss=`var' >= 1 & `var' <= 10000 /* (by chance, these codes demarcate valid for all vars)  */
  gsort +year +hid -h_nmiss -wk_hrs -mcamsis
  capture drop ht_`var' 
  bysort year hid: gen ht_`var' = `var' if _n==1 
  egen h_`var'=max(ht_`var'), by(year hid) 
  drop ht_`var'
  drop h_nmis
  }

list hid pid wk_hrs jbsoc h_jbsoc ns_sec h_ns_sec in 1/50  

*
pwcorr h_mcamsis h_isei h_jl_mcam h_jl_isei h_rgsc h_jl_rgsc, obs 

list hid pid wk_hrs isei h_isei jl_isei h_jl_isei jlsoc h_jlsoc in 1/50  

tab h_jl_ns_sec, missing /* typically hhld level plus last job info gives near complete coverage */
**  

* This file has full set of indv and hhld level UKHLS occupation-based measures (waves A-E) 

de
sort pid year 
isid pid year
saveold $path2a\bhps_occs_a2r_1.dta, replace 

**

de using $path2a\bhps_occs_a2r_1.dta

***


*********************************************************

