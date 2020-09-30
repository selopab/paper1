Notes regarding final replication. 

1) Cleaning

1a) Pilot
cleaning_pilot_rep.do - Main cleaning do file for pilot data and its surveys. Runs "name_cleaning_pilot_rep.do" for name cleaning. 

1b) Scaleup
cleaning_scaleup.do - Main cleanin do file for scaleup, surveys, and 2018 followup. Runs "name_cleaning_scaleup.do" for name cleaning.

1c) Historical data 
cleaning_hd_rep.do - Main cleaning do file for hd. Runs "name_cleaning_hd_rep.do" for name cleaning. 

1d) Time preferences
mxfls_cleaning.do appends and cleans answers to MxFLS data. 
DB_time_pref.do Constructs a comparable database of frequencies of answers between MxFLS survey and P1 surveys. 

1e) Updated data 
importAppend2020Followups.do Imports and cleans outcome data for both P1 and P2
cleaning_missingCasefiles.do Cleans initial casefilings that were recovered during 2019 - 2020
clean_missing_predictions.do cleans calculator predictions that were originally missing

1f) Pilot 3
cleanPilot3.do cleans P3 database

