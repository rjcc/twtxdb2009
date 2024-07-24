cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/d_hosp.csv", clear names
include _init
mvdecode _all, mv(0)
include _label
include _date_convert

quietly log using d_hosp, smcl replace

* Variables:
*   date, hosp, dnr_hosp, opo, opo_city, opo_area, d_opo, d_city, d_area
* Plans:
*   Donors
*    year * opo
*    year * d_opo
*    year * hosp_area
*    year * d_hosp_area
*    count by year if opo <> d_opo
*    count by year if area <> d_area

dconv write_date
label values hosp_area area_code
label values d_area area_code
gen y=year(write_date)
drop if y<2004
tabstat write_date, stat (min, max) col(var) format(%dCY-N-D)

tab opo y
tab d_opo y
tab hosp_area y
table d_area y, col row
table opo d_opo

table y d_opo if opo != d_opo
table opo d_opo if opo != d_opo

tab hosp_area d_area
tab y d_area if hosp_area != d_area
tab hosp_area d_area if hosp_area != d_area

quietly log close
quietly log2html d_hosp, replace erase linesize(255)

