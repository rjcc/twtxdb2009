label drop _all
label define organ_code 1 "Heart" 2 "Liver" 3 "Kidney" 4 "Lung" 5 "Pancreas" 6 "Cornea"
label define yn 0 "Y" 1 "N" 999 "?"
label define sex 1 "M" 2 "F" 999 "?"
label define side 1 "R" 2 "L" 999 "?"
label define btype 1 "O" 2 "A" 3 "B" 4 "AB" 999 "?"
label define area_code 1 "North" 2 "Mid" 3 "South" 4 "East" 999 "?"

label define cond_l_heart 1 "Stat-1A" 2 "Stat-1B" 3 "Stat-2" 7 "Stat-7"
label define cond_l_liver 1 "Stat-1" 2 "Non-Stat-1" 7 "Stat-7"
label define cond_l_kidney 1 "Valid" 7 "Void"
label define cond_l_lung 1 "Stat-1A" 2 "Stat-1B" 3 "Stat-2" 7 "Stat-7"
label define cond_l_pancreas 1 "Valid" 7 "Void"
label define cond_l_cornea 1 "Valid" 7 "Void" 0 "?"
label define source 1 "Cadaver" 2 "Living"
label define country 1 "Taiwan" 2 "Outside-TW"

exit
