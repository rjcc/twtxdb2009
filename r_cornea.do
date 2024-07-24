cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/r_cornea.csv", clear
ren pat_blood_type pat_btype
* (-1) -> values
include _init
include _label
include _date_convert

mvdecode pat_sex pat_btype, mv(0)

dconv write_date
dconv pat_birthday
dconv graft_date
gen y=year(graft_date)
label values pat_sex sex
label values pat_btype btype
label values source source
label values confine country
gen age=(write_date-pat_birthday)/365.24
mvencode graft_organ_status, mv(999)
label define status 2 "Clear" 3 "Semi-Clear" 4 "Fail" 999 "?"
label define cond 1 "Alive" 2 "Dead" 3 "Lost FU" 999 "?"
label values graft_organ_status status

quietly log using r_cornea, smcl replace
* Variables:
*   Recipient
*     Request: y organ age sex blood_type hepatitis
*     Date: write_date graft_date pat_pat_birthday
*     Date2: die_date lossfu_date chase_date          
*     OPO: trace_hosp_code writer_hosp_code graft_hosp_code
*     Basic: pat_btype pat_sex pat_ht pat_wt (age) 
*     Outcome: die_relation die_cause graft_organ_status complication_flag 
*         case_condi
*         cornea_fail_date eye_cause
*     Donor: dnr_id_no

tabstat write_date, stat(min max) format(%dCY-N-D) col(var)
misstable summarize _all
tab y
tabstat write_date if y>=2007, stat(min max) format(%dCY-N-D) col(var)
tab source y if y>=2007, col
tab confine y if y>=2007, col
tab pat_sex y if y>=2007, col
tabstat age if y>=2007, by(y) stat(n mean sd med min max) format(%9.2g)
tab pat_btype y if y>=2007, col
tab graft_organ_status y if y>=2007, col missing
tab source graft_organ_status if graft_organ_status!=999 & y>=2007, row exact
tab confine graft_organ_status if graft_organ_status!=999 & y>=2007, row exact

quietly log close
quietly log2html r_cornea, replace erase linesize(255)


