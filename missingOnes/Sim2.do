clear
set more off

global num_sim=1000
global num_sim_krls=1000
********************************************************************************



import delimited "$directorio\DB\observaciones_tope.csv", clear 


for var c_antiguedad c_indem-c_desc_ob c_recsueldo liq_total: ///
	capture replace X=0 if X<0 & X~=.
	
*Wizorise all at 99th percentile
for var c_* liq_total liq_total_tope: capture egen X99 = pctile(X) , p(99)
for var c_* liq_total liq_total_tope: ///
	capture replace X=X99 if X>X99 & X~=.
drop *99

	
*Gen variables for regression	
gen liq_gt0=liq_total>0 if liq_total~=.
	
	
/*--------------------*/
/* CROSS-VALIDATION   */
/*--------------------*/	

gen corr_m1_con=.
gen corr_m2_con=.
gen corr_m3_con=.
gen corr_m4_con=.

gen mse_m1_con=.
gen mse_m2_con=.
gen mse_m3_con=.
gen mse_m4_con=.

gen mean_m1_con=.
gen mean_m2_con=.
gen mean_m3_con=.
gen mean_m4_con=.

gen corr_m1_lau=.
gen corr_m2_lau=.
gen corr_m3_lau=.
gen corr_m4_lau=.

gen mse_m1_lau=.
gen mse_m2_lau=.
gen mse_m3_lau=.
gen mse_m4_lau=.

gen mean_m1_lau=.
gen mean_m2_lau=.
gen mean_m3_lau=.
gen mean_m4_lau=.


local varindep_con
foreach var of varlist  c_antiguedad c_indem reinst codem prop_hextra gen ///
		junta {
	*Decides whether variable is categorical or not
	capture drop nvals
	qui by `var', sort: gen nvals = (_n == 1 )
	qui count if nvals==1
	if `r(N)'<10 { 
		local varindep_con `varindep_con' i.`var'
		}
	else {
		capture gen log_`var'=log(`var')
		local varindep_con `varindep_con' log_`var'
		}
	}	

local varindep_lau
foreach var of varlist  c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		  top_despacho gen codem junta {
	*Decides whether variable is categorical or not
	capture drop nvals
	qui by `var', sort: gen nvals = (_n == 1 )
	qui count if nvals==1
	if `r(N)'<10 { 
		local varindep_lau `varindep_lau' i.`var'
		}
	else {
		capture gen log_`var'=log(`var')
		local varindep_lau `varindep_lau' log_`var'
		}
	}	
gen log_liq_total=log(liq_total)
gen log_liq_total_tope=log(liq_total_tope)

