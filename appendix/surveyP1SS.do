/* Survey SS
*/

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
********************************************************************************

bysort junta exp anio: gen DuplicatesPredrop=_N
forvalues i=1/3{
	gen T`i'_aux=[treatment==`i'] 
	bysort junta exp anio: egen T`i'=max(T`i'_aux)
}

gen T1T2=[T1==1 & T2==1]
gen T1T3=[T1==1 & T3==1]
gen T2T3=[T2==1 & T3==1]
gen TAll=[T1==1 & T2==1 & T3==1]

replace T1T2=0 if TAll==1
replace T1T3=0 if TAll==1
replace T2T3=0 if TAll==1

*32 drops
*drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1

*bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
*sort junta exp anio fecha
*bysort junta exp anio: keep if _n==1
********************************************************************************
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

keep folio

tempfile selectedCasefiles
save `selectedCasefiles'
/* Actores */

putexcel set "$sharelatex\Tables\surveySS.xlsx", sheet("Completa") modify
use "$sharelatex/DB/Append Encuesta Inicial Actor.dta", clear
merge 1:1 folio using `selectedCasefiles', nogen keep(3) 

//1) Age
putexcel A5 = ("Age")
qui sum Age
putexcel C5 = (r(mean))
putexcel C6 = (r(sd))
putexcel c7 = (r(N))

// 2) Tenure. Lawyersonly (9 - 11) 

// 3) Number of lawsuits. L (13 - 17)

// 4) Current number of lawsuits. L (19 - 23)

// 5) Number of employees
putexcel A25 = ("Number of employees") 
tab numempleados, matcell(empMat)  matrow(empLevels)
putexcel B25 = matrix(empLevels)
putexcel C25 = matrix(empMat)
putexcel c29 = (r(N))

// 6) Percentage of what is obtained
putexcel A31 = ("Percentage of what is obtained")
qui sum porc_pago
putexcel C31 = (r(mean))
putexcel C32 = (r(sd))
putexcel c33 = (r(N))

// 7) Probability of other part of winning
putexcel A35 = ("Probability of winning")
qui sum probotro
putexcel C35 = (r(mean))
putexcel C36 = (r(sd))
putexcel c37 = (r(N))

// 8) Education
putexcel A39 = ("Education")
tab A_1_2, matcell(edMat) matrow(edLevels)
putexcel b39 = matrix(edLevels)
putexcel C39 = matrix(edMat)
putexcel c43 = (r(N))

// 10) Changed lawyer
putexcel a45 =("Have you changed lawyer during trial?")
qui sum A_4_6
putexcel c45 = (r(mean))
putexcel c46 = (r(sd))
putexcel c47 = (r(N))

//11) Probability of winning trial
putexcel a49 = ("Probability of winning trial")
qui sum A_5_1
putexcel c49 = (r(mean))
putexcel c50 = (r(sd))
putexcel c51 = (r(N))

// 12) Most probable amount
putexcel a53 = ("Most probable amount")
qui sum A_5_5
putexcel c53 = (r(mean))
putexcel c54 = (r(sd))
putexcel c55 = (r(N))

// 13) Most probable time
putexcel a57 = ("Most probable time")
qui sum A_5_8
putexcel c57 = (r(mean))
putexcel c58 = (r(sd))
putexcel c59 = (r(N))

// 14) How well were you treated?
putexcel a61 = ("How well were you treated?")
tab A_6_1, matcell(trMat) matrow(trLevels)
putexcel b61 = matrix( trLevels)
putexcel C61 = matrix(trMat)
putexcel c65 = (r(N))

// 15) How common is the company mistreat its employees?
putexcel a67 = ("How common is the company mistreat its employees?")
tab A_6_2, matcell(trcMat) matrow(trcLevels)
putexcel b67 = matrix(trcLevels)
putexcel C67 = matrix( trcMat)
putexcel c71 = (r(N))

// 16) Level of anger with company
putexcel A73 = ("Level of anger with company")
tab A_6_3, matcell(angerMat) matrow(angerLevels)
putexcel b73 = matrix(trcLevels)
putexcel C73 = matrix( trcMat)
putexcel c77 = (r(N))

// 17) Repeated player
putexcel A79 = ("Repeated player")
sum A_7_3
putexcel c79 = (r(mean))
putexcel c80 = (r(sd))
putexcel c81 = (r(N))

// Currently employed
putexcel A83 = ("Currently employed")
sum A_9_1 
putexcel c83 = (r(mean))
putexcel c84 = (r(sd))
putexcel c85 = (r(N))

