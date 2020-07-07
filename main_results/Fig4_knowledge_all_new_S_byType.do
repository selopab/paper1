/*Figure 4. :  Knowledge about Law and their Own Claims in Lawsuit*/
/* 
knowledge of the law --panel (a) and (b)--
*/

use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	
merge m:1 folio using  "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , keep( 2 3)


*Histogram what the law says
	*A_7_1=knows
gen correct_sabe=( A_7_1_O==90) 

collapse (mean) mean_1=A_7_1 (sd) sd_1=A_7_1  (count) n_1=A_7_1 ///
		(mean) mean_2=correct_sabe (sd) sd_2=correct_sabe  (count) n_2=correct_sabe, ///
		by(abogado_pub)
		
gen id=1
reshape long mean_ sd_ n_, i(abogado_pub) j(sabe)

label define sabe 1 "Knows" 2 "Correctly knows" , replace
label values sabe sabe

tempfile primeras 
save `primeras'

************************************************
use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	
merge m:1 folio using  "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , keep(3)

gen asked_indemconst=(A_7_2_1==1 | A_7_2_2==1 | A_7_2_3==1 | A_7_2_4==1 | A_7_2_5==1 | A_7_2_6==1 | A_7_2_7==1 | A_7_2_8==1 | A_7_2_9==1)
gen asked_reinstalacion=(A_7_2_1==3 | A_7_2_2==3 | A_7_2_3==3 | A_7_2_4==3 | A_7_2_5==3 | A_7_2_6==3 | A_7_2_7==3 | A_7_2_8==3 | A_7_2_9==3)
gen asked_rechrextrat=(A_7_2_1==4 | A_7_2_2==4 | A_7_2_3==4 | A_7_2_4==4 | A_7_2_5==4 | A_7_2_6==4 | A_7_2_7==4 | A_7_2_8==4 | A_7_2_9==4)
gen asked_primavac=(A_7_2_1==6 | A_7_2_2==6 | A_7_2_3==6 | A_7_2_4==6 | A_7_2_5==6 | A_7_2_6==6 | A_7_2_7==6 | A_7_2_8==6 | A_7_2_9==6)
gen asked_nosabe=(A_7_2_1==.s)	


gen correct_indemconst=(asked_indemconst==indemconsttdummy)
gen correct_reinstalacion=(asked_reinstalacion==reinstalaciont)
gen correct_rechrextrat=(asked_rechrextrat==rechrextra)
gen correct_primavac=(asked_primavac==prima_vac)

collapse (mean) mean_1=correct_indemconst (sd) sd_1=correct_indemconst  (count) n_1=correct_indemconst ///
	(mean) mean_2=correct_reinstalacion (sd) sd_2=correct_reinstalacion  (count) n_2=correct_reinstalacion ///
	(mean) mean_3=correct_rechrextrat (sd) sd_3=correct_rechrextrat  (count) n_3=correct_rechrextrat ///
	(mean) mean_4=correct_primavac (sd) sd_4=correct_primavac  (count) n_4=correct_primavac, by(abogado_pub)



*gen id=1
reshape long mean_ sd_ n_, i(abogado_pub) j(asked)

rename asked sabe

replace sabe = sabe+2
append using `primeras'
sort sabe

label define sabe 1 "Knows" 2 "Correctly knows" 3 "Const. comp." 4  "Reinstatement" ///
5 "Extra hrs" 6 "Holiday bonus", replace

label values sabe sabe

rename mean_ mean_total
rename sd_ sd_total
rename n_ n_total

generate hi_total = max( min (mean_total + invttail(n_total-1,0.05)*(sd_total / sqrt(n_total)),1),0) if n_total!=0
generate low_total = max( min (mean_total - invttail(n_total-1,0.05)*(sd_total / sqrt(n_total)),1),0) if n_total!=0

local N = 2*_N
*Aux variables to graph in x pos
forvalues i = 1/`N'{
cap gen v`i' = `i'
}

/*
local n_tot1 = n_total[1]
local n_tot2 = n_total[2]
local n_tot3 = n_total[3]
local n_tot4 = n_total[4]
local n_tot5 = n_total[5]
local n_tot6 = n_total[6]
*/

twoway (bar mean_total v1 if sabe==2 & abogado_pub==0, color(black)) ///
	   (bar mean_total v2 if sabe==2 & abogado_pub==1, color(gs4)) ///
	   (bar mean_total v4 if sabe==3 & abogado_pub==0, color(black)) ///
	   (bar mean_total v5 if sabe==3 & abogado_pub==1, color(gs4)) ///
	   (bar mean_total v7 if sabe==4 & abogado_pub==0, color(black)) ///
	   (bar mean_total v8 if sabe==4 & abogado_pub==1, color(gs4)) ///
	   (bar mean_total v10 if sabe==5 & abogado_pub==0, color(black)) ///
	   (bar mean_total v11 if sabe==5 & abogado_pub==1, color(gs4)) ///
	   (rcap hi_total low_total v1 if sabe==2 & abogado_pub==0, color(black) lpattern(solid)) ///
	   (rcap hi_total low_total v2 if sabe==2 & abogado_pub==1, color(black) lpattern(solid)) ///
	   (rcap hi_total low_total v4 if sabe==3 & abogado_pub==0, color(black) lpattern(solid)) ///
	   (rcap hi_total low_total v5 if sabe==3 & abogado_pub==1, color(black) lpattern(solid)) ///
	   (rcap hi_total low_total v7 if sabe==4 & abogado_pub==0, color(black) lpattern(solid)) ///
	   (rcap hi_total low_total v8 if sabe==4 & abogado_pub==1, color(black) lpattern(solid)) ///
	   (rcap hi_total low_total v10 if sabe==5 & abogado_pub==0, color(black) lpattern(solid)) ///
	   (rcap hi_total low_total v11 if sabe==5 & abogado_pub==1, color(black) lpattern(solid)), ///
		ylabel (0(0.2)1) ///
		ytitle("Percentage Correct") ///
		legend(row(2) order(1 "Private" 2 "Public")) ///
		xlabel( 1.5 `" "Correctly knows" "Sev. Payment" "' ///
		4.5 `" "Knows if asked" "Sev. Payment" "'  ///
		7.5 `" "Knows if asked" "Reinstatement" "' ///
		10.5 `" "Knows if asked" "Overtime" "', noticks angle(vertical)) ///
		 scheme(s2mono) graphregion(color(none))
		graph export "$sharelatex\Figures\knows_all_byType.pdf", replace

	  






