ritest altT _b[altT], reps(1000) seed(125): reg seconcilio altT i.anio i.junta i.phase i.numActores if phase==1, robust  cluster(fecha)

matrix pvalues=r(p) //save the p-values from ritest
//mat colnames pvalues = treatment //name p-values so that esttab knows to which coefficient they be
local pvalNoInteract = pvalues[1,1]

reg seconcilio i.treatment `controls' if treatment!=0 & phase==1, robust  cluster(fecha)
	qui sum seconcilio if e(sample) & treatment == 1
	local DepVarMean = r(mean)
	
	outreg2 using  "./Tables/reg_results/treatment_effectsITT.xls", replace ctitle("Same day. P1") ///
	addtext(Court Dummies, Yes, Casefile Controls, No) keep(2.treatment 1.p_actor 2.treatment#1.p_actor ) ///
	addstat(Dependent Variable Mean, `DepVarMean', pvalueRI, `pvalNoInteract')  dec(3)



/*
ritest dtreatment _b[dtreatment], reps(1000) seed(125): reg convenio_m5m dtreatment##i.p_actor i.anio i.junta i.phase i.numActores if treatment!=0, robust  cluster(fecha)
