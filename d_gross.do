cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/d_gross.csv", clear names
* (-1) -> missing values
include _init
include _label
include _date_convert
mvdecode age, mv(0)

quietly log using d_gross, smcl replace

* Variables:
*   date, organ_code, blood_type, age, sex, opo
* Plans:
*   Donors
*     table: year * 
*     table: year * blood type (count by organ) by organ
*     table: year * age
*     table: year * sex by organ
*     table  year * opo
*
dconv write_date
gen y=year(write_date)
drop if y<2004
tabstat write_date, stat (min, max) col(var) format(%dCY-N-D)


label values organ_code organ_code
label values blood_type btype
label values sex_type sex

ren organ_code organ
ren blood_type btype
ren hosp_group opo
ren sex_type sex

table btype y, by(organ) col row scol
bysort organ: tabstat age, by(y) stat (n mean sd med min max)
table sex y, by(organ) col row scol
bysort organ: table opo y, col row

quietly log close
quietly log2html d_gross, replace erase linesize(255)

