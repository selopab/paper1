/*
Create a dummy to verify inconsistencies
*/

/*Import July 2020 P2 Followup*/

import excel "$sharelatex\Raw\P2jul2020Followup.xlsx", firstr clear cellrange(A4)
drop if missing(Junta)
//drop Muestra50 
duplicates drop

preserve

foreach var of varlist Mododetérmino* {
replace `var' = subinstr(`var', " ","",.)
}

/*
foreach var of varlist Fechade* {
gen `var'_d = date(`var', "YMD")
}
*/

//gen FechadetérminoFechadeúlti_d = date(FechadetérminoFechadeúlti, "YMD")

foreach var in Cantidadotorgadaenlaudoaco CantidadpagadaINEGI CANTIDADOTORGADAENCONVENIOO Cantidadpagada{
destring `var', replace force
}


replace MododetérminoEXPEDIENTE = "CONTINUA" if MododetérminoEXPEDIENTE == "CONTINUO"
replace MododetérminoEXPEDIENTE = "CONVENIO" if MododetérminoEXPEDIENTE == "CCONVENIO" | ///
MododetérminoEXPEDIENTE == "CONVENO"

*Nombres---------------
rename FechadetérminoFechadeúlti fechaOfirec
rename Junta junta
rename Expediente expediente
rename Año anio
rename Cantidadotorgadaenlaudoaco otorgadaOfirec
rename CantidadpagadaINEGI pagadaOfirec
rename MododetérminoOFIREC terminoOfirec
rename MododetérminoEXPEDIENTE terminoExp
rename DummylaudoconveniopagadoCOM pagoCompleto
rename OBSERVACIONESOFIREC comentariosOfirec
rename Observaciones comentariosExp
rename Cantidadpagada pagadaExp
ren CANTIDADOTORGADAENCONVENIOO otorgadaExp

//gen fechaExp = date(M, "DMY")
ren M fechaExp_s

gen fechaExp = date(fechaExp_s, "DMY")
replace fechaExp = date(fechaExp_s, "MDY") if missing(fechaExp)

format fechaOfirec %td
format fechaExp %td
lab var fechaOfirec "Fecha de ultimo movimiento registrado en OFIREC"
lab var fechaExp "Fecha de ultimo movimiento registrado en expediente"

gen difDates=abs(fechaOfirec-fechaExp)
gen difPag = abs(pagadaExp - pagadaOfirec)
gen difOtor = abs(otorgadaExp - otorgadaOfirec)

gen verify = 0

replace verify = 1 if  difDates>365 & !missing(fechaOfirec) & !missing(fechaExp)
gen problema1 = "Más de un año de diferencia entre expediente y ofirec" if  difDates>365 & !missing(fechaOfirec) & !missing(fechaExp) //102 obs

replace verify = 1 if  difPag > 0 & !missing(pagadaExp) & !missing(pagadaOfirec)
gen problema2 = "Cantidad pagada en expediente y ofirec es diferente" if  difPag > 0 & !missing(pagadaExp) & !missing(pagadaOfirec ) //25 obs

replace verify = 1 if difOtor>0 & !missing(otorgadaExp) & !missing(otorgadaOfirec)
gen problema3 = "Cantidad otorgada en expediente y ofirec es diferente" if difOtor>0 & !missing(otorgadaExp) & !missing(otorgadaOfirec) 

replace verify = 1 if  terminoOfirec != terminoExp
gen problema4 = "Modos de término difierentes" if difOtor>0 & !missing(otorgadaExp) & !missing(otorgadaOfirec) 


keep junta expediente anio NombreActor verify problema*

ren(junta expediente anio) (Junta Expediente Año)

tempfile toVerify
save `toVerify', replace

restore

merge 1:1 Junta Expediente Año NombreActor using `toVerify'

export excel "$sharelatex\out\toVerify2020FP.xlsx", firstr(var) replace
