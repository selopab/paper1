/*Table 4׺  Treatment Effects*/
/*
We add a control for potential endogeneity of the presence of the employee
Column (9)
*/
********************************************************************************

*Set controls.
local controls i.anio i.junta i.phase i.numActores

use "./DB/scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using "./DB/scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
	time_hearing time_hr numActores
gen phase=2
tempfile p2
save `p2'

use "./DB/pilot_operation.dta" , clear	
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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
	time_hearing time_hr numActores
append using `p2'
replace phase=1 if missing(phase)

merge m:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen
merge m:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)
replace seconcilio = 0 if modoTermino != 3 & !missing(modoTermino)
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

replace anio = 2010 if anio < 2010
replace numActores = 3 if numActores>3

********************************************************************************
********************************************************************************
********************************************************************************
*REGRESSIONS
*
*Instrument
gen time_instrument=inlist(time_hr,1,2,7,8) if !missing(time_hr) 
gen time_actor=time_instrument*p_actor

gen treat_inst=treatment*time_instrument
gen treat_p_actor=treatment*p_actor


*Drop conciliator observations
drop if treatment==3

*OLS (FS)
reg p_actor i.treatment time_instrument `controls', r cluster(fecha)
outreg2 using "./Tables/reg_results/CF_ITT.xls", replace ctitle("OLS FS") dec(3) keep(2.treatment 1.p_actor 2.treatment#1.p_actor time_actor)

*Probit (FS)
probit p_actor i.treatment time_instrument `controls', r cluster(fecha)
outreg2 using "./Tables/reg_results/CF_ITT.xls", append ctitle("Probit FS") dec(3)  keep(2.treatment 1.p_actor 2.treatment#1.p_actor time_actor)


cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
reg seconcilio i.treatment##i.p_actor gen_resid_pr `controls', vce(bootstrap, reps(1000)) cluster(fecha)
qui su seconcilio if e(sample)
local DepVarMean=r(mean)
qui su p_actor if e(sample)
local IntMean=r(mean)
outreg2 using "./Tables/reg_results/CF_ITT.xls", append ctitle("CF Probit") ///
addstat(DepVarMean, `DepVarMean', IntMean, `IntMean') dec(3)  keep(2.treatment 1.p_actor 2.treatment#1.p_actor gen_resid_pr)

	

*Now use dummy variables for time groups
tab time_hr, gen(time_hr)
foreach var of varlist time_hr2-time_hr8 {
	gen treat_`var'=treatment*`var'
	}
	
*Probit (FS)
probit p_actor i.treatment i.junta time_hr2-time_hr8 `controls', r cluster(fecha)
outreg2 using "./Tables/reg_results/CF_ITT.xls", append ctitle("Probit FS") dec(3)   keep(2.treatment 1.p_actor 2.treatment#1.p_actor gen_resid_pr time_hr2-time_hr8)

cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr8 = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
reg seconcilio i.treatment##i.p_actor i.junta  gen_resid_pr8 `controls', vce(bootstrap, reps(1000)) cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
qui su seconcilio if e(sample)
local DepVarMean=r(mean)
qui su p_actor if e(sample)
local IntMean=r(mean)
outreg2 using "./Tables/reg_results/CF_ITT.xls", append ctitle("CF Probit") addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', test interaction,`testInteraction') dec(3)  keep(2.treatment 1.p_actor 2.treatment#1.p_actor gen_resid_pr8)
 
