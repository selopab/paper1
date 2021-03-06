* TREATMENT EFFECTS - ITT
/*Table 6  Treatment Effects*/
/*
This table estimates the main treatment effects for PHASE 1 and PHASE 2
Columns (1)-(8)
*/
********************************************************************************

use "$scaleup\DB\scaleup_operation.dta", clear //phase2
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

*Homologation - TREATMENT
gen treatment=.
replace treatment=2 if dia_tratamiento==1
replace treatment=1 if dia_tratamiento==0
rename convenio seconcilio
rename convenio_seg_2m convenio_2m 
rename convenio_seg_5m convenio_5m
gen fecha=date(fecha_lista,"YMD")
format fecha %td

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub
gen phase=2
tempfile temp_p2
save `temp_p2'

use "$sharelatex/DB/pilot_operation.dta" , clear	//PHASE 1		
replace junta=7 if missing(junta) //phase 1 solo en J7
rename expediente exp
drop if tratamientoquelestoco==0

*Presence employee
rename tratamientoquelestoco treatment
//drop if (treatment!=1) & (treatment!=2)

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor ///
abogado_pub c1_cantidad_total_pagada_conveni
append using `temp_p2'
replace phase=1 if missing(phase)

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
*Follow-up (more than 5 months)

merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", keep(1 3)
merge 1:1 junta exp anio using "$sharelatex\Terminaciones\Data\terminaciones.dta", gen(merchados) keep(1 3)

gen ganancia = c1_cantidad_total_pagada_conveni
replace ganancia = cant_convenio_exp if missing(ganancia)
replace ganancia = cantidadOtorgada if missing(ganancia)

replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1

replace modo_termino_expediente=3 if missing(modo_termino_expediente) & convenio_m5m==1
replace modo_termino_expediente=2 if missing(modo_termino_expediente)

replace modo_termino_expediente = modoTermino  if missing(modo_termino_expediente)
replace modo_termino_expediente = 7 if modo_termino_expediente==6 & missing(ganancia)

label define finales 1 "Expired" 2 "Continues" 3 "Settled" 4 "Dropped" 5 "" 6 "Court ruling with payment" 7 "Court ruling without payment", modify
label val modo_termino_expediente finales

tab modo_termino_expediente treatment if modo_termino_expediente != 5 & phase == 1, column nofreq matcell(valores)
putexcel set "$sharelatex\Tables\Table5_December2018Followup_privatep1.xlsx", mod

putexcel C1 = ("Control") D1 = ("Calculator")
putexcel B2 = ("Expired") B3 = ("Continues") B4 = ("Settled") B5 = ("Dropped") B6 = ("Court ruling with payment") B7 = ("Court ruling without payment")
putexcel C2 = matrix(valores)

putexcel set "$sharelatex\Tables\Table5_December2018Followup", mod sheet("Table5_December2018Followup")

putexcel B2 = ("Expired") B3 = ("Continue") B4 = ("Settlement") B5 = ("Drop") B6 = ("Court ruling") B7 = ("Court ruling without payment")
putexcel C1 = ("Control") D1 = ("Calculator") 
tab modo_termino_expediente treatment if modo_termino_expediente != 5, column nofreq matcell(valores)
forvalues i = 1/5{
	local val = valores[1, `i']
	local renglon = `i' +1
	putexcel C`renglon' = (`val')
	
	local val = valores[2, `i']
	local renglon = `i' +1
	putexcel D`renglon' = (`val')
}	
	
	/*
forvalues j = 1/2{
tab treatment modo_termino_expediente if modo_termino_expediente != 5 & phase==`j', matcell(valores)

putexcel set "$sharelatex\Tables\Table5_December2018Followup.xlsx", mod sheet("P`j'")

putexcel B2 = ("Expired") B3 = ("Continue") B4 = ("Settlement") B5 = ("Drop") B6 = ("Court ruling") B7 = ("Court ruling without payment")
putexcel C1 = ("Control") D1 = ("Calculator") 
forvalues i = 1/5{
	local val = valores[1, `i']
	local renglon = `i' +1
	putexcel C`renglon' = (`val')
	
	local val = valores[2, `i']
	local renglon = `i' +1
	putexcel D`renglon' = (`val')
}
	}
	
	
**Tab percentages
tab modo_termino_expediente treatment if modo_termino_expediente != 5, column nofreq matcell(valores)

	putexcel set "$sharelatex\Tables\Table5_December2018Followup.xlsx", mod sheet("aver")
	putexcel B2 = matrix(valores)

	
