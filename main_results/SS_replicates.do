

/*Table 1׺  Summary Statistics*/
/* Summary statistics table for Outcomes, Basic and Strategic variables for the 3 pilots */

/*NOTE: AVOID SYNCING WITH DROPBOX (OR ANY OTHER SERVICE) WHILE RUNNING THIS DO FILE*/
********************************************************************************
	*DB: Calculator:5005
use  "$sharelatex\DB\scaleup_hd.dta", clear


*Variables
	*We define win as liq_total>0
	gen win=(liq_total>0)
	*Salario diario
	destring salario_diario, force replace
	*Conciliation
	gen con=(modo_termino==1)
	*Court ruling
	gen cr_0=(modo_termino==3 & liq_total==0)
	gen cr_m=(modo_termino==3 & liq_total>0)
	

*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelA") modify
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

	

*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set  "$sharelatex/Tables/SS.xlsx", sheet("PanelB") modify
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
	

	

********************************************************************************
	*DB: Subcourt 7 
keep if junta==7
	

 
*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelA") modify	
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  ///
	{
	qui su `var'

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


	
*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'

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
	


	

********************************************************************************
	*DB: March Pilot
use "$sharelatex\DB\pilot_operation.dta", clear
drop if tratamientoquelestoco==0
merge m:1 expediente anio using "$sharelatex\DB\pilot_casefiles_wod.dta", keep(1 3)
ren expediente exp
merge m:1 exp anio using "$pilot3\out\inicialesP1Faltantes_wod.dta", keep(1 3) gen(_mNuevasIniciales) force

foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	replace `var' = `var'N if missing(`var')
	}

//drop if tratamientoquelestoco==3
replace junta=7 if missing(junta)
rename tratamientoquelestoco treatment

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
********************************************************************************
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelA") modify
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

*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelB") modify		
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
	



	
	
********************************************************************************
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

local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("SS_A") modify		
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
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("SS_A") modify			
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
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

sort junta exp anio fecha_treat
by junta exp anio: gen renglon = _n
keep if renglon==1

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
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelA") modify
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


*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelB") modify		
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

use "$pilot3\out\dulce_1911.dta", clear
*/
merge m:1 id_actor using "$pilot3Complete\DB\treatment_data.dta", keep(2 3) nogen
merge m:1 id_actor using "$pilot3Complete\DB\survey_data_2m.dta", nogen keep(1 3)
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
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelA") modify
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


*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set "$sharelatex/Tables/SS.xlsx", sheet("PanelB") modify		
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
	

	

		
