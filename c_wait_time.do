cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/c_wait_time.csv", clear
* (-1) -> missing values ->(-999)
include _init
include _label
include _date_convert
mvdecode _all, mv(-1)
mvdecode _all, mv(-999)
dconv exit_date
dconv first_login_date
drop if first_login_date> exit_date
gen y=year(first_login_date)
drop if y<2004
label values organ_code organ_code
label define reason 1 "Dead" 2 "Loss FU" 3 "Transplant" 4 "Pt-Refusal" 5 "C/I" 6 "Others"
label values exit_reason reason
gen wait_time=exit_date - first_login_date
replace wait_time=today - first_login_date if exit_flag==1
quietly log using c_wait_time, smcl replace

* Variables:
*   Candidates all-included, not only transplanted
*      organ_code 1st_login_date->exit_date exit_reason
* Plans: Tabulate wait_time
*   Strata: organ_code exit_reason
*   cmvigg cmvigm pra


ren first_login_date list_date
tabstat list_date, stat(min max) format(%dCY-N-D) col(var)
display "Up to 2009-10-28"
bysort organ_code: tabstat wait_time, by(y) stat(n mean sd med) format(%9.2g)
bysort organ_code: tabstat wait_time, by(exit_reason) stat(n mean sd med) format(%9.2g)
gen wait_t=wait_time
* All candidates
forvalues i=1(1)6 {
   disp "Organ=" `i'
   pwcorrs pra wait_t if organ_code==`i', spearman sig star(0.05) obs
   }
* Candaidates that exited
forvalues i=1(1)6 {
   disp "Organ=" `i'
   pwcorrs pra wait_t if organ_code==`i' & exit_reason!=., spearman sig star(0.05) obs
   }
* Candidates that had transplantation
forvalues i=1(1)6 {
   disp "Organ=" `i'
   pwcorrs pra wait_t if organ_code==`i' & exit_reason==3, spearman sig star(0.05) obs
   }


quietly log close
mvencode _all, mv(-999)
outsheet id_no organ_code exit_flag exit_reason pra cmvigm cmvigg exit_date list_date wait_t using "/Users/apple/Documents/rjcc2/txdb2009/c_wait_time_import.csv", comma nolabel replace
log2html c_wait_time, replace erase linesize(255)


