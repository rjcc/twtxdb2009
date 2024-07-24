cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/r_wait_t_outcome.csv", clear
* (-1) -> missing values ->-999
include _init
include _label
include _date_convert
mvdecode _all, mv(-1)
mvdecode _all, mv(-999)
dconv graft_date
dconv die_date
dconv pat_birthday
dconv collapse_date
dconv ldonor_birthday

gen age=(graft_date-pat_birthday)/365.24
drop if graft_date> die_date
gen y=year(graft_date)
drop if y<2004
sort id_no
drop if id_no==id_no[_n+1] & organ_code==organ_code[_n+1] & abs(graft_date-graft_date[_n+1])<14
label values organ_code organ_code
label values source source
label values confine country

sort id_no
drop if id_no==id[_n-1]
quietly log using r_wait_t_outcome, smcl replace

* Variables:
*   Recipient
*     wait_t pra cmvigg cmvigm graft_date die_date
*     source: donor as cadaver or living
*     confine: Taiwan or Outside-Taiwan
* Plans:
*     Variables: wait_t pra cmv 
*                ldonor outside (liver kidney cornea)
*     Outcome: patient death
tabstat graft_date, stat(min max) format(%dCY-N-D) col(var)

* Donor: cadaver vs living
bysort organ_code: tab source y, col
bysort organ_code: tab confine y, col

gen die=1 if die_date!=.
replace die=0 if die_date==.
gen fu_die=die_date-graft_date if die==1
replace fu_die=today-graft_date if die==0

forvalues i=1(1)6 {
   disp "Organ=" `i'
   pwcorrs pra wait_t if organ_code==`i', spearman sig star(0.05) obs
   }
   
stset fu_die, failure(die==1) scale (30)
bysort organ_code: stcox wait_t
bysort organ_code: stcox age
bysort organ_code: stcox pra
bysort organ_code: stcox cmvigg
bysort organ_code: stcox cmvigm

gen gfail=1 if collapse_date!=.
replace gfail=0 if collapse_date==.
gen fu_gfail=collapse_date-graft_date if gfail==1
replace fu_gfail=today-graft_date if gfail==0

stset fu_gfail, failure(gfail==1) scale (30)
stcox wait_t if organ_code==2
stcox age if organ_code==2
stcox pra if organ_code==2
stcox cmvigg if organ_code==2
stcox cmvigm if organ_code==2
stcox wait_t if organ_code==3
stcox age if organ_code==3
stcox pra if organ_code==3
stcox cmvigg if organ_code==3
stcox cmvigm if organ_code==3

quietly log close
log2html r_wait_t_outcome, replace erase linesize(255)

