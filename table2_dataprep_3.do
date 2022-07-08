

** Called by 'analyticall_commands*.do '

** Data prep for Table 2 analysis 

********************************************************



** UKHLS 2015 outcome data : 
de e_hidp e_tenure_dv e_fihhmngrs_dv e_hhsize e_ieqmoecd_dv e_nkids_dv  ///
     using $path1b\e_hhresp.dta 
de pidp e_hidp   e_sex e_dvage e_fimngrs_dv e_*qfhigh_dv e_mastat_dv  e_hgbiof e_hgbiom e_indinub_xw  ///
           e_scghq1_dv e_scsf1 e_arts2freq using $path1b\e_indresp.dta 
*
use e_hidp e_tenure_dv e_fihhmngrs_dv e_hhsize e_ieqmoecd_dv e_nkids_dv   ///
     using $path1b\e_hhresp.dta , clear 
renpfix e_
sort hidp
sav $path9\m1.dta, replace
use pidp e_hidp   e_sex e_dvage e_fimngrs_dv e_*qfhigh_dv e_mastat_dv e_hgbiof e_hgbiom e_indinub_xw ///
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
*
sum fihhmngrs_dv hhsize ieqmoecd_dv
de fihhmngrs_dv hhsize ieqmoecd_dv
graph matrix fihhmngrs_dv ieqmoecd_dv hhsize if ieqmoecd_dv >= 1 & fihhmngrs_dv > 0 & fihhmngrs_dv < 50000 
capture drop hh_ln_eqinc 
gen hh_ln_eqinc = ln(fihhmngrs_dv / ieqmoecd_dv) if (ieqmoecd_dv >= 1 & fihhmngrs_dv > 0 & fihhmngrs_dv < 50000)

tab scsf1 
capture drop poor_hlth
gen poor_hlth=(scsf1==4 | scsf1==5) if (scsf1 >= 1 & scsf1 <= 5) 
correlate poor_hlth scghq1_dv if scghq1_dv >= 0 
* Measures in 2015: 
codebook mcamsis isei hh_ln_eqinc ns_sec rgsc ten3 poor_hlth, compact
sav $path9\ukhls_1.dta, replace 




**********************************************************************



**********************************************************************


** BHPS 1995 outcome data: 
de ehid etenure efihhmn ehhsize efieqfca enkids  ///
     using $path1c\ehhresp.dta 
de pid ehid   esex eage emastat exrwght efimn eqfedhi ehgfno ehgmno ///
           ehlghq1 ehlstat using $path1c\eindresp.dta 
*
use ehid etenure efihhmn ehhsize efieqfca enkids  ///
     using $path1c\ehhresp.dta , clear 
renpfix e
sort hid
sav $path9\m1.dta, replace
use pid ehid   esex eage emastat exrwght efimn eqfedhi ehgfno ehgmno ///
           ehlghq1 ehlstat using $path1c\eindresp.dta 
renpfix e
sort hid
merge m:1 hid using $path9\m1.dta 
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
capture drop year 
gen year=5
sort pid year
isid pid year
merge 1:1 pid year using $path2a\bhps_occs_a2r_1.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
numlabel _all, add 

tab tenure 
capture drop ten3 
gen ten3=tenure
recode ten3 1/2=1 5/8=3 3/4=2 *=.m 
capture label drop ten3l
label define ten3l 1 "Owner-occupier" 2 "Private rented" 3 "Social rented"
label values ten3 ten3l
tab ten3 
*
sum fihhmn hhsize fieqfca
de fihhmn hhsize fieqfca
graph matrix fihhmn hhsize fieqfca if fieqfca >= 0 & fihhmn > 0 & fihhmn < 50000 
capture drop hh_ln_eqinc 
gen hh_ln_eqinc = ln(fihhmn / fieqfca ) if (fieqfca  >= 0 & fihhmn > 0 & fihhmn < 50000)

tab hlstat
capture drop poor_hlth
gen poor_hlth=(hlstat==3 | hlstat==4 | hlstat==5) if (hlstat >= 1 & hlstat <= 5) 
correlate poor_hlth hlghq1 if hlghq1 >= 0 
* Measures in 1995: 
codebook mcamsis isei hh_ln_eqinc ns_sec rgsc ten3 poor_hlth, compact
sav $path9\bhps_1.dta, replace 

