/*Table C14: Treatment Effects conditional on type of lawyer*/
/*
This dofile reproduces the main treatment effects but by type of lawyer
*/

********************************************************************************

use "$scaleup\DB\scaleup_operation.dta", clear
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

*Homologation
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
save "`temp_p2'"

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub
append using "`temp_p2'"
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
********************************************************************************

*Follow-up (more than 5 months)
merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1

*Remove conciliator
drop if treatment==3

merge 1:1 junta exp anio using "$sharelatex\p1_w_p3\out\inicialesP1Faltantes_wod.dta", keep(1 3) keepusing(fechaDemanda_M tipodeabogado_M fechadecaptura2) gen(_mNuevasIniciales) 
*drop if fechadecaptura2=="05"

foreach var in fechaDemanda tipodeabogado{
replace `var' = `var'_M if missing(`var') 
}

replace abogado_pub = tipodeabogado_M if missing(abogado_pub)

replace abogado_pub = 0 if missing(abogado_pub)
********************************************************************************
	preserve
	keep if abogado_pub==0
	eststo clear
	
	
	
	*********************************
	*			POOLED				*
	*********************************
	
	*Same day
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/Table6_te_privateITT.xls", replace ctitle("Same day. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')

	
	*2 months
	reg convenio_2m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su convenio_2m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/Table6_te_privateITT.xls", append ctitle("2M. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')	
	
	*5 months
	reg convenio_5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su convenio_5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/Table6_te_privateITT.xls", append ctitle("5M. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')	
	
	*5+ months
	reg convenio_m5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su convenio_5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/Table6_te_privateITT.xls", append ctitle("LR. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')	
	
********************************************************************************	

	restore
	
********************************************************************************	
	preserve
	keep if abogado_pub==1

	*********************************
	*			POOLED				*
	*********************************
	
*Same day
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/Table6_te_publicITT.xls", replace ctitle("Same day. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')

	
	*2 months
	reg convenio_2m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su convenio_2m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/Table6_te_publicITT.xls", append ctitle("2M. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')	
	
	*5 months
	reg convenio_5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su convenio_5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/Table6_te_publicITT.xls", append ctitle("5M. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')	
	
	*5+ months
	reg convenio_m5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su convenio_5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/Table6_te_publicITT.xls", append ctitle("LR. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')	
	
	restore
		

	
