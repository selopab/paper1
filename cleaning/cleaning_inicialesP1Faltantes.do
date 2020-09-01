//Clean inicialesP1Faltantes

import delimited "$pilot3\inp\inicialesP1Faltantes2.csv", varn(1) clear

*drop if exp=="NA" & junta=="NA" & anio=="NA"

egen nombreactor_1=ends(nombreactor), head
egen nombreactor_n=ends(nombreactor), last

gen nombreactor_2=word(nombreactor,2)

/*
rename junta junta_s
rename exp exp_s
rename anio anio_s
rename género gen_F
rename sueldoestadístico sueldo_est_F
rename periodicidaddelsueldoestadístico per_sueldo_est_F
rename fechadeentrada fecha_entrada_Fstring
rename fechadesalida fecha_salida_Fstring


destring junta_s exp_s anio_s, generate(junta exp anio) 

destring gen_F, replace

replace sueldo_est_F="" if sueldo_est_F=="NO ESPECIFICA"
replace sueldo_est_F="" if sueldo_est_F=="NA"
replace per_sueldo_est_F="" if per_sueldo_est_F=="NO ESPECIFICA"
replace per_sueldo_est_F="" if per_sueldo_est_F=="NA"
destring sueldo_est_F, replace
destring per_sueldo_est_F, replace


gen fecha_entrada_F=date(fecha_entrada_Fstring, "DMY")
gen fecha_salida_F=date(fecha_salida_Fstring, "DMY")

gen antiguedad_F=fecha_salida_F-fecha_entrada_F
*/
*replace prevencion="" if prevencion=="NA"
*destring prevencion, replace 

foreach var in tipodeabogado trabajadordeconfianza{
*destring `var', gen(`var'_M) force
gen `var'_M =  `var'
}

cap gen tipodeabogado_M = tipodeabogado

replace tipodeabogado_M = tipodeabogado_M == 3

replace fechadedemanda = "" if strpos(fechadedemanda, "-7")
gen fechaDemanda_M = date(fechadedemanda, "DMY") 
gen codingDate = date(fechadecaptura, "DMY")
split fechadecaptura, p("/")

foreach var in indemnizaciónmonto salarioscaídosmonto primadeantigüedadmonto vacacionesmonto ///
primavacacionalmonto aguinaldomonto horasextramonto díasmonto primadominicalmonto ///
descansosemanalmonto descansoobligatoriomonto utilidadesmonto otrasprestacionesmonto{
	destring `var', force replace
	replace `var' = 0 if missing(`var')
}

save "$pilot3\out\inicialesP1Faltantes.dta", replace

sort junta exp anio
by junta exp anio:  gen numActoresN = _N
//by junta exp anio: gen valorTotal = sum(c_total)
quietly by junta exp anio:  gen dup = cond(_N==1,0,_n)
replace dup=1 if dup==0
keep if dup==1

foreach var in fechadeentrada fechadesalida{
gen `var'_d = date(`var', "DMY")
}

foreach var in sueldobase periodicidaddelsueldobase{
destring  `var', replace force
}
//0=diario 1=mensual 2=quincenal 3=semanal

gen salario_diarioN = sueldobase
replace salario_diarioN = salario_diarioN/30 if periodicidaddelsueldobase == 1
replace salario_diarioN = salario_diarioN/15 if periodicidaddelsueldobase == 2
replace salario_diarioN = salario_diarioN/4 if periodicidaddelsueldobase == 3

destring númerodehoraslaboradas, gen(horas_semN) force
destring periodicidaddelashoraslaboradas, replace force

replace horas_semN = horas_semN*5 if periodicidaddelashoraslaboradas == 0

gen abogado_pubN = tipodeabogado == 3
ren género genN
gen trabajador_baseN = abs(trabajadordeconfianza-1)
gen c_antiguedadN = fechadesalida_d - fechadeentrada_d

save "$pilot3\out\inicialesP1Faltantes_wod.dta", replace
