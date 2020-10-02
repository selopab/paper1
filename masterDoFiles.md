Notes regarding final replication.

# Cleaning

### 1.a- Pilot
_cleaning_pilot_rep.do_ - Main cleaning do file for pilot data and its surveys. Runs "name_cleaning_pilot_rep.do" for name cleaning.

### 1.b- Scaleup

_cleaning_scaleup.do_ - Main cleanin do file for scaleup, surveys, and 2018 followup. Runs "name_cleaning_scaleup.do" for name cleaning.
### 1.c- Historical data
_cleaning_hd_rep.do_ - Main cleaning do file for hd. Runs "name_cleaning_hd_rep.do" for name cleaning.

### 1.d- Time preferences
_mxfls_cleaning.do_ appends and cleans answers to MxFLS data.
_DB_time_pref.do_ Constructs a comparable database of frequencies of answers between MxFLS survey and P1 surveys.

### 1.e-P1 & P2 Followups
_importAppend2020Followups.do_ Imports and cleans outcome data for both P1 and P2
_cleaning_missingCasefiles.do_ Cleans initial casefilings that were recovered during 2019 - 2020
_clean_missing_predictions.do_ cleans calculator predictions that were originally missing
_cleanTerminaciones_v2.do_ cleans P1 & P2 2020 followups
### 1.f- Pilot 3
_cleanPilot3.do_ cleans P3 database for followup
_CleaningP3.do_ cleans survey (2m & 2w) data, as well as treatment data. It runs several auxiliay do files:  cleaning_2m_survey.do, cleaning_2w_survey.do

### 1.g- ITT sample for P1 & P2
_ITTSample.do_ selects casefiles that entered the ITT sample for the calculator experimental arm.

# Main Results

## Tables
### T1: Pilots description
_pilotsDescription.do_ Gets data for P1 & P2. May consider redoing the do file / table to include P3. Igual para incluir fechas etc.

### T2: Summary statistics
_SS_replicates.do_ Somehow the table got lost and this one does not replicate the one in the overleaf (we have more obs) I'll check the rest of the results to make sure this table is correct.

### T3: main regression
_ITTVersion.do_ This creates P1 & P2 columns except for CF
_treatment_effects_IV_CF_noConciliator_rep_NoDuplicatesITT.do_ Performs the CF regression under different assumptions (presented also in A.C)
_p3ResultMainTable.do_ Performs the regression with P3 outcomes

These results get merged in the excel file _TreatmentEffectsOnSettlement_main.xlsx_

### T4: TE by lawyer type
_teByLawyer.do_ Performs separate regressions for private and public lawyers. Result is formated in the te_bylawyer.xlsx file.

### T5 Expectation updating

_te_p3_updating.do_ Does the regression. Still misssing a xlsx to provide format.

### T6: Outcomes by treatments
_endMode.do_ Creates the table in a preformated xlsx

### T7: Recovery at 42 months (1 & 2)
_welfare42monthsP1P2.do_ Slight changes in the results.

### T9: Welfare effects P3
_P3welfare.do_ Missing an excel table that formats this.

## Figures

### F1: Claimed vs compensation
_Fig1_amount_plots_rep.R_ (ahorita la checo)

### F2: Time duration HD
_caseending_overtime_rep.do_

### F3: Knowledge of the law and lawsuit
_knowledge_allByType.do_

### F4: Treatment format
No do file

### F5: Calculator prediction for settled casefiles
_calculatorDistributionForSettled.do_

### F6: Calculator distribution for cases that won in court
_caseValueKdensitiesdo.do_ does it. It also does it disaggregated by phase.

# Appendix A
## Tables
### A1: Casefile variables Description
No do file
histograms_npv_hd.do <- quien sabe qué es esto

### A2: Survey SS For P1.
_surveyP1SS.do_

### A3: Experiment integrity
_complianceTable.do_ does panel A using only P1 data
_ComplianceP2Tables.do_ does panel B using only P2 data
_showUp.do_ does panel C using P1 & P2 data

### A4: Balance table
_balance.do_ Me faltan observaciones del P1. Supongo que vienen de las neuvas iniciales? Está raro

### A5: Fit assessment of the calculators (discrete)
calc_predictions.R (NO SE HA CORRIDO)

### A6: Fit assessment of the calculators (continoous)
calc_predictions.R (NO SE HA CORRIDO)

## Figures
### FA1: Covariate distribution comparison HS vs P1
\texttt{covariate\_plots.R , covariate\_plots\_hd.R }
### FA3: Covariate distribution comparison HS vs P2
\texttt{covariate\_plots.R , covariate\_plots\_hd.R }
