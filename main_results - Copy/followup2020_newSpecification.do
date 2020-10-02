* TREATMENT EFFECTS - ITT - con merge a faltanP1
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects for both experimental phases.
Columns (1)-(8)
*/
********************************************************************************
global int=3.43			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0 | tratamientoquelestoco==3
rename tratamientoquelestoco treatment

replace fechadem = fecha_treatment -90 if missing(fechadem)

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

*32 drops
drop if T1T2==1 & treatment == 1
*46 drops
*drop if T1T3==1
*31 drops
*drop if T2T3==1
*8 drops
drop if TAll==1


bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
sort junta exp anio fecha
bysort junta exp anio: keep if _n==1
********************************************************************************

merge 1:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", keep(1 3)
merge 1:1 junta exp anio using "E:\Pilot3\Terminaciones\Data\terminaciones.dta", gen(merchados) keep(1 3)

//Merge nuevas iniciales-----------------------------
merge 1:1 junta exp anio using "$sharelatex\p1_w_p3\out\inicialesP1Faltantes_wod.dta", keep(1 3) gen(_mNuevasIniciales) keepusing(sueldo_est_F per_sueldo_est_F gen_F fecha_entrada_F fecha_salida_F antiguedad_F fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M)

*generar salario diario
label define periodicidad_sueldo 0 "diario" 1 "mensual" 2 "quincenal" 3 "semanal"
label values per_sueldo_est_F periodicidad_sueldo
gen sueldo_diario_F=sueldo_est_F if per_sueldo_est_F==0
replace sueldo_diario_F=sueldo_est_F/30 if per_sueldo_est_F==1
replace sueldo_diario_F=sueldo_est_F/15 if per_sueldo_est_F==2
replace sueldo_diario_F=sueldo_est_F/7 if per_sueldo_est_F==3
replace salario_diario=sueldo_diario_F if missing(salario_diario)
*genero
replace gen=gen_F if missing(gen)
*antiguedad
gen ant_anios_F=antiguedad_F/365
replace c_antiguedad=ant_anios_F if missing(c_antiguedad)
//---------------------------------------------------

replace modoTermino = modo_termino_expediente if missing(modoTermino)

gen fechaTermino = fecha_convenio
replace fechaTermino = fecha_termino_exp if missing(fechaTermino)
replace fechaTermino = fechaExp if missing(fechaTermino) | modo_termino_expediente==2

gen ganancia = c1_cantidad_total_pagada_conveni
replace ganancia = cant_convenio_exp if missing(ganancia)
replace ganancia = cantidadOtorgada if missing(ganancia)
replace ganancia = 0 if missing(ganancia) | modoTermino==2
*replace ganancia = . if modoTermino==2


gen months=(fechaTermino-fecha_treatment)/30
gen npv=.

replace abogado_pub = 0 if missing(abogado_pub)

