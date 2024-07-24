cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/c_cornea.csv", clear
* (-1) -> missing values 
include _init
include _label
include _date_convert

dconv write_date
gen y=year(write_date)
drop if y<2004
quietly log using c_cornea, smcl replace

* Variables:
*   Candidates
*     y  contra_vision only_vision
tabstat write_date, stat(min max) format(%dCY-N-D) col(var)

label values contra_vision only_vision yn

misstable summarize _all

tab contra_vision y, missing col
tab only_vision y, missing col

quietly log close
log2html c_cornea, replace erase linesize(255)


