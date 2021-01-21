
global db _tope
global num_sim=1000

********************************************************************************

use "$directorio\DB\observaciones$db.dta", clear


label var c_total "Total demanded"
label var modo_term "Outcome"
label def modo 1 "Convenio" 2 "Desestimiento" 3 "Laudo" 4 "Caducidad"

capture replace modo_term="" if modo_term=="NA"
capture destring modo_term, replace
label values modo_term modo

for var c_antiguedad c_indem-c_desc_ob c_recsueldo gen horas_sem tipo_jornada ///
	reclutamiento sueldo tipo_abogado_ac edad trabajador_base: ///
	capture replace X="" if X=="NA"
capture replace salario_diario="" if salario_diario=="NA" | ///
	salario_diario=="NO ESPECIFICA" | salario_diario=="NO MENCIONA"

capture destring  c_antiguedad c_indem-c_desc_ob c_recsueldo gen horas_sem  ///
	tipo_jornada reclutamiento sueldo tipo_abogado_ac edad trabajador_base, replace
capture destring salario_diario, replace force

gen abogado_pub=tipo_abogado_ac==3 if tipo_abogado_ac~=.
gen edad_miss=edad==.
replace edad=0 if edad==.

gen y_dem=substr(fecha_demanda, 1, 4)
gen m_dem=substr(fecha_demanda, 6, 2)
gen d_dem=substr(fecha_demanda, 9, 2)

gen date_fil=y_dem + m_dem + d_dem
gen date_file=date(date_fil, "YMD")

format date_file %td 


for var c_antiguedad c_indem-c_desc_ob c_recsueldo liq_total: ///
	capture replace X=0 if X<0 & X~=.
	
*Wizorise all at 99th percentile
if "$db"=="_tope" {
	for var c_* liq_total: capture egen X99 = pctile(X) , p(99)
	for var c_antiguedad c_indem-c_desc_ob c_recsueldo liq_total: ///
		capture replace X=X99 if X>X99 & X~=.
	drop *99
	}
	
*Gen variables for regression	
gen liq_gt0=liq_total>0 if liq_total~=.
for var c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo : gen X2=X^2
	
	
/*--------------------*/
/* CROSS-VALIDATION   */
/*--------------------*/	

gen corr_m1_con=.
gen corr_m2_con=.
gen corr_m3_con=.

gen mse_m1_con=.
gen mse_m2_con=.
gen mse_m3_con=.

gen corr_m1_lau=.
gen corr_m2_lau=.

gen mse_m1_lau=.
gen mse_m2_lau=.

gen corr_m1_prob=.
gen corr_m2_prob=.
gen corr_m3_prob=.
gen corr_m4_prob=.
gen corr_m5_prob=.
gen corr_m6_prob=.
gen corr_m7_prob=.
gen corr_m8_prob=.
gen corr_m9_prob=.

gen mse_m1_prob=.
gen mse_m2_prob=.
gen mse_m3_prob=.
gen mse_m4_prob=.
gen mse_m5_prob=.
gen mse_m6_prob=.
gen mse_m7_prob=.
gen mse_m8_prob=.
gen mse_m9_prob=.

gen class_m1_prob=.
gen class_m2_prob=.
gen class_m3_prob=.
gen class_m4_prob=.
gen class_m5_prob=.
gen class_m6_prob=.
gen class_m7_prob=.
gen class_m8_prob=.
gen class_m9_prob=.


