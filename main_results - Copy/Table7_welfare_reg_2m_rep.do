use "$sharelatex\DB\treatment_data.dta", clear
merge 1:1 id_actor using "$sharelatex\DB\survey_data_2m.dta", keep(3)

*Drop conciliator
drop if main_treatment==3


local welfare_vars nivel_de_felicidad ultimos_3_meses_ha_dejado_de_pag ultimos_3_meses_le_ha_faltado_di comprado_casa_o_terreno comprado_electrodomestico trabaja_actualmente mejor_trabajo busca_trabajo probabilidad_de_que_encuentre_tr tiempo_arreglar_asunto_imputed
local controls mujer antiguedad salario_diario


*******************************
* 			REGRESSIONS		  *
*******************************
eststo clear

foreach var of varlist `welfare_vars' {
	eststo: reg `var' i.main_treatment `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	//qui test 2.main_treatment=3.main_treatment
	estadd scalar test_23=`r(p)'
	qui su `var' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"	
	}
	
	*************************
	esttab using "$sharelatex/Tables/reg_results/welfare_reg_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" "test_23 T2=T3") replace 
	
/*
	*Type of lawyer: 0-Public 1-Private 2-Coyote
gen type_lawyer=demando_con_abogado_privado
replace type_lawyer=2 if coyote==1

eststo clear
foreach var of varlist `welfare_vars' {
	eststo: reg `var' i.type_lawyer `controls', r cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	qui su `var' if e(sample)
	estadd scalar DepVarMean=r(mean)
	estadd local BVC="YES"
	estadd local Source="2m"	
	}
	
	*************************
	esttab using "$directorio/Tables/reg_results/welfare_reg_lawyer_2m.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "BVC BVC" "Source Source" ) replace 
		
*/