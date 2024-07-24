cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/r_liver.csv", clear
* (-1) -> missing values 
include _init
include _label
include _date_convert
mvdecode pat_sex pat_btype, mv(0)
dconv write_date
dconv pat_birthday
dconv graft_date
dconv die_date
dconv collapse_date

gen y=year(graft_date)
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
mvdecode case_condi, mv(999)
mvencode case_condi cancer graft_organ_status, mv(999)
label values case_condi cond
ren source_type source
ren confines_type confine
gen ldonor=0 if source==1
replace ldonor=1 if source==2
gen outside=0 if confine==1
replace outside=1 if confine==2
quietly log using r_liver, smcl replace

* Variables:
*   Recipient
*     Request: y organ age sex blood_type hepatitis cancer
*     Date: write_date graft_date pat_pat_birthday ldonor_date
*     Date2: die_date lossfu_date cancer_date 
*            chase_date rewaiting_date
*     OPO: trace_hosp_code writer_hosp_code graft_hosp_code
*     Basic: pat_btype pat_sex pat_ht pat_wt (age)
*     Op: op_type partial_liver split_liver 
*         warmischemic_time coldischemic_time
*     Outcome: die_relation die_cause graft_organ_status complication_flag 
*         case_condi cancer
*         collapse_date collapse_cause collapse_desc rewaiting rewaiting_date
*     Donor: dnr_id_no
*     Living donor: ldonor_sex ldonor_pat_birthday ldonor_blood ldonor_ht ldonor_wt ldonor_date
*         liver_percent liver_case_relation
*     Foreign: source_type confines_type
*     Lab: chem_got chem_gpt chem_alk_p chem_bil1 chem_ag1 chem_ag2 chem_cr 
*          blood_pt1 blood_pt2 blood_inr chem_bun chase_date
*     Domestic/Cadaver: source_type confines_type

tabstat graft_date, stat (min, max) col(var) format(%dCY-N-D)
misstable summarize _all
tab y
tabstat graft_date if y>=2004, stat (min, max) col(var) format(%dCY-N-D)

tab source y if y>=2004, col
tab confine y if y>=2004, col
tabstat age if y>=2004 & age>0 & age<100, by(y) stat(n mean sd med min max) format(%9.2g)
tab pat_sex y if y>=2004,  col
tab pat_btype y if y>2004, col
tab cancer y if y>=2004,  col missing
tab graft_organ_status y if y>=2004, missing col
tab case_condi y if y>=2004, missing col

gen die=1 if die_date!=.
replace die=0 if die_date==.
gen fu_die=die_date-graft_date if die==1
replace fu_die=today-graft_date if die==0

stset fu_die, failure(die==1) scale (30)

sts graph, ytitle(Proportion of Survival) ///
    ylabel(, angle(horizontal)) ///
    risktable censored(single) saving(km_liver_die, replace) ///
    xtitle(Month) xlabel(0 (24) 288) gwood ///
    title ("Liver: Kaplan-Meier Survival Curve")
graph export km_liver_die.pdf, replace
sts list, at (1 (24) 288)
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
    risktable censored(single) saving(km_liver_gfail, replace) ///
    xtitle(Month) xlabel(0 (24) 288) gwood ///
    title ("Liver: Kaplan-Meier Survival Curve")
graph export km_liver_gfail.pdf, replace
sts list, at (1 (24) 288)
stcox ldonor
stcox outside

ren graft_hosp_code hosp_code
merge m:1 hosp_code using hosp_code
drop if _merge!=3
tab opo
keep if opo==1 | opo==6 | opo==8 | opo==9
sts graph, ytitle(Proportion of Survival) ///
    ylabel(, angle(horizontal)) ///
    saving(km_liver_die_opo, replace) ///
    xtitle(Month) xlabel(0 (24) 288) by(opo) ///
    title ("Liver: Kaplan-Meier Survival Curve")
graph export km_liver_die_opo.pdf, replace
xi: stcox i.opo 
sts list, at(1 (24) 288) compare by(opo)
xi: sts test i.opo

quietly log close
quietly log2html r_liver, replace erase linesize(255)