replace npv=(ganancia/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(ganancia/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1
replace npv = 0 if missing(npv) & !missing(modoTermino)

gen lganancia = log(ganancia+1)
sum npv 
local elMinimo = `r(min)'
gen lnpv = log(npv-`elMinimo'+1)

winsor2 ganancia
gen npv_w = .
replace npv_w=(ganancia_w/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv_w=(ganancia_w/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1
replace npv_w = 0 if missing(npv_w) & !missing(modoTermino)

gen perdiste = npv<0 & !missing(npv)
reg perdiste i.treatment i.junta, robust  cluster(fecha)

gen lganancia_w = log(ganancia_w+1)
sum npv_w 
local elMinimo = `r(min)'
gen lnpv_w = log(npv_w-`elMinimo'+1)
 
 *OJO: CON EL LOG PIERDES LOS NEGATIVOS 

gen mpc = 1-prob_convenio
foreach var in prob_desist prob_cad prob_laudos prob_laudopos prob_laudocero{
gen `var'_conditional = `var'/(1-prob_convenio)
}

gen gananciaImputed = ganancia
replace gananciaImputed = liq_laudopos*prob_laudopos if !missing(prob_laudopos) ///
& !missing(liq_laudopos) & modoTermino==2

 bysort anio exp: gen order = _n


gen duracionEsperada = prob_desist_conditional*dur_desist + prob_cad_conditional*dur_cad + ///
prob_laudopos_conditional*dur_laudopos + dur_laudocero*prob_laudocero_conditional

gen diasDuracionEsperada = duracionEsperada*365

gen npvImputed=.

replace npvImputed=(gananciaImputed/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npvImputed=(gananciaImputed/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1
replace npvImputed = 0 if missing(npv) & !missing(modoTermino)

*reg npvImputed i.treatment i.p_actor i.treatment#i.p_actor if abogado_pub==0, robust cluster(fecha_treatment) 
gen lnpvImputed = log(npvImputed+2001)



*Drop conciliator observations
drop if treatment==3
gen fechaDemanda = date(fecha_demanda, "YMD")

foreach var in fechaDemanda tipodeabogado{
replace `var' = `var'_M if missing(`var') & `var'_M>0
}

replace trabajador_base = abs(trabajadordeconfianza_M-1) if !missing(trabajadordeconfianza_M)

gen fechaArtificial = s_anio + "-01-" + "01"
gen fechaDemandaImputed = fechaDemanda
replace fechaDemandaImputed = date(fechaArtificial, "YMD") if missing(fechaDemandaImputed) | fechaDemandaImputed <0 

gen trabajador_baseImputed = trabajador_base
replace trabajador_baseImputed = 2 if trabajador_baseImputed ==0
replace trabajador_baseImputed = 0 if missing(trabajador_baseImputed)

gen tipodeabogadoImputed = tipodeabogado
replace tipodeabogadoImputed = 0 if missing(tipodeabogadoImputed)

gen phase = 1
gen missingCasefiles =missing(tipodeabogado)


********************************************************************************
*																			   *
*								NPV											   *
*																			   *
********************************************************************************

*Primero sin controles
	
*1) Just treatment
reg npv i.treatment, robust cluster(fecha_treatment)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_npv.xls", replace ctitle("npv") ///
	addtext(BVC, No) addstat(DepVarMean, `DepVarMean')

*2) Treatment presence interaction
reg npv i.treatment i.p_actor i.treatment#i.p_actor, robust cluster(fecha_treatment)	
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_npv.xls", append ctitle("npv") ///
addtext(BVC, No) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean') 

*3) Just treatment + casefile level controls
reg npv i.treatment fechaDemanda i.tipodeabogado i.trabajador_base, robust cluster(fecha_treatment)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_npv.xls", append ctitle("npv. Controls") ///
	addtext(BVC, No) addstat(DepVarMean, `DepVarMean')

*4) Treatment presence interaction + casefile level controls
reg npv i.treatment i.p_actor i.treatment#i.p_actor fechaDemanda i.tipodeabogado i.trabajador_base, robust cluster(fecha_treatment)	
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_npv.xls", append ctitle("npv. Controls") ///
addtext(BVC, No) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean') 

*5) Just treatment + casefile level imputed controls
reg npv i.treatment c.order#i.missingCasefiles i.tipodeabogadoImputed#i.missingCasefiles i.trabajador_baseImputed#i.missingCasefiles missingCasefiles, robust cluster(fecha_treatment)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_npv.xls", append ctitle("npv. Imputed Controls") ///
	addtext(BVC, No) addstat(DepVarMean, `DepVarMean')

*6) Treatment presence interaction + imputed casefile level controls
reg npv i.treatment i.p_actor i.treatment#i.p_actor c.order#i.missingCasefiles i.tipodeabogadoImputed#i.missingCasefiles i.trabajador_baseImputed#i.missingCasefiles missingCasefiles, robust cluster(fecha_treatment)	
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_npv.xls", append ctitle("npv. Imputed Controls") ///
addtext(BVC, No) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean') 


********************************************************************************
*																			   *
*							log(NPV)										   *
*																			   *
********************************************************************************

*Primero sin controles
	
*1) Just treatment
reg lnpv i.treatment, robust cluster(fecha_treatment)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_lnpv.xls", replace ctitle("lnpv") ///
	addtext(BVC, No) addstat(DepVarMean, `DepVarMean')

*2) Treatment presence interaction
reg lnpv i.treatment i.p_actor i.treatment#i.p_actor, robust cluster(fecha_treatment)	
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_lnpv.xls", append ctitle("lnpv") ///
addtext(BVC, No) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean') 

*3) Just treatment + casefile level controls
reg lnpv i.treatment fechaDemanda i.tipodeabogado i.trabajador_base, robust cluster(fecha_treatment)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_lnpv.xls", append ctitle("lnpv. Controls") ///
	addtext(BVC, No) addstat(DepVarMean, `DepVarMean')

*4) Treatment presence interaction + casefile level controls
reg lnpv i.treatment i.p_actor i.treatment#i.p_actor fechaDemanda i.tipodeabogado i.trabajador_base, robust cluster(fecha_treatment)	
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_lnpv.xls", append ctitle("lnpv. Controls") ///
addtext(BVC, No) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean') 

*5) Just treatment + imputed casefile level controls
reg lnpv i.treatment c.order#i.missingCasefiles i.tipodeabogadoImputed#i.missingCasefiles i.trabajador_baseImputed#i.missingCasefiles missingCasefiles, robust cluster(fecha_treatment)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_lnpv.xls", append ctitle("lnpv. Imputed Controls") ///
	addtext(BVC, No) addstat(DepVarMean, `DepVarMean')

*6) Treatment presence interaction + imputed casefile level controls
reg lnpv i.treatment i.p_actor i.treatment#i.p_actor c.order#i.missingCasefiles i.tipodeabogadoImputed#i.missingCasefiles i.trabajador_baseImputed#i.missingCasefiles missingCasefiles, robust cluster(fecha_treatment)	
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
outreg2 using "$sharelatex\Tables\reg_results\December2018Followup_lnpv.xls", append ctitle("lnpv. Imputed Controls") ///
addtext(BVC, No) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean') 


