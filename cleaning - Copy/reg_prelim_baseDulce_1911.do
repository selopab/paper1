


import excel "D:\Dropbox\Dropbox\Documentos_\Joyce_Seira\p1_w_p3\inp\SEGUNDO SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear 
*import excel "C:\Users\joyce\Dropbox\Documentos_\Joyce_Seira\p1_w_p3\inp\SEGUNDO SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear
drop S T U V W X Y Z AA AB AC AD AE AF
replace EXPEDIENTE = subinstr(EXPEDIENTE, ".pdf","",.)
replace EXPEDIENTE = subinstr(EXPEDIENTE, "J","",.)
tempfile base
ren IDACTOR id_actor

replace id_actor = subinstr(id_actor, ",",";",.)
split id_actor, parse(";")


preserve 
keep EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD ///
CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES ///
OBSERVACIONESDEIDACTOR TRATAMIENTO OBSERVACIONESGENERALESDELEXPE auxiliar junta ///
expediente anio id_actor1
ren id_actor1 id_actor
tempfile base_ids
save `base_ids', replace
restore

forvalues i = 2/6{
preserve 
keep EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD ///
CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES ///
OBSERVACIONESDEIDACTOR TRATAMIENTO OBSERVACIONESGENERALESDELEXPE auxiliar junta ///
expediente anio id_actor`i'
ren id_actor`i' id_actor
append using `base_ids'
save `base_ids', replace
restore
}
use `base_ids', clear

drop if id_actor==""

duplicates tag id_actor EXPEDIENTE, gen(dups)
drop if dups>0
drop dups
save `base'

export excel "C:\Users\joyce\Dropbox\Documentos_\Joyce_Seira\p1_w_p3\out\dulce.xlsx", firstr(var) replace


import excel "D:\Dropbox\Dropbox\Documentos_\Joyce_Seira\p1_w_p3\inp\Base_completa2.xls", firstr clear
*import excel "C:\Users\joyce\Dropbox\Documentos_\Joyce_Seira\expedientes_a_fiscaizar\SEGUNDO SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear
replace Junta = subinstr(Junta, "J", "",.)
gen EXPEDIENTE = Junta +"_"+Exp+"_"+Año

*Remove blank spaces
gen nombre_actor=stritrim(trim(itrim(upper(Nombreactor))))

*Basic name cleaning 
replace nombre_actor = subinstr(nombre_actor, ".", "", .)
replace nombre_actor = subinstr(nombre_actor, " & ", " ", .)
replace nombre_actor = subinstr(nombre_actor, "&", "", .)
replace nombre_actor = subinstr(nombre_actor, ",", "", .)
replace nombre_actor = subinstr(nombre_actor, "ñ", "N", .)
replace nombre_actor = subinstr(nombre_actor, "Ñ", "N", .)
replace nombre_actor = subinstr(nombre_actor, "-", " ", .)
replace nombre_actor = subinstr(nombre_actor, "á", "A", .)
replace nombre_actor = subinstr(nombre_actor, "é", "E", .)
replace nombre_actor = subinstr(nombre_actor, "í", "I", .)
replace nombre_actor = subinstr(nombre_actor, "ó", "O", .)
replace nombre_actor = subinstr(nombre_actor, "ú", "U", .)
replace nombre_actor = subinstr(nombre_actor, "Á", "A", .)
replace nombre_actor = subinstr(nombre_actor, "É", "E", .)
replace nombre_actor = subinstr(nombre_actor, "Í", "I", .)
replace nombre_actor = subinstr(nombre_actor, "Ó", "O", .)
replace nombre_actor = subinstr(nombre_actor, "Ú", "U", .)
replace nombre_actor = subinstr(nombre_actor, "â", "A", .)
replace nombre_actor = subinstr(nombre_actor, "ê", "E", .)
replace nombre_actor = subinstr(nombre_actor, "î", "I", .)
replace nombre_actor = subinstr(nombre_actor, "ô", "O", .)
replace nombre_actor = subinstr(nombre_actor, "ù", "U", .)
replace nombre_actor = subinstr(nombre_actor, "Â", "A", .)
replace nombre_actor = subinstr(nombre_actor, "Ê", "E", .)
replace nombre_actor = subinstr(nombre_actor, "Î", "I", .)
replace nombre_actor = subinstr(nombre_actor, "Ô", "O", .)
replace nombre_actor = subinstr(nombre_actor, "Û", "U", .)
replace nombre_actor = subinstr(nombre_actor, " DE ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " DEL ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LA ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LAS ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LO ", " ", .)
replace nombre_actor = subinstr(nombre_actor, " LOS ", " ", .)

replace nombre_actor=stritrim(trim(itrim(upper(nombre_actor))))


*Remove special characters
gen newname = "" 
gen length = length(nombre_actor) 
su length, meanonly 

forval i = 1/`r(max)' { 
     local char substr(nombre_actor, `i', 1) 
     local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
     qui replace newname = newname + `char' if `OK' 
}
replace nombre_actor=newname
drop newname length

*Generate "new name" in alphabetical order
	*Split string
split nombre_actor, p(" ") gen(aux_names)

local k=0
foreach var of varlist aux_names* {
	local k=`k'+1
	}
	*Sort in rows
rowsort aux_names1-aux_names`k', generate(order_names1-order_names`k')

	*Gen "new name"
gen plaintiff_name=""
forvalues i=1/`k' {
	replace plaintiff_name=plaintiff_name + " " + order_names`i'
	}
replace plaintiff_name=stritrim(trim(itrim(upper(plaintiff_name))))


merge m:m plaintiff_name using D:\Dropbox\Dropbox\Documentos_\Joyce_Seira\p3_c_enrique\Pilot3_Paper\DB\treatment_data.dta, ///
nogen keep(3)
*keep if ESTATUS=="TERMINO"
duplicates tag id_actor EXPEDIENTE, gen(dups)
drop if dups>0
drop dups
merge 1:1 id_actor EXPEDIENTE using `base'

//*******

gen convenio = MODODETERMINO == "CONVENIO"
gen main_treatment = .
replace main_treatment = 1 if TRATAMIENTO=="1A"
replace main_treatment = 1 if TRATAMIENTO=="1B"
replace main_treatment = 2 if TRATAMIENTO == "2"

save "$sharelatex\DB\Dulce_1911_prueba", replace

/*
reg convenio i.main_treatment


use , clear
