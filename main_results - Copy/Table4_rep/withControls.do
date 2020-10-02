/*Table 4׺  Treatment Effects*/
/*
We add a control for potential endogeneity of the presence of the employee
Column (9)
*/
********************************************************************************

use "$scaleup/DB/scaleup_operation.dta", clear
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup/DB/scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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


*Time hearing (Instrument)
gen time_hearing=substr(horario_aud,strpos(horario_aud," "),length(horario_aud))
egen time_hr=group(time_hearing)
gen fechaDemanda =date(fecha_demanda, "YMD")

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub trabajador_base fechaDemanda ///
	time_hearing time_hr /* addresses_* distance  duration */
gen phase=2
save "$paper\DB\temp_p2", replace

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)

*Presence employee
replace p_actor=(p_actor==1)
*Not in experiment
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
rename expediente exp

*Time hearing (Instrument)
gen time_hearing=substr(horarioaudiencia,strpos(horarioaudiencia," "),length(horarioaudiencia))
egen time_hr=group(time_hearing)
gen fechaDemanda =date(fecha_demanda, "YMD")

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub trabajador_base fechaDemanda ///
	time_hearing time_hr /*addresses_*  distance duration */
append using "$paper\DB\temp_p2"
replace phase=1 if missing(phase)



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

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

*Drop conciliator observations
drop if treatment==3
ren abogado_pub tipodeabogado

merge 1:1 junta exp anio using "$sharelatex\p1_w_p3\out\inicialesP1Faltantes_wod.dta", keep(1 3) gen(_mNuevasIniciales) keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M)

foreach var in fechaDemanda tipodeabogado{
replace `var' = `var'_M if missing(`var') & `var'_M>0
}

replace trabajador_base = abs(trabajadordeconfianza_M-1) if !missing(trabajadordeconfianza_M)

tostring anio, gen(s_anio)
gen fechaArtificial = s_anio + "-01-" + "01"
gen fechaDemandaImputed = fechaDemanda
replace fechaDemandaImputed = date(fechaArtificial, "YMD") if missing(fechaDemandaImputed)

gen trabajador_baseImputed = trabajador_base
replace trabajador_baseImputed = 2 if trabajador_baseImputed ==0
replace trabajador_baseImputed = 0 if missing(trabajador_baseImputed)

gen tipodeabogadoImputed = tipodeabogado
replace tipodeabogadoImputed = 0 if missing(tipodeabogadoImputed)
gen missingCasefiles =missing(trabajador_base) & missing(tipodeabogado)

sort junta anio exp 
by junta: gen order = _n
*******************************************************************************
* Normal *
********** 
	*********************************
	*			PHASE 1				*
	*********************************
	
	*Same day conciliation
	reg seconcilio i.treatment i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0 & phase==1, robust  cluster(fecha)
	qui sum seconcilio if e(sample)
	local DepVarMean = r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls.xls", replace ctitle("Same day. P1") addtext(Court Dummies, No) ///
	addstat(Dependant Variable Mean, `DepVarMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor )

	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0 & phase==1 , robust  cluster(fecha)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls.xls", append ctitle("Same day. P1") addtext(Court Dummies, No) ///
	addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor )

	
	*********************************
	*			PHASE 2				*
	*********************************
	
	*Same day conciliation
	reg seconcilio i.treatment i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0 & phase==2, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls.xls", append ctitle("Same day. P2") addtext(Court Dummies, Yes) ///
	addstat(Dependant Variable Mean, `DepVarMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor )

	
	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0 & phase==2 , robust  cluster(fecha)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls.xls", append ctitle("Same day. P2") addtext(Court Dummies, Yes) ///
	addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
	
	*********************************
	*			POOLED				*
	*********************************
	
	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_controls.xls", append ctitle("Same day. Pooled") ///
	addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor )


	
	*Interaction employee was present PROBIT SPECIFICATION
	probit seconcilio i.treatment##i.p_actor i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls.xls", append ctitle("Same day. Pooled. Probit") ///
	addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
	*2 months
	reg convenio_2m i.treatment##i.p_actor i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0, robust  cluster(fecha)
	qui su convenio_2m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls.xls", append ctitle("2M. Pooled") ///
	addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
	*5 months
	reg convenio_5m i.treatment##i.p_actor i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0, robust  cluster(fecha)
	qui su convenio_5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls.xls", append ctitle("5M. Pooled") ///
	addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor )

	*Long run
	reg convenio_m5m i.treatment##i.p_actor i.junta fechaDemanda i.tipodeabogado i.trabajador_base if treatment!=0, robust  cluster(fecha)
	qui su convenio_m5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls.xls", append ctitle("Long Run. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
	****************************************************************************
	* Imputed
	
	
		*********************************
	*			PHASE 1				*
	*********************************
	
	*Same day conciliation
	reg seconcilio i.treatment i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0 & phase==1, robust  cluster(fecha)
	qui sum seconcilio if e(sample)
	local DepVarMean = r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed.xls", replace ctitle("Same day. P1") addtext(Court Dummies, No) addstat(Dependant Variable Mean, `DepVarMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)

	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta c.order#missingCasefiles  i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0 & phase==1 , robust  cluster(fecha)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed.xls", append ctitle("Same day. P1") addtext(Court Dummies, No) addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)
 
	
	*********************************
	*			PHASE 2				*
	*********************************
	
	*Same day conciliation
	reg seconcilio i.treatment i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0 & phase==2, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed.xls", append ctitle("Same day. P2") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)

	
	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0 & phase==2 , robust  cluster(fecha)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed.xls", append ctitle("Same day. P2") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)
	
	
	*********************************
	*			POOLED				*
	*********************************
	
	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed_controls.xls", append ctitle("Same day. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)


	
	*Interaction employee was present PROBIT SPECIFICATION
	probit seconcilio i.treatment##i.p_actor i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed.xls", append ctitle("Same day. Pooled. Probit") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)
	
	*2 months
	reg convenio_2m i.treatment##i.p_actor i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0, robust  cluster(fecha)
	qui su convenio_2m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed.xls", append ctitle("2M. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)
	
	*5 months
	reg convenio_5m i.treatment##i.p_actor i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0, robust  cluster(fecha)
	qui su convenio_5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed.xls", append ctitle("5M. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)

	*Long run
	reg convenio_m5m i.treatment##i.p_actor i.junta c.order#missingCasefiles i.tipodeabogadoImputed#missingCasefiles i.trabajador_baseImputed#missingCasefiles missingCasefiles if treatment!=0, robust  cluster(fecha)
	qui su convenio_m5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT_controls_imputed.xls", append ctitle("Long Run. Pooled") addtext(Court Dummies, Yes) addstat(Dependant Variable Mean, `DepVarMean', Interaction Mean,`IntMean') keep(2.treatment 1.p_actor 2.treatment#1.p_actor  missingCasefiles)

