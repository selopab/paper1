********************************************************************************
*																			   *
*						Main do file for Appendix A						   *
*																			   *
********************************************************************************

clear
set more off
cd "D:\MCLC\Pilot 1\information_sett\ReplicationFinal"
//qui do ".\DoFiles\tabnumlab.do"

***************
*   Tables    *
***************
*  A2: Survey SS For P1.
do "DoFiles\appendix\surveyP1SS.do"

* A3: Experiment integrity
do "DoFiles\appendix\complianceTable.do" //does panel A using only P1 data
do "DoFiles\appendix\ComplianceP2Tables.do" //does panel B using only P2 data
do "DoFiles\appendix\showUp.do" //does panel C using P1 & P2 data

* A4: Balance table
do "DoFiles\appendix\balance.do" //Me faltan observaciones del P1. Supongo que vienen de las neuvas iniciales? Está raro
