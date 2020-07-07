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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
	time_hearing time_hr /*addresses_*  distance duration */
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

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

*Drop conciliator observations
drop if treatment==3


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
reg p_actor i.treatment time_instrument i.junta, r cluster(fecha)
outreg2 using "$sharelatex/Tables/reg_results/CF_ITT.xls", replace ctitle("OLS FS")

*Probit (FS)
probit p_actor i.treatment time_instrument i.junta, r cluster(fecha)
outreg2 using "$sharelatex/Tables/reg_results/CF_ITT.xls", append ctitle("Probit FS")


cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
reg seconcilio i.treatment##i.p_actor i.junta gen_resid_pr, vce(bootstrap, reps(1000)) cluster(fecha)
qui su seconcilio if e(sample)
local DepVarMean=r(mean)
qui su p_actor if e(sample)
local IntMean=r(mean)
outreg2 using "$sharelatex/Tables/reg_results/CF_ITT.xls", append ctitle("CF Probit") addstat(DepVarMean, `DepVarMean', IntMean, `IntMean')

	

*Now use dummy variables for time groups
tab time_hr, gen(time_hr)
foreach var of varlist time_hr2-time_hr8 {
	gen treat_`var'=treatment*`var'
	}
	
*Probit (FS)
probit p_actor i.treatment i.junta time_hr2-time_hr8, r cluster(fecha)
outreg2 using "$sharelatex/Tables/reg_results/CF_ITT.xls", append ctitle("Probit FS")

cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr8 = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
reg seconcilio i.treatment##i.p_actor i.junta  gen_resid_pr8, vce(bootstrap, reps(1000)) cluster(fecha)
qui su seconcilio if e(sample)
local DepVarMean=r(mean)
qui su p_actor if e(sample)
local IntMean=r(mean)
outreg2 using "$sharelatex/Tables/reg_results/CF_ITT.xls", append ctitle("CF Probit") addstat(DepVarMean, `DepVarMean', IntMean, `IntMean')

