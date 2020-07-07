* TREATMENT EFFECTS - ITT
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects for both experimental phases.
Columns (1)-(8)
*/
********************************************************************************

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0 | missing(tratamientoquelestoco)
rename tratamientoquelestoco treatment

*keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub
*append using "$paper\DB\temp_p2"
*replace phase=1 if missing(phase)


*Follow-up (more than 5 months)
merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen keep(1 3)

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1
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
drop if T1T2==1 & treatment == 1
*46 drops
*drop if T1T3==1
*31 drops
*drop if T2T3==1
*8 drops
drop if TAll==1

*bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
sort junta exp anio fecha
bysort junta exp anio: keep if _n==1
********************************************************************************

*Drop conciliator observations
drop if treatment==3

bysort anio exp: gen order = _n


gen fechaDemanda = date(fecha_demanda, "YMD")
merge 1:1 junta exp anio using "$sharelatex\p1_w_p3\out\inicialesP1Faltantes_wod.dta", keep(1 3) gen(_mNuevasIniciales) keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M)

foreach var in fechaDemanda tipodeabogado{
replace `var' = `var'_M if missing(`var') & `var'_M>0
}

replace trabajador_base = abs(trabajadordeconfianza_M-1) if !missing(trabajadordeconfianza_M)

gen fechaArtificial = s_anio + "-01-" + "01"
gen fechaDemandaImputed = fechaDemanda
replace fechaDemandaImputed = date(fechaArtificial, "YMD") if missing(fechaDemandaImputed)

gen trabajador_baseImputed = trabajador_base
replace trabajador_baseImputed = 2 if trabajador_baseImputed ==0
replace trabajador_baseImputed = 0 if missing(trabajador_baseImputed)

gen tipodeabogadoImputed = tipodeabogado
replace tipodeabogadoImputed = 0 if missing(tipodeabogadoImputed)
gen missingCasefiles =missing(tipodeabogado)

gen phase = 1

	*********************************
	*		Original specification	*
	*********************************
	
	*Original specification
	reg seconcilio i.treatment i.junta if treatment!=0 & phase==1, robust  cluster(fecha)
	qui sum seconcilio if e(sample)
	local DepVarMean = r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsNewSpecification.xls", replace ctitle("Original specification") addtext(Court Dummies, No) addstat(Dependant Variable Mean, `DepVarMean')

	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0 & phase==1 , robust  cluster(fecha)
	qui su seconcilio if e(sample) & p_actor==1
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsNewSpecification.xls", append ctitle("Original specification") addtext(Court Dummies, No) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')

	*************************************************
	*		Original specification, reduced sample	*
	*************************************************
	
	*Original specification
	reg seconcilio i.treatment i.junta if treatment!=0 & phase==1 & !missing(fechaDemanda), robust  cluster(fecha)
	qui sum seconcilio if e(sample)
	local DepVarMean = r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsNewSpecification.xls", append ctitle("Original specification. Reduced sample.") addtext(Court Dummies, No) addstat(Dependant Variable Mean, `DepVarMean')

	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0 & phase==1 & !missing(fechaDemanda) , robust  cluster(fecha)
	qui su seconcilio if e(sample) & p_actor==1
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsNewSpecification.xls", append ctitle("Original specification. Reduced sample.") addtext(Court Dummies, No) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')

	*************************************************
	*		Case-level controlls, reduced sample	*
	*************************************************
	
	*Original specification
	reg seconcilio i.treatment i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0 & phase==1 & !missing(tipodeabogado), robust  cluster(fecha)
	qui sum seconcilio if e(sample)
	local DepVarMean = r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsNewSpecification.xls", append ctitle("Additional controls. Reduced sample.") addtext(Court Dummies, No) addstat(Dependant Variable Mean, `DepVarMean')

	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor fechaDemanda i.junta i.tipodeabogado i.trabajador_base if treatment!=0 & phase==1 & !missing(tipodeabogado) , robust  cluster(fecha)
	qui su seconcilio if e(sample) & p_actor==1
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsNewSpecification.xls", append ctitle("Additional controls. Reduced sample.") addtext(Court Dummies, No) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')

	*****************************************************
	*	Imputed Case-level controlls. Complete sample	*
	*****************************************************
	
	*Original specification
	reg seconcilio i.treatment i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0 & phase==1, robust  cluster(fecha)
	qui sum seconcilio if e(sample)
	local DepVarMean = r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsNewSpecification.xls", append ctitle("Imputed controls. Complete sample.") addtext(Court Dummies, No) addstat(Dependant Variable Mean, `DepVarMean')

	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0 & phase==1, robust  cluster(fecha)
	qui su seconcilio if e(sample) & p_actor==1
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsNewSpecification.xls", append ctitle("Imputed controls. Complete sample.") addtext(Court Dummies, No) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean')
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	