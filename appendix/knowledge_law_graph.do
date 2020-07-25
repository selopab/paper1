/*Figure C6: Prob plaintiff correctly knows what is in the lawsuit */
/*
We regress a dummy variable indicating the plaintiff correctly answered a
question about the contents of her case against a variable indicating the
plaintiff is represented by a public lawyer. 
*/

********************************************************************************
*								Phase 1										   *
********************************************************************************

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
********************************************************************************

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
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

keep junta exp anio 
ren exp expediente

merge 1:1 junta exp anio using "$sharelatex\DB\pilot_casefiles_wod.dta", keep(3) nogen
merge m:1 folio using  "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , keep(3)


	
* What employee asked
gen asked_indemconst=(A_7_2_1==1 | A_7_2_2==1 | A_7_2_3==1 | A_7_2_4==1 | A_7_2_5==1 | A_7_2_6==1 | A_7_2_7==1 | A_7_2_8==1 | A_7_2_9==1)
gen asked_sarimssinf=(A_7_2_1==2 | A_7_2_2==2 | A_7_2_3==2 | A_7_2_4==2 | A_7_2_5==2 | A_7_2_6==2 | A_7_2_7==2 | A_7_2_8==2 | A_7_2_9==2)
gen asked_reinstalacion=(A_7_2_1==3 | A_7_2_2==3 | A_7_2_3==3 | A_7_2_4==3 | A_7_2_5==3 | A_7_2_6==3 | A_7_2_7==3 | A_7_2_8==3 | A_7_2_9==3)
gen asked_rechrextrat=(A_7_2_1==4 | A_7_2_2==4 | A_7_2_3==4 | A_7_2_4==4 | A_7_2_5==4 | A_7_2_6==4 | A_7_2_7==4 | A_7_2_8==4 | A_7_2_9==4)
gen asked_primdom=(A_7_2_1==5 | A_7_2_2==5 | A_7_2_3==5 | A_7_2_4==5 | A_7_2_5==5 | A_7_2_6==5 | A_7_2_7==5 | A_7_2_8==5 | A_7_2_9==5)
gen asked_primavac=(A_7_2_1==6 | A_7_2_2==6 | A_7_2_3==6 | A_7_2_4==6 | A_7_2_5==6 | A_7_2_6==6 | A_7_2_7==6 | A_7_2_8==6 | A_7_2_9==6)
gen asked_nosabe=(A_7_2_1==.s)	


gen correct_indemconst=(asked_indemconst==indemconsttdummy)
gen correct_sarimssinf=(asked_sarimssinf==sarimssinf)
gen correct_reinstalacion=(asked_reinstalacion==reinstalaciont)
gen correct_rechrextrat=(asked_rechrextrat==rechrextra)
gen correct_primdom=(asked_primdom==prima_dom)


*Education
gen more_high_school=inlist(A_1_2, 3,4) if !missing(A_1_2)

*Severance pay
gen knows=( A_7_1_O==90) 
gen knows_correctly=( A_7_1_O==90) if !missing(A_7_1_O)

********************************************************************************
*Regression

matrix results = J(14, 4, .)

local i=1
local j=1
foreach var of varlist correct_*  {	
	*NO CONTROLS
	reg `var' i.abogado_pub, robust
	local df = e(df_r)
	//Row
	matrix results[`i',1] = `j'
	// Beta 
	matrix results[`i',2] = _b[1.abogado_pub]
	// S.E.
	matrix results[`i',3] = _se[1.abogado_pub]
	// P-value
	matrix results[`i',4] = 2*ttail(`df', ///
		abs(_b[1.abogado_pub]/_se[1.abogado_pub]) ///
	)
	local ++i
	local ++j
	
	*CONTROLS
	reg `var' i.abogado_pub i.A_1_2 gen trabajador_base c_antiguedad salario_diario horas_sem, robust
	local df = e(df_r)
	//Row
	matrix results[`i',1] = `j'
	// Beta 
	matrix results[`i',2] = _b[1.abogado_pub]
	// S.E.
	matrix results[`i',3] = _se[1.abogado_pub]
	// P-value
	matrix results[`i',4] = 2*ttail(`df', ///
		abs(_b[1.abogado_pub]/_se[1.abogado_pub]) ///
	)	
	local ++i
	local j=`j'+3
	}

	
matrix colnames results =  "row" "beta" "se" "p" 
matlist results


***************************
** GRAPH 				 **
***************************
// First, replace data in memory with results
clear
svmat results, names(col) 

// GRAPH FORMATTING
// For graphs:
local estimate_options_0  mcolor(gs12)   
local estimate_options_90 mcolor(gs7)   
local estimate_options_95 mcolor(gs0) 
local rcap_options_0  lcolor(gs12)   lwidth(thin)
local rcap_options_90 lcolor(gs7)   lwidth(thin)
local rcap_options_95 lcolor(gs0) lwidth(thin)


// Confidence intervals (95%)
local alpha = .05 // for 95% confidence intervals
gen rcap_lo = beta - invttail(`df',`=`alpha'/2')*se
gen rcap_hi = beta + invttail(`df',`=`alpha'/2')*se



// GRAPH
#delimit ;
twoway (bar beta row if p<0.05,           `estimate_options_95' ) 
	(bar beta row if p>=0.05 & p<0.10, `estimate_options_90') 
	(bar beta row if p>=0.10,          `estimate_options_0' ) 
	(rcap rcap_hi rcap_lo row if p<0.05,           `rcap_options_95')
	(rcap rcap_hi rcap_lo row if p>=0.05 & p<0.10, `rcap_options_90')
	(rcap rcap_hi rcap_lo row if p>=0.10,          `rcap_options_0' ),
	graphregion(color(white)) scheme(s2mono) ytitle("Effect" "Public Lawyer") 
	title("")
	xtitle("") legend(off) 
	xlabel( 1.5 `" "Knows if asked" "Sev. Payment" "' 
		5.5 `" "Knows if asked" "Medical insurance" "' 
		9.5 `" "Knows if asked" "Reinstatement" "'
		13.5 `" "Knows if asked" "Overtime" "'
		17.5 `" "Knows if asked" "Premium w. saturdays" "'
		, noticks angle(vertical))
	
;
#delimit cr	
graph export "$sharelatex/Figures/knowledge_law_graph.pdf", replace 


*******************************************
