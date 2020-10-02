*****************************************************************
*																*
*		Get basic statistics for pilot description table		*
*																*
*****************************************************************

* 1) Create databas
********************************************************************************
use  ".\DB\ITTSample.dta"

*2) Calculate things and write table
putexcel set ".\Tables\tablePilots.xlsx", modify sheet("pilotsDescription")
count if phase==1
local num = `r(N)'
putexcel D2 = (`num')
count if phase==1 & treatment == 2
putexcel E2 = (`r(N)')

count if phase==2
putexcel D3 = (`r(N)')
count if phase==2 & treatment == 2
putexcel E3 = (`r(N)')




