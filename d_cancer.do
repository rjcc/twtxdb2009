cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/d_cancer.csv", clear names
* (-1) -> missing values
include _init
include _label
include _date_convert

label values organ_code organ_code
label values cancer yn
dconv donor_date
gen y=year(donor_date)

quietly log using d_cancer, smcl replace

bysort organ_code: tab cancer y if y>=2004, col
bysort organ_code: list cancer_desc if cancer==0 & trim(cancer_desc)!="" & y>=2004, table

quietly log close

quietly log2html d_cancer, replace erase linesize(255)

