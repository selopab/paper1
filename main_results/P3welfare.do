**********************************
* P3 welfare effects for paper 1 *
* Calculator only				 *
**********************************


use ".\DB\treatment_data.dta", clear
merge 1:1 id_actor using ".\DB\survey_data_2m.dta", keep(3)

keep if !missing(main_treatment) & main_treatment != 3

local welfare_vars nivel_de_felicidad ultimos_3_meses_ha_dejado_de_pag ultimos_3_meses_le_ha_faltado_di ///
trabaja_actualmente
local controls mujer antiguedad salario_diario


*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear

foreach var of varlist `welfare_vars' {
	eststo: qui reg `var' 2.main_treatment `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui su `var' if main_treatment==1
	estadd scalar sd = r(sd)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"	
}
	
	*************************
	esttab using "./Tables/reg_results/welfare_reg_2m_calcOnly.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" "test_23 T2=T3" "control_mean Control group mean" "sd sd") replace 
	
	eststo clear
