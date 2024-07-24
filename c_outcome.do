cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/c_outcome.csv", clear
* (-1) -> missing values ->999
include _init
include _label
include _date_convert
mvdecode _all, mv(-1)
mvdecode _all, mv(-999)
dconv graft_date
dconv die_date
dconv pat_birthday
dconv collapse_date
dconv eye_condi_date

gen y=year(graft_date)
drop if y<2004
label values organ_code organ_code
quietly log using c_outcome, smcl replace

* Variables:
*   Candidates
*      organ_code 1st_quietly login_date->exit_date exit_reason
* Plans:
*   Variables: wait_t cmvigg cmvigm pra
*   Effect on outcomes


tabstat graft_date, stat(min max) format(%dCY-N-D) col(var)
display "Up to 2009-10-28"

forvalues i=1(1)6 {
   disp "Organ=" `i'
   pwcorrs pra wait_t if organ_code==`i', spearman sig star(0.05) obs
   }
gen die=1 if die_date!=.
replace die=0 if die_date==.
gen fu_die=die_date-graft_date if die==1
replace fu_die=today-graft_date if die==0

stset fu_die, failure(die==1) scale (30)
bysort organ_code: stcox wait_t

quietly log off
program dd
args v o
stcox `v' if organ_code==`o'
end
quietly log on

gen gfail=1 if collapse_date!=.
replace gfail=0 if collapse_date==.
gen fu_gfail=collapse_date-graft_date if gfail==1
replace fu_gfail=today-graft_date if gfail==0 & die_date==.
replace fu_gfail=die_date-graft_date if gfail==0 & die_date!=.

stset fu_gfail, failure(gfail==1) scale (30)
dd wait_t 3
dd wait_t 2

gen eyefail=1 if eye_condi_date!=.
replace eyefail=0 if eye_condi_date==.
gen fu_eyefail=eye_condi_date-graft_date if eyefail==1
replace fu_eyefail=today-graft_date if eyefail==0 & die_date==.
replace fu_eyefail=die_date-graft_date if eyefail==0 & die_date!=.

stset fu_eyefail, failure(eyefail==1) scale (30)
dd wait_t 6

quietly log close
quietly log2html c_outcome, replace erase linesize(255)

