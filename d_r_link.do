cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/d_r_link.csv", clear
* (-1) -> missing values ->-999
include _init
include _label
include _date_convert
mvdecode _all, mv(-1)
mvdecode _all, mv(-999)
dconv graft_date
dconv die_date
dconv donor_date
dconv d_birthday
dconv pat_birthday
dconv collapse_date
dconv eye_condi_date

gen age=(graft_date-pat_birthday)/365.24
gen d_age=(donor_date-d_birthday)/365.24
drop if graft_date> die_date
gen y=year(graft_date)
drop if y<2004
label values organ_code organ_code
quietly log using d_r_link, smcl replace

* Variables:
*   Recipient
*     graft_date die_date
*   Donor
*     age clinical
* Plans:
*    Donor effect on recipient survival

tabstat graft_date, stat(min max) format(%dCY-N-D) col(var)

gen die=1 if die_date!=.
replace die=0 if die_date==.
gen fu_die=die_date-graft_date if die==1
replace fu_die=today-graft_date if die==0

stset fu_die, failure(die==1) scale (30)
bysort organ_code: stcox d_age
bysort organ_code: stcox d_sex
bysort organ_code: stcox d_drug_abuse 
bysort organ_code: stcox d_cancer 
bysort organ_code: stcox d_kidney_dz 
bysort organ_code: stcox d_liver_dz 
bysort organ_code: stcox d_heart_dz 
bysort organ_code: stcox d_shock 
bysort organ_code: stcox d_cpr 
bysort organ_code: stcox d_anti_hcv 
bysort organ_code: stcox d_hbs_ag 
bysort organ_code: stcox d_hbe_ag 
bysort organ_code: stcox d_anti_hbc 
bysort organ_code: stcox d_anti_hbs
bysort organ_code: stcox d_lactic_acid 
bysort organ_code: stcox d_na 
bysort organ_code: stcox d_epinephrine
bysort organ_code: stcox d_norepinephrine
bysort organ_code: stcox d_pitressin
bysort organ_code: stcox d_steroids


quietly log off
program dd
args v o
stcox `v' if organ_code==`o'
end
log on

gen gfail=1 if collapse_date!=.
replace gfail=0 if collapse_date==.
gen fu_gfail=collapse_date-graft_date if gfail==1
replace fu_gfail=today-graft_date if gfail==0 & die_date==.
replace fu_gfail=die_date-graft_date if gfail==0 & die_date!=.

stset fu_gfail, failure(gfail==1) scale (30)
dd d_age 2
dd d_sex 2
dd d_drug_abuse 2
dd d_cancer 2
dd d_kidney_dz 2
dd d_liver_dz 2
dd d_heart_dz 2
dd d_shock 2
dd d_cpr 2
dd d_anti_hcv 2
dd d_hbs_ag 2
dd d_hbe_ag 2
dd d_anti_hbc 2
dd d_anti_hbs 2
dd d_lactic_acid 2
dd d_na 2
dd d_epinephrine 2
dd d_norepinephrine 2
dd d_pitressin 2
dd d_steroids 2


dd d_age 3
dd d_sex 3
dd d_drug_abuse 3
dd d_cancer 3
dd d_kidney_dz 3
dd d_liver_dz 3
dd d_heart_dz 3
dd d_shock 3
dd d_cpr 3
dd d_anti_hcv 3
dd d_hbs_ag 3
dd d_hbe_ag 3
dd d_anti_hbc 3
dd d_anti_hbs 3
dd d_lactic_acid 3
dd d_na 3
dd d_epinephrine 3
dd d_norepinephrine 3
dd d_pitressin 3
dd d_steroids 3

gen eyefail=1 if eye_condi_date!=.
replace eyefail=0 if eye_condi_date==.
gen fu_eyefail=eye_condi_date-graft_date if eyefail==1
replace fu_eyefail=today-graft_date if eyefail==0 & die_date==.
replace fu_eyefail=die_date-graft_date if eyefail==0 & die_date!=.

stset fu_eyefail, failure(eyefail==1) scale (30)
dd d_age 6
dd d_sex 6
dd d_drug_abuse 6
dd d_cancer 6
dd d_kidney_dz 6
dd d_liver_dz 6
dd d_heart_dz 6
dd d_shock 6
dd d_cpr 6
dd d_anti_hcv 6
dd d_hbs_ag 6
dd d_hbe_ag 6
dd d_anti_hbc 6
dd d_anti_hbs 6
dd d_lactic_acid 6
dd d_na 6
dd d_epinephrine 6
dd d_norepinephrine 6
dd d_pitressin 6
dd d_steroids 6

quietly log close
log2html d_r_link, replace erase linesize(255)