// Looking for a job
putexcel A87 = ("Looking for a job")
sum A_9_2
putexcel c87 = (r(mean))
putexcel c88 = (r(sd))
putexcel c89 = (r(N))
 
// Probability of finding a job in next 3 months
putexcel A91 = ("Probability of finding a job in next 3 months")
sum A_9_3
putexcel c91 = (r(mean))
putexcel c92 = (r(sd))
putexcel c93 = (r(N))

******************
/* Actor lawyer */
******************
use "$sharelatex/DB/Append Encuesta Inicial Representante Actor.dta", clear
merge m:1 folio using `selectedCasefiles', nogen keep(3) 

//1) Age
qui sum Age
putexcel D5 = (r(mean))
putexcel D6 = (r(sd))
putexcel D7 = (r(N))

// 2) Tenure
putexcel A9 = ("Tenure") 
qui sum Tenure
putexcel D9 = (r(mean))
putexcel D10 = (r(sd))
putexcel D11 = (r(N))

// 3) Number of lawsuits
putexcel A13 = ("Number of lawsuits")
tab litigiosha, matcell(numLaw) matrow(numLawLevels)
putexcel B13 = matrix(numLawLevels)
putexcel D13 = matrix( numLaw)
putexcel D17 = (r(N))

// 4) Current number of lawsuits
putexcel A19 = ("Current number of lawsuits")
tab litigiosesta, matcell(cnumLaw) matrow(cnumLawLevels)
putexcel B19 = matrix(cnumLawLevels)
putexcel D19 = matrix(cnumLaw)
putexcel D23 = (r(N))

// 5) Number of employees
tab numempleados, matcell(empMat)  matrow(empLevels)
putexcel D25 = matrix(empMat)
putexcel D29 = (r(N))

// 6) Percentage of what is obtained
qui sum porc_pago
putexcel D31 = (r(mean))
putexcel D32 = (r(sd))
putexcel D33 = (r(N))

// 7) Probability of other part of winning
qui sum probotro
putexcel D35 = (r(mean))
putexcel D36 = (r(sd))
putexcel D37 = (r(N))

// 8) Education. P. (39 - 41)

// 9) Changed lawyer. P. (43 - 45)

//10) Probability of winning trial
qui sum A_5_1
putexcel D49 = (r(mean))
putexcel D50 = (r(sd))
putexcel D51 = (r(N))

// 11) Most probable amount
qui sum A_5_5
putexcel D53 = (r(mean))
putexcel D54 = (r(sd))
putexcel D55 = (r(N))

// 12) Most probable time
qui sum A_5_8
putexcel D57 = (r(mean))
putexcel D58 = (r(sd))
putexcel D59 = (r(N))

**********************
/* Defendant lawyer */
**********************

use "$sharelatex/DB/Append Encuesta Inicial Representante Demandado.dta", clear
merge m:1 folio using `selectedCasefiles', nogen keep(3) 

//1) Age

qui sum Age
putexcel E5 = (r(mean))
putexcel E6 = (r(sd))
putexcel E7 = (r(N))

// 2) Tenure
qui sum Age
putexcel E9 = (r(mean))
putexcel E10 = (r(sd))
putexcel E11 = (r(N))

// 3) Number of lawsuits
tab litigiosha, matcell(numLaw) matrow(numLawLevels)
putexcel E13 = matrix( numLaw)
putexcel E17 = (r(N))

// 4) Current number of lawsuits
tab litigiosesta, matcell(cnumLaw) matrow(cnumLawLevels)
putexcel E19 = matrix(cnumLaw)
putexcel E23 = (r(N))

// 5) Number of employees
tab numempleados, matcell(empMat)  matrow(empLevels)
putexcel E25 = matrix(empMat)
putexcel E29 = (r(N))

// 6) Percentage of what is obtained. (31 - 33)

// 7) Probability of other part of winning
qui sum probotro
putexcel E35 = (r(mean))
putexcel E36 = (r(sd))
putexcel E37 = (r(N))

// 8) Education. P. (39 - 41)

// 9) Changed lawyer. P. (43 - 45)


//10) Probability of winning trial
qui sum A_5_1
putexcel E49 = (r(mean))
putexcel E50 = (r(sd))
putexcel E51 = (r(N))

// 11) Most probable amount
qui sum A_5_5
putexcel E53 = (r(mean))
putexcel E54 = (r(sd))
putexcel E55 = (r(N))

// 12) Most probable time
qui sum A_5_8
putexcel E57 = (r(mean))
putexcel E58 = (r(sd))
putexcel E59 = (r(N))






