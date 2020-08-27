clear
set more off
global F5 "br;"

global directorio "D:\MCLC\Pilot3"

import excel "$sharelatex\p1_w_p3\inp\SEGUNDO SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear

drop S - AF
replace EXPEDIENTE = subinstr(EXPEDIENTE, ".pdf","",.)
replace EXPEDIENTE = subinstr(EXPEDIENTE, "J","",.)
tempfile base
ren IDACTOR id_actor
duplicates tag id_actor EXPEDIENTE, gen(dups)
drop if dups>0
drop dups
save `base', replace
replace id_actor = subinstr(id_actor, ",", ";",.)
split id_actor, parse(";")
drop id_actor

preserve
ren id_actor1 id_actor
keep id_actor EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES OBSERVACIONESDEIDACTOR TRATAMIENTO OBSERVACIONESGENERALESDELEXPE auxiliar junta expediente anio
save `base', replace
restore

forvalues i = 2/6{
preserve
keep id_actor`i' EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES OBSERVACIONESDEIDACTOR TRATAMIENTO OBSERVACIONESGENERALESDELEXPE auxiliar junta expediente anio
ren id_actor`i' id_actor
append using `base'
save `base', replace
restore 
}

use `base', clear
drop if id_actor==""

replace id_actor=stritrim(trim(itrim(upper(id_actor))))

drop LUGAURL junta expediente anio
gen date = date(FECHADETERMINO, "DMY")
drop FECHADETERMINO
ren date FECHADETERMINO
destring COINCIDEACTOR1SI0NO2NOE, force replace
gen source = 1
save `base', replace

import excel "$sharelatex\p1_w_p3\inp\TERCER SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear

drop if EXPEDIENTE =="" | missing(IDACTOR)
ren IDACTOR id_actor
drop N O P Q R S T U V W X Y Z AA AB AC AD AE
gen source = 2 
append using `base'
save `base', replace 

import excel "$sharelatex\p1_w_p3\inp\SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear
drop S T U V W X Y Z AA AB AC AD AE AF

replace EXPEDIENTE = subinstr(EXPEDIENTE, ".pdf","",.)
replace EXPEDIENTE = subinstr(EXPEDIENTE, "J","",.)
ren IDACTOR id_actor
duplicates drop
duplicates tag id_actor EXPEDIENTE, gen(dups)
drop if dups>0
drop dups
gen fechadate = date(FECHADETERMINO, "DMY")
format fechadate %td
drop FECHADETERMINO
rename fechadate FECHADETERMINO
*save `base', replace


replace id_actor = subinstr(id_actor, ",", ";",.)
split id_actor, parse(";")
drop id_actor

*tempfile base0 `base0'

*preserve
*ren id_actor1 id_actor
*keep id_actor EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES OBSERVACIONESDEIDACTOR TRATAMIENTO auxiliar junta expediente anio
*save `base0', replace
*restore

ren id_actor2 id_actor
keep id_actor EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES OBSERVACIONESDEIDACTOR TRATAMIENTO auxiliar junta expediente anio
*append using `base0'
drop if missing(id_actor)
gen source = 0
*gen fecha = date(FECHADETERMINO, "DMY")
*drop FECHADETERMINO
*ren fecha FECHADETERMINO
destring auxiliar, replace force

append using `base'
duplicates drop 
duplicates tag EXPEDIENTE id_actor, gen(dupsgraves)
drop if dups==1

save "$sharelatex\p1_w_p3\out\dulce_1911.dta", replace
export excel "$sharelatex\p1_w_p3\out\dulce_1911.xlsx", replace firstr(var)


*use "D:\Dropbox\Dropbox\Documentos_\Joyce_Seira\p1_w_p3\out\dulce_1911.dta", clear
use "$sharelatex\p1_w_p3\out\dulce_1911.dta", clear
*/
merge m:1 id_actor using "$directorio\DB\treatment_data.dta", keep(2 3) nogen
merge m:1 id_actor using "$directorio\DB\survey_data_2m.dta", nogen keep(1 3)

gen calculadora = main_treatment
replace calculadora = . if main_treatment==3
gen convenio = MODODETERMINO == "CONVENIO"
gen doble_convenio = convenio ==1 | conflicto_arreglado == 1
*replace doble_convenio = . if missing(conflicto_arreglado)
gen convenio_mamon = [conflicto_arreglado==1]

local depvar conflicto_arreglado convenio doble_convenio
local controls mujer antiguedad salario_diario

qui gen esample=1	
qui gen nvals=.

eststo clear	
	
foreach var in `depvar'	{	
	eststo: reg `var' i.calculadora `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	estadd local BVC="YES"
	estadd local Source=""
	qui sum `var' if main_treatment==1
	estadd local control_mean=`r(mean)'
	forvalues i=1/2 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'"
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/2 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'"
	
	}
	
	
	*************************
	esttab using "$directorio/Tables_Draft/reg_results/te123_calculator_p1.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3" "control_mean Control group mean") replace 
