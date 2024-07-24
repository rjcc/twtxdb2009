cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/c_desc1.csv", clear
* (-1) -> values 
include _init
include _label
include _date_convert

dconv write_date
dconv birthday
gen y=year(write_date)
drop if y<2004
mvencode hepatitis hepatitis_b, mv(999)
label values hepatitis hepatitis_b cancer yn
label values organ_code organ_code
label values sex_type sex
label values blood_type btype
gen age=(write_date-birthday)/365.24

quietly log using c_desc, smcl replace

* Variables:
*   Candidates
*     y organ age sex blood_type hepatitis cancer
tabstat write_date, stat(min max) format(%dCY-N-D) col(var)
misstable summarize _all
tab organ_code y
bysort organ_code: tabstat age, by(y) stat(n mean sd med min max) format(%9.2g)
bysort organ_code: tab sex y, col
bysort organ_code: tab blood_type y, col
bysort organ_code: tab cancer y, col
bysort organ_code: tab hepatitis y, col missing
bysort organ_code: tab hepatitis_b y, col


insheet using "/Users/apple/Documents/rjcc2/txdb2009/c_desc2.csv", clear
mvdecode _all, mv(-99)
mvdecode _all, mv(-1)
dconv write_date
dconv birthday
gen y=year(write_date)
drop if y<2004
label values organ_code organ_code
label values sex_type sex
label values blood_type btype
gen age=(write_date-birthday)/365.24
gen age_18up=0 if age>=18 & age!=.
replace age_18up=1 if age<18 & age!=.
label define age18 0 "Age>=18" 1 "Age<18"
label values age_18up age18

* Variables:
*   Candidates
*     y organ age sex blood_type cond_level liver_mpeldscore
tabstat write_date, stat(min max) format(%dCY-N-D) col(var)
misstable summarize _all
tab organ_code y
bysort organ_code: tabstat age, by(y) stat(n mean sd med min max) format(%9.2g)

bysort organ_code: tab sex y, col

bysort organ_code: tab blood_type y, col

bysort age_18up: tabstat liver_mpeldscore if organ_code==2 & age_18up!=., by(y) stat(n mean sd med min max) format(%9.2g)

label values cond_level cond_l_heart
tab cond_level y if organ_code==1, col

label values cond_level cond_l_liver
tab cond_level y if organ_code==2, col

label values cond_level cond_l_kidney
tab cond_level y if organ_code==3, col

label values cond_level cond_l_lung
tab cond_level y if organ_code==4, col

label values cond_level cond_l_pancreas
tab cond_level y if organ_code==5, col

label values cond_level cond_l_cornea
tab cond_level y if organ_code==6, col

quietly log close
quietly log2html c_desc, replace erase linesize(255)



