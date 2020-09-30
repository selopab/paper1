********************************************************************************
*																			   *
*						Main do file for cleaning data						   *
*																			   *
********************************************************************************

clear
set more off
cd "D:\MCLC\Pilot 1\information_sett\ReplicationFinal"
qui do ".\DoFiles\tabnumlab.do"

*********************
*		Pilot 1		* 
*********************

do ".\DoFiles\cleaning\cleaning_pilot_rep.do" 

*****************************
*		Pilot 2	(scaleup)	* 
*****************************

do ".\DoFiles\cleaning\cleaning_scaleup.do"

*****************************
*		Historical data 	* 
*****************************

do ".\DoFiles\cleaning\cleaning_hd.do"

*****************************
*		Time preferences 	* 
*****************************

do ".\DoFiles\cleaning\mxfls_cleaning.do"
do ".\DoFiles\cleaning\DB_time_pref.do"

*****************************
*		P1 & P2 Followups 	* 
*****************************

do ".\DoFiles\importAppend2020Followups.do"
do ".\DoFiles\cleaning_missingCasefiles.do"
do ".\DoFiles\clean_missing_predictions.do"

*****************************
*		P3 results 		 	* 
*****************************

do ".\DoFiles\clean_pilot3.do"

















