cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/r_pancreas.csv", clear
ren pat_blood_type pat_btype
ren pat_sex_type pat_sex

* (-1) -> missing values 
include _init
include _label
include _date_convert
mvdecode pat_sex pat_btype, mv(0)

dconv write_date
dconv pat_birthday
dconv graft_date
dconv die_date
gen y=year(graft_date)
label values cancer yn
label values pat_sex sex
label values pat_btype btype
gen age=(write_date-pat_birthday)/365.24
label define status 0 "Good" 1 "Organ Fail" 999 "?"
label define cond 1 "Alive" 2 "Dead" 3 "FU Loss" 999 "?"
label values graft_organ_status status
mvdecode case_condi, mv(0)
mvencode case_condi graft_organ_status cancer, mv(999)
label values case_condi cond

quietly log using r_pancreas, smcl replace

* Variables:
*   Recipient
*     Request: y organ age sex blood_type hepatitis cancer
*     Date: write_date graft_date pat_pat_birthday
*     Date2: die_date lossfu_date cancer_date 
*            chase_date
*     OPO: trace_hosp_code writer_hosp_code graft_hosp_code
*     Basic: pat_btype pat_sex pat_ht pat_wt (age)
*     Op: op_type
*     Outcome: die_relation die_cause graft_organ_status complication_flag 
*         case_condi cancer
*     Donor: dnr_id_no

tabstat graft_date, stat (min, max) col(var) format(%dCY-N-D)
misstable summarize _all
tab y
tabstat graft_date if y>=2004, stat (min, max) col(var) format(%dCY-N-D)
tab pat_sex y if y>=2004, col
tabstat age if y>=2004, by(y) stat(n mean sd med min max) format(%9.2g)
tab pat_btype y if y>=2004, col
tab cancer y if y>=2004, missing col
tab graft_organ_status y if y>=2004, missing col
tab case_condi y if y>=2004, missing col

gen die=1 if die_date!=.
replace die=0 if die_date==.
gen fu_die=die_date-graft_date if die==1
replace fu_die=today-graft_date if die==0

stset fu_die, failure(die==1) scale (30)

sts graph, ytitle(Proportion of Survival) ///
    ylabel(, angle(horizontal)) ///
    risktable censored(single) saving(km_pancreas_die, replace) ///
    xtitle(Month) xlabel(0 (12) 144) gwood ///
    title ("Pancreas: Kaplan-Meier Survival Curve")
graph export km_pancreas_die.pdf, replace

quietly log close
quietly log2html r_pancreas, replace erase linesize(255)


