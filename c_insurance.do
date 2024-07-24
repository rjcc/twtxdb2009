cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/c_insurance.csv", clear names
include _init
include _label
include _date_convert
quietly log using c_insurance, smcl replace
label define insurance_stat 2 "Pending" 3 "Passed" 4 "Rejected"

* Variables:
*   date, organ, status
* Plans:
*   Transplant candidates
*   1. date range
*   2. year * organ
*   3. by organ, year * status
*   4. with check_status=3 (passed review), year * organ

label values organ_code organ_code
label values check_flag insurance_stat
dconv write_date
gen y=year(write_date)
drop if y<2004
tabstat write_date, stat (min, max) col(var) format(%dCY-N-D)
tab organ_code y
bysort organ_code: tab y check_flag, row
* Counts by year if insurance-passed
tab organ_code y if check_flag==3
quietly log close
quietly log2html c_insurance, replace erase linesize(255)


