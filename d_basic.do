cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/d_basic.csv", clear names
* (-1) -> missing values ->999
include _init
include _label
include _date_convert
mvdecode height weight dnr_result brain_cause die_cause, mv(0)
mvdecode _all, mv(999)
dconv write_date
dconv donor_date
dconv birthday
replace donor_date=write_date if donor_date>write_date
gen y_donor=year(donor_date)
gen y_write=year(write_date)

label values sex_type sex
label values blood_type btype
label values dm htn heart_dz liver_dz kidney_dz drug_abuse head_injury fever shock cpr cancer yn
label define ynn 0 "Y" 1 "N" 2 "?" 999 "?
label values anti_hcv anti_hbc anti_hbs anti_hdv anti_hbe hbs_ag hbe_ag ynn
label values dopamine dobutamine epinephrine nor_epinephrine ddavp pitressin dnr_agree_doc yn
label define tw 1 "Taiwan" 2 "Foreign" 999 "?"
label values country_type tw
label define bdie 1 "Hypoxia/Asystole" 2 "Head Injury" 3 "CVA/AVM/Aneurysm" 4 "CNS tumor" 5 "Others" 999 "?"
label values brain_cause bdie
label define die 1 "Accident" 2 "Child Abuse" 3 "Suicide" 4 "Homicide" 5 "Disease" 6 "Others" 999 "?"
label values die_cause die
label define result 1 "Non-donate" 2 "Tissue/Cornea" 3 "Organ" 4 "Organ & Tissue" 999 "?"
label values dnr_result result
label define nd 1 "Family" 2 "Attorney" 3 "Medical" 4 "Traffic" 5 "Others" 999 "?"
label values non_dnr_reason nd
label define ndd 1 "Organ" 2 "Tissue/Cornea" 999 "?"
label values dnr_types ndd
label values blood_type btype

quietly log using d_basic, smcl replace
gen hepatitis=0 if anti_hcv==0| anti_hbs==0| hbs_ag==0| hbe_ag==0
replace hepatitis=1 if anti_hcv==1& anti_hbs==1& hbs_ag==1& hbe_ag==1
label values hepatitis yn

* Variables: sex, btype, drug_abuse, head_injury, fever, shock, cpr
*      brain_cause, die_cause
*      hepatitis, dnr_agree_doc, dnr_result, non_dnr_resaon, dnr_types
* Plans:
*   Donors (dnr=donor)
*    cancer
*    non_donor (elsewhere)
*    yearly: sex, age, hepatitis, brain_cause, die_cause, dnr_result
*            non_dnr_reason, dnr_types

misstable summarize donor_date write_date
drop if y_donor<2004
* Drop unreliable data before 2004
tabstat donor_date, stat (min, max) col(var) format(%dCY-N-D)

tab sex_type y_donor, col
gen age=(donor_date-birthday)/365.24
tabstat age, by(y_donor) stat(n mean sd med min max) format(%9.2g)
tab blood_type y_donor, col
* Hepatitis=Y if anti_hcv=Y or anti_hbs=Y or hbs_ag=Y or hbe_ag=Y
* Hepatitis=N if all above N
mvencode _all, mv(999)
tab hepatitis y_donor, col
tab cancer y_donor, col
tab brain_cause y_donor, col
tab die_cause y_donor, col
tab dnr_result y_donor, col
tab non_dnr_reason y_donor if non_dnr_reason<9, col
tab dnr_types y_donor, col
mvdecode _all, mv(999)

* Successful organ donor
keep if dnr_result==2 | dnr_result==3 | dnr_result==4
tab sex_type y_donor, col
tabstat age, by(y_donor) stat(n mean sd med min max) format(%9.2g)
tab blood_type y_donor, col
* Hepatitis=Y if anti_hcv=Y or anti_hbs=Y or hbs_ag=Y or hbe_ag=Y
* Hepatitis=N if all above N
mvencode _all, mv(999)
tab hepatitis y_donor, col
tab cancer y_donor, col
tab brain_cause y_donor, col
tab die_cause y_donor, col
tab dnr_result y_donor, col
tab non_dnr_reason y_donor if non_dnr_reason<9, col
tab dnr_types y_donor, col

quietly log close
quietly log2html d_basic, replace erase linesize(255)

