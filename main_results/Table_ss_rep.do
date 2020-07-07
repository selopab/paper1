*REPLICATION: Table_SS

/* Summary statistics table for Outcomes, Basic and Strategic variables for the 3 pilots */
/*Label modo termino en scaleup_hd
1- conciliation
2- 
3- court ruling, ie. laudo
4- 
*/

*******************************************************************************
/*COLUMNA 1: 5 juntas, muestra completa 2011-2015*/
use  "$sharelatex\DB\scaleup_hd.dta", clear
//scaleup_hd.dta n=5005, juntas: 2,7,9,11,16, 232 variables

*Variables
	*We define win as liq_total>0
	gen win=(liq_total>0)
	*Salario diario
	destring salario_diario, force replace
	*Conciliation
	gen con=(modo_termino==1)
	*Court ruling
	gen cr_0=(modo_termino==3 & liq_total==0) //laudo y trabajador recibe nada
	gen cr_m=(modo_termino==3 & liq_total>0) //laudo y trabajador recibe algo

*PANEL A (Outcomes)
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelA") modify
local n=5
local m=6
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")  
	
	*Obs
	qui putexcel B`n'=(r(N))  
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel C`m'=("`sd'")  
	
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel D`n'=("`range'")  		
		
	local n=`n'+2
	local m=`m'+2
	}
	
*PANEL B (Basic variables)
putexcel clear
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelB") modify
local n=5
local m=6
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'") 
	
	*Obs
	qui putexcel B`n'=(r(N))  
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel C`m'=("`sd'")  
		
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel D`n'=("`range'")  		
		
	local n=`n'+2
	local m=`m'+2
	}

*******************************************************************************
/*COLUMNA 2: J7, muestra completa 2011-2015*/
keep if junta==7

*PANEL A (Outcomes)
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelA") modify
local n=5
local m=6
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  ///
	{
	qui su `var'
	*Variable 
	qui putexcel G`n'=("`var'")  
	
	*Obs
	qui putexcel H`n'=(r(N))  
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel I`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel I`m'=("`sd'")  
	
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel J`n'=("`range'")  		
		
	local n=`n'+2
	local m=`m'+2
	}
	
*PANEL B (Basic variables)
putexcel clear
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelB") modify
local n=5
local m=6
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	*Variable 
	qui putexcel G`n'=("`var'") 
	
	*Obs
	qui putexcel H`n'=(r(N))  
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel I`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel I`m'=("`sd'")  
		
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel J`n'=("`range'")  		
		
	local n=`n'+2
	local m=`m'+2
	}
	
*******************************************************************************
/*COLUMNA 3: J7, phase 1, March Pilot*/
use "$sharelatex\DB\pilot_operation.dta", clear
merge m:1 expediente anio using "$sharelatex\DB\pilot_casefiles_wod.dta", keep(1 3) nogen
drop if tratamientoquelestoco==3 //sin conciliator: n=2709

*PANEL A (Outcomes)
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelA_2") modify
local n=5
local m=6
foreach var of varlist win liq_total c_total con cr_0 cr_m  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")  
	
	*Obs
	qui putexcel E`n'=(r(N))  
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel F`n'=("`mu'")
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel F`m'=("`sd'")  
	
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel G`n'=("`range'")  	
	local n=`n'+2
	local m=`m'+2
	}

*PANEL B (Basic Variables)
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelB_2") modify
local n=5
local m=6
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	
	*Obs
	qui putexcel E`n'=(r(N))  
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel F`n'=("`mu'")  	
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel F`m'=("`sd'")  
	
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel G`n'=("`range'")  
	local n=`n'+2
	local m=`m'+2
	}
	
*******************************************************************************
*DB: March Pilot merged with surveys (Table 1A)
use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	

preserve
*Employee
merge m:1 folio using  "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , keep(2 3)
rename A_5_1 masprob_employee
replace masprob=masprob/100
rename A_5_5 dineromasprob_employee
rename A_5_8 tiempomasprob_employee

*Drop outlier
xtile perc=tiempomasprob_employee, nq(99)
replace tiempomasprob_employee=. if perc>=98

putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelSS_A") modify
local n=5
local m=6
foreach var of varlist masprob dineromasprob tiempomasprob ///
	{

	qui su `var' if tipodeabogado!=.
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel C`m'=("`sd'")  		

	local n=`n'+2
	local m=`m'+2
	}

	*Obs
	qui su masprob if tipodeabogado!=.
	qui putexcel C11=("`r(N)'")  

restore

preserve
*Employee's Lawyer
merge m:m folio using  "$sharelatex/Raw/Append Encuesta Inicial Representante Actor.dta" , keep(2 3)
rename RA_5_1 masprob_law_emp
replace masprob=masprob/100
rename RA_5_5 dineromasprob_law_emp
rename RA_5_8 tiempomasprob_law_emp
	
