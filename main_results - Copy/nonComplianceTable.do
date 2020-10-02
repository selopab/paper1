//Double treatment table
/*
Crerat an ITT table 
*/
********************************************************************************
cap label define treatmentsLabel 1 "Control" 2 "Calculator" 3 "Conciliator"
use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
*cap drop tipodeabogado
*ren abogado_pub tipodeabogado
*replace fechadem = fecha_treatment -90 if missing(fechadem)

*keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment ///
*p_actor abogado_pub fechadem

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

/*
*32 drops
*drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1
*/
keep if T1T2 + T1T3 + T2T3 + TAll >0
// 2 casefiles treated more than 2 times
sort junta exp anio fecha
by junta exp anio: keep if _n<3
by junta exp anio: gen firstTreatment = treatment[1]
by junta exp anio: gen secondTreatment = treatment[2]

label val firstTreatment secondTreatment treatmentsLabel

keep junta exp anio firstTreatment secondTreatment
duplicates drop


putexcel set "$sharelatex\Tables\nonCompliance.xlsx", replace
tab secondTreatment firstTreatment  if firstTreatment != 3,matcell(valores) matrow(rownames) matcol(colnames)

putexcel C2 = matrix(valores)

putexcel c1 = ("Control") 
putexcel d1 = ("Calculator") 

putexcel b2 = ("Control") 
putexcel b3 = ("Calculator") 
putexcel b4 = ("Conciliator") 

/*
*32 drops
*drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1
