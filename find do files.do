*ssc install find
*ssc install rcd
 
*******************************************************************************/
clear
set more off
 
 
rcd "./DoFiles"  : find *.do , match(Append Encuesta Inicial Representante Actor.dta) show