local n=5
local m=6
foreach var of varlist masprob dineromasprob tiempomasprob ///
	{

	qui su `var' if tipodeabogado!=.
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel D`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel D`m'=("`sd'")  	
		
	local n=`n'+2
	local m=`m'+2
	}

	*Obs
	qui su masprob if tipodeabogado!=.
	qui putexcel D11=("`r(N)'")  
	
restore


preserve
*Firm's Lawyer
merge m:m folio using  "$sharelatex/Raw/Append Encuesta Inicial Representante Demandado.dta" , keep(2 3)
rename RD5_1_1 masprob_law_firm
replace masprob=masprob/100
rename RD5_5 dineromasprob_law_firm
rename RD5_8 tiempomasprob_law_emp

local n=5
local m=6
foreach var of varlist masprob dineromasprob tiempomasprob ///
	{

	qui su `var' if tipodeabogado!=.
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel E`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel E`m'=("`sd'") 
		
	local n=`n'+2
	local m=`m'+2
	}

	*Obs
	qui su masprob if tipodeabogado!=.
	qui putexcel E11=("`r(N)'")  
	
restore

********************************************************************************
	*DB: ScaleUp
use "$scaleup\DB\scaleup_operation.dta", clear
*Merge with iniciales DB
keep if num_actores==1 
rename expediente exp
rename ao anio
duplicates drop  exp anio junta, force

merge 1:1 exp anio junta  using "$scaleup\DB\scaleup_casefiles_wod.dta", keep(3)


	
*Variable homologation
rename convenio con


*Generate missing variables
foreach var in ///
	win liq_total c_total con cr_0 cr_m  ///
	abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	reinst indem sal_caidos prima_antig prima_vac hextra ///
	rec20 prima_dom desc_sem desc_ob sarimssinf utilidades nulidad  ///
	vac ag codem ///
	{
		capture confirm variable  `var'
		if !_rc {
               qui di ""
               }
        else {
               gen `var'=.
               }
	}	



*PANEL A (Outcomes)
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelA_2") modify
local n=5
local m=6
foreach var of varlist win liq_total c_total con cr_0 cr_m  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")  
	
	*Obs
	qui putexcel K`n'=(r(N))  
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel L`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel L`m'=("`sd'")  
	
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel M`n'=("`range'") 		
		
	local n=`n'+2
	local m=`m'+2
	}

	
*PANEL B (Basicas)
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelB_2") modify

local n=5
local m=6
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	
	*Obs
	qui putexcel K`n'=(r(N))  	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel L`n'=("`mu'")  	
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel L`m'=("`sd'")
	
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel M`n'=("`range'")  	
		
	local n=`n'+2
	local m=`m'+2
	}
	

********************************************************************************
*DB: Pilot3

use "$sharelatex\p1_w_p3\out\dulce_1911.dta", clear

merge m:1 id_actor using "$sharelatex\DB\treatment_data.dta", keep(2 3) nogen
merge m:1 id_actor using "$sharelatex\DB\survey_data_2m.dta", nogen keep(1 3)
drop if missing(main_treatment) | main_treatment == 3

*Variable homologation

gen convenio = MODODETERMINO == "CONVENIO"
gen con = convenio ==1 | conflicto_arreglado == 1

ren (demando_con_abogado_publico mujer antiguedad)(abogado_pub gen c_antiguedad)
replace abogado_pub= 0 if entablo_demanda==1 & missing(abogado_pub)
*Generate missing variables
foreach var in ///
	win liq_total c_total con cr_0 cr_m  ///
	abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	reinst indem sal_caidos prima_antig prima_vac hextra ///
	rec20 prima_dom desc_sem desc_ob sarimssinf utilidades nulidad  ///
	vac ag codem ///
	{
		capture confirm variable  `var'
		if !_rc {
               qui di ""
               }
        else {
               gen `var'=.
               }
	}	


replace c_total = 100000
*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelA_p3") modify
foreach var of varlist win liq_total c_total con cr_0 cr_m  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")  
	*Obs
	
	qui putexcel N`n'=(r(N))  
	
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel O`n'=("`mu'")  
	
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel O`m'=("`sd'") 
	
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel P`n'=("`range'") 

		
	local n=`n'+2
	local m=`m'+2
	}

*PANEL B (Basicas)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS_rep.xlsx", sheet("PanelB_p3") modify
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	
	*Obs
	qui putexcel N`n'=(r(N))  
	
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel O`n'=("`mu'") 
	
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel O`m'=("`sd'") 
	
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel P`n'=("`range'")  	
		
	local n=`n'+2
	local m=`m'+2
	}
	



	


