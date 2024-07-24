cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/r_wait_t_outcome.csv", clear
ren graft_date tx_d
ren organ_code organ
* (-1) -> missing values ->-999
include _init
include _label
include _date_convert
mvdecode _all, mv(-1)
mvdecode _all, mv(-999)
dconv tx_d
dconv die_date
dconv pat_birthday
dconv collapse_date
dconv ldonor_birthday

gen age=(tx_d-pat_birthday)/365.24
drop if tx_d> die_date
gen y=year(tx_d)
drop if y<2004
label values organ organ_code
label values source source
label values confine country
gen ldonor=0 if source==1
replace ldonor=1 if source==2
gen outside=0 if confine==1
replace outside=1 if confine==2
quietly log using r_multi, smcl replace

* Variables:
*   Recipient
*     wait_t pra cmvigg cmvigm tx_d die_date
*     source: donor as cadaver or living
*     confine: Taiwan or Outside-Taiwan
* Plans:
*     Seek multi_tx
keep id_no organ tx_d 
sort id_no organ tx_d
list id_no organ tx_d if id_no==id_no[_n+1] & organ==organ[_n+1] & tx_d==tx_d[_n+1]
drop if id_no==id_no[_n+1] & organ==organ[_n+1] & abs(tx_d-tx_d[_n+1])<14
keep if id_no==id_no[_n+1] | id_no==id_no[_n-1]
sort id_no organ tx_d
gen o=1
replace o=o[_n-1]+1 if id_no==id_no[_n-1]

count
list id_no organ tx_d o if id_no==id_no[_n-1] | id_no==id_no[_n+1]
tabstat tx_d, stat(min max) format(%dCY-N-D) col(var)
reshape wide organ tx_d, i(id_no) j(o)
label values organ1 organ2 organ3 organ_code
label variable organ1 "organ-1"
label variable organ2 "organ-2"
label variable organ3 "organ-3"
table organ1 organ2 if organ1==organ2
count if organ1==organ2
table organ1 organ2 if organ1!=organ2
count if organ1!=organ2
table organ1 organ2 if organ1!=organ2 & abs(tx_d1-tx_d2)<3
sort tx_d1
list if organ3!=.


quietly log close
log2html r_multi, replace erase linesize(255)

