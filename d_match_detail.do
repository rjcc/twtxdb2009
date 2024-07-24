cd "/Users/apple/Documents/rjcc2/txdb2009"
insheet using "/Users/apple/Documents/rjcc2/txdb2009/d_match_detail.csv", clear
* (-1) ->  values ->999
include _init
include _label
include _date_convert
mvdecode score hla_score age_score donor_score hbs_ag_score anti_hcv_score blood_score ///
      if organ_code!=3 | organ_code!=5, mv(0)
dconv write_date
dconv transplant_date
dconv match_date
gen y_tx=year(transplant_date)
drop if y<2007
label values hbs_ag anti_hbs anti_hbc anti_hcv ecmo iabp mv vad hcc yn
label define hla_flag 0 "No-mismatch" 1 "Mismatch"
label values hla_flag hla_flag
label values area_code area_code
label values organ_code organ_code

quietly log using d_match_detail, smcl replace
gen hepatitis=0 if anti_hcv==0| anti_hbc==0 | anti_hbs==0| hbs_ag==0
replace hepatitis=1 if anti_hcv==1& anti_hbc==1& anti_hbs==1& hbs_ag==1
replace hepatitis=999 if hepatitis==.
label values hepatitis yn
gen wait1=substr(trim(more_wait),1,1)
gen wait2=substr(trim(more_wait),-1,1)
destring wait1 wait2, replace
label values wait1 organ_code
label values wait2 organ_code

* Variables:
*   matched candidate-donor with transplant
*   donor: transplant_date id_no hbs_ag anti_hbs anti_hbc anti_hcv
*   candidate:
*      all: wtg_transplant_date wtg_age cond_level wait_day(invalid) wait1 wait2
*      heart: ecmo iabp mv vad
*      liver: meld_score hcc
*      kidney: score area_code
*         waittime_score hla_score age_score donor_score hbs_ag_score anti_hcv_score
*      lung: mv
*      pancreas: score
*         waittime_score hla_score age_score hbs_ag_score anti_hcv_score blood_score
*      cornea: 
* Plans: Keep only matched donor-candidates with transplantation
*   1. Donor stat
*   2. By organ: yearly statistics
*   3. Organ-specific variables and labelling

* Only matched donors with transplanted candidates 
display "age_score: (kidney) <11:+4, 11~18:+3, >18:+2"
display "age_score: (pancreas) <18:+3, 18~55:+3, >55:+3"
display "donor_score: (kidney) +4 if prior donor"
display "blood_score: (pancreas) +1 if identical"
display "waittime_score: +0.5/yr, max 2"
display "hla_score: (kidney) BDR miamatch: +4 if 0, +3 if 1, +2 if 2"
display "hla_score: (pancreas) BDR mismatch: +8 if 0, +6 if 1, +4 if 2"
display "hbs_ag_score: -1 if (+)"
display "anti_hcv_score: -1 if (+)"
display "Kidney: score=age donor waittime hla hbs_ag anti_hcv"
display "Pancreas: score=age blood waitimg hla hbs_ag anti_hcv"

* area_code: needed in kidney (N M S E) and lung (N M S)

keep if y_tx>2000
misstable summarize _all
* Drop unreliable data before 2000
* Donor
tabstat transplant_date, stat (min, max) col(var) format(%dCY-N-D)
* Hepatitis=Y if anti_hcv=Y or anti_hbc=Y or anti_hbe=Y or hbs_ag=Y 
* Hepatitis=N if all above N
bysort organ_code: tab hepatitis y_tx, col
* bysort organ_code: tabstat wait_day, by(y_tx) stat(n mean sd med min max) format(%9.2g)
* Elsewhere for wait_day (wait_time)
bysort organ_code: tabstat wtg_age, by(y_tx) stat(n mean sd med min max) format(%9.2g)

list wtg_id_no transplant_date organ_code more_wait wait1 wait2 if wait1!=. | wait2!=.
bysort organ_code: tab hosp_group y_tx

*  heart: ecmo iabp mv vad
*  liver: meld_score hcc
*  kidney: score area_code
*     waittime_score hla_score age_score donor_score hbs_ag_score anti_hcv_score
*  lung: mv
*  pancreas: score
*     waittime_score hla_score age_score hbs_ag_score anti_hcv_score blood_score
*  cornea: 

* Heart
tabstat transplant_date if organ_code==1, stat (min, max) col(var) format(%dCY-N-D)
tab ecmo y_tx if organ_code==1,  col
tab iabp y_tx if organ_code==1,  col
tab vad y_tx if organ_code==1,  col
tab mv y_tx if organ_code==1,  col
label values cond_level cond_l_heart
tab cond_level y_tx if organ_code==1,  col

* Liver
mvdecode meld_score, mv(0)
tabstat transplant_date if organ_code==2, stat (min, max) col(var) format(%dCY-N-D)
tab hcc y_tx if organ_code==2 & y_tx>=2007,  col
replace meld_score=40 if organ_code==2 & wtg_age>=18 & meld_score>40
tabstat meld_score if organ_code==2 & wtg_age>=18, by(y_tx) stat(n mean sd med min max) format(%9.2g)
tabstat meld_score if organ_code==2 & wtg_age<18, by(y_tx) stat(n mean sd med min max) format(%9.2g)
label values cond_level cond_l_liver
tab cond_level y_tx if organ_code==2,  col

* Kidney
tabstat transplant_date if organ_code==3, stat (min, max) col(var) format(%dCY-N-D)
tab area_code y_tx if organ_code==3,  col
tabstat score if organ_code==3 & y_tx>=2008, by(y_tx) stat(n mean sd med min max) format(%9.2g)
tab waittime_score y_tx if organ_code==3 & y_tx>=2008, col
tab hla_score y_tx if organ_code==3 & y_tx>=2008,  col
tab age_score y_tx if organ_code==3 & y_tx>=2008,  col
tab donor_score y_tx if organ_code==3 & y_tx>=2008,  col
tab hbs_ag_score y_tx if organ_code==3 & y_tx>=2008,  col
tab anti_hcv_score y_tx if organ_code==3 & y_tx>=2008,  col
label values cond_level cond_l_kidney
tab cond_level y_tx if organ_code==3 & y_tx>=2007,  col

* Lung
tabstat transplant_date if organ_code==4, stat (min, max) col(var) format(%dCY-N-D)
tab area_code y_tx if organ_code==4,  col
tab mv y_tx if organ_code==4,  col
label values cond_level cond_l_lung
tab cond_level y_tx if organ_code==4,  col

* Pancreas
tabstat transplant_date if organ_code==5, stat (min, max) col(var) format(%dCY-N-D)
tabstat score if organ_code==5, by(y_tx) stat(n mean sd med min max) format(%9.2g)
tab waittime_score y_tx if organ_code==5, col
tab hla_score y_tx if organ_code==5,  col
tab age_score y_tx if organ_code==5,  col
tab blood_score y_tx if organ_code==5,  col
tab hbs_ag_score y_tx if organ_code==5,  col
tab anti_hcv_score y_tx if organ_code==5,  col
label values cond_level cond_l_pancreas
tab cond_level y_tx if organ_code==5,  col


* Cornea
tabstat transplant_date if organ_code==6, stat (min, max) col(var) format(%dCY-N-D)
label values cond_level cond_l_cornea
tab cond_level y_tx if organ_code==6,  col

quietly log close
quietly log2html d_match_detail, replace erase linesize(255)

