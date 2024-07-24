*! Date variables
*!   yyyy-mm-dd -> (date) 

program dconv
args v
tostring `v', replace
gen temp=date(`v',"YMD")
drop `v'
ren temp `v'
format `v' %dCY-N-D
end





