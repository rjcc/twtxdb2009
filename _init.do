set more off
set linesize 128
set scheme s2mono
char _dta[omit] "prevalent"
program drop _all

program dsf
version 9
args d
gen dtemp=daily(`d',"ymd") if `d'!=""
format dtemp %dCY/N/D
drop `d'
ren dtemp `d'
end

program co
args gp var
rjcmw `var' `gp'
end

program ca
args gp var
tab `gp' `var', exact row
end

program destr
args str
encode `str', generate(`str'2)
drop `str'
ren `str'2 `str'
end


program stl
args v
encode(`v'), gen(_temp) label(`v')
drop `v'
renam _temp `v'
end

mvdecode _all, mv(-1)

gen today=mdy(10,28,2009)
format today %dCY-N-D
