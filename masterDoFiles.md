Notes regarding final replication.

# 1) Cleaning

## 1.a- Pilot
cleaning_pilot_rep.do - Main cleaning do file for pilot data and its surveys. Runs "name_cleaning_pilot_rep.do" for name cleaning.

## 1.b- Scaleup
cleaning_scaleup.do - Main cleanin do file for scaleup, surveys, and 2018 followup. Runs "name_cleaning_scaleup.do" for name cleaning.

## 1.c- Historical data
cleaning_hd_rep.do - Main cleaning do file for hd. Runs "name_cleaning_hd_rep.do" for name cleaning.

## 1.d- Time preferences
mxfls_cleaning.do appends and cleans answers to MxFLS data.
DB_time_pref.do Constructs a comparable database of frequencies of answers between MxFLS survey and P1 surveys.

## 1.e-P1 & P2 Followups
importAppend2020Followups.do Imports and cleans outcome data for both P1 and P2
cleaning_missingCasefiles.do Cleans initial casefilings that were recovered during 2019 - 2020
clean_missing_predictions.do cleans calculator predictions that were originally missing
cleanTerminaciones_v2.do cleans P1 & P2 2020 followups
## 1.f- Pilot 3
cleanPilot3.do cleans P3 database for followup
CleaningP3.do cleans survey (2m & 2w) data, as well as treatment data. It runs several auxiliay do files:  cleaning_2m_survey.do, cleaning_2w_survey.do

## 1.g- ITT sample for P1 & P2
ITTSample.do selects casefiles that entered the ITT sample for the calculator experimental arm.

# 2) Main Tables

## T1: Pilots description
pilotsDescription.do Gets data for P1 & P2. May consider redoing the do file / table to include P3. Igual para incluir fechas etc.

## T2: Summary statistics
SS_replicates.do Somehow the table got lost and this one does not replicate the one in the overleaf (we have more obs) I'll check the rest of the results to make sure this table is correct.

## T3: main regression
ITTVersion.do This creates P1 & P2 columns except for CF
treatment_effects_IV_CF_noConciliator_rep_NoDuplicatesITT.do Performs the CF regression under different assumptions (presented also in A.C)
p3ResultMainTable.do Performs the regression with P3 outcomes

These results get merged in the excel file TreatmentEffectsOnSettlement_main.xlsx

## T4: TE by lawyer type
teByLawyer.do Performs separate regressions for private and public lawyers. Result is formated in the te_bylawyer.xlsx file.

## T5 Expectation updating

te_p3_updating.do Does the regression. Still misssing a xlsx to provide format.

## T6: Outcomes by treatments
endMode.do Creates the table in a preformated xlsx

## T7: Recovery at 42 months (1 & 2)
welfare42monthsP1P2.do Slight changes in the results.

## T9: Welfare effects P3
P3welfare.do. Missing an excel table that formats this.

# Main figures

## F1: Claimed vs compensation
Fig1_amount_plots_rep.R (ahorita la checo)

## F2: Time duration HD
caseending_overtime_rep.do

## F3: Knowledge of the law and lawsuit
knowledge_allByType.do

## F4: Treatment format
No do file

## F5: Calculator prediction for settled casefiles
calculatorDistributionForSettled.do

## F6: Calculator distribution for cases that won in court
caseValueKdensitiesdo.do does it. It also does it disaggregated by phase. 
