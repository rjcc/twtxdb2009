cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/r_kidney.csv", clear
* (-1) -> missing values 
include _init
include _label
include _date_convert

mvdecode pat_sex, mv(0)
mvdecode pat_btype, mv(0)
dconv write_date
dconv pat_birthday
dconv graft_date
dconv die_date
dconv collapse_date
gen y=year(graft_date)
drop if y==.
label values cancer yn
label values pat_sex sex
label values pat_btype btype
gen age=(write_date-pat_birthday)/365.24
label define status 0 "Good" 1 "Organ Fail" 999 "?"
label define cond 1 "Alive" 2 "Dead" 3 "FU Loss" 999 "?"
label values graft_organ_status status
label values source_type source
label values confines_type country
mvdecode case_condi, mv(0)
mvencode case_condi graft_organ_status cancer, mv(999)
label values case_condi cond
ren source_type source
ren confines_type confine
gen ldonor=0 if source==1
replace ldonor=1 if source==2
gen outside=0 if confine==1
replace outside=1 if confine==2
quietly log using r_kidney, smcl replace

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
*     Domestic/Cadaver: source_type confines_type

tabstat graft_date, stat (min, max) col(var) format(%dCY-N-D)
misstable summarize _all
tab y
tabstat graft_date if y>=2004, stat (min, max) col(var) format(%dCY-N-D)
tab pat_sex y if y>=2004, col
tab source y if y>=2004, col
tab confine y if y>=2004, col
tabstat age if y>=2004 & y!=., by(y) stat(n mean sd med min max) format(%9.2g)
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
    risktable censored(single) saving(km_kidney_die, replace) ///
    xtitle(Month) xlabel(0 (36) 360) gwood ///
    title ("Kidney: Kaplan-Meier Survival Curve")
sts list, at (1 (36) 360)
graph export km_kidney_die.pdf, replace
stcox ldonor
stcox outside

gen gfail=1 if collapse_date!=.
replace gfail=0 if collapse_date==.
replace gfail=1 if die==1
gen fu_gfail=collapse_date-graft_date if gfail==1
replace fu_gfail=today-graft_date if gfail==0 & die==0
replace fu_gfail=die_date- graft_date if collapse_date==. & die==1

stset fu_gfail, failure(gfail==1) scale (30)

sts graph, ytitle(Proportion of Functioning Grafts) ///
    ylabel(, angle(horizontal)) ///
    risktable censored(single) saving(km_kidney_gfail, replace) ///
    xtitle(Month) xlabel(0 (36) 360) gwood ///
    title ("Kidney: Kaplan-Meier Survival Curve")
graph export km_kidney_gfail.pdf, replace
sts list, at (1 (36) 360)
stcox ldonor
stcox outside

ren graft_hosp_code hosp_code
merge m:1 hosp_code using hosp_code
drop if _merge!=3
tab opo
keep if opo==1 | opo==8 | opo==9 | opo==10
sts graph, ytitle(Proportion of Functioning Grafts) ///
    ylabel(0.7 (0.05) 1, angle(horizontal)) ///
    saving(km_kidney_die_opo, replace) ///
    xtitle(Month) xlabel(0 (36) 360) by(opo) ///
    title ("Kidney: Kaplan-Meier Survival Curve")
graph export km_kidney_die_opo.pdf, replace
xi: stcox i.opo 
sts list, at(1 (36) 360) compare by(opo)
xi: sts test i.opo

quietly log close
quietly log2html r_kidney, replace erase linesize(255)


