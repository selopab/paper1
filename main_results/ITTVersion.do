* TREATMENT EFFECTS - ITT
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects  (ITT) for both experimental phases.
Columns (1)-(8)
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
save "$paper\DB\temp_p2", replace

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub
append using "$paper\DB\temp_p2"
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
merge 1:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen keep(1 3)
merge 1:1 junta exp anio using "$sharelatex\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1
replace convenio_m5m = 1 if modoTermino == 3
replace convenio_m5m = 0 if modoTermino != 3 & !missing(modoTermino)
replace seconcilio = 0 if modoTermino != 3 & !missing(modoTermino)


	*********************************
	*			PHASE 1				*
	*********************************
	
	*Same day conciliation
	reg seconcilio i.treatment i.junta if treatment!=0 & phase==1, robust  cluster(fecha)
	qui sum seconcilio if e(sample)
	local DepVarMean = r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", replace ctitle("Same day. P1") ///
	addtext(Court Dummies, Yes, Casefile Controls, No) keep(2.treatment 1.p_actor 2.treatment#1.p_actor ) ///
	addstat(Dependent Variable Mean, `DepVarMean')  dec(3)


	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0 & phase==1 , robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", append ctitle("Same day. P1")  ///
	addtext(Court Dummies, Yes, Casefile Controls, No) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor ) dec(3)

	
	*********************************
	*			PHASE 2				*
	*********************************
	
	*Same day conciliation
	reg seconcilio i.treatment i.junta if treatment!=0 & phase==2, robust  cluster(fecha)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", append ctitle("Same day. P2")  ///
	addtext(Court Dummies, Yes, Casefile Controls, No) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor ) dec(3)

	
	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0 & phase==2 , robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", append ctitle("Same day. P2")  ///
	addtext(Court Dummies, Yes, Casefile Controls, No) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean',test interaction,`testInteraction') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor )	dec(3)
	
	*********************************
	*			POOLED				*
	*********************************
	
	*Interaction employee was present
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", append ctitle("Same day. Pooled")  ///
	addtext(Court Dummies, Yes, Casefile Controls, No) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean',test interaction,`testInteraction') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor ) dec(3)


	
	*Interaction employee was present PROBIT SPECIFICATION
	probit seconcilio i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", append ctitle("Same day. Pooled. Probit")  ///
	addtext(Court Dummies, Yes, Casefile Controls, No) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean',test interaction,`testInteraction') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor )	dec(3)
	*2 months
	reg convenio_2m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su convenio_2m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", append ctitle("2M. Pooled")  ///
	addtext(Court Dummies, Yes, Casefile Controls, No) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor )	dec(3)
	
	*5 months
	reg convenio_5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui su convenio_5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", append ctitle("5M. Pooled")  ///
	addtext(Court Dummies, Yes, Casefile Controls, No) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor ) dec(3)

	*Long run
	reg convenio_m5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su convenio_m5m if e(sample)
	local DepVarMean=r(mean)
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsITT.xls", append ctitle("Long Run. Pooled")  ///
	addtext(Court Dummies, Yes, Casefile Controls, No) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean',test interaction,`testInteraction') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor ) dec(3)



	