** -> derive stats for summary association patterns...


********

**********************************************************************






*************************

*** UKHLS, for trajectories

** Starting from wave 3, 2013, construct wide-format 
** data file with up to 4 previous years of stratification measures aside from current
foreach wav in a b c d  { 
 use `wav'_hidp `wav'_tenure_dv `wav'_fihhmngrs_dv `wav'_ieqmoecd_dv   ///
     using $path1b\`wav'_hhresp.dta , clear 
 sort `wav'_hidp
 sav $path9\m1.dta, replace
 use pidp `wav'_hidp  using $path1b\`wav'_indresp.dta 
 sort `wav'_hidp
 merge m:1 `wav'_hidp using $path9\m1.dta 
 tab _merge
 keep if _merge==1 | _merge==3 
 drop _merge
 gen wave="`wav'"
 sort pidp wave
 isid pidp wave
 merge 1:1 pidp wave using $path2a\ukhls_occs_a2e_1.dta
 tab _merge
 keep if _merge==1 | _merge==3 
 drop _merge
 numlabel _all, add 
 capture drop hh_ln_eqinc 
 gen hh_ln_eqinc = ln(`wav'_fihhmngrs_dv / `wav'_ieqmoecd_dv) if (`wav'_ieqmoecd_dv >= 1 & `wav'_fihhmngrs_dv > 0 & `wav'_fihhmngrs_dv < 50000)
 capture drop ten3 
 gen ten3=`wav'_tenure_dv
 recode ten3 1/2=1 3/4=3 5/7=2 *=.m 
 capture label drop ten3l
 label define ten3l 1 "Owner-occupier" 2 "Private rented" 3 "Social rented"
 label values ten3 ten3l
 keep pidp  h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3
 foreach var in h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 {
   rename `var' `wav'_`var' 
  }
 sum 
 sav $path9\m_`wav'.dta, replace 
} 



** Link this with the core data from 2015: 
** UKHLS 2015 outcome data : 
de e_hidp e_tenure_dv e_fihhmngrs_dv e_hhsize e_ieqmoecd_dv e_nkids_dv  ///
     using $path1b\e_hhresp.dta 
de pidp e_hidp   e_sex e_dvage e_fimngrs_dv e_*qfhigh_dv e_mastat_dv  e_hgbiof e_hgbiom e_indinub_xw  ///
           e_scghq1_dv e_scsf1 e_arts2freq using $path1b\e_indresp.dta 
*
use e_hidp e_tenure_dv e_fihhmngrs_dv e_hhsize e_ieqmoecd_dv e_nkids_dv   ///
     using $path1b\e_hhresp.dta , clear 
renpfix e_
sort hidp
sav $path9\m1.dta, replace
use pidp e_hidp   e_sex e_dvage e_fimngrs_dv e_*qfhigh_dv e_mastat_dv e_hgbiof e_hgbiom e_indinub_xw ///
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
*
sum fihhmngrs_dv hhsize ieqmoecd_dv
de fihhmngrs_dv hhsize ieqmoecd_dv
graph matrix fihhmngrs_dv ieqmoecd_dv hhsize if ieqmoecd_dv >= 1 & fihhmngrs_dv > 0 & fihhmngrs_dv < 50000 
capture drop hh_ln_eqinc 
gen hh_ln_eqinc = ln(fihhmngrs_dv / ieqmoecd_dv) if (ieqmoecd_dv >= 1 & fihhmngrs_dv > 0 & fihhmngrs_dv < 50000)

tab scsf1 
capture drop poor_hlth
gen poor_hlth=(scsf1==4 | scsf1==5) if (scsf1 >= 1 & scsf1 <= 5) 
correlate poor_hlth scghq1_dv if scghq1_dv >= 0 
* 

* Merge with additional data from waves 1-4 
sort pidp
foreach wav in a b c d { 
  merge 1:1 pidp using $path9\m_`wav'.dta
  keep if _merge==1 | _merge==3
  drop _merge
   }
codebook pidp *h_jl_mcam *h_jl_isei *hh_ln_eqinc *h_jl_ns_sec *h_jl_rgsc *ten3 , compact
sav $path9\ukhls_2.dta, replace 


***************************************************************************






*************************

*** BHPS, for trajectories
foreach wav in a b c d  { 
 use `wav'hid `wav'tenure `wav'fihhmn `wav'fieqfca   ///
     using $path1c\`wav'hhresp.dta , clear 
 sort `wav'hid
 sav $path9\m1.dta, replace
 use pid `wav'hid  using $path1c\`wav'indresp.dta 
 sort `wav'hid
 merge m:1 `wav'hid using $path9\m1.dta 
 tab _merge
 keep if _merge==1 | _merge==3 
 drop _merge
 gen wave="`wav'"
 sort pid wave
 isid pid wave
 merge 1:1 pid wave using $path2a\bhps_occs_a2r_1.dta
 tab _merge
 keep if _merge==1 | _merge==3 
 drop _merge
 numlabel _all, add 
 capture drop hh_ln_eqinc 
 gen hh_ln_eqinc = ln(`wav'fihhmn / `wav'fieqfca ) if (`wav'fieqfca  >= 0 & `wav'fihhmn > 0 & `wav'fihhmn < 50000)
 capture drop ten3 
 gen ten3=`wav'tenure
 recode ten3 1/2=1 5/8=3 3/4=2 *=.m 
 capture label drop ten3l
 label define ten3l 1 "Owner-occupier" 2 "Private rented" 3 "Social rented"
 label values ten3 ten3l
 keep pid  h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3
 foreach var in h_jl_mcam h_jl_isei hh_ln_eqinc h_jl_ns_sec h_jl_rgsc ten3 {
   rename `var' `wav'_`var' 
  }
 sum 
 sav $path9\m_`wav'.dta, replace 
} 


** BHPS, core 1995 outcome data: 
de ehid etenure efihhmn ehhsize efieqfca enkids  ///
     using $path1c\ehhresp.dta 
de pid ehid   esex eage emastat exrwght efimn eqfedhi ehgfno ehgmno ///
           ehlghq1 ehlstat using $path1c\eindresp.dta 
*
use ehid etenure efihhmn ehhsize efieqfca enkids ///
     using $path1c\ehhresp.dta , clear 
renpfix e
sort hid
sav $path9\m1.dta, replace
use pid  ehid   esex eage emastat exrwght efimn eqfedhi ehgfno ehgmno ///
           ehlghq1 ehlstat using $path1c\eindresp.dta  
renpfix e
sort hid
merge m:1 hid using $path9\m1.dta 
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
capture drop year 
gen year=5
sort pid year
isid pid year
merge 1:1 pid year using $path2a\bhps_occs_a2r_1.dta
tab _merge
keep if _merge==1 | _merge==3 
drop _merge
numlabel _all, add 
tab tenure 
capture drop ten3 
gen ten3=tenure
recode ten3 1/2=1 5/8=3 3/4=2 *=.m 
capture label drop ten3l
label define ten3l 1 "Owner-occupier" 2 "Private rented" 3 "Social rented"
label values ten3 ten3l
tab ten3 
*
sum fihhmn hhsize fieqfca
de fihhmn hhsize fieqfca
graph matrix fihhmn hhsize fieqfca if fieqfca >= 0 & fihhmn > 0 & fihhmn < 50000 
capture drop hh_ln_eqinc 
gen hh_ln_eqinc = ln(fihhmn / fieqfca ) if (fieqfca  >= 0 & fihhmn > 0 & fihhmn < 50000)
tab hlstat
capture drop poor_hlth
gen poor_hlth=(hlstat==3 | hlstat==4 | hlstat==5) if (hlstat >= 1 & hlstat <= 5) 
correlate poor_hlth hlghq1 if hlghq1 >= 0 

* Merge with additional data from waves 1-4 
sort pid
foreach wav in a b c d { 
  merge 1:1 pid using $path9\m_`wav'.dta
  keep if _merge==1 | _merge==3
  drop _merge
   }
codebook pid *h_jl_mcam *h_jl_isei *hh_ln_eqinc *h_jl_ns_sec *h_jl_rgsc *ten3 , compact
sav $path9\bhps_2.dta, replace 


************************************************

