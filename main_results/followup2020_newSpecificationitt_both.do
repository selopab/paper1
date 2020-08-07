* TREATMENT EFFECTS - ITT - con merge a faltanP1
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects for both experimental phases.
Columns (1)-(8)
*/
********************************************************************************
****************************
use "$scaleup\DB\scaleup_operation.dta", clear
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)
merge m:1 junta exp anio using "$scaleup\DB\scaleup_predictions.dta", nogen keep(1 3)

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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
trabajador_base liq_total_laudo_avg

gen phase=2
save "$paper\DB\temp_p2", replace

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

gen liq_total_laudo_avg =  liq_laudopos * prob_laudopos

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
trabajador_base liq_total_laudo_avg

append using "$paper\DB\temp_p2"
replace phase=1 if missing(phase)

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
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

//Merge nuevas iniciales-----------------------------

merge 1:1 junta exp anio using "$sharelatex\p1_w_p3\out\inicialesP1Faltantes_wod.dta", ///
keep(1 3) gen(_mNuevasIniciales) keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M)
//

//gen fechaDemanda = date(fecha, "YMD")
gen fechaDemanda = fecha
*foreach var in fechaDemanda tipodeabogado{
*replace `var' = `var'_M if missing(`var') & `var'_M>0
*}

replace abogado_pub = tipodeabogado_M if missing(abogado_pub)

replace trabajador_base = abs(trabajadordeconfianza_M-1) if !missing(trabajadordeconfianza_M)
tostring anio, gen(s_anio)
gen fechaArtificial = s_anio + "-01-" + "01"
gen fechaDemandaImputed = fechaDemanda
replace fechaDemandaImputed = date(fechaArtificial, "YMD") if missing(fechaDemandaImputed) | fechaDemandaImputed <0 

gen trabajador_baseImputed = trabajador_base
replace trabajador_baseImputed = 2 if trabajador_baseImputed ==0
replace trabajador_baseImputed = 0 if missing(trabajador_baseImputed)

gen tipodeabogadoImputed = tipodeabogado
replace tipodeabogadoImputed = 0 if missing(tipodeabogadoImputed)

gen missingCasefiles =missing(tipodeabogado_M)
bysort anio exp: gen order = _n

*Drop conciliator observations
*drop if treatment==3
********************************************************************************

merge 1:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", keep(1 3)
replace cant_convenio = cant_convenio_exp if missing(cant_convenio)
replace cant_convenio = cant_convenio_ofirec if missing(cant_convenio)
replace cant_convenio = 0 if modo_termino_expediente == 6 & missing(cant_convenio)
merge 1:1 junta exp anio using "$sharelatex\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)

/*
--------------+-----------------------------------
1)           AG |         18        5.70        5.70
2)     CONTINUA |         98       31.01       36.71
3)     CONVENIO |        130       41.14       77.85
4) DESISTIMIENTO |          5        1.58       79.43
5) INCOMPETENCIA |          5        1.58       81.01
6)        LAUDO |         60       18.99      100.00
--------------+-----------------------------------
*/


gen fechaTerminoAux = date("$S_DATE", "DMY") //date("$dateCode", "YMD") 
format fechaTerminoAux

replace modoTermino = modo_termino_expediente if missing(modoTermino)
replace modoTermino = 2 if missing(modoTermino)

egen fechaTermino = rowmax(fecha_termino_ofirec fecha_termino_exp fechaOfirec fechaExp)
*replace fechaTermino = fecha_termino_exp if missing(fechaTermino)
*replace fechaTermino = fechaOfirec if missing(fechaTermino)
*replace fechaTermino = fechaTerminoAux if missing(fechaTermino) | modo_termino_expediente==2 | fechaTermino<0
*
gen ganancia = cant_convenio 
replace ganancia = cant_convenio_exp if missing(ganancia)
replace ganancia = cant_convenio_ofirec if missing(ganancia)
replace ganancia = cantidadPagada if missing(ganancia) & cantidadPagada != 0 //liq_convenio
replace ganancia = cantidadOtorgada if missing(ganancia)

replace ganancia = 0 if [modoTermino == 4 & missing(ganancia)]| modoTermino==5 | [modoTermino==6  & missing(ganancia)] ///
| [modoTermino==1  & missing(ganancia)]