forvalues n=1/$num_sim {
	
	capture drop pre_*
	capture drop sampl
	qui capture gen sampl=runiform()
	qui capture replace sampl=(sampl<=0.7)
	
	
	/*--------------------*/
	/*REGRESIONS ON MONEY */
	/*--------------------*/
	
		/*----------*/
		/*CONVENIOS */
		/*----------*/
	
	*MODELO 1 CONVENIOS
		*more covariates CONVENIOS
	qui capture xi: reg liq_total    c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file i.junta i.giro if modo_termino==1 & sampl==1 , robust

	qui capture predict pre_m1_con if sampl==0 & modo_termino==1
		*Correlation
	qui capture corr pre_m1_con	liq_total 
	qui capture replace corr_m1_con=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m1_con)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m1_con=prom in `n'

	*MODELO 2 CONVENIOS 
		*add some covariates squared CONVENIOS
	qui capture xi: reg liq_total    c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		c_antiguedad2 c_indem2 c_rec202  c_utilidades2  gen codem date_file ///
		i.junta i.giro if modo_termino==1 & sampl==1 , robust

	qui capture predict pre_m2_con if sampl==0 & modo_termino==1
		*Correlation
	qui capture corr pre_m2_con	liq_total 
	qui capture replace corr_m2_con=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m2_con)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m2_con=prom in `n'	
	
	*MODELO 3 CONVENIOS
		*do we need to interact regressor with junta dummies
	qui capture xi: reg liq_total  c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file i.junta*c_antiguedad i.junta*c_indem i.junta*c_utilidades ///
		i.junta*i.gen  i.giro if modo_termino==1 & sampl==1 , robust
 
	qui capture predict pre_m3_con if sampl==0 & modo_termino==1
		*Correlation
	qui capture corr pre_m3_con	liq_total 
	qui capture replace corr_m3_con=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m3_con)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m3_con=prom in `n' 
 
		/*----------*/
		/*  LAUDOS 	*/
		/*----------*/

	*MODELO 1 LAUDOS
		*$LAUDOS | $Laudos>0
	qui capture xi: reg liq_total    c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		c_antiguedad2 c_indem2 c_rec202  c_utilidades2  gen codem date_file i.junta ///
		i.giro if modo_termino==3 & liq_total>0 & sampl==1, robust

	qui capture predict pre_m1_lau if sampl==0 & modo_termino==3
		*Correlation
	qui capture corr pre_m1_lau	liq_total 
	qui capture replace corr_m1_lau=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m1_lau)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m1_lau=prom in `n'

	*MODELO 2 LAUDOS
		*do we need to interact regressor with junta dummies
	qui capture xi: reg liq_total  c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file i.junta*c_antiguedad i.junta*c_indem i.junta*c_utilidades ///
		i.junta*i.gen  i.giro if modo_termino==3 & liq_total>0 & sampl==1, robust

	qui capture predict pre_m2_lau if sampl==0 & modo_termino==3
		*Correlation
	qui capture corr pre_m2_lau	liq_total 
	qui capture replace corr_m2_lau=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_total-pre_m2_lau)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m2_lau=prom in `n'
 
	/*--------------------------*/
	/*REGRESIONS ON PROBABILITY */
	/*--------------------------*/
 
		*Pr($LAUDO | LAUDO=0)
 
	*MODELO 1 PROBABILIDAD
	qui capture xi: dprobit liq_gt0  i.junta  if modo_termino==3 & sampl==1  , robust
	qui capture estat classification
	
		*Correctly classified
	qui capture replace class_m1_prob=`r(P_corr)' in `n'
	
	qui capture predict pre_m1_prob if sampl==0 & modo_termino==3
	
		*Correlation
	qui capture corr pre_m1_prob	liq_gt0 
	qui capture replace corr_m1_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m1_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m1_prob=prom in `n'
 
	*MODELO 2 PROBABILIDAD
	qui capture xi: dprobit liq_gt0    c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file  if modo_termino==3 & sampl==1 , robust
	qui capture estat classification
	
		*Correctly classified
	qui capture replace class_m2_prob=`r(P_corr)' in `n'
	
	qui capture predict pre_m2_prob if sampl==0 & modo_termino==3
	
		*Correlation
	qui capture corr pre_m2_prob	liq_gt0 
	qui capture replace corr_m2_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m2_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m2_prob=prom in `n'
	
	*MODELO 3 PROBABILIDAD
	qui capture discrim lda c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file  if modo_termino==3 & sampl==1, group(liq_gt0)  priors(proportional)
	
	qui capture predict pre_m3_prob if sampl==0 & modo_termino==3

		*Correctly classified
	qui capture tab pre_m3_prob liq_gt0, matcell(classif)
	qui capture mat classif=(classif\0,0)
	qui capture replace class_m3_prob=(classif[1,1]+classif[2,2])/`r(N)' in `n'
		*Correlation
	qui capture corr pre_m3_prob liq_gt0 
	qui capture replace corr_m3_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m3_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m3_prob=prom in `n'
 
	*MODELO 4 PROBABILIDAD
	qui capture discrim qda c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file  if modo_termino==3 & sampl==1, group(liq_gt0)  priors(proportional)
	
	qui capture predict pre_m4_prob if sampl==0 & modo_termino==3

		*Correctly classified
	qui capture tab pre_m4_prob liq_gt0, matcell(classif)
	qui capture mat classif=(classif\0,0)
	qui capture replace class_m4_prob=(classif[1,1]+classif[2,2])/`r(N)' in `n'
		*Correlation
	qui capture corr pre_m4_prob liq_gt0 
	qui capture replace corr_m4_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m4_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m4_prob=prom in `n'
	
	*MODELO 5 PROBABILIDAD
	qui capture discrim knn c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file  if modo_termino==3 & sampl==1, group(liq_gt0) k(15)  priors(proportional)
	
	qui capture predict pre_m5_prob if sampl==0 & modo_termino==3

		*Correctly classified
	qui capture tab pre_m5_prob liq_gt0, matcell(classif)
	qui capture mat classif=(classif\0,0)	
	qui capture replace class_m5_prob=(classif[1,1]+classif[2,2])/`r(N)' in `n'
		*Correlation
	qui capture corr pre_m5_prob liq_gt0 
	qui capture replace corr_m5_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m5_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m5_prob=prom in `n'
	
	*MODELO 6 PROBABILIDAD
	qui capture xi: krls liq_gt0  i.junta  if modo_termino==3 & sampl==1  

	qui capture predict pre_m6_prob if sampl==0 & modo_termino==3

		*Correctly classified
	qui gen pre_m6_prob_round=(pre_m6_prob>=0.5) if sampl==0 & modo_termino==3
	qui capture tab pre_m6_prob_round liq_gt0, matcell(classif)
	qui capture mat classif=(classif\0,0)
	qui capture replace class_m6_prob=(classif[1,1]+classif[2,2])/`r(N)' in `n'
		*Correlation
	qui capture corr pre_m6_prob liq_gt0 
	qui capture replace corr_m6_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m6_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m6_prob=prom in `n'
 
	*MODELO 7 PROBABILIDAD
	qui capture xi: krls liq_gt0   c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file  if modo_termino==3 & sampl==1 

	qui capture predict pre_m7_prob if sampl==0 & modo_termino==3

		*Correctly classified
	qui gen pre_m7_prob_round=(pre_m7_prob>=0.5) if sampl==0 & modo_termino==3		
	qui capture tab pre_m7_prob_round liq_gt0, matcell(classif)
	qui capture mat classif=(classif\0,0)
	qui capture replace class_m7_prob=(classif[1,1]+classif[2,2])/`r(N)' in `n'
		*Correlation
	qui capture corr pre_m7_prob liq_gt0 
	qui capture replace corr_m7_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m7_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m7_prob=prom in `n'
	
	*MODELO 8 PROBABILIDAD
	qui capture xi: logit liq_gt0  i.junta  if modo_termino==3 & sampl==1  , robust
	qui capture estat classification
	
		*Correctly classified
	qui capture replace class_m8_prob=`r(P_corr)' in `n'
	
	qui capture predict pre_m8_prob if sampl==0 & modo_termino==3
	
		*Correlation
	qui capture corr pre_m8_prob	liq_gt0 
	qui capture replace corr_m8_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m8_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m8_prob=prom in `n'
 
	*MODELO 9 PROBABILIDAD
	qui capture xi: logit liq_gt0    c_antiguedad c_indem c_rec20  c_utilidades c_recsueldo ///
		gen codem date_file  if modo_termino==3 & sampl==1 , robust
	qui capture estat classification
	
		*Correctly classified
	qui capture replace class_m9_prob=`r(P_corr)' in `n'
	
	qui capture predict pre_m9_prob if sampl==0 & modo_termino==3
	
		*Correlation
	qui capture corr pre_m9_prob	liq_gt0 
	qui capture replace corr_m9_prob=`r(rho)' in `n'
		*MSE
	capture drop diff prom
	qui capture gen diff=(liq_gt0-pre_m9_prob)^2
	qui capture egen prom=mean(diff)
	qui capture replace mse_m9_prob=prom in `n'
	

	qui preserve
	qui keep liq_total liq_gt0 pre_*
	qui tempfile temp_pred_`n'
	qui save `temp_pred_`n''
	qui restore


		*Progress bar

	if `n'==1 {
		di "Progress"
		di "--------"
		}
	if `n'==floor($num_sim/10) {
		di "10%"
		}
	if `n'==floor($num_sim*2/10) {
		di "20%"
		}
	if `n'==floor($num_sim*3/10) {
		di "30%"
		}
	if `n'==floor($num_sim*4/10) {
		di "40%"
		}
	if `n'==floor($num_sim*5/10) {
		di "50%"
		}
	if `n'==floor($num_sim*6/10) {
		di "60%"
		}
	if `n'==floor($num_sim*7/10) {
		di "70%"
		}
	if `n'==floor($num_sim*8/10) {
		di "80%"
		}
	if `n'==floor($num_sim*9/10) {
		di "90%"
		}
	if `n'==floor($num_sim) {
		di "100%"
		di "--------"
		di "        "
		}
}

save "$directorio\_aux\predicted$db.dta", replace



use `temp_pred_1', clear


forvalues n=2/$num_sim {

	append using `temp_pred_`n''
	
			*Progress bar

	if `n'==1 {
		di "Progress"
		di "--------"
		}
	if `n'==floor($num_sim/10) {
		di "10%"
		}
	if `n'==floor($num_sim*2/10) {
		di "20%"
		}
	if `n'==floor($num_sim*3/10) {
		di "30%"
		}
	if `n'==floor($num_sim*4/10) {
		di "40%"
		}
	if `n'==floor($num_sim*5/10) {
		di "50%"
		}
	if `n'==floor($num_sim*6/10) {
		di "60%"
		}
	if `n'==floor($num_sim*7/10) {
		di "70%"
		}
	if `n'==floor($num_sim*8/10) {
		di "80%"
		}
	if `n'==floor($num_sim*9/10) {
		di "90%"
		}
	if `n'==floor($num_sim) {
		di "100%"
		di "--------"
		di "        "
		}
	erase `temp_pred_`n''	
	}
save "$directorio\_aux\diff_append$db.dta", replace



