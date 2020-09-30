/*
Import missing predictions 
*/

import delimited "$sharelatex\DB\missingPredictionsP1.csv", varn(1) clear

destring junta prediccionmontolaudopos prediccionproblaudoneg prediccionproblaudopos, force replace

gen liq_total_laudo_avgM = prediccionproblaudopos*prediccionmontolaudopos

save "$sharelatex\DB\missingPredictionsP1", replace

bysort junta exp anio: drop if _n>1

save "$sharelatex\DB\missingPredictionsP1_wod", replace
