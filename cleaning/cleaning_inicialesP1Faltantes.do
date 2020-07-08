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

*foreach var in tipodeabogado trabajadordeconfianza{
*destring `var', gen(`var'_M) force
*}

gen tipodeabogado_M = tipodeabogado

replace tipodeabogado_M = tipodeabogado_M == 3

replace fechadedemanda = "" if strpos(fechadedemanda, "-7")
gen fechaDemanda_M = date(fechadedemanda, "DMY") 
gen codingDate = date(fechadecaptura, "DMY")
split fechadecaptura, p("/")
save "$pilot3\out\inicialesP1Faltantes.dta", replace

sort junta exp anio
quietly by junta exp anio:  gen dup = cond(_N==1,0,_n)
replace dup=1 if dup==0
keep if dup==1

save "$pilot3\out\inicialesP1Faltantes_wod.dta", replace