forvalues n=1/$num_sim {
	
	capture drop pre_*
	capture drop sampl
	qui capture gen sampl=runiform()
	qui capture replace sampl=(sampl<=0.5)
	
	
		/*----------*/
		/*CONVENIOS */
		/*----------*/
	
	*MODELO 1 CONVENIOS
	qui capture xi: reg liq_total    c_antiguedad c_indem reinst codem prop_hextra gen ///
		i.junta  if modo_termino==1 & sampl==1 , robust

	qui capture predict pre_m1_con if sampl==0 & modo_termino==1
		*Correlation
	qui capture corr pre_m1_con	liq_total 
	qui capture replace corr_m1_con=`r(rho)' in `n'
		*Prom
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m1_con)
	qui capture egen prom=mean(diff)
	qui capture replace mean_m1_con=prom in `n'	
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m1_con)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m1_con=prom in `n'



	*MODELO 2 CONVENIOS 
	if `n'<=$num_sim_krls {
		qui capture xi: krls liq_total    c_antiguedad c_indem reinst codem prop_hextra gen ///
			i.junta  if modo_termino==1 & sampl==1 
		
		qui capture predict pre_m2_con if sampl==0 & modo_termino==1
			*Correlation
		qui capture corr pre_m2_con	liq_total 
		qui capture replace corr_m2_con=`r(rho)' in `n'
			*Prom
		capture drop diff prom
		qui capture gen diff=(liq_total-pre_m2_con)
		qui capture egen prom=mean(diff)
		qui capture replace mean_m2_con=prom in `n'	
			*MSE
		capture drop diff prom
		qui capture gen diff=(liq_total-pre_m2_con)^2
		qui capture egen prom=mean(diff)
		qui capture replace mse_m2_con=prom in `n'	
		}
	
	*MODELO 3 CONVENIOS
	qui capture xi: reg log_liq_total  `varindep_con' if modo_termino==1 & sampl==1 , robust
 
	qui capture predict pre_m3_con if sampl==0 & modo_termino==1
		*Correlation
	qui capture corr pre_m3_con	log_liq_total 
	qui capture replace corr_m3_con=`r(rho)' in `n'
		*Prom
	capture drop diff prom
	qui capture gen diff=(log_liq_total-pre_m3_con)
	qui capture egen prom=mean(diff)
	qui capture replace mean_m3_con=prom in `n'	
		*MSE
	capture drop diff prom
	qui capture gen diff=(log_liq_total-pre_m3_con)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m3_con=prom in `n' 
 
 	*MODELO 4 CONVENIOS
	if `n'<=$num_sim_krls {
		qui capture xi: krls log_liq_total  `varindep_con' if modo_termino==1 & sampl==1 
 
		qui capture predict pre_m4_con if sampl==0 & modo_termino==1
			*Correlation
		qui capture corr pre_m4_con	log_liq_total 
		qui capture replace corr_m4_con=`r(rho)' in `n'
			*Prom
		capture drop diff prom
		qui capture gen diff=(log_liq_total-pre_m4_con)
		qui capture egen prom=mean(diff)
		qui capture replace mean_m4_con=prom in `n'	
			*MSE
		capture drop diff prom
		qui capture gen diff=(log_liq_total-pre_m4_con)^2
		qui capture egen prom=mean(diff)
		qui capture replace mse_m4_con=prom in `n' 
		}
		
		/*----------*/
		/*  LAUDOS 	*/
		/*----------*/

	*MODELO 1 LAUDOS  
	qui capture xi: reg liq_total_tope    c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		  i.top_despacho gen codem i.junta ///
		 if modo_termino==3 & liq_total_tope>0 & sampl==1 , robust

	qui capture predict pre_m1_lau if sampl==0 & modo_termino==3 & liq_total_tope>0
		*Correlation
	qui capture corr pre_m1_lau	liq_total 
	qui capture replace corr_m1_lau=`r(rho)' in `n'
		*Prom
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m1_lau)
	qui capture egen prom=mean(diff)
	qui capture replace mean_m1_lau=prom in `n'		
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m1_lau)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m1_lau=prom in `n'

	*MODELO 2 LAUDOS
	qui capture xi: krls liq_total_tope    c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		  i.top_despacho gen codem i.junta ///
		 if modo_termino==3 & liq_total_tope>0 & sampl==1
		 
	qui capture predict pre_m2_lau if sampl==0 & modo_termino==3 & liq_total_tope>0
		*Correlation
	qui capture corr pre_m2_lau	liq_total 
	qui capture replace corr_m2_lau=`r(rho)' in `n'
		*Prom
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m2_lau)
	qui capture egen prom=mean(diff)
	qui capture replace mean_m2_lau=prom in `n'	
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m2_lau)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m2_lau=prom in `n'
 
	*MODELO 3 LAUDOS
	qui capture xi: reg log_liq_total  `varindep_lau' ///
		if modo_termino==3 & liq_total>0 & sampl==1, robust

	qui capture predict pre_m3_lau if sampl==0 & modo_termino==3 & liq_total_tope>0
		*Correlation
	qui capture corr pre_m3_lau	log_liq_total 
	qui capture replace corr_m3_lau=`r(rho)' in `n'
		*Prom
	capture drop diff prom
	qui capture gen diff=(log_liq_total-pre_m3_lau)
	qui capture egen prom=mean(diff)
	qui capture replace mean_m3_lau=prom in `n'	
		*MSE
	capture drop diff prom
	qui capture gen diff=(log_liq_total-pre_m3_lau)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m3_lau=prom in `n'
	
	*MODELO 4 LAUDOS
	qui capture xi: krls log_liq_total `varindep_lau' ///
		if modo_termino==3 & liq_total>0 & sampl==1

	qui capture predict pre_m4_lau if sampl==0 & modo_termino==3 & liq_total_tope>0
		*Correlation
	qui capture corr pre_m4_lau	log_liq_total 
	qui capture replace corr_m4_lau=`r(rho)' in `n'
		*Prom
	capture drop diff prom
	qui capture gen diff=(log_liq_total-pre_m4_lau)
	qui capture egen prom=mean(diff)
	qui capture replace mean_m4_lau=prom in `n'	
		*MSE
	capture drop diff prom
	qui capture gen diff=(log_liq_total-pre_m4_lau)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m4_lau=prom in `n'
		

		*Progress bar

	if `n'==1 {
		di "Progress"
		di "--------"
		}
	if `n'==floor($num_sim/20) {
		di "5%"
		}
	if `n'==floor($num_sim*2/20) {
		di "10%"
		}
	if `n'==floor($num_sim*3/20) {
		di "15%"
		}
	if `n'==floor($num_sim*4/20) {
		di "20%"
		}
	if `n'==floor($num_sim*5/20) {
		di "25%"
		}
	if `n'==floor($num_sim*6/20) {
		di "30%"
		}
	if `n'==floor($num_sim*7/20) {
		di "35%"
		}
	if `n'==floor($num_sim*8/20) {
		di "40%"
		}
	if `n'==floor($num_sim*9/20) {
		di "45%"
		}
	if `n'==floor($num_sim*10/20) {
		di "50%"
		}
	if `n'==floor($num_sim*11/20) {
		di "55%"
		}
	if `n'==floor($num_sim*12/20) {
		di "60%"
		}	
	if `n'==floor($num_sim*13/20) {
		di "65%"
		}
	if `n'==floor($num_sim*14/20) {
		di "70%"
		}
	if `n'==floor($num_sim*15/20) {
		di "75%"
		}
	if `n'==floor($num_sim*16/20) {
		di "80%"
		}
	if `n'==floor($num_sim*17/20) {
		di "85%"
		}
	if `n'==floor($num_sim*18/20) {
		di "90%"
		}	
	if `n'==floor($num_sim*19/20) {
		di "95%"
		}	
	if `n'==floor($num_sim) {
		di "100%"
		di "--------"
		di "        "
		}

}

keep  corr_* mse_* mean_*
save "$directorio\_aux\predicted.dta", replace
export delimited using "$directorio\_aux\predicted.csv", replace

