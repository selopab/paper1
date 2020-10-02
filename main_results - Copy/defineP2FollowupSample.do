* Create P2 sample for doenload

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

merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", keep(1 3)
//merge m:1 junta exp anio using "$sharelatex\Terminaciones\Data\terminaciones.dta", gen(merchados) keep(1 3)

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
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1 
*Follow-up (more than 5 months)

replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1
replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1
replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1

replace modo_termino_expediente=3 if missing(modo_termino_expediente) & convenio_m5m==1
replace modo_termino_expediente=2 if missing(modo_termino_expediente)

gen toKeepNoConvenio = _merge==1 & modo_termino_expediente!=3
replace toKeepNoConvenio = 1 if modo_termino_expediente == 2
replace toKeepNoConvenio = 1 if modo_termino_expediente == 6 & missing(cant_convenio) & ///
missing(cant_convenio_exp) & missing(cant_convenio_ofirec)

gen toKeepConvenio = modo_termino_expediente == 3 & missing(cant_convenio) & ///
missing(cant_convenio_exp) & missing(cant_convenio_ofirec)




preserve
keep if toKeepConvenio  >0
keep junta exp anio
export excel "$sharelatex\DB\checkP2CasefilesJul2020_convenios.xlsx", replace first(var)
restore 

keep if toKeepNoConvenio  >0
keep junta exp anio
export excel "$sharelatex\DB\checkP2CasefilesJul2020.xlsx", replace first(var)
