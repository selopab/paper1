**Table 3: Immediate expectation updating***

*Update in expectations against treatment arms

eststo clear

*							Immediate exp - Baseline    	   			       *
********************************************************************************

		 
use "$sharelatex\DB\treatment_data.dta", clear
//merge 1:1 id_actor using "$sharelatex\DB\survey_data_2w.dta", keep(3) //esto por qué

drop if main_treatment==3

*****************************      PROBABILITY      ****************************

*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_treat<prob_ganar if  !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(prob_ganar)

eststo: reg bajo_inm i.main_treatment mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)

**Independent continuous variable
cap drop bajo_inm
gen bajo_inm=prob_ganar_treat-prob_ganar if !missing(prob_ganar) & !missing(prob_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(prob_ganar)

eststo: reg bajo_inm i.main_treatment mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)

******************************        AMOUNT        ****************************
	
*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat<cantidad_ganar if  !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)

eststo: reg bajo_inm i.main_treatment mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)

	
*Independent dummy variable
cap drop bajo_inm
gen bajo_inm=cantidad_ganar_treat-cantidad_ganar if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)

eststo: reg bajo_inm i.main_treatment mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)	
	
*Independent dummy variable - log difference
cap drop bajo_inm
gen bajo_inm=ln(cantidad_ganar_treat)-ln(cantidad_ganar) if !missing(cantidad_ganar) & !missing(cantidad_ganar_treat)
replace bajo_inm=0 if main_treatment==1 & !missing(cantidad_ganar)

eststo: reg bajo_inm i.main_treatment mujer antiguedad salario_diario ///
	, robust cluster(fecha_alta)	

	
*************************
	esttab using "$sharelatex/Tables/reg_results/Table3_update_treatment.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) r2 ///
	scalars("BVC BVC" "test_23 T2=T3") replace 