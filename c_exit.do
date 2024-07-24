cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/c_exit.csv", clear
* (-1) -> missing values 
include _init
include _label
include _date_convert

dconv write_date
gen y=year(write_date)
label values exit yn
label values organ_code organ_code

label define reason 1 "Dead" 2 "Loss FU" 3 "Transplant" 4 "Pt-Refusal" 5 "C/I" 6 "Others"
label values reason reason

quietly log using c_exit, smcl replace

* Variables:
*   Candidates
*     y organ exit reason
drop if y<2004
tabstat write_date, stat(min max) format(%dCY-N-D) col(var)
misstable summarize _all
tab organ_code y

tab organ_code y if exit==1
table exit y, col row by(organ_code) scol
table exit y, col row scol
bysort organ_code: tab exit y, col
bysort organ_code: tab reason y if exit==0, col

quietly log close
quietly log2html c_exit, replace erase linesize(255)



