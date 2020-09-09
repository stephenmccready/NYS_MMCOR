SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_UpdateServiceTypeCode]
AS
BEGIN


/*
There are three different methodologies available for classifying an encounter into a service category: 
Multi-Level, Line Level and Header Level.
Based on the amount of detail available on the encounter record, Issuers are advised to select the appropriate methodology 
using the following iterative hierarchy:
1. Multi-Level
	This is the 'Gold Standard' for reporting. If an encounter record satisfies all conditions of a multi-level logic
	, it can be classified as such. If a multi-level logic is not available for a category of service, this step can be skipped altogether.
	For most service categories, the logic follows this standard syntax:
	(((Category of Service) or (Provider Specialty Code)) and (Procedure Code and/or Revenue Code)))
2. Line Level – Procedure Code
	Records that remain not categorized by multi-level logic, are assigned based on meeting a line-level procedure code definition.
3. Line Level – Revenue Code
	Records that remain not categorized after
4. Header Level – Provider Specialty Code
	Records that remain not categorized after step 3 are assigned based on meeting a header-level provider specialty code definition.
5. Header Level - Primary Diagnosis Code
	Records that remain uncategorized are assigned based on
*/

/*
For DIAG_LAB ne 1, Diagnostic Laboratory Procedure Codes to Exclude: 
IF Procedure_Code in (‘36400’, ‘36410’, ‘36415’, ‘59000’, ‘59012’, ‘59015’, ‘74741’) 
						OR (‘70000’ <= Procedure_Code <= ‘74739’) 
						OR (‘74743’ <= Procedure_Code <= ‘76840’) 
						Or (‘76842’ <= Procedure_Code <= ‘76856’) 
						OR (‘76858’ <= Procedure_Code <= ‘79999’) 
						Or (‘80002’ <= Procedure_Code <= ‘89309’) 
						OR (‘89311’ <= Procedure_Code <= ‘89499’) 
						Or (‘P0000’ <= Procedure_Code <= ‘P9999’) 
						OR (‘R0000’ <= Procedure_Code <= ‘R5999’) then DIAG_LABS = 1;
*/
-- SET DIAG_LABS flag
UPDATE	E
SET		DIAG_LABS = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Procedure_Code IN('36400', '36410', '36415', '59000', '59012', '59015', '74741') 
OR		E.Procedure_Code BETWEEN '70000' AND '74739'
OR		E.Procedure_Code BETWEEN '74743' AND '76840'
OR		E.Procedure_Code BETWEEN '76842' AND '76856'
OR		E.Procedure_Code BETWEEN '76858' AND '79999'
OR		E.Procedure_Code BETWEEN '80002' AND '89309'
OR		E.Procedure_Code BETWEEN '89311' AND '89499'
OR		E.Procedure_Code BETWEEN 'P0000' AND 'P9999'
OR		E.Procedure_Code BETWEEN 'R0000' AND 'R5999'

-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- MULTI LEVEL "GOLD STANDARD"
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================

/*
Inpatient Categories of Service

Services provided under the direction of a physician, physician's assistant, nurse practitioner, 
psychiatrist, psychologist, or dentist in the hospital for care and treatment of inpatients. 
Inpatient services include care, treatment, maintenance and nursing services that may be required on an 
inpatient hospital basis. Inpatient hospital services encompass a full range of necessary diagnostic and 
therapeutic care including medical, surgical, radiological and rehabilitative services.
All categories are mutually exclusive.
Health plans should not include HCRA surcharge amounts in encounter data paid amounts.
*/

/* -------------------------------------------------------------------------------------------------------
10: INPATIENT NEWBORN > = 1200 grams

Newborn care, as defined by NCQA, is care provided from birth to discharge to home. 
Newborn care that is rendered after the baby has been discharged to home is not included. 
Only newborns with birth weight greater than or equal to 1200 grams can be included here. 
Per Discharge
IF Category_of_Service = '11' then do;
	if AP_DRG_Code = ‘0641’ 
	OR ('0609' <= AP_DRG_Code <= '0624') 
	OR ('0626' <= AP_DRG_Code <= '0630') then NEWBORN = 1;
IF Category_of_Service = '11' then do;
	if APR_DRG_Code in (‘602’, ‘603’, ‘607’, ‘608’, ‘609’, ‘611’, ‘612’, ‘613’, ‘614’, ‘621’, ‘622’, ‘623’
	, ‘625’, ‘626’, ‘630’, ‘631’, ‘633’, ‘634’, ‘636’, ‘639’, ‘640’) then NEWBORN = 1;
IF Category_of_Service = '11' then do;
	if (AP_DRG_Code = '0635' 
	OR ('0606'<= AP_DRG_Code <= '0608')
	OR ('0637' <= AP_DRG_Code <= '0640')) AND (Birth Weight >= 1200 grams OR = 0 grams) then NEWBORN = 1;
IF Category_of_Service = '11' then do;
	if APR_DRG_Code in (‘580’, ‘581’, ‘583’, ‘588’) AND (Birth Weight >= 1200 grams OR = 0 grams) then NEWBORN = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 10
,		NEWBORN = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		E.NewBorn_Flag = 1
AND		(	E.AP_DRG_Code = '0641' 
			OR E.AP_DRG_Code BETWEEN '0609' AND '0624'
			OR E.AP_DRG_Code BETWEEN '0626' AND '0630'	
			OR E.AP_DRG_Code IN('0602', '0603', '0607', '0608', '0609', '0611', '0612', '0613', '0614'
								, '0621', '0622', '0623', '0625', '0626', '0630', '0631'
								, '0633', '0634', '0636', '0639', '0640')
			OR 
			(	(	E.AP_DRG_Code = '0635' 
					OR E.AP_DRG_Code BETWEEN '0606' AND '0608'
					OR E.AP_DRG_Code BETWEEN '0637' AND '0640'
					OR E.AP_DRG_Code In('0580', '0581', '0583', '0588')
				)
				AND E.Birthweight IS NOT NULL 
				AND E.Birthweight >= 1200
			)
		)

/* -------------------------------------------------------------------------------------------------------
20: INPATIENT NEWBORN – LOW BIRTH WEIGHT (<1200 grams)

Newborn care, as defined by NCQA, is care provided from birth to discharge to home. 
Newborn care that is rendered after the baby has been discharged to home is not included. 
Only newborns with birth weight less than 1200 grams can be included here. 
Per Discharge

IF Category_of_Service = '11' then do;
	If ('0602'<= AP_DRG_Code <= '0605') then LBW NEWBORN = 1;
IF Category_of_Service = '11' then do;
	If APR_DRG_Code = (‘589’, ‘591’, ‘593’) then LBW NEWBORN = 1;
IF Category_of_Service = '11' then do;
	if (AP_DRG_Code = '0635' 
	OR ('0606' <= AP_DRG_Code <= '0608') 
	OR ('0637'<= AP_DRG_Code <= '0640')) AND (Birth Weight < 1200 grams) then LBW NEWBORN = 1;
IF Category_of_Service= '11' then do;
	if APR_DRG_Code in (‘580’, ‘581’, ‘583’, ‘588’, ‘602’, ‘603’) AND (Birth Weight < 1200 grams) then LBW NEWBORN = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 20
,		LBW_NEWBORN = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		E.NewBorn_Flag = 1
AND		(	E.AP_DRG_Code BETWEEN '0602' AND '0605'
			OR E.AP_DRG_Code IN('0589', '0591', '0593')
			OR 
			(	(	E.AP_DRG_Code = '0635' 
					OR E.AP_DRG_Code BETWEEN '0606' AND '0608'
					OR E.AP_DRG_Code BETWEEN '0637' AND '0640'
					OR E.AP_DRG_Code In('0580', '0581', '0583', '0588', '0602', '0603')
				)
				AND E.Birthweight IS NOT NULL 
				AND E.Birthweight < 1200
			)
		)

/* -------------------------------------------------------------------------------------------------------
30: INPATIENT MATERNITY

Not all OB discharges should be included in this category: 
include only those during which a delivery (live birth or stillborn) occurred. 
Per Discharge
IF Category_of_Service = '11' then do;
	if ('0370' <= AP_DRG_Code <= '0375') OR ('0650' <= AP_DRG_Code <= '0652') then MATERNITY = 1;
IF Category_of_Service = '11' then do;
	if APR_DRG_Code in (‘540’, ‘541’, ‘542’, ‘560’) then MATERNITY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 30
,		MATERNITY = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		(	E.AP_DRG_Code BETWEEN '0370' AND '0375'
			OR E.AP_DRG_Code BETWEEN '0650' AND '0652'
			OR E.AP_DRG_Code IN('0540', '0541', '0542', '560')
		)

/* -------------------------------------------------------------------------------------------------------
40: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: INPATIENT MENTAL HEALTH

A 24-hours per day hospital-based program which includes psychiatric, medical, nursing, and 
social services which are required for the assessment and or treatment of a person with a primary 
diagnosis of mental illness who cannot be adequately served in the community. Such programs may be 
offered by general hospitals, private hospitals for the mentally ill, and state operated 
psychiatric centers.
Per Discharge
IF Category_of_Service = '11' AND Rate_Code in (‘2852’, ‘2858’, ‘2946’) then do;
	if AP_DRG_Code in ('0425','0426','0427','0428','0430','0431','0432') then PYSCHSA = 1;
IF Category_of_Service = '11' AND Rate_Code in (‘2852’, ‘2858’, ‘2946’) then do;
	if AP_DRG_Code in (‘750’, ‘751’, ‘752’, ‘753’, ‘754’, ‘755’, ‘756’,’757’, ‘758’, ‘759’) then PYSCHSA = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 40
,		PYSCHSA = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		E.Rate_Code IN('2852', '2858', '2946')
AND		(	E.AP_DRG_Code IN('0425','0426','0427','0428','0430','0431','0432')
			OR E.AP_DRG_Code BETWEEN '0650' AND '0652'
			OR E.AP_DRG_Code IN('0750', '0751', '0752', '0753', '0754', '0755', '0756', '0757', '0758', '0759')
		)

/* -------------------------------------------------------------------------------------------------------
50: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD DETOXIFICATION: MEDICALLY MANAGED WITHDRAWAL

This category includes inpatient detoxification services provided in an Article 28 acute care hospital or 
Medically Managed Withdrawal Services (MMWS) provided in an inpatient setting. These services include 
medically directed inpatient care to individuals who are at risk of serious alcohol or substance 
withdrawal, a risk to self or others, or diagnosed with an acute physical or mental co-morbidity that 
could increase medical risk.
Per Discharge
IF Category_of_Service = '11' AND Provider_Specialty_Code in (‘013’) then do;
	if Rate_Code = ‘4800’ then PYSCHSA = 1;
IF Category_of_Service = '11' AND Provider_Specialty_Code in (‘013’) then do;
	if APR_DRG_Code in (‘770’, ‘772’, ‘773’, ‘774’, ‘775’, ‘776’) 
	AND AP_DRG_Type_Code = 2 then PYSCHSA = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 50
,		PYSCHSA = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		E.Provider_Specialty_Code = '013'	--
AND		(	E.Rate_Code = '4800'
			OR	(	E.AP_DRG_Code IN('0770', '0772', '0773', '0774', '0775', '0776') 
					AND E.AP_DRG_Type_Code = 2	)
		)

/* -------------------------------------------------------------------------------------------------------
60: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD DETOXIFICATION: MEDICALLY SUPERVISED WITHDRAWAL

This category includes inpatient detoxification services provided in an Article 28 acute care hospital or 
Medically Supervised Withdrawal Services (MSWS) provided in an inpatient setting. These services include 
medically directed inpatient care to individuals who are at risk of serious alcohol or substance withdrawal
, a risk to self or others, or diagnosed with an acute physical or mental co-morbidity that could increase 
medical risk.
Per Discharge
IF Category_of_Service = '11' AND Provider_Specialty_Code in (‘309’) then do;
	if Rate_Code in (‘4203’, ‘4220’, ‘4801’, ‘4802’, ‘4803’) then PYSCHSA = 1;
IF APR-DRG_Code in (‘770’, ‘772’, ‘773’, ‘774’, ‘775’, ‘776’) AND AP_DRG_Type_Code = 2 then PYSCHSA = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 60
,		PYSCHSA = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		E.Provider_Specialty_Code = '309'
AND		(	E.Rate_Code IN('4203', '4220', '4801', '4802', '4803')
			OR	(	E.AP_DRG_Code IN('0770', '0772', '0773', '0774', '0775', '0776') 
					AND E.AP_DRG_Type_Code = 2	)
		)

/* -------------------------------------------------------------------------------------------------------
70: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD INPATIENT REHABILITATION

This category includes inpatient substance use disorder rehabilitation and treatment services provided in 
a hospital or free- standing facility certified by the Office of Alcohol and Substance Abuse Services 
(OASAS) to provide such services. These services include medically directed inpatient care to individuals 
who have high risk of imminent harm if pattern of use continues or who have serious medical or psychiatric 
co-morbidity.
Per Discharge
IF Category_of_Service = '11' AND Provider_Specialty_Code = ‘007’ then do;
	if Rate_Code in (‘2957’, ’2993’, ‘4202’, ‘4204’, ‘4213’) then PYSCHSA = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 70
,		PYSCHSA = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		E.Provider_Specialty_Code = '007'
AND		E.Rate_Code IN('2957', '2993', '4202', '4204', '4213')

/* -------------------------------------------------------------------------------------------------------
80: INPATIENT MENTAL HEALTH and SUBSTANCE ABUSE: OASAS RESIDENTIAL TREATMENT PER DIEM
OASAS Residential Treatment Per Diem
Per Day
IF Category_of_Service in (‘11’) AND Provider_Specialty_Code in (‘754’) AND Rate Code In (‘1144’, ‘1145’, ‘1146’) then PSYCHSA = 1;
IF Category_of_Service in (‘11’) AND Provider_Specialty_Code = ‘959’ AND Rate_Code = ‘4210’ then PSYCHSA = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 80
,		PYSCHSA = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		(	(	E.Provider_Specialty_Code = '754'
				AND E.Rate_Code IN('1144', '1145', '1146')	)
			OR
			(	E.Provider_Specialty_Code = '959'
				AND E.Rate_Code = '4210')
		)

/* -------------------------------------------------------------------------------------------------------
90: INPATIENT MEDICAL SURGICAL

This category includes all medical and surgical services provided in an acute care hospital that are not 
identified as part of another category of service defined in inpatient section.
Per Discharge
IF Category_of_Service = '11' AND NOT (NEWBORN, LBW NEWBORN, MATERNITY, PYSCHSA) then MEDSURG = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 90
,		MEDSURG = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '11'
AND		ISNULL(E.NEWBORN,0) = 0
AND		ISNULL(E.LBW_NEWBORN,0) = 0
AND		ISNULL(E.MATERNITY,0) = 0
AND		ISNULL(E.PYSCHSA,0) = 0

/* -------------------------------------------------------------------------------------------------------
100: HOSPICE

Inpatient Hospice
Per Day

IF (Category_of_Service in ('73', '12') 
OR Provider_Specialty_Code in ('669')) 
AND Revenue_Code in ('0655', '0656', '0658') then HOSPICE = 1
*/
UPDATE	E
SET		ServiceTypeCode = 100
,		HOSPICE = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service IN('73', '12')
			OR E.Provider_Specialty_Code = '669'	)
AND		E.Revenue_Code IN('0655', '0656', '0658')


/* -------------------------------------------------------------------------------------------------------
110: SKILLED NURSING FACILITY (SNF) - NON-SPECIALTY

Skilled Nursing Facility (non-specialty) nursing home utilization reported includes short term rehab, 
therapeutic, hospital care and long term skilled nursing care rendered in a Residential Health Care 
Facility (RHCF) or Nursing Home.
Per Day
*/
UPDATE	E
SET		ServiceTypeCode = 110
,		NH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '12'
AND		E.Provider_Specialty_Code IN('660','663', '790')
AND		E.Ins_Type_Bill_1_2 = '21'
AND		(	E.Revenue_Code BETWEEN '0180' AND '0185'
			OR E.Revenue_Code BETWEEN '0189' AND '0199'
			OR E.Revenue_Code BETWEEN '0100' AND '0169'
			OR E.Revenue_Code BETWEEN '0420' AND '0444'	)

/* -------------------------------------------------------------------------------------------------------
120: SKILLED NURSING FACILITY (SNF) - SPECIALTY

Skilled Nursing Facility specialty nursing home utilization reported includes AIDS, Head Injury/Traumatic 
Brain Injury (TBI), Neuro, Pediatric or Vent-care rendered in a Residential Health Care Facility (RHCF) or 
Nursing Home. 
Per Day

*/
UPDATE	E
SET		ServiceTypeCode = 120
,		NH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '12'
AND		E.Provider_Specialty_Code IN('655', '656', '657', '658', '659')
AND		E.Ins_Type_Bill_1_2 = '21'
AND		(	E.Revenue_Code BETWEEN '0180' AND '0185'
			OR E.Revenue_Code BETWEEN '0189' AND '0199'
			OR E.Revenue_Code BETWEEN '0100' AND '0169'
			OR E.Revenue_Code BETWEEN '0420' AND '0444'	)


/* ========================================================================================================
Outpatient Categories of Service

In general, outpatient encounters can be classified by provider type. When this is not possible, or where a 
provider type overlaps more than one category, additional information from the encounter such as diagnosis 
and procedure codes should be used to categorize it appropriately.
For most claims that contain multiple service lines assignable to more than one category of service, the 
plan should map the claim to the COS that reflects the primary reason for the encounter or which is the 
primary driver of the payment.

If the encounter generates multiple claims requiring payments to different providers, then multiple 
encounters should be counted.

Primary Care and Physician Specialist claims may include diagnostic tests provided during the visit. 
Even though a single payment covering all service lines may be made to the provider, the cost for the 
diagnostic tests should be reported under Diagnostic Testing Lab and X-ray category while the professional 
component should be reported in the appropriate physician category.
*/

/* -------------------------------------------------------------------------------------------------------
200: EMERGENCY ROOM

Health care procedures, treatments or services provided in a hospital Emergency Room (ER) needed to 
evaluate or stabilize an Emergency Medical Condition, including psychiatric stabilization and medical 
detoxification from drugs or alcohol.

An Emergency Medical Condition is a medical or behavioral condition, the onset of which is sudden, 
manifesting itself by symptoms of sufficient severity, including severe pain, that a prudent layperson, 
possessing an average knowledge of medicine and health, could reasonably expect the absence of medical 
attention to result in 
(a) placing the health of the person afflicted with such condition in serious 
jeopardy, or in the case of a behavioral condition placing the health of such person or others in serious 
jeopardy; 
(b) serious impairment of such person's bodily functions; 
(c) serious dysfunction of any bodily organ or part of such person; or 
(d) serious disfigurement of such person.

A single visit should be counted regardless of the number of procedures and/or treatments utilized during 
the visit. Do not include visits to an urgent care center, walk-in clinic or ER visits paid at a triage rate.
Per Visit
*/
UPDATE	E
SET		ServiceTypeCode = 200
,		ER = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service = '87'
			AND	(	E.Provider_Specialty_Code = '901'
					OR E.Revenue_Code IN('0450','0451','0452','0459'	)	)
		)
OR		(	E.Hospital_Indicator = 1
			AND (	E.Provider_Specialty_Code = '901'
					OR E.Procedure_Code BETWEEN '99281' AND '99285'
					OR E.Revenue_Code IN('0450','0451','0452','0459'	)	)
		)

/* -------------------------------------------------------------------------------------------------------
210: FAMILY PLANNING

Services provided to plan the spacing of children by medically acceptable means to prevent or terminate 
unwanted pregnancy.
Per Visit
*/
UPDATE	E
SET		ServiceTypeCode = 210
,		FAMILY_PLANNING = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Provider_Specialty_Code IN('906','907')
OR		Procedure_Code IN('A4260', 'A4261', 'J7300', 'J7302', 'J7303', 'J7306', 'J7307', '11975'
			, '11976', '11977', '55250', '55450', '57170', '57700', '57720', '58300', '58301', '58345'
			, '58600', '58605', '58611', '58615', '58700', '58740', '58752', '58770', '58983', '59105'
			, '59320', '59325', '59827', '59840', '59841', '59842', '59850', '59851', '59852', '59853'
			, '59855', '59856', '59857', '74740', '74742', '76841', '76857')
OR		Primary_Dx_Code IN('O045', 'O0487', 'O046', 'O0484', 'O0482', 'O0483', 'O0481', 'O047', 'O0485'
			, 'O0486', 'O0488', 'O0489', 'O0485', 'O0486', 'O0480', 'Z332', 'O045', 'O046', 'O0484', 'O0482'
			, 'O0483', 'O0481', 'O047', 'O0489', 'O0480', 'Z332', 'O070', 'O0737', 'O071', 'O0734', 'O0732'
			, 'O0733', 'O0731', 'O072', 'O0735', 'O0736', 'O0738', 'O0739', 'O0730', 'O074', 'A34', 'O080'
			, 'O0882', 'O081', 'O086', 'O084', 'O085', 'O083', 'O082', 'O087', 'O0881', 'O0883', 'O0889', 'O089'
			, 'Z30011', 'Z30018', 'Z3009', 'Z3040', 'Z3041', 'Z30431', 'Z3049', 'Z975', 'Z640', 'Z30430', 'Z30432'
			, 'Z30433', 'Z302', 'Z3049', 'Z308', 'Z309', 'Z3143', 'Z31438', 'Z315', 'Z3144', 'Z31441', 'Z31448'
			, 'Z3161', 'Z3162', 'Z3169', 'Z3183', 'Z3184', 'Z3189', 'Z319')
			
/* -------------------------------------------------------------------------------------------------------
220: PRENATAL/POSTPARTUM CARE

NO GOLD STANDARD CRITERIA

*/

/* -------------------------------------------------------------------------------------------------------
230: AMBULATORY SURGERY

Surgical services provided in hospital outpatient departments, and diagnostic and treatment centers 
(free standing clinics).
Per Visit

IF AMB_Surgery_Center = 1 OR Provider_Specialty_Code in ('993','997') then do; 
if Amb_Surgery_Procedure = 1 OR ('0490' <= Revenue_Code <= '0499')
then AMBULATORY_SURGERY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 230
,		AMBULATORY_SURGERY = 1
FROM	dbo.tblEncounters AS E
WHERE	E.AMB_Surgery_Center = 1			-- Rendundant for now
OR		E.Provider_Specialty_Code IN('993','997') 
OR		E.Revenue_Code BETWEEN '0490' AND '0499'


/* -------------------------------------------------------------------------------------------------------
240: HOME HEALTH CARE: LEVEL 3 HOME HEALTH CARE AIDE

Level 3 (Home Health Aide): Level 1 and 2 plus health-related tasks (vital signs, transferring with hoyer 
lift, stable dressings, ostomy care, prepare meals for complex diets, maintenance exercise programs.
Per Hour

IF (Category_of_Service in ('01',’15’) AND Provider_Specialty_Code = '668') 
	AND ((Procedure_Code in ('S5125',’S5126’, ‘S9122’) 
	OR (Procedure_Code in ('S5125’, ‘S5126’) AND Procedure_Code_Modifier in (‘U2’)) 
	OR (Procedure_Code in ('S9122’) and Procedure_Code_Modifier in (‘U1’))) then HH_Aide = 1;
IF Provider_Specialty_Code = '668' AND ('0570' <= Revenue_Code <= '0579') then HH_Aide = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 240
,		HH_Aide = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service IN('01','15')
			AND E.Provider_Specialty_Code = '668'
			AND (	E.Procedure_Code IN('S5125','S5126', 'S9122') 
					OR	(	E.Procedure_Code IN('S5125', 'S5126') 
							AND (E.Modifier_1 = 'U2' OR E.Modifier_2 = 'U2' OR E.Modifier_3 = 'U2' OR E.Modifier_4 = 'U2')	)
					OR (	E.Procedure_Code IN('S9122') 
							AND (E.Modifier_1 = 'U1' OR E.Modifier_2 = 'U1' OR E.Modifier_3 = 'U1' OR E.Modifier_4 = 'U1')	)
				)
		)
OR		(	E.Provider_Specialty_Code = '668' AND E.Revenue_Code BETWEEN '0570' AND '0579'	)

/* Note:
U1: This rate code modifier would be used for the provision of Advanced Home Health Aide services on an hourly basis.
U2: This rate code modifier will be used for the provision of personal care Level I or Level II services to one of 
two clients in the same household where both clients are receiving personal care services from the same aide.
*/

/* -------------------------------------------------------------------------------------------------------
250: HOME HEALTH CARE: MEDICAL SOCIAL SERVICES

Level 3 (Home Health Aide): Level 1 and 2 plus health-related tasks (vital signs, transferring with hoyer 
lift, stable dressings, ostomy care, prepare meals for complex diets, maintenance exercise programs.
Per Hour

IF (Category_of_Service IN ('01','15') AND Procedure_Code in ('S9127')) 
OR (Provider_Specialty_Code = '781' AND Procedure_Code in ('S9127')) 
OR (Provider_Specialty_Code = '781' AND ('0560' <= Revenue_Code <= '0569')) then HH_MED_SOCIAL_SRVS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 250
,		HH_MED_SOCIAL_SRVS = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service IN('01','15') AND E.Procedure_Code = 'S9127')
OR		(	E.Provider_Specialty_Code = '781' AND E.Procedure_Code = 'S9127')
OR		(	E.Provider_Specialty_Code = '781' AND E.Revenue_Code BETWEEN '0560' AND '0569'	)

/* -------------------------------------------------------------------------------------------------------
260: HOME HEALTH CARE: NURSING

Intermittent, part-time and continuous nursing services provided by RNs and LPNs in accordance with the 
Nurse Practice Act in the home.
Per Visit
IF Category_of_Service in ('01', '15') OR Provider_Specialty_Code = '680' then do; 
	if (('99500'<= Procedure_Code<= '99507') 
	OR Procedure_Codein ('99511', '99512', '99600', 'T1000', 'T1002','T1003', 'T1030', 'T1031', 'T2024', 'S9123', 'S9124')
	then HH_NURSING = 1;
IF Provider_Specialty_Code = '680' AND ('0550' <= Revenue_Code <= '0559') then HH_NURSING = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 260
,		HH_NURSING = 1
FROM	dbo.tblEncounters AS E
WHERE	(	(	E.Category_of_Service In('01', '15') OR E.Provider_Specialty_Code = '680')
			AND		(	E.Procedure_Code BETWEEN '99500' AND '99507') 
						OR E.Procedure_Code IN('99511', '99512', '99600', 'T1000', 'T1002','T1003', 'T1030'
											, 'T1031', 'T2024', 'S9123', 'S9124')
		)
OR		(	Provider_Specialty_Code = '680' AND E.Revenue_Code BETWEEN '0550' AND '0559'	)



/* -------------------------------------------------------------------------------------------------------
270: HOME HEALTH CARE: OCCUPATIONAL THERAPY

Rehabilitation services by a licensed and registered occupational therapist for maximum reduction of 
physical disability and restoration or maintenance of member to their best functional level rendered 
in the home.
Per Visit
IF Category_of_Service IN ('01', '15') 
AND Provider_Specialty_Code = '301' 
AND Procedure_Code in ('S9129') then HH_OT = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 270
,		HH_OT = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01', '15') 
AND		E.Provider_Specialty_Code = '301' 
AND		E.Procedure_Code = 'S9129'

/* -------------------------------------------------------------------------------------------------------
280: HOME HEALTH CARE: PHYSICAL THERAPY

Rehabilitation services provided in the home by a licensed and registered physical therapist for maximum 
reduction of physical disability and restoration or maintenance of member to their best functional level.
Per Visit
IF (Category_of_Service in ('01', '15') 
AND Provider_Specialty_Code = '300') 
AND Procedure_Code in ('S9131') then HH_PT = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 280
,		HH_PT = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01', '15') 
AND		E.Provider_Specialty_Code = '300' 
AND		E.Procedure_Code = 'S9131'

/* -------------------------------------------------------------------------------------------------------
290: HOME HEALTH CARE: RESPIRATORY THERAPY

Performance of preventive, maintenance and restorative airway related techniques and procedures provided 
by a qualified respiratory therapist in the home.
Per Visit
IF (Category_of_Service IN ('01', '15') 
OR Provider_Specialty_Code = '674') then do; 
if Procedure_Code in ('G0237','G0238') then HH_RESP_THRPY = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 290
,		HH_RESP_THRPY = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01', '15')  
AND		E.Provider_Specialty_Code = '674' 
AND		E.Procedure_Code IN('G0237','G0238')

/* -------------------------------------------------------------------------------------------------------
300: HOME HEALTH CARE: SPEECH THERAPY

Rehabilitation services provided by a licensed and registered speech-language pathologist for maximum 
reduction of physical disability and restoration or maintenance of member to their best functional level 
rendered in the home.
Per Visit
IF (Category_of_Service in ('01', '15') 
AND Provider_Specialty_Code = '302' 
AND Procedure_Code = 'S9128' then HH_SPEECH = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 300
,		HH_SPEECH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01', '15')  
AND		E.Provider_Specialty_Code = '302' 
AND		E.Procedure_Code = 'S9128'

/* -------------------------------------------------------------------------------------------------------
310: HOME HEALTH CARE: SOCIAL AND ENVIRONMENTAL SUPPORTS

Services and items that support the medical need of the member, such as home maintenance tasks and housing 
improvements
Per Service

IF Category_of_Service IN('01', '15') OR Provider_Specialty_Code = '661' then do;
if (Procedure_Code IN('T1028','S5165') AND ('0580' <= Revenue_Code <= '0589')) then SOCIAL_EVIRON_SPPTS = 1; end;

*/
UPDATE	E
SET		ServiceTypeCode = 310
,		HH_SOCIAL_EVIRON_SPPTS = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01', '15')  
AND		E.Provider_Specialty_Code = '661' 
AND		E.Procedure_Code IN('T1028','S5165') 
AND		E.Revenue_Code BETWEEN '0580' AND '0589'

/* -------------------------------------------------------------------------------------------------------
320 HOME HEALTH CARE: NUTRITIONAL COUNSELING

Assessment of nutritional needs and food patterns, planning for the provision of food and drink, providing 
nutritional education and counseling to patient and family by qualified nutritionist/dietician.
Per Visit

IF Category_of_Service IN('01', '15') AND Provider_Specialty_Code IN('909') AND Procedure_Code IN('S9470') then NUTRITION = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 320
,		NUTRITION = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01', '15')  
AND		E.Provider_Specialty_Code = '909' 
AND		E.Procedure_Code = 'S9470'

/* -------------------------------------------------------------------------------------------------------
330: HOME HEALTH CARE: SIGN LANGUAGE/ORAL INTERPRETER

Sign language or oral interpretive services, per 15 minutes

IF Category_of_Service IN('01', '15') AND Procedure_Code IN('T1013') then HH_SGN_LNG_ORAL_INTRPTER = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 330
,		NUTRITION = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01', '15') 
AND		E.Procedure_Code = 'T1013'

/* -------------------------------------------------------------------------------------------------------
340: DENTAL SERVICES ????

Includes but shall not be limited to preventive, prophylactic and other dental care, services and supplies, 
routine exams, prophylaxis, oral surgery, and dental prosthetics and orthotic appliances required to alleviate 
a serious health condition including one which affects employability. Do not include dental services provided 
in an inpatient or ambulatory surgery setting in this category.

Multi-Level Logic (Gold Standard)
IF Category_of_Service in ('13','85') 
OR Provider_Specialty_Code in ('248', '350','351','815','910','911','912') 
OR ('800' <= Provider_Specialty_Code <= '810') then do;
if Revenue_Code='0512' OR ('D0100' <= Procedure_Code <= 'D9999') then DENTAL = 1; 

Line Level Logic
IF Revenue_Code='0512' OR ('D0100' <= Procedure_Code <= 'D9999') then DENTAL = 1; 

Header Level Logic
IF Provider_Specialty_Code in ('248', '350', '351', '800', '801', '802', '803', '804', '805', '806',
'807', '808', '809', '810', '815', '910', '911', '912') then DENTAL = 1;
*/

--UPDATE	E
--SET		ServiceTypeCode = 340
--,		MMCORCostReportCategoryCode = 0
--,		DENTAL = 1
--,		MMCORMappingLogicLEVEL = 1	-- 1 = GOLD level
--FROM	dbo.tblEncounters AS E
--WHERE	E.Category_of_Service IN('01', '15') 
--AND		E.Procedure_Code = 'T1013'

/* -------------------------------------------------------------------------------------------------------
350: PRIMARY CARE

Services provided by primary care providers (as defined by the provider specialty codes listed below) in 
outpatient setting. 
Per Visit

IF Provider_Specialty_Code IN('050', '055', '056', '058', '060', '089', '092', '150', '182', '184', '254'
, '306', '324', '601', '602', '620', '776', '779', '782', '904', '905', '908', '909', '914', '936', '990', '991') 
OR Revenue_Code IN('0514', '0515', '0517', '0523', '0770', '0771', '0779') AND NOT (Prenatal_Postpartum DX1 – DX9) 
then PRIMARY_CARE = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 350
,		PRIMARY_CARE = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Provider_Specialty_Code IN('050', '055', '056', '058', '060', '089', '092', '150', '182', '184', '254'
, '306', '324', '601', '602', '620', '776', '779', '782', '904', '905', '908', '909', '914', '936', '990', '991') 
OR		(	E.Revenue_Code IN('0514', '0515', '0517', '0523', '0770', '0771', '0779')
			AND E.PRENATAL_POSTPARTUM <> 1	)

/* -------------------------------------------------------------------------------------------------------
370: DIAGNOSTIC TESTING, LABORATORY, X-RAY SERVICES

Medically necessary tests and procedures ordered by a qualified medical professional. This category includes 
outpatient laboratory, diagnostic radiology, diagnostic ultrasound, nuclear medicine, radiation oncology, and 
magnetic resonance imaging (MRI) services.
Per Test

IF Category_of_Service = '16' OR Provider_Specialty_Code IN('074', '080', '081', '127', '128', '130', '131', '135', '136'
, '138', '139', '140', '142', '146', '148', '189', ,'201', '202', '205', '206', '207', '208', '244', '246', '411', '412'
, '413', '414', '415', '416', '419', '420', '421', '422', '423', '427', '430', '431', '432', '435', '436', '438','439'
, '440', '441', '442', '450', '451', '460', '463', '470', '481', '482', '483', '484', '485', '486', '491', '510', '511'
, '512', '513', '514', '515', '516', '518', '521', '523', '524', '531', '540', '550', '551', '552', '553', '560', '571'
, '572', '573', '599', '994', '998') then do;
IF ('0300' <= Revenue_Code <= '0329') OR Revenue_Code = '0341' 
OR ('0350' <= Revenue_Code <= '0359') 
OR ('0400' <= Revenue_Code <= '0409') OR ('0610' <= Revenue_Code <= '0619') 
OR ('0730' <= Revenue_Code <= '0749') OR ('0920' <= Revenue_Code <= '0929') 
OR (Procedure_Code IN('36400', '36410', '36415', '59000', '59012', '59015', '74741') 
OR ('70000' <= Procedure_Code <= '74739') OR ('74743' <= Procedure_Code <= '76840') 
OR ('76842' <= Procedure_Code <= '76856') OR ('76858' <= Procedure_Code <= '79999') 
OR ('80002' <= Procedure_Code <= '89309') OR ('89311' <= Procedure_Code <= '89399') 
OR ('P0000' <= Procedure_Code <= 'P9999') OR ('R0000' <= Procedure_Code <= 'R5999'))
then DX_LAB_XRAY = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 370
,		DX_LAB_XRAY = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service = '16'
			OR E.Provider_Specialty_Code IN('074', '080', '081', '127', '128', '130', '131', '135', '136'
				, '138', '139', '140', '142', '146', '148', '189', '201', '202', '205', '206', '207', '208', '244', '246', '411', '412'
				, '413', '414', '415', '416', '419', '420', '421', '422', '423', '427', '430', '431', '432', '435', '436', '438', '439'
				, '440', '441', '442', '450', '451', '460', '463', '470', '481', '482', '483', '484', '485', '486', '491', '510', '511'
				, '512', '513', '514', '515', '516', '518', '521', '523', '524', '531', '540', '550', '551', '552', '553', '560', '571'
				, '572', '573', '599', '994', '998')	)
AND		(	E.Revenue_Code BETWEEN '0300'AND '0329'
			OR E.Revenue_Code = '0341' 
			OR E.Revenue_Code BETWEEN '0350' AND '0359'
			OR E.Revenue_Code BETWEEN '0400' AND '0409'
			OR E.Revenue_Code BETWEEN '0610' AND '0619'
			OR E.Revenue_Code BETWEEN '0730' AND '0749'
			OR E.Revenue_Code BETWEEN '0920' AND '0929'
			OR E.Procedure_Code IN('36400', '36410', '36415', '59000', '59012', '59015', '74741') 
			OR E.Procedure_Code BETWEEN '70000' AND '74739'
			OR E.Procedure_Code BETWEEN '74743' AND '76840'
			OR E.Procedure_Code BETWEEN '76842' AND '76856'
			OR E.Procedure_Code BETWEEN '76858' AND '79999'
			OR E.Procedure_Code BETWEEN '80002' AND '89309'
			OR E.Procedure_Code BETWEEN '89311' AND '89399'
			OR E.Procedure_Code BETWEEN 'P0000' AND 'P9999'
			OR E.Procedure_Code BETWEEN 'R0000' AND 'R5999'	)

/* -------------------------------------------------------------------------------------------------------
380: PERSONAL EMERGENCY RESPONSE SYSTEM (PERS)

An electronic device that enables certain high-risk patients to secure help in the event of a physical, 
emotional or environmental emergency.
Per Unit
IF ((Category_of_Service = '22' AND Provider_Specialty_Code = '307') 
AND Procedure_Code IN('S5160','S5161')) then PERS = 1;
IF ((Category_of_Service = '15' AND Provider_Specialty_Code IN('665','798')) 
AND Procedure_Code IN('S5160','S5161')) then PERS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 380
,		PERS = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service = '22'
			AND E.Provider_Specialty_Code = '307'
			AND E.Procedure_Code IN('S5160','S5161')	)
OR		(	E.Category_of_Service = '15'
			AND E.Provider_Specialty_Code IN('665','798')
			AND E.Procedure_Code IN('S5160','S5161')			)

/* -------------------------------------------------------------------------------------------------------
390: DME, MEDICAL/SURGICAL SUPPLIES, PROSTHESES AND ORTHOTICS

DME: Durable medical equipment (DME) are devices and equipment, other than prosthetic or orthotic appliances, 
which have been ordered by a practitioner in the treatment of a specific medical condition. DME includes 
hearing aids, ear molds, batteries, special fittings and replacement parts.

MEDICAL/SURGICAL SUPPLIES: Medical/surgical supplies are items for medical use other than drugs, durable 
medical equipment, prosthetics and orthotic appliances, or orthopedic footwear, which treat a specific 
medical condition and are usually consumable, non-reusable, disposable, for a specific purpose and generally 
have no salvageable value. These would include enteral and parenteral formulas.

PROSTHESES: Prosthetic appliances and devices replace any missing part of the body.

ORTHOTICS: Orthotic appliances and devices are used to support a weak or deformed body member or to restrict 
or eliminate motion in a diseased or injured part of the body. Orthopedic footwear are shoes, shoe modifications 
or shoe additions which are used to correct, accommodate or prevent a physical deformity or range of motion 
malfunction in a diseased or injured part of the ankle or foot; to support a weak or deformed structure of the 
ankle or foot or to form an integral part of a brace.
Per Unit

IF Category_of_Service = '22' OR Provider_Specialty_Code IN('307','969') then do;
IF (Procedure_Code IN('V5009', 'K0452') OR
('A4000' <= Procedure_Code <= 'A9999') OR
('B4034' <= Procedure_Code <= 'B5200') OR
('L0000' <= Procedure_Code <= 'L9900') OR
('E0100' <= Procedure_Code <= 'E9999') OR
('V5000' <= Procedure_Code <= 'V5007') OR
('V5012' <= Procedure_Code <= 'V5019') OR
('V5021' <= Procedure_Code <= 'V5336') OR
('K0001' <= Procedure_Code <= 'K0108') OR
('K0800' <= Procedure_Code <= 'K0898') OR
('0290' <= Revenue_Code<='0299')) then DME = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 390
,		DME = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service = '22' 
			OR E.Provider_Specialty_Code IN('307','969')	)
AND		(	E.Procedure_Code IN('V5009', 'K0452') 
			OR E.Procedure_Code BETWEEN 'A4000' AND 'A9999'
			OR E.Procedure_Code BETWEEN 'B4034' AND 'B5200'
			OR E.Procedure_Code BETWEEN 'L0000' AND 'L9900'
			OR E.Procedure_Code BETWEEN 'E0100' AND 'E9999'
			OR E.Procedure_Code BETWEEN 'V5000' AND 'V5007'
			OR E.Procedure_Code BETWEEN 'V5012' AND 'V5019'
			OR E.Procedure_Code BETWEEN 'V5021' AND 'V5336'
			OR E.Procedure_Code BETWEEN 'K0001' AND 'K0108'
			OR E.Procedure_Code BETWEEN 'K0800' AND 'K0898'
			OR E.Revenue_Code BETWEEN '0290' AND '0299'		)

/* -------------------------------------------------------------------------------------------------------
400: AUDIOLOGY AND HEARING AID SERVICES

Audiology services include audiometric examination or testing, hearing aid evaluation, conformity evaluation 
and hearing aid prescription or recommendations if indicated. Hearing aid services include selecting, fitting 
and dispensing of hearing aids, hearing aid checks following dispensing and hearing aid repairs.

Per Unit

IF Category_of_Service = '01' OR Provider_Specialty_Code = '640' then do;
if Procedure_Code IN('V5008', 'V5010', 'V5011', 'V5020') OR ('0470' <= Revenue_Code <= '0479') then AUDIOLOGY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 400
,		AUDIOLOGY = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service = '01' 
			OR E.Provider_Specialty_Code = '640'	)
AND		(	E.Procedure_Code IN('V5008', 'V5010', 'V5011', 'V5020') 
			OR E.Revenue_Code BETWEEN '0470' AND '0479'				) 

/* -------------------------------------------------------------------------------------------------------
410: EMERGENCY TRANSPORTATION

Transportation as a result of an emergency condition. This category includes ambulance transportation, 
including air ambulance service for the purpose of obtaining emergency medical services. 
Per 1 Way

IF Category_Of_Service = '19' OR Provider_Specialty_Code = '670' then do; 
if Procedure_Code IN('A0021', 'A0225') 
OR ('A0420' <= Procedure_Code <= 'A0427') 
OR ('A0429' <= Procedure_Code <= 'A0999') 
OR ('0540' <= Revenue_Code <= '0549') then ER_TRANS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 410
,		ER_TRANS = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service = '19' 
			OR E.Provider_Specialty_Code = '670'	)
AND		(	E.Procedure_Code IN('A0021', 'A0225') 
			OR E.Procedure_Code BETWEEN 'A0420' AND 'A0427'	
			OR E.Procedure_Code BETWEEN 'A0429' AND 'A0999'	
			OR E.Revenue_Code BETWEEN '0540' AND '0549'				) 

/* -------------------------------------------------------------------------------------------------------
420: NON-EMERGENCY TRANSPORTATION

Transportation provided at the appropriate level for an enrollee to receive medically necessary services. 
This category includes transportation that is essential for an enrollee to obtain medically necessary care 
such as taxicab
Per 1 Way

IF Category_of_Service = ‘19’ 
	OR Provider_Specialty_Code in (‘671’, ‘740’) then do;
	if Procedure_Code 
		in (‘T2001’ <= Procedure_Code <= ‘T2005’) 
		OR (‘A0080’ <= Procedure_Code <= ‘A0214’) 
		OR Procedure_Code in (‘A0428’) then NON_ER_TRANS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 420
,		NON_ER_TRANS = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service = '19' 
			OR E.Provider_Specialty_Code IN('671','740')	)	
AND		(	E.Procedure_Code BETWEEN 'T2001' AND 'T2005'	
			OR E.Procedure_Code BETWEEN 'A0080' AND 'A0214'	
			OR E.Procedure_Code = 'A0428'	)

/* -------------------------------------------------------------------------------------------------------
430: ?????? OUTPATIENT PHARMACY (Including Mental Health and SUD Pharmacy)
SUD = Substance Use Disorders
Report all individual claims for each prescription, whether an original script or refill. These include 
medically necessary prescription drugs only. Do not include over-the-counter drugs.
For Managed Long Term Care health plans, Pharmacy data covered through Medicare. In addition to Part D 
covered pharmacy scripts, PACE plans should report non-Part D scripts.
The MMCOR requires that pharmacy be reported in three categories, with associated with associated class codes, 
as follows: Non-BH Pharmacy; MH Pharmacy and SUD Pharmacy.
Per the American Hospital Formulary System, Substance abuse medications would be primarily in classes 
28:08.08, 28:08.12 and 28:10. 
For Mental Health they would be primarily 28:12 and 28:16 (including all the subcategories below those) 
but may also include any of the classes between 28:00.00 and 28:92.99. 
Per Script

Multi-Level Logic (Gold Standard)
(IF Category_of_Service = '14' OR Provider_Specialty_Code = '760') 
AND (('0250' <= Revenue_Code <= '0259') OR ('0630' <= Revenue_Code <= '0639')) then RX = 1;

Line Level Logic
IF ('0250' <= Revenue_Code <= '0259') OR ('0630' <= Revenue_Code <= '0639') then RX = 1; 

Header Level Logic
IF Provider_Specialty_Code = '760' Then RX = 1;
*/

--UPDATE	E
--SET		ServiceTypeCode = 430
--,		MMCORCostReportCategoryCode = 0
--,		RX = 1
--,		MMCORMappingLogicLEVEL = 1	-- 1 = GOLD level
--FROM	dbo.tblEncounters AS E

/* -------------------------------------------------------------------------------------------------------
440: Home delivered meals are meals delivered to a member's home. Congregate meals are meals in a group 
setting such as a senior center. 
Per Meal
(IF Category_of_Service = '15' OR Provider_Specialty_Code = '667')
 AND Procedure_Code IN('S5170', 'S9977') then MEALS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 440
,		MEALS = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service = '15' 
			OR E.Provider_Specialty_Code = '667'	)	
AND		E.Procedure_Code IN('S5170', 'S9977')

/* -------------------------------------------------------------------------------------------------------
450: OUTPATIENT REHABILITATION THERAPIES: PHYSICAL THERAPY, OCCUPATIONAL THERAPY, SPEECH THERAPY
Rehabilitation services in an outpatient setting provided by licensed and registered therapists for maximum 
reduction of physical disability and restoration or maintenance of the member to their best functional level. 
Report each time an enrollee receives therapy services regardless of the number of procedures or clinicians seen. 
This includes physical, occupational and speech therapies, but excludes mental health, drug and alcohol therapy.
Per Visit
(IF Category_of_Service IN('01', '06') 
OR Provider_Specialty_Code IN('160', '162', '183', '300', '301', '302', '674', '920', '921', '923', '924', '967', '968')) then do;
if (('97001' <= Procedure_Code <= '97799') 
OR ('V5362' <= Procedure_Code <= 'V5364') 
OR ('0420' <= Revenue_Code <= '0449') 
OR ('0930' >= Revenue_Code <= '0939') 
OR ('0950' <= Revenue_Code <= '0959') 
OR ('0940' <= Revenue_Code <= '0943') 
OR ('0946' <= Revenue_Code <= '0949') then REHAB = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 450
,		REHAB = 1
FROM	dbo.tblEncounters AS E
WHERE	(	E.Category_of_Service IN('15','06')
			OR E.Provider_Specialty_Code IN('160', '162', '183', '300', '301', '302', '674', '920', '921', '923', '924', '967', '968')	)	
AND		(	E.Procedure_Code BETWEEN '97001' AND '97799'
			OR E.Procedure_Code BETWEEN 'V5362' AND 'V5364'
			OR E.Revenue_Code BETWEEN '0420' AND '0449'
			OR E.Revenue_Code BETWEEN '0930' AND '0939'
			OR E.Revenue_Code BETWEEN '0950' AND '0959'
			OR E.Revenue_Code BETWEEN '0940' AND '0943'
			OR E.Revenue_Code BETWEEN '0946' AND '0949'		)

/* -------------------------------------------------------------------------------------------------------
460: PODIATRY
Description
Podiatry means services by a podiatrist which must include routine foot care when the member's physical 
condition poses a hazard due to the presence of localized illness, injury or symptoms involving the foot, 
or when they are performed as a necessary and integral part of medical care such as diagnosis and treatment 
of corns, calluses, the trimming of nails. Other hygienic care is not covered in the absence of a pathological 
condition. 
Per Visit

IF Category_of_Service IN('01', '03') 
AND Provider_Specialty_Code IN('778', '918') then PODIATRY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 460
,		PODIATRY = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01','03')
OR		E.Provider_Specialty_Code IN('778', '918')

/* -------------------------------------------------------------------------------------------------------
470: ???? VISION CARE

Optometry includes the services of an optometrist and an ophthalmic dispenser, and includes eyeglasses,
medical necessary contact lenses and polycarbonate lenses, artificial eyes (stock or custom made) low 
vision aids. The optometrist may perform an eye exam to detect visual defects and eye disease as necessary 
and as required by the member's condition. Examinations that include refraction are limited to every two 
years unless otherwise justified as medically necessary. Ophthalmic dispenser fills the prescription of an 
optometrist or ophthalmologist and supplies eyeglasses or other vision aids upon the order of qualified practitioner.
Do not include ophthalmologist services, which should be reported under Physician Specialist.

Per Visit

Multi-Level Logic (Gold Standard)
IF ((Category_of_Service = '05' OR Provider_Specialty_Code in ('714', '715', '716', '851', '919')) 
AND ('V2000' <= Procedure_Code <= 'V2999') then VISON = 1; 

Line Level Logic
IF ('V2000' <= Procedure_Code <= 'V2999') then VISION = 1; 

Header Level Logic
IF Provider_Specialty_Code in ('714', '715', '716', '851', '919') then VISION = 1;
*/
--UPDATE	E
--SET		ServiceTypeCode = 470
--,		MMCORCostReportCategoryCode = 0
--,		VISION = 1
--,		MMCORMappingLogicLEVEL = 1	-- 1 = GOLD level
--FROM	dbo.tblEncounters AS E
--WHERE	(	E.Category_of_Service = '05'
--			OR E.Provider_Specialty_Code IN('714', '715', '716', '851', '919')	)
--AND		E.Procedure_Code BETWEEN 'V2000'AND 'V2999'

/* -------------------------------------------------------------------------------------------------------
480: PARAPROFESSIONAL SERVICES: Level 1 – HOMEMAKER / HOUSEKEEPER

Level 1: Performance of nutritional and environmental support function (housekeeping, preparing simple meals). 
Includes assessments of care and supervision.
Per Unit

IF Category_of_Service IN('01','15') 
AND Provider_Specialty_Code = '672' 
AND Procedure_Code = 'S5130' 
AND Procedure_Code_Modifier IN('U1','U2','U3','TV') then PERSONAL_CARE_LVL1 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 480
,		PERSONAL_CARE_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01','15')
AND		E.Provider_Specialty_Code = '672'
AND		E.Procedure_Code = 'S5130'
AND		(E.Modifier_1 IN('U1','U2','U3','TV')
			OR E.Modifier_2 IN('U1','U2','U3','TV')	)

/* -------------------------------------------------------------------------------------------------------
490: PARAPROFESSIONAL SERVICES: LEVEL 2 – PERSONAL CARE

Level 2: Level 1 plus personal care functions (bathing, grooming, dressing, toileting, walking, 
transferring, and feeding)
Paraprofessional Services – Level 1 supersedes Level 2 based on Procedure Code only. 
Per Hour

IF Category_of_Service IN('01','15') 
AND Provider_Specialty_Code = '673' 
AND (	(Procedure_Code = 'T1019' 
			AND Procedure_Code_Modifier IN('U1','U2','U3', 'U4', 'U5', 'TV')) 
		OR (Procedure_Code = 'T1020' 
			AND 'Procedure_Code_Modifier IN('U2', 'U5', 'TV'))
	) then PERSONAL_CARE_LVL2 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 480
,		PERSONAL_CARE_LVL2 = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01','15')
AND		E.Provider_Specialty_Code = '673'
AND		(	(	E.Procedure_Code = 'T1019'
				AND		(	E.Modifier_1 IN('U1','U2','U3','U4','U5','TV')
							OR E.Modifier_2 IN('U1','U2','U3','U4','U5','TV')	)
			OR
			(	E.Procedure_Code = 'T1020'
				AND		(	E.Modifier_1 IN('U2','U5','TV')
							OR E.Modifier_2 IN('U2','U5','TV')		)		)	)
		)

/* -------------------------------------------------------------------------------------------------------
500: ADULT DAY HEALTH CARE
Care and services provided in a residential health care facility or approved extension site under the 
medical direction of a physician to a person who is functionally impaired, not homebound and who requires 
certain preventative, diagnostic, therapeutic, rehabilitative or palliative items or services.
Per Visit
IF Category_of_Service IN('12','15') 
AND Provider_Specialty_Code = '664' 
AND Procedure_Code = 'S5102' 
AND Procedure_Code_Modifier IN('U1','U2','U3') then ADULT_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 500
,		ADULT_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('12','15')
AND		E.Provider_Specialty_Code = '664'
AND		E.Procedure_Code = 'S5102'
AND		(E.Modifier_1 IN('U1','U2','U3')
			OR E.Modifier_2 IN('U1','U2','U3')	)

/* -------------------------------------------------------------------------------------------------------
510: AIDS ADULT DAY HEALTH CARE
Care and services provided in a residential health care facility or approved Extension site under the medical 
direction of a physician to a person who is functionally impaired, not homebound and who requires certain 
preventative, diagnostic, therapeutic, rehabilitative or palliative items or services
Per Visit
IF Category_of_Service IN('12','15') 
AND Provider_Specialty_Code = '355' 
AND Procedure_Code in 'S5100', 'S5101', 'S5102', 'S5105' then AIDS_ADULT_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 510
,		AIDS_ADULT_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('12','15')
AND		E.Provider_Specialty_Code = '355'
AND		E.Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105')

/* -------------------------------------------------------------------------------------------------------
520: SOCIAL DAY CARE

Structured, comprehensive program which provides functionally impaired individuals with socialization, 
supervision and monitoring, personal care, and nutrition in a protective setting during any part of the day, 
but less than a 24-hour period.
Per Visit

IF Category_of_Service IN('12','15') 
AND Provider_Specialty_Code = '662' 
AND Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105') then SOCIAL_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 520
,		SOCIAL_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('12','15')
AND		E.Provider_Specialty_Code = '662'
AND		E.Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105')

/* -------------------------------------------------------------------------------------------------------
530: CHRONIC RENAL DIALYSIS

Services provided by a renal dialysis center.
Per Visit

IF Category_of_Service IN('07','85','87') 
AND Provider_Specialty_Code = '913' then REN_DIALYSIS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 530
,		REN_DIALYSIS = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('07','85','87')
AND		E.Provider_Specialty_Code = '913'

/* -------------------------------------------------------------------------------------------------------
540: OTHER MEDICAL

Medical services under plan arrangement, which are not appropriately assignable to the medical categories defined.
Per Visit

IF Provider_Specialty_Code IN('661', '999') 
AND Category_of_Service <> '15' then OTHER_MEDICAL = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 540
,		OTHER_MEDICAL = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Provider_Specialty_Code IN('661','999')
AND		E.Category_of_Service <> '15'

/* -------------------------------------------------------------------------------------------------------
550: OTHER PROFESSIONAL SERVICES

Services by non-physician providers engaged in the delivery of covered medical services that cannot be appropriately reported elsewhere.
Private Duty Nursing provided by an independent practitioner should be reported under Home Health Care.
Per Visit

IF Provider_Specialty_Code IN('400', '781') 
AND Category_of_Service <> '15' then OTHER_PROFESSIONAL = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 550
,		OTHER_PROFESSIONAL = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Provider_Specialty_Code IN('400','781')
AND		E.Category_of_Service <> '15'	

/* -------------------------------------------------------------------------------------------------------
570: CONSUMER DIRECTED PERSONAL ASSISTANT LEVEL I

Level I: Under the supervision of consumer, the Consumer Directed Personal Assistant performs all necessary 
personal care, home health and nursing tasks. 
Per Unit

IF Category_of_Service IN('01','15') 
AND Provider_Specialty_Code = '675' 
AND Procedure_Code = 'T1019' 
AND Procedure_Code_Modifier IN('U6', 'U7', 'U8', 'U9') then CDPAP_LVL1 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 570
,		CDPAP_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01','15')
AND		E.Provider_Specialty_Code = '675'
AND		E.Procedure_Code = 'T1019' 
AND		(	E.Modifier_1 IN('U6', 'U7', 'U8', 'U9')
			OR  E.Modifier_2 IN('U6', 'U7', 'U8', 'U9')	)

/* -------------------------------------------------------------------------------------------------------
580: CONSUMER DIRECTED PERSONAL ASSISTANT LEVEL 2

Level 2: Under the supervision of the consumer, the live-in Consumer Directed Personal Assistant performs 
all necessary personal care, home health and nursing tasks. 
Per Hour

IF Category_of_Service IN('01','15') 
AND Provider_Specialty_Code = '676' 
AND Procedure_Code = 'T1020' 
AND Procedure_Code_Modifier IN('U6', 'U7', 'U8', 'U9') then CDPAP_LVL2 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 580
,		CDPAP_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01','15')
AND		E.Provider_Specialty_Code = '676'
AND		E.Procedure_Code = 'T1020' 
AND		(	E.Modifier_1 IN('U6', 'U7', 'U8', 'U9')
			OR  E.Modifier_2 IN('U6', 'U7', 'U8', 'U9')	)

/* -------------------------------------------------------------------------------------------------------
590: OUTPATIENT SERVICES: HEALTH HOMES - ADULT

Report all Health Home costs and utilization under this category of service. Health
Homes designated to serve adults must bill at the adult rate.
Per Visit Administrative

IF Category_of_Service IN('15) 
AND Provider_Specialty_Code = '371' 
AND Revenue_Code = '0500' then do;
if Rate_Code IN('1853', '1860', '1862', '1873', '1874') 
OR Procedure_Code = 'G9001' 
Or (Procedure_Code = 'G9005' AND Procedure_Code_Modifier IN('U1', 'U2', 'U3', 'U4')) then HEALTH_HOMES = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 590
,		HEALTH_HOMES = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '15' 
AND		E.Provider_Specialty_Code = '371' 
AND		E.Revenue_Code = '0500'
AND		(	E.Rate_Code IN('1853', '1860', '1862', '1873', '1874')
			OR E.Procedure_Code = 'G9001' 
			OR (	E.Procedure_Code = 'G9005' 
					AND (	E.Modifier_1 IN('U1', 'U2', 'U3', 'U4')
							OR E.Modifier_2 IN('U1', 'U2', 'U3', 'U4')	)
			   )
		)

/* -------------------------------------------------------------------------------------------------------
600: OUTPATIENT SERVICES: HEALTH HOMES – CHILD

Report all health comes costs and utilization under this category of service. Only Health Homes designated 
to serve children may bill at children's rate. Health Homes that enroll children but are not designated for 
children must bill at the adult rate.
Per Visit
IF Category_of_Service IN('15') 
AND Provider_Specialty_Code IN('371') 
AND Revenue_Code IN('0500') then do;
if Rate Code IN('1863', '1864', '1865', '1866', '1868', '1869', '1870', '1871') 
OR (Procedure_Code IN('G9001') AND Procedure_Code_Modifier IN('U1')) 
OR Procedure_Code IN('G0506') 
OR (Procedure_Code IN('T2022') AND Procedure_Code_Modifier IN('U1', 'U2', 'U3')) then HEALTH_HOMES = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 600
,		HEALTH_HOMES = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '15' 
AND		E.Provider_Specialty_Code = '371'
AND		E.Revenue_Code = '0500'
AND		(	E.Rate_Code IN('1863', '1864', '1865', '1866', '1868', '1869', '1870', '1871')
			OR (	E.Procedure_Code = 'G9001' AND (E.Modifier_1 = 'U1' OR E.Modifier_2 = 'U1')	)
			OR E.Procedure_Code = 'G0506' 
			OR (	E.Procedure_Code = 'T2022' 
					AND (	E.Modifier_1 IN('U1', 'U2', 'U3')
							OR E.Modifier_2 IN('U1', 'U2', 'U3')	)
			   )
		)

/* -------------------------------------------------------------------------------------------------------
610: HARM REDUCTION SERVICES

Harm reduction services represent a fully integrated client-oriented approach to health and wellness, which 
includes, but is not limited to, overdose prevention and response and preventing transmission of HIV, 
Hepatitis B and C, and other illnesses in substance users.
1 unit per 15 minutes per recipient

IF Category_of_Service IN('15', '85', '87) 
AND Provider_Specialty_Code = '283' then do;
If Procedure_Code IN('96150', '96151', '96152', 'H0034', '96153', 'H2027') 
OR Rate_Code IN('3146', '3147') then OTHER_MEDICAL=1;
*/
UPDATE	E
SET		ServiceTypeCode = 610
,		OTHER_MEDICAL = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('15','85','87') 
AND		E.Provider_Specialty_Code = '283'
AND		(	E.Procedure_Code IN('96150', '96151', '96152', 'H0034', '96153', 'H2027')
			OR E.Rate_Code IN('3146', '3147')
		)

/* -------------------------------------------------------------------------------------------------------
620: DOULA SERVICES

A doula is a non-medical birth coach who assists a woman during the prenatal period, labor, delivery, 
and post childbirth.
The Medicaid doula pilot will be implemented through a phased-in approach in order to ensure access to this 
new benefit. Phase 1 of the pilot will launch in Erie County. Medicaid eligible pregnant women who reside 
in the selected zip codes (Erie) would be eligible to receive doula services.
Per Visit

IF (Category_of_Service IN('01', '41') 
AND Provider_Specialty_Code = '755' 
AND (	(Procedure_Code IN('99600', '99499') 
			OR (Procedure_Code = '99600' and Modifier = 'UA')	) 
		OR Primary_Dx_Code IN('Z32.2', 'Z32.3')
	) then OTHER_MEDICAL = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 620
,		OTHER_MEDICAL = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01','41') 
AND		E.Provider_Specialty_Code = '755'
AND		(	E.Procedure_Code IN('99600', '99499')
			OR (	E.Procedure_Code = '99600' AND ( E.Modifier_1 = 'UA' OR E.Modifier_2 = 'UA'	)	)
			OR E.Primary_Dx_Code IN('Z32.2', 'Z32.3')
		)

/* -------------------------------------------------------------------------------------------------------
630: OUTPATIENT SUD: OUTPATIENT SUD CLINIC

Report all outpatient costs and utilization under this category of service Unit of Measurement
Per Visit

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code IN('984','986') then do;
if Rate Code IN('1114', '1118', '1528', '1540', '1552', '1468') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 630
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code IN('984', '986')
AND		E.Rate_Code IN('1114', '1118', '1528', '1540', '1552', '1468')

/* -------------------------------------------------------------------------------------------------------
640: OUTPATIENT SUD: OUTPATIENT SUD REHABILITATION

Report all outpatient rehabilitation costs and utilization under this category of service
Per Visit
IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code = '987' then do;
if Rate_Code IN('1561', '1573', '1558', '1570') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 640
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code = '987'
AND		E.Rate_Code IN('1561', '1573', '1558', '1570')

/* -------------------------------------------------------------------------------------------------------
650: OUTPATIENT SUD: OUTPATIENT SUD OPIATE TREATMENT PROGRAM

Report all outpatient opiate treatment program costs and utilization under this category of service.
Per Visit

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code = ('751', '922', '321') then do;
if Rate_Code IN('1564', '1567', '1555', '1471') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 650
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code IN('751', '922', '321')
AND		E.Rate_Code IN('1564', '1567', '1555', '1471')

/* -------------------------------------------------------------------------------------------------------
660: OUTPATIENT SUD: OUTPATIENT SUD INTEGRATED OPIATE TREATMENT PROGRAM

Report all outpatient opiate treatment program costs and utilization under this category of service
Per Visit

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty IN(751') then do;
if Rate Code IN('1116', '1120', '1134', '1130') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 660
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code  = '751'
AND		E.Rate_Code IN('1116', '1120', '1134', '1130')

/* -------------------------------------------------------------------------------------------------------
670: OUTPATIENT SUD: OUTPATIENT SUD INTEGRATED CLINIC

Report all outpatient costs and utilization under this category of service.
Per Visit

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code = '984' then do;
IF Rate_Code IN('1132', '1147', '1486') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 670
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code  = '984'
AND		E.Rate_Code IN('1132', '1147', '1486')

/* -------------------------------------------------------------------------------------------------------
680: OUTPATIENT SUD: OUTPATIENT SUD DETOXIFICATION

Report all outpatient detoxification costs and utilization under this category of service 
Per Visit

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code IN('357', '989') then do;
if Rate_Code IN('4279', '4221') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 680
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code  IN('357','989')
AND		E.Rate_Code IN('4279', '4221')

/* -------------------------------------------------------------------------------------------------------
690: OUTPATIENT SUD: OFFICE-BASED OUTPATIENT SUD

Report all outpatient costs and utilization under this category of service.
Per Visit

IF Category_of_Service = '01' 
AND Provider_Specialty_Code IN('198', '282') then do;
if ('291' <= Primary_Dx_Code <= '29299')
OR ('303' <= Primary_Dx_Code <= '30699', excluding 305.1) 
OR Primary_Dx_Code IN(F10 – F16999, F18 – F19999) then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 690
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '01' 
AND		E.Provider_Specialty_Code  IN('198','282')
AND		E.Rate_Code IN('4279', '4221')
ANd		(	E.Primary_Dx_Code BETWEEN '291' AND '29299'
			OR (	E.Primary_Dx_Code BETWEEN '303' AND '30699' AND E.Primary_Dx_Code <> '305.1'	) 
			OR E.Primary_Dx_Code BETWEEN 'F10' AND 'F16999'
			OR E.Primary_Dx_Code BETWEEN 'F18' AND 'F19999'	
		)

/* -------------------------------------------------------------------------------------------------------
700: OUTPATIENT SUD: OTHER SUD OUTPATIENT SERVICES
Report all outpatient detoxification costs and utilization under this category of service.
Per Visit

IF Category_of_Service IN('01', '85', '87') 
AND Provider_Specialty_Code = '749' then do;
If Primary_Dx_Code IN(F10 – F16999, F18 – F19999) then OUTPATIENT_SUD = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 700
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01','85','87') 
AND		E.Provider_Specialty_Code = '749'
AND		E.Rate_Code IN('4279', '4221')
ANd		(	E.Primary_Dx_Code BETWEEN 'F10' AND 'F16999'
			OR E.Primary_Dx_Code BETWEEN 'F18' AND 'F19999'	
		)

/* -------------------------------------------------------------------------------------------------------
710: OUTPATIENT MENTAL HEALTH: OFFICE-BASED MENTAL HEALTH SERVICES

This category includes services provided by psychologists, psychiatrists and other mental health providers. 
Report each time a patient receives mental health services regardless of the number of procedures or 
clinicians seen.
Per Visit
IF Category_of_Service IN('01', '04') 
AND Provider_Specialty_Code IN('057', '187'. '191', '192', '195', '196', '197', '281', '283', '320', '328', 
'331', '780', '945', '946', '947', '948', '963', '964') 
AND Procedure_Code IN('H0002', 'H0004', 'H0031', 'H0032', 'H0036', 'H0037', 'H0046', 'H2012'
, 'H2013', 'H2017', 'H2018', 'H2019', 'H2020') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 710
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('01','04') 
AND		E.Provider_Specialty_Code IN('057', '187', '191', '192', '195', '196', '197', '281', '283', '320', '328', 
										'331', '780', '945', '946', '947', '948', '963', '964') 
AND		E.Procedure_Code IN('H0002', 'H0004', 'H0031', 'H0032', 'H0036', 'H0037', 'H0046', 'H2012', 'H2013', 'H2017', 'H2018', 'H2019', 'H2020')

/* -------------------------------------------------------------------------------------------------------
720: OUTPATIENT MENTAL HEALTH: OUTPATIENT MENTAL HEALTH CLINIC

Services provided in OMH-licensed free-standing and hospital-based clinics; voluntary, county (LGU), and state-operated. 
Per Visit (procedure-based)
IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code IN('310','311',315',316',971',974') 
AND Rate_Code IN('1106', '1110','1122','1474','1480','1504','1516','1576','1579','1588') 
OR Procedure_Code IN('J0401', 'J2358', 'J2426', 'J2794') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 720
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code IN('310','311','315','316','971','974') 
AND		(	E.Rate_Code IN('1106', '1110','1122','1474','1480','1504','1516','1576','1579','1588') 
			OR E.Procedure_Code IN('J0401', 'J2358', 'J2426', 'J2794')	)

/* -------------------------------------------------------------------------------------------------------
730: OUTPATIENT MENTAL HEALTH: OMH ASSERTIVE COMMUNITY TREATMENT

Assertive Community Treatment: A comprehensive and integrated combination of treatment, rehabilitation, 
case management, and support services primarily provided in the client's residence or other community 
locations by a mobile multi-disciplinary mental health treatment team (billed as either full payment, 
partial payment or inpatient payment, depending on the number of contacts and the setting in which they 
take place) Unit of Measurement
Monthly

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code = '816' 
AND Rate_Code IN('4508', '4509', '4511') Then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 730
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code = '816' 
AND		E.Rate_Code IN('4508', '4509', '4511')

/* -------------------------------------------------------------------------------------------------------
740: OUTPATIENT MENTAL HEALTH: OMH CONTINUING DAY TREATMENT

Continuing Day Treatment: provides active treatment and rehabilitation designed to maintain or enhance current 
levels of functioning and skills, to maintain community living and to develop self-awareness and self-esteem 
through the exploration and development of patient strengths and interests.
Half-day visit - Minimum duration of two hours. One or more medically necessary services must be provided and documented.
Full-day visit - Minimum duration of four hours. Three or more medically necessary services must be provided and documented.
Collateral visit - Clinical support services of at least 30 minutes duration of face-to-face interaction documented.
Group collateral visit - Clinical support services of at least 60 minutes duration of face-to-face interaction 
documented between collaterals and/or family members of multiple recipients with or without recipients.
Crisis visit - Crisis intervention services are face-to-face interactions documented by the provider between a 
recipient and a therapist, regardless of the actual duration of the visit.
Preadmission visit - Services of at least 60 minutes duration of face-to-face interaction documented. 
Per Day

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code IN('312', '317') 
AND Rate_Code IN('4310', '4311', '4312', '4316', '4317', '4318', '4325', '4331', '4337', '4346') Then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 740
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code IN('312', '317')  
AND		E.Rate_Code IN('4310', '4311', '4312', '4316', '4317', '4318', '4325', '4331', '4337', '4346')

/* -------------------------------------------------------------------------------------------------------
750: OUTPATIENT MENTAL HEALTH: OMH COMPREHENSIVE PSYCHIATRIC EMERGENCY PROGRAM

Comprehensive Psychiatric Emergency Program: A licensed, hospital-based psychiatric emergency program that 
establishes a primary entry point to the mental health system for individuals who may be mentally ill to 
receive emergency observation, evaluation, care and treatment in a safe and comfortable environment. 

Components of CPEP include:
Brief emergency visit - Face-to-face interaction between a patient and a staff physician, to determine the 
scope of emergency service required. Note: Services provided in a medical/surgical emergency or clinic 
setting for comorbid conditions are separately reimbursed.

Full emergency visit - A face-to-face interaction between a patient and clinical staff to determine a 
recipient's current psychosocial and medical condition.

Crisis outreach service – Emergency services provided outside an ER which includes clinical assessment 
and crisis intervention.

Interim crisis service - Mental health service provided outside an ER for persons who are released from 
the ER of the comprehensive psychiatric emergency program, which includes immediate face-to-face contact 
with a mental health professional for purposes of facilitating a recipient's community tenure while waiting 
for a first post-CPEP visit with a community based mental health provider.

Extended observation bed – For any person alleged to have a mental illness which is likely to result in 
serious harm to the person or others and for whom immediate observation, care and treatment in the CPEP is 
appropriate. Shall not exceed 72 hours (voluntarily, or involuntarily).
Per Day
IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code = '992' 
AND Rate_Code IN('4007', '4008', '4009', '4010', '4049') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 750
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code = '992'
AND		E.Rate_Code IN('4007', '4008', '4009', '4010', '4049')

/* -------------------------------------------------------------------------------------------------------
760: OUTPATIENT MENTAL HEALTH: OMH INTENSIVE PSYCHIATRIC REHABILITATION TREATMENT PROGRAM
Description
Intensive Psychiatric Rehabilitation Treatment Program: time limited, designed to assist persons in forming 
and achieving mutually agreed upon goals in living, learning, working and social environments, to intervene 
with psychiatric rehabilitation technologies to overcome functional disabilities, and to improve 
environmental supports.
Duration-based (hours)

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code IN('314', '319') 
AND Rate_Code IN('4364', '4365', '4366', '4367', '4368') then OUTPATIENT_MENTAL_HEALTH = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 760
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code IN('314', '319') 
AND		E.Rate_Code IN('4364', '4365', '4366', '4367', '4368')


/* -------------------------------------------------------------------------------------------------------
770: OUTPATIENT MENTAL HEALTH: OMH PARTIAL HOSPITALIZATION

Partial Hospitalization: active treatment designed to stabilize and ameliorate acute symptoms, to serve as 
an alternative to inpatient hospitalization, or to reduce the length of a hospital stay within a medically 
supervised program.
Collateral service - Clinical support services of between 30 minutes and two hours of face-to-face interaction.
Group collateral service - Clinical support services of between 60 minutes and two hours provided to more 
than one recipient and/or his or her collaterals.
Pre-admission - Visits of one to three hours are billed using the crisis visit rate codes (4357, 4358 or 4359). 
Visits of four hours or more are billed using partial hospitalization regular rate codes (4349, 4350, 4351 or 4352).
Duration-based (hours)

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code IN('313', '318') 
AND Rate_Code IN('4349' – '4363') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 770
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code IN('313', '318') 
AND		E.Rate_Code BETWEEN '4349' AND '4363'

/* -------------------------------------------------------------------------------------------------------
780: OUTPATIENT MENTAL HEALTH: OMH PERSONALIZED RECOVERY ORIENTED SERVICES

Personalized Recovery Oriented Services (PROS): a comprehensive recovery oriented program for individuals 
with severe and persistent mental illness. The goal of the program is to integrate treatment, support and 
rehabilitation in a manner that facilitates the individual's recovery. Goals for individuals in the program 
are to: improve functioning, reduce inpatient utilization, reduce emergency services, reduce contact with 
the criminal justice system, increase employment, attain higher levels of education and secure preferred 
housing. OMH issues operating certificates to PROS programs, reimbursed on a monthly case payment basis, 
last day of month is service date for all services incurred during the month.

Monthly

If Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code = '829' 
AND Rate_Code IN('4510', '4520' – '4527', '4531' – '4534') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 780
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code = '829'  
AND		(	E.Rate_Code = '4510'
			OR E.Rate_Code BETWEEN '4520' AND '4527'
			OR E.Rate_Code BETWEEN '4531' AND '4534'	)

/* -------------------------------------------------------------------------------------------------------
790: OUTPATIENT MENTAL HEALTH: CRISIS INTERVENTION

Crisis Intervention (NOTE: Crisis Intervention billed out of clinics will be billed using APG rate codes 
and recorded as a clinic service. This is a separate program billed outside of the APG methodology.)
Per Hour / Per Diem

IF Category_of_Service = '15' 
AND Provider_Specialty_Code = '824' 
AND Procedure_Code IN('S9484', 'S9485') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 790
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service ='15'
AND		E.Provider_Specialty_Code = '824'  
AND		E.Procedure_Code IN('S9484', 'S9485')

/* -------------------------------------------------------------------------------------------------------
800: OUTPATIENT MENTAL HEALTH: OMH LICENSED BEHAVIORAL HEALTH PRACTITIONER (LBHP)

Licensed Behavioral Health Practitioner (Billed out of clinics using APG rate codes, but specialty code 838 must be reported in MEDS)
Per Unit

If Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code = '838' 
AND Rate_Code IN('1507', '1519') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 800
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85','87') 
AND		E.Provider_Specialty_Code = '838'  
AND		E.Rate_Code IN('1507', '1519')

/* -------------------------------------------------------------------------------------------------------
810: OUTPATIENT MENTAL HEALTH: OTHER LICENSED PRACTITIONER - KIDS

Other Licensed Practitioners (OLP): An OLP is an individual who is licensed in NYC to diagnose, and/or 
treat individuals with a physical illness, mental illness, substance use disorder, or functional limitations 
at issue, operating within the scope of practice defined in NYS law and in any setting permissible under 
State Practice Law.
Only services pertaining to kids (Age under 21 years) enrolled in HCBS should be reported under this category.
For OLP Licensed Evaluation, Counseling – Individual, Crisis, Crisis Triage, Counseling Group, 
Offsite – OLP Individual and Offsite - OLP Counseling– Unit of Measure is 15 minutes
For OLP Crisis Complex Care, Unit of Measure is 5 minutes.

IF Category_Of_Service IN('85', '87') 
AND Provider_Specialty_Code = '838' 
AND Rate_Code IN('7900', '7901', '7902', '7903', '7904', '7905', '7919', '7920', '7927') 
AND ((Procedure_Code = '90791' AND Procedure_Code_Modifier in 'EP', 'SC')) 
	OR (Procedure_Code = 'H0004' AND Procedure_Code_Modifier IN('EP', 'HQ', 'SC')) 
	OR (Procedure_Code = 'H2011' AND Procedure_Code_Modifier IN('EP', 'ET', GT')) 
	OR (Procedure_Code = '90882' AND Procedure_Code_Modifier IN('EP', 'TS'))) then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 810
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service IN('85', '87')
AND		E.Provider_Specialty_Code = '838'
AND		E.Rate_Code IN('7900', '7901', '7902', '7903', '7904', '7905', '7919', '7920', '7927') 
AND		(	(	E.Procedure_Code = '90791' AND (E.Modifier_1 IN('EP', 'SC') OR E.Modifier_2 IN('EP', 'SC') )	)
					OR (	E.Procedure_Code = 'H0004' AND (E.Modifier_1 IN('EP', 'HQ', 'SC') OR E.Modifier_2 IN('EP', 'HQ', 'SC')	)	)
					OR (	E.Procedure_Code = 'H2011' AND (E.Modifier_1 IN('EP', 'ET', 'GT') OR E.Modifier_2 IN('EP', 'ET', 'GT')	)	)
					OR (	E.Procedure_Code = '90882' AND (E.Modifier_1 IN('EP', 'TS') OR E.Modifier_2 IN('EP', 'TS') )	)
		)

/* -------------------------------------------------------------------------------------------------------
820: OUTPATIENT MENTAL HEALTH: COMMUNITY PSYHCIATRIC SUPPORT AND TREATMENT

Community Psychiatric Support and Treatment (CPST): CPST services are goal-directed supports and 
solution-focused interventions intended to achieve identified goals or objectives as set forth in the 
child's treatment plan. Only services that pertain to kids (Age under 21 years) enrolled in HCBS should be 
reported under this category.
15 minutes
IF Category_Of_Service = '06' 
AND Provider_Specialty_Code = '839' 
AND Rate_Code IN('7911', '7912', '7921', '7928') 
AND Procedure_Code = 'H0036' AND Procedure_Code_Modifier IN('EP', 'HQ', 'SC') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 820
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '06'
AND		E.Provider_Specialty_Code = '839'
AND		E.Rate_Code IN('7911', '7912', '7921', '7928') 
AND		E.Procedure_Code = 'H0036' 
AND		(E.Modifier_1 IN('EP', 'HQ', 'SC') OR E.Modifier_2 IN('EP', 'HQ', 'SC'))

/* -------------------------------------------------------------------------------------------------------
830: OUTPATIENT MENTAL HEALTH: PYSCHOSOCIAL REHABILITATION

Psychosocial Rehabilitation (PSR). Behavioral Health services pertaining only to children (Age under 21 years) 
enrolled in HCBS should be reported under this category. 
15 minutes

IF Category_Of_Service = '06' 
AND Provider_Specialty_Code = '836' 
AND Rate_Code IN('7913', '7914', '7922', '7929') 
AND Procedure_Code = 'H2017' AND Procedure_Code_Modifier IN('EP', 'HQ', 'SC') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 830
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '06'
AND		E.Provider_Specialty_Code = '836'
AND		E.Rate_Code IN('7913', '7914', '7922', '7929') 
AND		E.Procedure_Code = 'H2017' 
AND		(E.Modifier_1 IN('EP', 'HQ', 'SC') OR E.Modifier_2 IN('EP', 'HQ', 'SC'))

/* -------------------------------------------------------------------------------------------------------
840: HARP HCBS

HARP Home and Community Based Services – consist of a number of rehabilitation services, as outlined below
Various service-specific units of measurement
IF Category_Of_Service = '06' 
AND Provider_Specialty_Code IN('356', '835', '836', '837', '839', '854', '855', '856', '857', '858', '859'
, '860'', '861', '862') 
AND Rate_Code IN('7778', '7779', '7780', '7784', '7785', '7786', '7787', '7788', '7789', '7790', '7791'
, '7792', '7793', '7794', '7795', '7796', '7798', '7799', '7800', '7801', '7802', 7803', '7804', '7805'
, '7806',' 7807') then HCBS_SERVICES = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 840
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	E.Category_of_Service = '06'
AND		E.Provider_Specialty_Code IN('356', '835', '836', '837', '839', '854', '855', '856', '857', '858', '859', '860', '861', '862') 
AND		E.Rate_Code IN('7778', '7779', '7780', '7784', '7785', '7786', '7787', '7788', '7789', '7790', '7791'
						, '7792', '7793', '7794', '7795', '7796', '7798', '7799', '7800', '7801', '7802', '7803', '7804', '7805', '7806',' 7807') 

/* -------------------------------------------------------------------------------------------------------
????? MOVED TO THE END OF THE HIERARCHY
560: OTHER OUTPATIENT UNCLASSIFIED

Provider Specialty Codes which do not fall into the classification scheme.
Per Visit
IF Sum Of (NH, ER, FAMILY_PLANNING, PRENATAL_POSTPATUM, AMBULATORY_SURGERY, HH_AIDE, HH_MED_SOCIAL_SRVS, 
HH_NURSING, HH_OT, HH_PT, HH_RESP_THRPY, HH_SPEECH, NUTRITION, HH_SOCIAL_EVIRON_SPPTS, DENTAL, DX_LAB_XRAY, 
AUDIOLOGY, DME, ER_TRANS, NON_ER_TRANS, OTHER_MEDICAL, OTHER_PROFESSIONAL, DRUG_ALCOHOL, MENTAL_HEALTH, RX, 
REHAB, PHYSICIAN_SPEC, PODIATRY, PRIMARY_CARE, VISION, PERSONAL_CARE_LVL1, PERSONAL_CARE_LVL2, ADULT_DAYCARE, 
SOCIAL_DAYCARE, MEALS, PERS, REN_DIALYSIS, CDPAP_LVL1, CDPAP_LVL2, HEALTH_HOMES) = 0 THEN OTHER = 1;
*/
UPDATE	E
SET		SUM_OF_OTHER = NH + ER + FAMILY_PLANNING + PRENATAL_POSTPARTUM + AMBULATORY_SURGERY + HH_AIDE + HH_MED_SOCIAL_SRVS + 
		HH_NURSING + HH_OT + HH_PT + HH_RESP_THRPY + HH_SPEECH + NUTRITION + HH_SOCIAL_EVIRON_SPPTS + DENTAL + DX_LAB_XRAY + 
		AUDIOLOGY + DME + ER_TRANS + NON_ER_TRANS + OTHER_MEDICAL + OTHER_PROFESSIONAL + DRUG_ALCOHOL + MENTAL_HEALTH + OUTPATIENT_MENTAL_HEALTH + RX + 
		REHAB + PHYSICIAN_SPEC + PODIATRY + PRIMARY_CARE + VISION + PERSONAL_CARE_LVL1 + PERSONAL_CARE_LVL2 + ADULT_DAYCARE + 
		SOCIAL_DAYCARE + MEALS + PERS + REN_DIALYSIS + CDPAP_LVL1 + CDPAP_LVL2 + HEALTH_HOMES
		-- ??? NOT IN GUIDE:
		+ HH_SGN_LNG_ORAL_INTRPTER + OUTPATIENT_SUD + AIDS_ADULT_DAYCARE + OUTPATIENT_HOSPICE + HCBS_Services
FROM	dbo.tblEncounters AS E

UPDATE	E
SET		ServiceTypeCode = 560
,		OTHER_PROFESSIONAL = 1
FROM	dbo.tblEncounters AS E
WHERE	E.SUM_OF_OTHER = 0

-- MMCOR Hierarchy
UPDATE	E
SET		MMCORCostReportCategoryId = 
		CASE	WHEN NEWBORN = 1 THEN 1 				-- Inpatient Newborn Births (> = 1 THEN 0 >=1200g weight)
				WHEN LBW_NEWBORN = 1 THEN 2 			-- Inpatient Newborn Births – Low Birth Weight <1200g weight
				WHEN MATERNITY = 1 THEN 3 				-- Inpatient Maternity Delivery
				WHEN PYSCHSA = 1 THEN 4 				-- Inpatient Mental Health & Substance Abuse
				WHEN MEDSURG = 1 THEN 5 				-- Inpatient Medical Surgical
				WHEN HOSPICE = 1 THEN 6 				-- Hospice
				WHEN NH = 1 THEN 7 						-- Nursing Facility
				WHEN ER = 1 THEN 8						-- Emergency Room
				WHEN FAMILY_PLANNING = 1 THEN 9 		-- Family Planning
				WHEN PRENATAL_POSTPARTUM = 1 THEN 10	-- Prenatal/Postpartum
				WHEN AMBULATORY_SURGERY = 1 THEN 11		-- Ambulatory Surgery
				WHEN HH_AIDE = 1 THEN 12 				-- Home Health Care (Level 3: Home Home Health Care Aide)
				WHEN HH_MED_SOCIAL_SRVS = 1 THEN 13 	--  (Medical Social Services)Home Health Care
				WHEN HH_NURSING = 1 THEN 14 			--  (Nursing)Home Health Care
				WHEN HH_OT = 1 THEN 15 					--  (Occupational Therapy)Home Health Care
				WHEN HH_PT = 1 THEN 16 					--  (Physical Therapy)Home Health Care
				WHEN HH_RESP_THRPY = 1 THEN 17 			--  (Respiratory Therapy)Home Health Care
				WHEN HH_SPEECH = 1 THEN 18 				--  (Speech Therapy)Home Health Care
				WHEN HH_SOCIAL_EVIRON_SPPTS = 1 THEN 19	--  (Social and Environmental Supports)Home Health Care
				WHEN NUTRITION = 1 THEN 20 				--  (Nutrition)Home Health Care
				WHEN HH_SGN_LNG_ORAL_INTRPTER = 1 THEN 21 	--  (Sign Language/Oral Interpreter)Home Health care
				WHEN DENTAL = 1 THEN 22 				-- Dental
				WHEN PRIMARY_CARE = 1 THEN 23 			-- Primary Care
				WHEN PHYSICIAN_SPEC = 1 THEN 24 		-- Specialty Care
				WHEN DX_LAB_XRAY = 1 THEN 25 			-- Diagnostic Testing, Laboratory, X-Ray
				WHEN PERS = 1 THEN 26 					-- Personal Emergency Response System (PERS)
				WHEN DME = 1 THEN 27 					-- Durable Medical Equipment
				WHEN AUDIOLOGY = 1 THEN 28 				--  (Audiology and Hearing Aid Services)Other Professional
				WHEN ER_TRANS = 1 THEN 29 				-- Transportation - Emergent
				WHEN NON_ER_TRANS = 1 THEN 30 			-- Transportation – Non-Emergent
				WHEN OUTPATIENT_SUD = 1 THEN 31 		-- Outpatient SUD Treatment
				WHEN OUTPATIENT_MENTAL_HEALTH = 1 THEN 32 	-- Outpatient Mental Health
				WHEN RX = 1 THEN 33 					-- Pharmacy
				WHEN MEALS = 1 THEN 34 					--  (Home Delivered or Congregated Meals)Other Medical
				WHEN REHAB = 1 THEN 35 					-- Outpatient Physical Rehab/Therapy
				WHEN PODIATRY = 1 THEN 36				-- Foot Care
				WHEN VISION = 1 THEN 37					-- Vision Care Inc. Eyeglasses
				WHEN PERSONAL_CARE_LVL1 = 1 THEN 38		-- (Paraprofessional Services Level 1: Homemaker/Housekeeper)Personal Care
				WHEN PERSONAL_CARE_LVL2 = 1 THEN 39		-- (Paraprofessional Services Level 2: Personal Care)Personal Care
				WHEN ADULT_DAYCARE = 1 THEN 40			-- (Adult Day Health Care)Other Medical
				WHEN AIDS_ADULT_DAYCARE = 1 THEN 41		-- (AIDS Adult Day Health Care)Other Medical
				WHEN SOCIAL_DAYCARE = 1 THEN 42			-- (Social Day Care)Other Professional Services
				WHEN REN_DIALYSIS = 1 THEN 43			-- (Chronic Renal Dialysis)Other Medical
				WHEN OTHER_MEDICAL = 1 THEN 44			-- Other Medical
				WHEN OTHER_PROFESSIONAL = 1 THEN 45		-- Other Professional Services
				WHEN OTHER = 1 THEN 46					-- Other Outpatient Unclassified
				WHEN CDPAP_LVL1 = 1 THEN 47				-- (Consumer Directed Personal Care: Level 1)Personal Care
				WHEN CDPAP_LVL2 = 1 THEN 48				-- (Consumer Directed Personal Care: Level 2)Personal Care
				WHEN OUTPATIENT_HOSPICE = 1 THEN 49		-- Other Medical
				WHEN HCBS_Services = 1 THEN 50			-- Behavioral Health HCBS Services
				ELSE 0
		END
FROM	dbo.tblEncounters AS E

-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- 2: LINE LEVEL : PROCEDURE CODE
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================
BEGIN

/* -------------------------------------------------------------------------------------------------------
100: HOSPICE

Inpatient Hospice
Per Day

IF Provider_Specialty_Code = '669' 
AND Revenue_Code in ('0655', '0656', '0658') then HOSPICE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 100
,		HOSPICE = 1
FROM	dbo.tblEncounters AS E
WHERE		MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '669'
AND		E.Revenue_Code IN('0655', '0656', '0658')

/* -------------------------------------------------------------------------------------------------------
220: PRENATAL/POSTPARTUM CARE

Physician or Clinic services with a pregnancy related diagnosis or procedure code. Do not include 
laboratory and diagnostic testing procedures with pregnancy-related diagnosis.
Per Visit
*/
UPDATE	E
SET		ServiceTypeCode = 220
,		PRENATAL_POSTPARTUM = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Procedure_Code IN('59400', '59409', '59410', '59412', '59414', '59425', '59426', '59430', '59510'
				, '59514', '59515', '59610', '59612', '59614', '59515', '59610', '59612', '59614', '59618', '59620'
				, '59622', '59866', '59898', '59899') 
			OR (	E.Procedure_Code = '99078' AND (E.Modifier_1 = 'TH' OR E.Modifier_2 = 'TH' OR E.Modifier_3 = 'TH' OR E.Modifier_4 = 'TH')	)
		)


/* -------------------------------------------------------------------------------------------------------
240: HOME HEALTH CARE: LEVEL 3 HOME HEALTH CARE AIDE

Level 3 (Home Health Aide): Level 1 and 2 plus health-related tasks (vital signs, transferring with hoyer 
lift, stable dressings, ostomy care, prepare meals for complex diets, maintenance exercise programs.
Per Hour

IF (Procedure_Code in ('S5125', 'S5126', 'S9122') 
	OR Procedure_Code in (('S5125', 'S5126') AND Procedure_Code_Modifier in ('U2')) 
	OR ((Procedure_Code in ('S9122') AND Procedure_Code_Modifier in ('U1'))) then HH_Aide = 1;
IF ('0570' <= Revenue_Code <= '0579') then HH_Aide = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 240
,		HH_Aide = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	(	E.Procedure_Code IN('S5125','S5126', 'S9122') 
					OR	(	E.Procedure_Code IN('S5125', 'S5126') 
							AND (E.Modifier_1 = 'U2' OR E.Modifier_2 = 'U2' OR E.Modifier_3 = 'U2' OR E.Modifier_4 = 'U2')	)
					OR (	E.Procedure_Code IN('S9122') 
							AND (E.Modifier_1 = 'U1' OR E.Modifier_2 = 'U1' OR E.Modifier_3 = 'U1' OR E.Modifier_4 = 'U1')	)
				)
		)
/* Note:
U1: This rate code modifier would be used for the provision of Advanced Home Health Aide services on an hourly basis.
U2: This rate code modifier will be used for the provision of personal care Level I or Level II services to one of 
two clients in the same household WHERE	MMCORCostReportCategoryId = 0
AND	 both clients are receiving personal care services from the same aide.
*/

/* -------------------------------------------------------------------------------------------------------
250: HOME HEALTH CARE: MEDICAL SOCIAL SERVICES

Level 3 (Home Health Aide): Level 1 and 2 plus health-related tasks (vital signs, transferring with hoyer 
lift, stable dressings, ostomy care, prepare meals for complex diets, maintenance exercise programs.
Per Hour

if Procedure_Code = 'S9127' AND then HH_MED_SOCIAL_SRVS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 250
,		HH_MED_SOCIAL_SRVS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code = 'S9127'

/* -------------------------------------------------------------------------------------------------------
260: HOME HEALTH CARE: NURSING

Intermittent, part-time and continuous nursing services provided by RNs and LPNs in accordance with the 
Nurse Practice Act in the home.
Per Visit
IF ('99500' <= Procedure_Code <= '99507') 
OR Procedure_Code in ('99511', '99512', '99600', 'T1000', 'T1002', 'T1003', 'T1030', 'T1031', 'T2024', 'S9123', 'S9124') then
HH_NURSING = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 260
,		HH_NURSING = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Procedure_Code BETWEEN '99500' AND '99507'
			OR E.Procedure_Code IN('99511', '99512', '99600', 'T1000', 'T1002','T1003', 'T1030', 'T1031', 'T2024', 'S9123', 'S9124')
		)

/* -------------------------------------------------------------------------------------------------------
270: HOME HEALTH CARE: OCCUPATIONAL THERAPY

Rehabilitation services by a licensed and registered occupational therapist for maximum reduction of 
physical disability and restoration or maintenance of member to their best functional level rendered 
in the home.
Per Visit
IF Procedure_Code in ('S9129') then HH_OT = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 270
,		HH_OT = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code = 'S9129'

/* -------------------------------------------------------------------------------------------------------
280: HOME HEALTH CARE: PHYSICAL THERAPY

Rehabilitation services provided in the home by a licensed and registered physical therapist for maximum 
reduction of physical disability and restoration or maintenance of member to their best functional level.
Per Visit
IF Procedure_Code in ('S9131') then HH_PT = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 280
,		HH_PT = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code = 'S9131'

/* -------------------------------------------------------------------------------------------------------
290: HOME HEALTH CARE: RESPIRATORY THERAPY

Performance of preventive, maintenance and restorative airway related techniques and procedures provided 
by a qualified respiratory therapist in the home.
Per Visit
IF Procedure_Code in ('G0237','G0238) AND ('0580' <= Revenue_Code <= '0589') then HH_RESP_THRPY = 1;
IF Procedure_Code in ('G0237,'G0238') AND Category_of_Service = '15' Then HH_RESP_THRPY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 290
,		HH_RESP_THRPY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	(	E.Procedure_Code IN('G0237','G0238')
				AND E.Revenue_Code BETWEEN '0580' AND '0589'	)
			OR
			(	E.Procedure_Code IN('G0237','G0238')
				AND E.Category_of_Service ='15'					)
		)

/* -------------------------------------------------------------------------------------------------------
300: HOME HEALTH CARE: SPEECH THERAPY

Rehabilitation services provided by a licensed and registered speech-language pathologist for maximum 
reduction of physical disability and restoration or maintenance of member to their best functional level 
rendered in the home.
Per Visit
IF (Category_of_Service in ('01', '15') 
AND Provider_Specialty_Code = '302' 
AND Procedure_Code = 'S9128' then HH_SPEECH = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 300
,		HH_SPEECH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code = 'S9128'


/* -------------------------------------------------------------------------------------------------------
310: HOME HEALTH CARE: SOCIAL AND ENVIRONMENTAL SUPPORTS

Services and items that support the medical need of the member, such as home maintenance tasks and housing 
improvements
Per Service

IF Procedure_Code in ('T1028','S5165') then SOCIAL_EVIRON_SPPTS = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 310
,		HH_SOCIAL_EVIRON_SPPTS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code IN('T1028','S5165') 

/* -------------------------------------------------------------------------------------------------------
320 HOME HEALTH CARE: NUTRITIONAL COUNSELING

Assessment of nutritional needs and food patterns, planning for the provision of food and drink, providing 
nutritional education and counseling to patient and family by qualified nutritionist/dietician.
Per Visit

IF Category_of_Service in ('01', '15') AND Procedure_Code in ('S9470') then NUTRITION = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 320
,		NUTRITION = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Category_of_Service IN('01', '15')  
AND		E.Procedure_Code = 'S9470'

/* -------------------------------------------------------------------------------------------------------
370: DIAGNOSTIC TESTING, LABORATORY, X-RAY SERVICES

Medically necessary tests and procedures ordered by a qualified medical professional. This category includes 
outpatient laboratory, diagnostic radiology, diagnostic ultrasound, nuclear medicine, radiation oncology, and 
magnetic resonance imaging (MRI) services.
Per Test

IF (Procedure_Code IN('36400', '36410', '36415', '59000', '59012', '59015', '74741') 
OR ('70000' <= Procedure_Code <= '74739') OR ('74743' <= Procedure_Code <= '76840') 
OR ('76842' <= Procedure_Code <= '76856') OR ('76858' <= Procedure_Code <= '79999') 
OR ('80002' <= Procedure_Code <= '89309') OR ('89311' <= Procedure_Code <= '89399') 
OR ('P0000' <= Procedure_Code <= 'P9999') OR ('R0000' <= Procedure_Code <= 'R5999'))
then DX_LAB_XRAY = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 370
,		DX_LAB_XRAY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Procedure_Code IN('36400', '36410', '36415', '59000', '59012', '59015', '74741') 
			OR E.Procedure_Code BETWEEN '70000' AND '74739'
			OR E.Procedure_Code BETWEEN '74743' AND '76840'
			OR E.Procedure_Code BETWEEN '76842' AND '76856'
			OR E.Procedure_Code BETWEEN '76858' AND '79999'
			OR E.Procedure_Code BETWEEN '80002' AND '89309'
			OR E.Procedure_Code BETWEEN '89311' AND '89399'
			OR E.Procedure_Code BETWEEN 'P0000' AND 'P9999'
			OR E.Procedure_Code BETWEEN 'R0000' AND 'R5999'	)

/* -------------------------------------------------------------------------------------------------------
380: PERSONAL EMERGENCY RESPONSE SYSTEM (PERS)

An electronic device that enables certain high-risk patients to secure help in the event of a physical, 
emotional or environmental emergency.
Per Unit
IF Procedure_Code in ('S5160','S5161') then PERS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 380
,		PERS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code IN('S5160','S5161')

/* -------------------------------------------------------------------------------------------------------
400: AUDIOLOGY AND HEARING AID SERVICES

Audiology services include audiometric examination or testing, hearing aid evaluation, conformity evaluation 
and hearing aid prescription or recommendations if indicated. Hearing aid services include selecting, fitting 
and dispensing of hearing aids, hearing aid checks following dispensing and hearing aid repairs.

Per Unit

IF Procedure_Code IN('V5008', 'V5010', 'V5011', 'V5020')  then AUDIOLOGY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 400
,		AUDIOLOGY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code IN('V5008', 'V5010', 'V5011', 'V5020')

/* -------------------------------------------------------------------------------------------------------
410: EMERGENCY TRANSPORTATION

Transportation as a result of an emergency condition. This category includes ambulance transportation, 
including air ambulance service for the purpose of obtaining emergency medical services. 
Per 1 Way

IF Procedure_Code IN('A0021', 'A0225') 
OR ('A0420' <= Procedure_Code <= 'A0427') 
OR ('A0429' <= Procedure_Code <= 'A0999') 
 then ER_TRANS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 410
,		ER_TRANS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Procedure_Code IN('A0021', 'A0225') 
			OR E.Procedure_Code BETWEEN 'A0420' AND 'A0427'	
			OR E.Procedure_Code BETWEEN 'A0429' AND 'A0999'				) 
			
/* -------------------------------------------------------------------------------------------------------
420: NON-EMERGENCY TRANSPORTATION

Transportation provided at the appropriate level for an enrollee to receive medically necessary services. 
This category includes transportation that is essential for an enrollee to obtain medically necessary care 
such as taxicab
Per 1 Way

IF Procedure_Code IN('T2001' <= Procedure_Code <= 'T2005') 
OR ('A0080' <= Procedure_Code <= 'A0214') 
OR Procedure_Code IN('A0428') then NON_ER_TRANS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 420
,		NON_ER_TRANS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Procedure_Code BETWEEN 'T2001' AND 'T2005'	
			OR E.Procedure_Code BETWEEN 'A0080' AND 'A0214'	
			OR E.Procedure_Code = 'A0428'	)

/* -------------------------------------------------------------------------------------------------------
440: HOME DELIVERED OR CONGREGATE MEALS
Home delivered meals are meals delivered to a member's home. Congregate meals are meals in a group 
setting such as a senior center. 
Per Meal
IF Procedure_Code in ('S5170', 'S9977') then MEALS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 440
,		MEALS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code IN('S5170', 'S9977')

/* -------------------------------------------------------------------------------------------------------
450: OUTPATIENT REHABILITATION THERAPIES: PHYSICAL THERAPY, OCCUPATIONAL THERAPY, SPEECH THERAPY
Rehabilitation services in an outpatient setting provided by licensed and registered therapists for maximum 
reduction of physical disability and restoration or maintenance of the member to their best functional level. 
Report each time an enrollee receives therapy services regardless of the number of procedures or clinicians seen. 
This includes physical, occupational and speech therapies, but excludes mental health, drug and alcohol therapy.
Per Visit
IF ('97001' <= Procedure_Code <= '97799') 
OR ('V5362' <= Procedure_Code <= 'V5364') 
 then REHAB = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 450
,		REHAB = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Procedure_Code BETWEEN '97001' AND '97799'
			OR E.Procedure_Code BETWEEN 'V5362' AND 'V5364')

/* -------------------------------------------------------------------------------------------------------
480: PARAPROFESSIONAL SERVICES: Level 1 – HOMEMAKER / HOUSEKEEPER
Level 1: Performance of nutritional and environmental support function (housekeeping, preparing simple meals). 
Includes assessments of care and supervision.
Per Unit
IF Provider_Specialty_Code = '672' and Procedure_Code = 'S5130' 
AND Procedure_Code_Modifier in ('U1', 'U2', 'U3', 'TV') then PERSONAL_CARE_LVL1 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 480
,		PERSONAL_CARE_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '672'
AND		E.Procedure_Code = 'S5130'
AND		(E.Modifier_1 IN('U1','U2','U3','TV')
			OR E.Modifier_2 IN('U1','U2','U3','TV')	)

/* -------------------------------------------------------------------------------------------------------
490: PARAPROFESSIONAL SERVICES: LEVEL 2 – PERSONAL CARE

Level 2: Level 1 plus personal care functions (bathing, grooming, dressing, toileting, walking, 
transferring, and feeding)
Paraprofessional Services – Level 1 supersedes Level 2 based on Procedure Code only. 
Per Hour

IF Provider_Specialty_Code = '673' 
AND (	(Procedure_Code = 'T1019' AND Procedure_Code_Modifier in ('U1', 'U2', 'U3', 'U4', 'U5', 'TV')) 
		OR Procedure_Code = 'T1020' AND Procedure_Code_Modifier in ('U2, 'U5', 'TV') then PERSONAL_CARE_LVL2 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 480
,		PERSONAL_CARE_LVL2 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '673'
AND		(	(	E.Procedure_Code = 'T1019'
				AND		(	E.Modifier_1 IN('U1','U2','U3','U4','U5','TV')
							OR E.Modifier_2 IN('U1','U2','U3','U4','U5','TV')	)
			OR
			(	E.Procedure_Code = 'T1020'
				AND		(	E.Modifier_1 IN('U2','U5','TV')
							OR E.Modifier_2 IN('U2','U5','TV')		)		)	)
		)

/* -------------------------------------------------------------------------------------------------------
500: ADULT DAY HEALTH CARE
Care and services provided in a residential health care facility or approved extension site under the 
medical direction of a physician to a person who is functionally impaired, not homebound and who requires 
certain preventative, diagnostic, therapeutic, rehabilitative or palliative items or services.
Per Visit
IF Provider_Specialty = '664' 
AND Procedure_Code = 'S5102' 
AND Procedure_Code_Modifier in ('U1', 'U2', 'U3') then ADULT_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 500
,		ADULT_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '664'
AND		E.Procedure_Code = 'S5102'
AND		(E.Modifier_1 IN('U1','U2','U3')
			OR E.Modifier_2 IN('U1','U2','U3')	)
					
/* -------------------------------------------------------------------------------------------------------
510: AIDS ADULT DAY HEALTH CARE
Care and services provided in a residential health care facility or approved Extension site under the medical 
direction of a physician to a person who is functionally impaired, not homebound and who requires certain 
preventative, diagnostic, therapeutic, rehabilitative or palliative items or services
Per Visit
IF Provider_Specialty_Code = '355' 
AND Procedure_Code in 'S5100', 'S5101', 'S5102', 'S5105' then AIDS_ADULT_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 510
,		AIDS_ADULT_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '355'
AND		E.Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105')

/* -------------------------------------------------------------------------------------------------------
520: SOCIAL DAY CARE

Structured, comprehensive program which provides functionally impaired individuals with socialization, 
supervision and monitoring, personal care, and nutrition in a protective setting during any part of the day, 
but less than a 24-hour period.
Per Visit

IF Provider_Specialty_Code = '662' 
AND Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105') then SOCIAL_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 520
,		SOCIAL_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '662'
AND		E.Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105')

/* -------------------------------------------------------------------------------------------------------
570: CONSUMER DIRECTED PERSONAL ASSISTANT LEVEL I

Level I: Under the supervision of consumer, the Consumer Directed Personal Assistant performs all necessary 
personal care, home health and nursing tasks. 
Per Unit

IF Provider_Specialty_Code = '675' 
AND Procedure_Code = 'T1019' 
AND Procedure_Code_Modifier IN('U6', 'U7', 'U8', 'U9') then CDPAP_LVL1 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 570
,		CDPAP_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '675'
AND		E.Procedure_Code = 'T1019' 
AND		(	E.Modifier_1 IN('U6', 'U7', 'U8', 'U9')
			OR  E.Modifier_2 IN('U6', 'U7', 'U8', 'U9')	)

/* -------------------------------------------------------------------------------------------------------
580: CONSUMER DIRECTED PERSONAL ASSISTANT LEVEL 2

Level 2: Under the supervision of the consumer, the live-in Consumer Directed Personal Assistant performs 
all necessary personal care, home health and nursing tasks. 
Per Hour

IF Provider_Specialty_Code = '676' 
AND Procedure_Code = 'T1020' 
AND Procedure_Code_Modifier IN('U6', 'U7', 'U8', 'U9') then CDPAP_LVL2 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 580
,		CDPAP_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '676'
AND		E.Procedure_Code = 'T1020' 
AND		(	E.Modifier_1 IN('U6', 'U7', 'U8', 'U9')
			OR  E.Modifier_2 IN('U6', 'U7', 'U8', 'U9')	)

/* -------------------------------------------------------------------------------------------------------
590: OUTPATIENT SERVICES: HEALTH HOMES - ADULT

Report all Health Home costs and utilization under this category of service. Health
Homes designated to serve adults must bill at the adult rate.
Per Visit Administrative

IF Procedure_Code = 'G9001' 
Or (Procedure_Code = 'G9005' AND Procedure_Code_Modifier IN('U1', 'U2', 'U3', 'U4')) then HEALTH_HOMES = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 590
,		HEALTH_HOMES = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Procedure_Code = 'G9001' 
			OR (	E.Procedure_Code = 'G9005' 
					AND (	E.Modifier_1 IN('U1', 'U2', 'U3', 'U4')
							OR E.Modifier_2 IN('U1', 'U2', 'U3', 'U4')	)
			   )
		)

/* -------------------------------------------------------------------------------------------------------
600: OUTPATIENT SERVICES: HEALTH HOMES – CHILD

Report all health comes costs and utilization under this category of service. Only Health Homes designated 
to serve children may bill at children's rate. Health Homes that enroll children but are not designated for 
children must bill at the adult rate.
Per Visit
IF (Procedure_Code IN('G9001') AND Procedure_Code_Modifier IN('U1')) 
OR Procedure_Code IN('G0506') 
OR (Procedure_Code IN('T2022') AND Procedure_Code_Modifier IN('U1', 'U2', 'U3')) then HEALTH_HOMES = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 600
,		HEALTH_HOMES = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	(	E.Procedure_Code = 'G9001' AND (E.Modifier_1 = 'U1' OR E.Modifier_2 = 'U1')	)
			OR E.Procedure_Code = 'G0506' 
			OR (	E.Procedure_Code = 'T2022' 
					AND (	E.Modifier_1 IN('U1', 'U2', 'U3')
							OR E.Modifier_2 IN('U1', 'U2', 'U3')	)
			   )
		)

/* -------------------------------------------------------------------------------------------------------
620: DOULA SERVICES

A doula is a non-medical birth coach who assists a woman during the prenatal period, labor, delivery, 
and post childbirth.
The Medicaid doula pilot will be implemented through a phased-in approach in order to ensure access to this 
new benefit. Phase 1 of the pilot will launch in Erie County. Medicaid eligible pregnant women who reside 
in the selected zip codes (Erie) would be eligible to receive doula services.
Per Visit

IF (Category_of_Service IN('01', '41') 
AND Provider_Specialty_Code = '755' 
AND (	(Procedure_Code IN('99600', '99499') 
			OR (Procedure_Code = '99600' and Modifier = 'UA')	) 
		OR Primary_Dx_Code IN('Z32.2', 'Z32.3')
	) then OTHER_MEDICAL = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 620
,		OTHER_MEDICAL = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Procedure_Code IN('99600', '99499')
			OR (	E.Procedure_Code = '99600' AND ( E.Modifier_1 = 'UA' OR E.Modifier_2 = 'UA'	)	)
			OR E.Primary_Dx_Code IN('Z32.2', 'Z32.3')
		)

/* -------------------------------------------------------------------------------------------------------
690: OUTPATIENT SUD: OFFICE-BASED OUTPATIENT SUD

Report all outpatient costs and utilization under this category of service.
Per Visit

IF Provider_Specialty_Code IN('198', '282') then do;
if ('291' <= Primary_Dx_Code <= '29299')
OR ('303' <= Primary_Dx_Code <= '30699', excluding 305.1) 
OR Primary_Dx_Code IN(F10 – F16999, F18 – F19999) then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 690
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code  IN('198','282')
ANd		(	E.Primary_Dx_Code BETWEEN '291' AND '29299'
			OR (	E.Primary_Dx_Code BETWEEN '303' AND '30699' AND E.Primary_Dx_Code <> '305.1'	) 
			OR E.Primary_Dx_Code BETWEEN 'F10' AND 'F16999'
			OR E.Primary_Dx_Code BETWEEN 'F18' AND 'F19999'	
		)

/* -------------------------------------------------------------------------------------------------------
710: OUTPATIENT MENTAL HEALTH: OFFICE-BASED MENTAL HEALTH SERVICES

This category includes services provided by psychologists, psychiatrists and other mental health providers. 
Report each time a patient receives mental health services regardless of the number of procedures or 
clinicians seen.
Per Visit
IF Procedure_Code IN('H0002', 'H0004', 'H0031', 'H0032', 'H0036', 'H0037', 'H0046', 'H2012'
, 'H2013', 'H2017', 'H2018', 'H2019', 'H2020') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 710
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code IN('H0002', 'H0004', 'H0031', 'H0032', 'H0036', 'H0037', 'H0046', 'H2012', 'H2013', 'H2017', 'H2018', 'H2019', 'H2020')

/* -------------------------------------------------------------------------------------------------------
720: OUTPATIENT MENTAL HEALTH: OUTPATIENT MENTAL HEALTH CLINIC

Services provided in OMH-licensed free-standing and hospital-based clinics; voluntary, county (LGU), and state-operated. 
Per Visit (procedure-based)
IF Category_of_Service IN('85', '87') AND Procedure_Code IN('J0401', 'J2358', 'J2426', 'J2794') 
OR Provider_Specialty_Code = '749'
then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 720
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	(	E.Category_of_Service IN('85','87') 
				AND E.Procedure_Code IN('J0401', 'J2358', 'J2426', 'J2794')	
			)
			OR
			E.Provider_Specialty_Code = '749'
		)
/* -------------------------------------------------------------------------------------------------------
730: OUTPATIENT MENTAL HEALTH: OMH ASSERTIVE COMMUNITY TREATMENT

Assertive Community Treatment: A comprehensive and integrated combination of treatment, rehabilitation, 
case management, and support services primarily provided in the client's residence or other community 
locations by a mobile multi-disciplinary mental health treatment team (billed as either full payment, 
partial payment or inpatient payment, depending on the number of contacts and the setting in which they 
take place) Unit of Measurement
Monthly

IF Category_of_Service IN('85', '87') 
AND Provider_Specialty_Code = '816' 
AND Rate_Code IN('4508', '4509', '4511') Then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 730
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '816' 
AND		E.Procedure_Code = 'H0040'

/* -------------------------------------------------------------------------------------------------------
740: OUTPATIENT MENTAL HEALTH: OMH CONTINUING DAY TREATMENT

Continuing Day Treatment: provides active treatment and rehabilitation designed to maintain or enhance current 
levels of functioning and skills, to maintain community living and to develop self-awareness and self-esteem 
through the exploration and development of patient strengths and interests.
Half-day visit - Minimum duration of two hours. One or more medically necessary services must be provided and documented.
Full-day visit - Minimum duration of four hours. Three or more medically necessary services must be provided and documented.
Collateral visit - Clinical support services of at least 30 minutes duration of face-to-face interaction documented.
Group collateral visit - Clinical support services of at least 60 minutes duration of face-to-face interaction 
documented between collaterals and/or family members of multiple recipients with or without recipients.
Crisis visit - Crisis intervention services are face-to-face interactions documented by the provider between a 
recipient and a therapist, regardless of the actual duration of the visit.
Preadmission visit - Services of at least 60 minutes duration of face-to-face interaction documented. 
Per Day

IF Provider_Specialty_Code in ('312', ‘317’) AND Procedure_Code = ’H2012' then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 740
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('312', '317')  
AND		E.Procedure_Code = 'H2012'

/* -------------------------------------------------------------------------------------------------------
750: OUTPATIENT MENTAL HEALTH: OMH COMPREHENSIVE PSYCHIATRIC EMERGENCY PROGRAM

Comprehensive Psychiatric Emergency Program: A licensed, hospital-based psychiatric emergency program that 
establishes a primary entry point to the mental health system for individuals who may be mentally ill to 
receive emergency observation, evaluation, care and treatment in a safe and comfortable environment. 

Components of CPEP include:
Brief emergency visit - Face-to-face interaction between a patient and a staff physician, to determine the 
scope of emergency service required. Note: Services provided in a medical/surgical emergency or clinic 
setting for comorbid conditions are separately reimbursed.

Full emergency visit - A face-to-face interaction between a patient and clinical staff to determine a 
recipient's current psychosocial and medical condition.

Crisis outreach service – Emergency services provided outside an ER which includes clinical assessment 
and crisis intervention.

Interim crisis service - Mental health service provided outside an ER for persons who are released from 
the ER of the comprehensive psychiatric emergency program, which includes immediate face-to-face contact 
with a mental health professional for purposes of facilitating a recipient's community tenure while waiting 
for a first post-CPEP visit with a community based mental health provider.

Extended observation bed – For any person alleged to have a mental illness which is likely to result in 
serious harm to the person or others and for whom immediate observation, care and treatment in the CPEP is 
appropriate. Shall not exceed 72 hours (voluntarily, or involuntarily).
Per Day
IF Provider_Specialty_Code = '992’ AND Procedure_Code in (’90791’, ‘S9485', ‘H0037’) then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 750
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '992'
AND		E.Procedure_Code in ('90791', 'S9485', 'H0037')

/* -------------------------------------------------------------------------------------------------------
760: OUTPATIENT MENTAL HEALTH: OMH INTENSIVE PSYCHIATRIC REHABILITATION TREATMENT PROGRAM
Description
Intensive Psychiatric Rehabilitation Treatment Program: time limited, designed to assist persons in forming 
and achieving mutually agreed upon goals in living, learning, working and social environments, to intervene 
with psychiatric rehabilitation technologies to overcome functional disabilities, and to improve 
environmental supports.
Duration-based (hours)

IF Provider_Specialty_Code in ('314’, ‘319’) AND Procedure_Code = ‘H2012’ then OUTPATIENT_MENTAL_HEALTH = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 760
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('314', '319') 
AND		E.Procedure_Code ='H2012'

/* -------------------------------------------------------------------------------------------------------
770: OUTPATIENT MENTAL HEALTH: OMH PARTIAL HOSPITALIZATION

Partial Hospitalization: active treatment designed to stabilize and ameliorate acute symptoms, to serve as 
an alternative to inpatient hospitalization, or to reduce the length of a hospital stay within a medically 
supervised program.
Collateral service - Clinical support services of between 30 minutes and two hours of face-to-face interaction.
Group collateral service - Clinical support services of between 60 minutes and two hours provided to more 
than one recipient and/or his or her collaterals.
Pre-admission - Visits of one to three hours are billed using the crisis visit rate codes (4357, 4358 or 4359). 
Visits of four hours or more are billed using partial hospitalization regular rate codes (4349, 4350, 4351 or 4352).
Duration-based (hours)

IF Provider_Specialty_Code in ('314’, ‘319’) AND Procedure_Code = ‘H2012’ then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 770
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('313', '318') 
AND		E.Procedure_Code = 'H2012'

/* -------------------------------------------------------------------------------------------------------
780: OUTPATIENT MENTAL HEALTH: OMH PERSONALIZED RECOVERY ORIENTED SERVICES

Personalized Recovery Oriented Services (PROS): a comprehensive recovery oriented program for individuals 
with severe and persistent mental illness. The goal of the program is to integrate treatment, support and 
rehabilitation in a manner that facilitates the individual's recovery. Goals for individuals in the program 
are to: improve functioning, reduce inpatient utilization, reduce emergency services, reduce contact with 
the criminal justice system, increase employment, attain higher levels of education and secure preferred 
housing. OMH issues operating certificates to PROS programs, reimbursed on a monthly case payment basis, 
last day of month is service date for all services incurred during the month.
Monthly

If Provider_Specialty_Code = ('829’) And Procedure_Code In (‘H0002’, ‘H2018’, ‘H2019’, ‘H2025’, ‘T1015’’) then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 780
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '829'  
AND		E.Procedure_Code IN('H0002', 'H2018', 'H2019', 'H2025', 'T1015')

/* -------------------------------------------------------------------------------------------------------
790: OUTPATIENT MENTAL HEALTH: CRISIS INTERVENTION

Crisis Intervention (NOTE: Crisis Intervention billed out of clinics will be billed using APG rate codes 
and recorded as a clinic service. This is a separate program billed outside of the APG methodology.)
Per Hour / Per Diem

IF Provider_Specialty_Code = '824’ AND Procedure_Code in (‘S9484’, ‘S9485’) then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 790
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '824'  
AND		E.Procedure_Code IN('S9484', 'S9485')

/* -------------------------------------------------------------------------------------------------------
810: OUTPATIENT MENTAL HEALTH: OTHER LICENSED PRACTITIONER - KIDS

Other Licensed Practitioners (OLP): An OLP is an individual who is licensed in NYC to diagnose, and/or 
treat individuals with a physical illness, mental illness, substance use disorder, or functional limitations 
at issue, operating within the scope of practice defined in NYS law and in any setting permissible under 
State Practice Law.
Only services pertaining to kids (Age under 21 years) enrolled in HCBS should be reported under this category.
For OLP Licensed Evaluation, Counseling – Individual, Crisis, Crisis Triage, Counseling Group, 
Offsite – OLP Individual and Offsite - OLP Counseling– Unit of Measure is 15 minutes
For OLP Crisis Complex Care, Unit of Measure is 5 minutes.

IF Provider_Specialty_Code = ‘838’ AND
((Procedure_Code = ‘90791’ AND Procedure_Code_Modifier in (‘EP’, ‘SC’)) 
	OR (Procedure_Code = ’H0004’ AND Procedure_Code_Modifier in (‘EP’, ‘HQ’, ‘SC’)) 
	OR (Procedure_Code = ’H2011’ AND Procedure_Code_Modifier in (‘EP’, ‘ET’, GT’)) 
	OR (Procedure_Code = ’90882’ AND Procedure_Code_Modifier in (‘EP’, ‘TS’))) then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 810
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '838'
AND		(	(	E.Procedure_Code = '90791' AND (E.Modifier_1 IN('EP', 'SC') OR E.Modifier_2 IN('EP', 'SC') )	)
					OR (	E.Procedure_Code = 'H0004' AND (E.Modifier_1 IN('EP', 'HQ', 'SC') OR E.Modifier_2 IN('EP', 'HQ', 'SC')	)	)
					OR (	E.Procedure_Code = 'H2011' AND (E.Modifier_1 IN('EP', 'ET', 'GT') OR E.Modifier_2 IN('EP', 'ET', 'GT')	)	)
					OR (	E.Procedure_Code = '90882' AND (E.Modifier_1 IN('EP', 'TS') OR E.Modifier_2 IN('EP', 'TS') )	)
		)

		
/* -------------------------------------------------------------------------------------------------------
820: OUTPATIENT MENTAL HEALTH: COMMUNITY PSYHCIATRIC SUPPORT AND TREATMENT

Community Psychiatric Support and Treatment (CPST): CPST services are goal-directed supports and 
solution-focused interventions intended to achieve identified goals or objectives as set forth in the 
child's treatment plan. Only services that pertain to kids (Age under 21 years) enrolled in HCBS should be 
reported under this category.
15 minutes
IF Provider_Specialty_Code = ‘839’ 
AND Procedure_Code = ‘H0036’ 
AND Procedure_Code_Modifier in (‘EP’, ‘HQ’, ‘SC’) then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 820
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '839'
AND		E.Procedure_Code = 'H0036' 
AND		(E.Modifier_1 IN('EP', 'HQ', 'SC') OR E.Modifier_2 IN('EP', 'HQ', 'SC'))

/* -------------------------------------------------------------------------------------------------------
830: OUTPATIENT MENTAL HEALTH: PYSCHOSOCIAL REHABILITATION

Psychosocial Rehabilitation (PSR). Behavioral Health services pertaining only to children (Age under 21 years) 
enrolled in HCBS should be reported under this category. 
15 minutes

IF Provider_Specialty_Code = ‘836’ 
AND Procedure_Code = ‘H2017’ 
AND Procedure_Code_Modifier in (‘EP’, ‘HQ’, ‘SC’) then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 830
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '836'
AND		E.Procedure_Code = 'H2017' 
AND		(E.Modifier_1 IN('EP', 'HQ', 'SC') OR E.Modifier_2 IN('EP', 'HQ', 'SC'))

--GOLD HIERARCHY:
UPDATE	E
SET		MMCORCostReportCategoryId = 
		CASE	WHEN NEWBORN = 1 THEN 1 				-- Inpatient Newborn Births (> = 1 THEN 0 >=1200g weight)
				WHEN LBW_NEWBORN = 1 THEN 2 			-- Inpatient Newborn Births – Low Birth Weight <1200g weight
				WHEN MATERNITY = 1 THEN 3 				-- Inpatient Maternity Delivery
				WHEN PYSCHSA = 1 THEN 4 				-- Inpatient Mental Health & Substance Abuse
				WHEN MEDSURG = 1 THEN 5 				-- Inpatient Medical Surgical
				WHEN HOSPICE = 1 THEN 6 				-- Hospice
				WHEN NH = 1 THEN 7 						-- Nursing Facility
				WHEN ER = 1 THEN 8						-- Emergency Room
				WHEN FAMILY_PLANNING = 1 THEN 9 		-- Family Planning
				WHEN PRENATAL_POSTPARTUM = 1 THEN 10	-- Prenatal/Postpartum
				WHEN AMBULATORY_SURGERY = 1 THEN 11		-- Ambulatory Surgery
				WHEN HH_AIDE = 1 THEN 12 				-- Home Health Care (Level 3: Home Home Health Care Aide)
				WHEN HH_MED_SOCIAL_SRVS = 1 THEN 13 	--  (Medical Social Services)Home Health Care
				WHEN HH_NURSING = 1 THEN 14 			--  (Nursing)Home Health Care
				WHEN HH_OT = 1 THEN 15 					--  (Occupational Therapy)Home Health Care
				WHEN HH_PT = 1 THEN 16 					--  (Physical Therapy)Home Health Care
				WHEN HH_RESP_THRPY = 1 THEN 17 			--  (Respiratory Therapy)Home Health Care
				WHEN HH_SPEECH = 1 THEN 18 				--  (Speech Therapy)Home Health Care
				WHEN HH_SOCIAL_EVIRON_SPPTS = 1 THEN 19	--  (Social and Environmental Supports)Home Health Care
				WHEN NUTRITION = 1 THEN 20 				--  (Nutrition)Home Health Care
				WHEN HH_SGN_LNG_ORAL_INTRPTER = 1 THEN 21 	--  (Sign Language/Oral Interpreter)Home Health care
				WHEN DENTAL = 1 THEN 22 				-- Dental
				WHEN PRIMARY_CARE = 1 THEN 23 			-- Primary Care
				WHEN PHYSICIAN_SPEC = 1 THEN 24 		-- Specialty Care
				WHEN DX_LAB_XRAY = 1 THEN 25 			-- Diagnostic Testing, Laboratory, X-Ray
				WHEN PERS = 1 THEN 26 					-- Personal Emergency Response System (PERS)
				WHEN DME = 1 THEN 27 					-- Durable Medical Equipment
				WHEN AUDIOLOGY = 1 THEN 28 				--  (Audiology and Hearing Aid Services)Other Professional
				WHEN ER_TRANS = 1 THEN 29 				-- Transportation - Emergent
				WHEN NON_ER_TRANS = 1 THEN 30 			-- Transportation – Non-Emergent
				WHEN OUTPATIENT_SUD = 1 THEN 31 		-- Outpatient SUD Treatment
				WHEN OUTPATIENT_MENTAL_HEALTH = 1 THEN 32 	-- Outpatient Mental Health
				WHEN RX = 1 THEN 33 					-- Pharmacy
				WHEN MEALS = 1 THEN 34 					--  (Home Delivered or Congregated Meals)Other Medical
				WHEN REHAB = 1 THEN 35 					-- Outpatient Physical Rehab/Therapy
				WHEN PODIATRY = 1 THEN 36				-- Foot Care
				WHEN VISION = 1 THEN 37					-- Vision Care Inc. Eyeglasses
				WHEN PERSONAL_CARE_LVL1 = 1 THEN 38		-- (Paraprofessional Services Level 1: Homemaker/Housekeeper)Personal Care
				WHEN PERSONAL_CARE_LVL2 = 1 THEN 39		-- (Paraprofessional Services Level 2: Personal Care)Personal Care
				WHEN ADULT_DAYCARE = 1 THEN 40			-- (Adult Day Health Care)Other Medical
				WHEN AIDS_ADULT_DAYCARE = 1 THEN 41		-- (AIDS Adult Day Health Care)Other Medical
				WHEN SOCIAL_DAYCARE = 1 THEN 42			-- (Social Day Care)Other Professional Services
				WHEN REN_DIALYSIS = 1 THEN 43			-- (Chronic Renal Dialysis)Other Medical
				WHEN OTHER_MEDICAL = 1 THEN 44			-- Other Medical
				WHEN OTHER_PROFESSIONAL = 1 THEN 45		-- Other Professional Services
				WHEN OTHER = 1 THEN 46					-- Other Outpatient Unclassified
				WHEN CDPAP_LVL1 = 1 THEN 47				-- (Consumer Directed Personal Care: Level 1)Personal Care
				WHEN CDPAP_LVL2 = 1 THEN 48				-- (Consumer Directed Personal Care: Level 2)Personal Care
				WHEN OUTPATIENT_HOSPICE = 1 THEN 49		-- Other Medical
				WHEN HCBS_Services = 1 THEN 50			-- Behavioral Health HCBS Services
				ELSE 0
		END
FROM	dbo.tblEncounters AS E
WHERE	E.MMCORCostReportCategoryId = 0

-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- 3: LINE LEVEL : REVENUE CODE
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================

/* -------------------------------------------------------------------------------------------------------
230: AMBULATORY SURGERY
Surgical services provided in hospital outpatient departments, and diagnostic and treatment centers 
(free standing clinics).
Per Visit
IF AMB_Surgery_Procedure = 1 OR ('0490' <= Revenue_Code <= '0499') then AMBULATORY_SURGERY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 230
,		AMBULATORY_SURGERY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.AMB_Surgery_Center = 1		
			OR E.Revenue_Code BETWEEN '0490' AND '0499'	)

/* -------------------------------------------------------------------------------------------------------
240: HOME HEALTH CARE: LEVEL 3 HOME HEALTH CARE AIDE

Level 3 (Home Health Aide): Level 1 and 2 plus health-related tasks (vital signs, transferring with hoyer 
lift, stable dressings, ostomy care, prepare meals for complex diets, maintenance exercise programs.
Per Hour

IF ('0570' <= Revenue_Code <= '0579') then HH_Aide = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 240
,		HH_Aide = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Revenue_Code BETWEEN '0570' AND '0579'

/* -------------------------------------------------------------------------------------------------------
250: HOME HEALTH CARE: MEDICAL SOCIAL SERVICES

Level 3 (Home Health Aide): Level 1 and 2 plus health-related tasks (vital signs, transferring with hoyer 
lift, stable dressings, ostomy care, prepare meals for complex diets, maintenance exercise programs.
Per Hour

if ('0560' <= Revenue_Code <= '0569')) then HH_MED_SOCIAL_SRVS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 250
,		HH_MED_SOCIAL_SRVS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Revenue_Code BETWEEN '0560' AND '0569'

/* -------------------------------------------------------------------------------------------------------
260: HOME HEALTH CARE: NURSING

Intermittent, part-time and continuous nursing services provided by RNs and LPNs in accordance with the 
Nurse Practice Act in the home.
Per Visit
IF ('0550' <= Revenue_Code <= '0559') then HH_NURSING = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 260
,		HH_NURSING = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Revenue_Code BETWEEN '0550' AND '0559'


/* -------------------------------------------------------------------------------------------------------
350: PRIMARY CARE

Services provided by primary care providers (as defined by the provider specialty codes listed below) in 
outpatient setting. 
Per Visit

IF Revenue_Code in ('0514', '0515', '0517', '0523', '0770', '0771', '0779') 
AND NOT (Prenatal_Postpartum DX1 – DX9) then PRIMARY_CARE = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 350
,		PRIMARY_CARE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Revenue_Code IN('0514', '0515', '0517', '0523', '0770', '0771', '0779')
AND		E.PRENATAL_POSTPARTUM <> 1


/* -------------------------------------------------------------------------------------------------------
370: DIAGNOSTIC TESTING, LABORATORY, X-RAY SERVICES

Medically necessary tests and procedures ordered by a qualified medical professional. This category includes 
outpatient laboratory, diagnostic radiology, diagnostic ultrasound, nuclear medicine, radiation oncology, and 
magnetic resonance imaging (MRI) services.
Per Test

IF ('0300' <= Revenue_Code <= '0329') OR Revenue_Code = '0341' 
OR ('0350' <= Revenue_Code <= '0359') 
OR ('0400' <= Revenue_Code <= '0409') OR ('0610' <= Revenue_Code <= '0619') 
OR ('0730' <= Revenue_Code <= '0749') OR ('0920' <= Revenue_Code <= '0929') 
then DX_LAB_XRAY = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 370
,		DX_LAB_XRAY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Revenue_Code BETWEEN '0300'AND '0329'
			OR E.Revenue_Code = '0341' 
			OR E.Revenue_Code BETWEEN '0350' AND '0359'
			OR E.Revenue_Code BETWEEN '0400' AND '0409'
			OR E.Revenue_Code BETWEEN '0610' AND '0619'
			OR E.Revenue_Code BETWEEN '0730' AND '0749'
			OR E.Revenue_Code BETWEEN '0920' AND '0929'	)

/* -------------------------------------------------------------------------------------------------------
400: AUDIOLOGY AND HEARING AID SERVICES

Audiology services include audiometric examination or testing, hearing aid evaluation, conformity evaluation 
and hearing aid prescription or recommendations if indicated. Hearing aid services include selecting, fitting 
and dispensing of hearing aids, hearing aid checks following dispensing and hearing aid repairs.

Per Unit

IF ('0470' <= Revenue_Code <= '0479') then AUDIOLOGY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 400
,		AUDIOLOGY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Revenue_Code BETWEEN '0470' AND '0479' 

/* -------------------------------------------------------------------------------------------------------
410: EMERGENCY TRANSPORTATION

Transportation as a result of an emergency condition. This category includes ambulance transportation, 
including air ambulance service for the purpose of obtaining emergency medical services. 
Per 1 Way

IF ('0540' <= Revenue_Code <= '0549') then ER_TRANS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 410
,		ER_TRANS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Revenue_Code BETWEEN '0540' AND '0549'

/* -------------------------------------------------------------------------------------------------------
450: OUTPATIENT REHABILITATION THERAPIES: PHYSICAL THERAPY, OCCUPATIONAL THERAPY, SPEECH THERAPY
Rehabilitation services in an outpatient setting provided by licensed and registered therapists for maximum 
reduction of physical disability and restoration or maintenance of the member to their best functional level. 
Report each time an enrollee receives therapy services regardless of the number of procedures or clinicians seen. 
This includes physical, occupational and speech therapies, but excludes mental health, drug and alcohol therapy.
Per Visit
IF ('0420' <= Revenue_Code <= '0449') 
OR ('0930' >= Revenue_Code <= '0939') 
OR ('0950' <= Revenue_Code <= '0959') 
OR ('0940' <= Revenue_Code <= '0943') 
OR ('0946' <= Revenue_Code <= '0949') then REHAB = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 450
,		REHAB = 1

FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Revenue_Code BETWEEN '0420' AND '0449'
			OR E.Revenue_Code BETWEEN '0930' AND '0939'
			OR E.Revenue_Code BETWEEN '0950' AND '0959'
			OR E.Revenue_Code BETWEEN '0940' AND '0943'
			OR E.Revenue_Code BETWEEN '0946' AND '0949'		)

UPDATE	E
SET		MMCORCostReportCategoryId = 
		CASE	WHEN NEWBORN = 1 THEN 1 				-- Inpatient Newborn Births (> = 1 THEN 0 >=1200g weight)
				WHEN LBW_NEWBORN = 1 THEN 2 			-- Inpatient Newborn Births – Low Birth Weight <1200g weight
				WHEN MATERNITY = 1 THEN 3 				-- Inpatient Maternity Delivery
				WHEN PYSCHSA = 1 THEN 4 				-- Inpatient Mental Health & Substance Abuse
				WHEN MEDSURG = 1 THEN 5 				-- Inpatient Medical Surgical
				WHEN HOSPICE = 1 THEN 6 				-- Hospice
				WHEN NH = 1 THEN 7 						-- Nursing Facility
				WHEN ER = 1 THEN 8						-- Emergency Room
				WHEN FAMILY_PLANNING = 1 THEN 9 		-- Family Planning
				WHEN PRENATAL_POSTPARTUM = 1 THEN 10	-- Prenatal/Postpartum
				WHEN AMBULATORY_SURGERY = 1 THEN 11		-- Ambulatory Surgery
				WHEN HH_AIDE = 1 THEN 12 				-- Home Health Care (Level 3: Home Home Health Care Aide)
				WHEN HH_MED_SOCIAL_SRVS = 1 THEN 13 	--  (Medical Social Services)Home Health Care
				WHEN HH_NURSING = 1 THEN 14 			--  (Nursing)Home Health Care
				WHEN HH_OT = 1 THEN 15 					--  (Occupational Therapy)Home Health Care
				WHEN HH_PT = 1 THEN 16 					--  (Physical Therapy)Home Health Care
				WHEN HH_RESP_THRPY = 1 THEN 17 			--  (Respiratory Therapy)Home Health Care
				WHEN HH_SPEECH = 1 THEN 18 				--  (Speech Therapy)Home Health Care
				WHEN HH_SOCIAL_EVIRON_SPPTS = 1 THEN 19	--  (Social and Environmental Supports)Home Health Care
				WHEN NUTRITION = 1 THEN 20 				--  (Nutrition)Home Health Care
				WHEN HH_SGN_LNG_ORAL_INTRPTER = 1 THEN 21 	--  (Sign Language/Oral Interpreter)Home Health care
				WHEN DENTAL = 1 THEN 22 				-- Dental
				WHEN PRIMARY_CARE = 1 THEN 23 			-- Primary Care
				WHEN PHYSICIAN_SPEC = 1 THEN 24 		-- Specialty Care
				WHEN DX_LAB_XRAY = 1 THEN 25 			-- Diagnostic Testing, Laboratory, X-Ray
				WHEN PERS = 1 THEN 26 					-- Personal Emergency Response System (PERS)
				WHEN DME = 1 THEN 27 					-- Durable Medical Equipment
				WHEN AUDIOLOGY = 1 THEN 28 				--  (Audiology and Hearing Aid Services)Other Professional
				WHEN ER_TRANS = 1 THEN 29 				-- Transportation - Emergent
				WHEN NON_ER_TRANS = 1 THEN 30 			-- Transportation – Non-Emergent
				WHEN OUTPATIENT_SUD = 1 THEN 31 		-- Outpatient SUD Treatment
				WHEN OUTPATIENT_MENTAL_HEALTH = 1 THEN 32 	-- Outpatient Mental Health
				WHEN RX = 1 THEN 33 					-- Pharmacy
				WHEN MEALS = 1 THEN 34 					--  (Home Delivered or Congregated Meals)Other Medical
				WHEN REHAB = 1 THEN 35 					-- Outpatient Physical Rehab/Therapy
				WHEN PODIATRY = 1 THEN 36				-- Foot Care
				WHEN VISION = 1 THEN 37					-- Vision Care Inc. Eyeglasses
				WHEN PERSONAL_CARE_LVL1 = 1 THEN 38		-- (Paraprofessional Services Level 1: Homemaker/Housekeeper)Personal Care
				WHEN PERSONAL_CARE_LVL2 = 1 THEN 39		-- (Paraprofessional Services Level 2: Personal Care)Personal Care
				WHEN ADULT_DAYCARE = 1 THEN 40			-- (Adult Day Health Care)Other Medical
				WHEN AIDS_ADULT_DAYCARE = 1 THEN 41		-- (AIDS Adult Day Health Care)Other Medical
				WHEN SOCIAL_DAYCARE = 1 THEN 42			-- (Social Day Care)Other Professional Services
				WHEN REN_DIALYSIS = 1 THEN 43			-- (Chronic Renal Dialysis)Other Medical
				WHEN OTHER_MEDICAL = 1 THEN 44			-- Other Medical
				WHEN OTHER_PROFESSIONAL = 1 THEN 45		-- Other Professional Services
				WHEN OTHER = 1 THEN 46					-- Other Outpatient Unclassified
				WHEN CDPAP_LVL1 = 1 THEN 47				-- (Consumer Directed Personal Care: Level 1)Personal Care
				WHEN CDPAP_LVL2 = 1 THEN 48				-- (Consumer Directed Personal Care: Level 2)Personal Care
				WHEN OUTPATIENT_HOSPICE = 1 THEN 49		-- Other Medical
				WHEN HCBS_Services = 1 THEN 50			-- Behavioral Health HCBS Services
				ELSE 0
		END
FROM	dbo.tblEncounters AS E
WHERE	E.MMCORCostReportCategoryId = 0

-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- 4. HEADER LEVEL– Provider Specialty Code
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================

/* -------------------------------------------------------------------------------------------------------
100: HOSPICE

Inpatient Hospice
Per Day

IF Provider_Specialty_Code = '669' then HOSPICE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 100
,		HOSPICE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '669'

/*
230: AMBULATORY SURGERY

Surgical services provided in hospital outpatient departments, and diagnostic and treatment centers 
(free standing clinics).
Per Visit

IF AMB_Surgery_Center = 1 OR Provider_Specialty_Code in ('993','997') then AMBULATORY_SURGERY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 230
,		AMBULATORY_SURGERY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.AMB_Surgery_Center = 1		
			OR E.Provider_Specialty_Code in ('993','997') )

/* -------------------------------------------------------------------------------------------------------
240: HOME HEALTH CARE: LEVEL 3 HOME HEALTH CARE AIDE

Level 3 (Home Health Aide): Level 1 and 2 plus health-related tasks (vital signs, transferring with hoyer 
lift, stable dressings, ostomy care, prepare meals for complex diets, maintenance exercise programs.
Per Hour

IF Provider_Specialty_Code ='668' then HH_AIDE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 240
,		HH_Aide = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '668'

/* -------------------------------------------------------------------------------------------------------
250: HOME HEALTH CARE: MEDICAL SOCIAL SERVICES

Level 3 (Home Health Aide): Level 1 and 2 plus health-related tasks (vital signs, transferring with hoyer 
lift, stable dressings, ostomy care, prepare meals for complex diets, maintenance exercise programs.
Per Hour

if Category_of_Service in ('01', '15') AND Provider_Specialty_Code = '781' then HH_MED_SOCIAL_SRVS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 250
,		HH_MED_SOCIAL_SRVS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Category_of_Service in ('01', '15') 
AND		E.Provider_Specialty_Code = '781'

/* -------------------------------------------------------------------------------------------------------
260: HOME HEALTH CARE: NURSING

Intermittent, part-time and continuous nursing services provided by RNs and LPNs in accordance with the 
Nurse Practice Act in the home.
Per Visit
IF Provider_Specialty_Code = '680' then HH_NURSING = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 260
,		HH_NURSING = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '680'

/* -------------------------------------------------------------------------------------------------------
270: HOME HEALTH CARE: OCCUPATIONAL THERAPY

Rehabilitation services by a licensed and registered occupational therapist for maximum reduction of 
physical disability and restoration or maintenance of member to their best functional level rendered 
in the home.
Per Visit
IF Category_of_Service in ('01', '15') AND Provider_Specialty_Code = '301' then HH_OT = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 270
,		HH_OT = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Category_of_Service IN('01', '15') 
AND		E.Provider_Specialty_Code = '301' 

/* -------------------------------------------------------------------------------------------------------
280: HOME HEALTH CARE: PHYSICAL THERAPY

Rehabilitation services provided in the home by a licensed and registered physical therapist for maximum 
reduction of physical disability and restoration or maintenance of member to their best functional level.
Per Visit
IF Category_of_Service in ('01', '15') AND Provider_Specialty_Code = '300' then HH_PT = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 280
,		HH_PT = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND	 	E.Category_of_Service IN('01', '15') 
AND		E.Provider_Specialty_Code = '300' 

/* -------------------------------------------------------------------------------------------------------
290: HOME HEALTH CARE: RESPIRATORY THERAPY

Performance of preventive, maintenance and restorative airway related techniques and procedures provided 
by a qualified respiratory therapist in the home.
Per Visit
IF Category_of_Service IN ('01', '15') AND Provider_Specialty_Code = '674' then HH_RESP_THRPY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 290
,		HH_RESP_THRPY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Category_of_Service IN('01','15')
AND		E.Provider_Specialty_Code = '674'

/* -------------------------------------------------------------------------------------------------------
300: HOME HEALTH CARE: SPEECH THERAPY

Rehabilitation services provided by a licensed and registered speech-language pathologist for maximum 
reduction of physical disability and restoration or maintenance of member to their best functional level 
rendered in the home.
Per Visit
IF Category_of_Service in ('01', '15') AND Provider_Specialty_Code = '302' then HH_SPEECH = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 300
,		HH_SPEECH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Category_of_Service IN('01','15')
AND		E.Provider_Specialty_Code = '302'

/* -------------------------------------------------------------------------------------------------------
310: HOME HEALTH CARE: SOCIAL AND ENVIRONMENTAL SUPPORTS

Services and items that support the medical need of the member, such as home maintenance tasks and housing 
improvements
Per Service
IF Category_of_Service in ('01', '15') AND Provider_Specialty_Code = '661' then SOCIAL_EVIRON_SPPTS = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 310
,		HH_SOCIAL_EVIRON_SPPTS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Category_of_Service IN('01', '15')  
AND		E.Provider_Specialty_Code = '661' 

/* -------------------------------------------------------------------------------------------------------
320 HOME HEALTH CARE: NUTRITIONAL COUNSELING

Assessment of nutritional needs and food patterns, planning for the provision of food and drink, providing 
nutritional education and counseling to patient and family by qualified nutritionist/dietician.
Per Visit

IF Category_of_Service in ('01', '15') AND Provider_Specialty_Code = '909' then NUTRITION = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 320
,		NUTRITION = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Category_of_Service IN('01', '15')  
AND		E.Provider_Specialty_Code = '909' 

/* -------------------------------------------------------------------------------------------------------
350: PRIMARY CARE

Services provided by primary care providers (as defined by the provider specialty codes listed below) in 
outpatient setting. 
Per Visit

IF Provider_Specialty_Code in ('050', '055', '056', '058', '060', '089', '092', '150', '182', '184', '254'
, '306', '324', '601', '602', '620', '776', '779', '782', '904', '905', '908', '909', '914', '936', '990', '991') 
AND NOT (Prenatal_Postpartum DX1 – DX9) then PRIMARY_CARE = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 350
,		PRIMARY_CARE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('050', '055', '056', '058', '060', '089', '092', '150', '182', '184', '254'
, '306', '324', '601', '602', '620', '776', '779', '782', '904', '905', '908', '909', '914', '936', '990', '991') 
AND		E.PRENATAL_POSTPARTUM <> 1

/* -------------------------------------------------------------------------------------------------------
360: PHYSICIAN SPECIALIST

Services provided by specialists (as defined by the physician specialty codes listed below) in outpatient 
setting for the treatment of a particular medical condition. A single visit may include multiple specialist 
encounters. For example, a patient may visit a medical group and see a primary care provider and be referred 
to two specialists in the same medical group for two different medical conditions; although only one threshold 
visit occurred, a total of three encounters should be counted (one primary care and two specialists).
Per Visit

IF Provider_Specialty_Code IN('010', '100', '101', '110', '111', '112', '113', '114', '120', '121', '137', '141', 
'143', '149', '151', '152', '153', '154', '155', '156', '157', '161', '163', '164', '165', '166', '167', '170', 
'186', '188', '190', '193','194', '199', '020', '210', '211', '220', '230', '231', '241', '242', '245', '249', '250', 
'030', '303', '305', '308', '321', '325', '332', '355', '356', '358', '040', '041', '059', '600', '603', '061', '062', 
'063', '630', '064', '065', '650', '651', '652', '066', '067', '068', '069', '070', '071', '072', '073', '730', '741', 
'075', '076', '775', '799', '811', '902', '903', '915', '916', '917', '925', '926', '927', '928', '929', '093', '930', 
'931', '932', '933', '934', '935', '937', '938', '939', '940', '941', '942', '943', '944', '095', '950', '951', '952', 
'953', '954', '955', '956', '958', '960', '961', '962', '965', '966','977', '979', '980', '981', '983', '995', '996')
AND NOT (Prenatal_Postpartum DX1 – DX9)

*/
UPDATE	E
SET		ServiceTypeCode = 360
,		PHYSICIAN_SPEC = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('010', '100', '101', '110', '111', '112', '113', '114', '120', '121', '137', '141', 
'143', '149', '151', '152', '153', '154', '155', '156', '157', '161', '163', '164', '165', '166', '167', '170', 
'186', '188', '190', '193','194', '199', '020', '210', '211', '220', '230', '231', '241', '242', '245', '249', '250', 
'030', '303', '305', '308', '321', '325', '332', '355', '356', '358', '040', '041', '059', '600', '603', '061', '062', 
'063', '630', '064', '065', '650', '651', '652', '066', '067', '068', '069', '070', '071', '072', '073', '730', '741', 
'075', '076', '775', '799', '811', '902', '903', '915', '916', '917', '925', '926', '927', '928', '929', '093', '930', 
'931', '932', '933', '934', '935', '937', '938', '939', '940', '941', '942', '943', '944', '095', '950', '951', '952', 
'953', '954', '955', '956', '958', '960', '961', '962', '965', '966','977', '979', '980', '981', '983', '995', '996')
AND			E.PRENATAL_POSTPARTUM <> 1


/* -------------------------------------------------------------------------------------------------------
370: DIAGNOSTIC TESTING, LABORATORY, X-RAY SERVICES

Medically necessary tests and procedures ordered by a qualified medical professional. This category includes 
outpatient laboratory, diagnostic radiology, diagnostic ultrasound, nuclear medicine, radiation oncology, and 
magnetic resonance imaging (MRI) services.
Per Test

IF Provider_Specialty_Code IN('074', '080', '081', '127', '128', '130', '131', '135', '136'
, '138', '139', '140', '142', '146', '148', '189', ,'201', '202', '205', '206', '207', '208', '244', '246', '411', '412'
, '413', '414', '415', '416', '419', '420', '421', '422', '423', '427', '430', '431', '432', '435', '436', '438','439'
, '440', '441', '442', '450', '451', '460', '463', '470', '481', '482', '483', '484', '485', '486', '491', '510', '511'
, '512', '513', '514', '515', '516', '518', '521', '523', '524', '531', '540', '550', '551', '552', '553', '560', '571'
, '572', '573', '599', '994', '998') then DX_LAB_XRAY = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 370
,		DX_LAB_XRAY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Provider_Specialty_Code IN('074', '080', '081', '127', '128', '130', '131', '135', '136'
				, '138', '139', '140', '142', '146', '148', '189', '201', '202', '205', '206', '207', '208', '244', '246', '411', '412'
				, '413', '414', '415', '416', '419', '420', '421', '422', '423', '427', '430', '431', '432', '435', '436', '438', '439'
				, '440', '441', '442', '450', '451', '460', '463', '470', '481', '482', '483', '484', '485', '486', '491', '510', '511'
				, '512', '513', '514', '515', '516', '518', '521', '523', '524', '531', '540', '550', '551', '552', '553', '560', '571'
				, '572', '573', '599', '994', '998')	)


/* -------------------------------------------------------------------------------------------------------
390: DME, MEDICAL/SURGICAL SUPPLIES, PROSTHESES AND ORTHOTICS

DME: Durable medical equipment (DME) are devices and equipment, other than prosthetic or orthotic appliances, 
which have been ordered by a practitioner in the treatment of a specific medical condition. DME includes 
hearing aids, ear molds, batteries, special fittings and replacement parts.

MEDICAL/SURGICAL SUPPLIES: Medical/surgical supplies are items for medical use other than drugs, durable 
medical equipment, prosthetics and orthotic appliances, or orthopedic footwear, which treat a specific 
medical condition and are usually consumable, non-reusable, disposable, for a specific purpose and generally 
have no salvageable value. These would include enteral and parenteral formulas.

PROSTHESES: Prosthetic appliances and devices replace any missing part of the body.

ORTHOTICS: Orthotic appliances and devices are used to support a weak or deformed body member or to restrict 
or eliminate motion in a diseased or injured part of the body. Orthopedic footwear are shoes, shoe modifications 
or shoe additions which are used to correct, accommodate or prevent a physical deformity or range of motion 
malfunction in a diseased or injured part of the ankle or foot; to support a weak or deformed structure of the 
ankle or foot or to form an integral part of a brace.
Per Unit

IF Provider_Specialty_Code IN('307','969') then DME = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 390
,		DME = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('307','969')

/* -------------------------------------------------------------------------------------------------------
400: AUDIOLOGY AND HEARING AID SERVICES

Audiology services include audiometric examination or testing, hearing aid evaluation, conformity evaluation 
and hearing aid prescription or recommendations if indicated. Hearing aid services include selecting, fitting 
and dispensing of hearing aids, hearing aid checks following dispensing and hearing aid repairs.

Per Unit

IF Provider_Specialty_Code = '640' then AUDIOLOGY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 400
,		AUDIOLOGY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '640'
 
/* -------------------------------------------------------------------------------------------------------
410: EMERGENCY TRANSPORTATION

Transportation as a result of an emergency condition. This category includes ambulance transportation, 
including air ambulance service for the purpose of obtaining emergency medical services. 
Per 1 Way

IF Provider_Specialty_Code = '670' then ER_TRANS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 410
,		ER_TRANS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '670'	
/* -------------------------------------------------------------------------------------------------------
420: NON-EMERGENCY TRANSPORTATION

Transportation provided at the appropriate level for an enrollee to receive medically necessary services. 
This category includes transportation that is essential for an enrollee to obtain medically necessary care 
such as taxicab
Per 1 Way

IF Provider_Specialty_Code IN('671', '740') then NON_ER_TRANS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 420
,		NON_ER_TRANS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('671','740')	

/* -------------------------------------------------------------------------------------------------------
440: HOME DELIVERED OR CONGREGATE MEALS
Home delivered meals are meals delivered to a member's home. Congregate meals are meals in a group 
setting such as a senior center. 
Per Meal
IF Provider_Specialty_Code = '667' then MEALS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 440
,		MEALS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '667'

/* -------------------------------------------------------------------------------------------------------
450: OUTPATIENT REHABILITATION THERAPIES: PHYSICAL THERAPY, OCCUPATIONAL THERAPY, SPEECH THERAPY
Rehabilitation services in an outpatient setting provided by licensed and registered therapists for maximum 
reduction of physical disability and restoration or maintenance of the member to their best functional level. 
Report each time an enrollee receives therapy services regardless of the number of procedures or clinicians seen. 
This includes physical, occupational and speech therapies, but excludes mental health, drug and alcohol therapy.
Per Visit
IF Provider_Specialty_Code IN('160', '162', '183', '300', '301', '302', '674', '920', '921', '923', '924', '967', '968')) then do;
then REHAB = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 450
,		REHAB = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('160', '162', '183', '300', '301', '302', '674', '920', '921', '923', '924', '967', '968')		


/* -------------------------------------------------------------------------------------------------------
460: PODIATRY
Description
Podiatry means services by a podiatrist which must include routine foot care when the member's physical 
condition poses a hazard due to the presence of localized illness, injury or symptoms involving the foot, 
or when they are performed as a necessary and integral part of medical care such as diagnosis and treatment 
of corns, calluses, the trimming of nails. Other hygienic care is not covered in the absence of a pathological 
condition. 
Per Visit

IF Provider_Specialty_Code IN('778', '918') then PODIATRY = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 460
,		PODIATRY = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('778', '918')

/* -------------------------------------------------------------------------------------------------------
480: PARAPROFESSIONAL SERVICES: Level 1 – HOMEMAKER / HOUSEKEEPER
Level 1: Performance of nutritional and environmental support function (housekeeping, preparing simple meals). 
Includes assessments of care and supervision.
Per Unit
IF Provider_Specialty = '672' then PERSONAL_CARE_LVL1 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 480
,		PERSONAL_CARE_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '672'

/* -------------------------------------------------------------------------------------------------------
480: PARAPROFESSIONAL SERVICES: Level 1 – HOMEMAKER / HOUSEKEEPER
Level 1: Performance of nutritional and environmental support function (housekeeping, preparing simple meals). 
Includes assessments of care and supervision.
Per Unit
Based only on Procedure Code, Paraprofessional Services Level 1 supersedes Level 2.
IF Procedure_Code = 'S5130' AND Procedure_Code_Modifier in ('U1', 'U2', 'U3', 'TV') then PERSONAL_CARE_LVL1 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 480
,		PERSONAL_CARE_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Procedure_Code = 'S5130'
AND		(	E.Modifier_1 IN('U1', 'U2', 'U3', 'TV') OR E.Modifier_2 IN('U1', 'U2', 'U3', 'TV')	)

/* -------------------------------------------------------------------------------------------------------
490: PARAPROFESSIONAL SERVICES: LEVEL 2 – PERSONAL CARE

Level 2: Level 1 plus personal care functions (bathing, grooming, dressing, toileting, walking, 
transferring, and feeding)
Paraprofessional Services – Level 1 supersedes Level 2 based on Procedure Code only. 
Per Hour

IF Provider_Specialty_Code = '673' then PERSONAL_CARE_LVL2 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 480
,		PERSONAL_CARE_LVL2 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '673'

/* -------------------------------------------------------------------------------------------------------
500: ADULT DAY HEALTH CARE
Care and services provided in a residential health care facility or approved extension site under the 
medical direction of a physician to a person who is functionally impaired, not homebound and who requires 
certain preventative, diagnostic, therapeutic, rehabilitative or palliative items or services.
Per Visit
IF Provider_Specialty_Code = '664' then ADULT_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 500
,		ADULT_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '664'
		
/* -------------------------------------------------------------------------------------------------------
510: AIDS ADULT DAY HEALTH CARE
Care and services provided in a residential health care facility or approved Extension site under the medical 
direction of a physician to a person who is functionally impaired, not homebound and who requires certain 
preventative, diagnostic, therapeutic, rehabilitative or palliative items or services
Per Visit
IF Provider_Specialty_Code = '355' 
IF Procedure_Code in 'S5100', 'S5101', 'S5102', 'S5105' then AIDS_ADULT_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 510
,		AIDS_ADULT_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Provider_Specialty_Code = '355'
			OR E.Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105')	)

/* -------------------------------------------------------------------------------------------------------
520: SOCIAL DAY CARE

Structured, comprehensive program which provides functionally impaired individuals with socialization, 
supervision and monitoring, personal care, and nutrition in a protective setting during any part of the day, 
but less than a 24-hour period.
Per Visit

IF Provider_Specialty_Code = '662' 
IF Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105') then SOCIAL_DAYCARE = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 520
,		SOCIAL_DAYCARE = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Provider_Specialty_Code = '662'
			OR E.Procedure_Code IN('S5100', 'S5101', 'S5102', 'S5105')	)

/* -------------------------------------------------------------------------------------------------------
530: CHRONIC RENAL DIALYSIS

Services provided by a renal dialysis center.
Per Visit

IF Provider_Specialty_Code = '913' then REN_DIALYSIS = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 530
,		REN_DIALYSIS = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '913'

/* -------------------------------------------------------------------------------------------------------
540: OTHER MEDICAL

Medical services under plan arrangement, which are not appropriately assignable to the medical categories defined.
Per Visit

IF Provider_Specialty_Code IN('661', '999') OTHER_MEDICAL = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 540
,		OTHER_MEDICAL = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('661','999')

/* -------------------------------------------------------------------------------------------------------
550: OTHER PROFESSIONAL SERVICES

Services by non-physician providers engaged in the delivery of covered medical services that cannot be appropriately reported elseWHERE	MMCORCostReportCategoryId = 0
AND	.
Private Duty Nursing provided by an independent practitioner should be reported under Home Health Care.
Per Visit

IF Provider_Specialty_Code IN('400', '781') then OTHER_PROFESSIONAL = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 560
,		OTHER_PROFESSIONAL = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('400','781')

/* -------------------------------------------------------------------------------------------------------
570: CONSUMER DIRECTED PERSONAL ASSISTANT LEVEL I

Level I: Under the supervision of consumer, the Consumer Directed Personal Assistant performs all necessary 
personal care, home health and nursing tasks. 
Per Unit

IF Provider_Specialty_Code = '675'  then CDPAP_LVL1 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 570
,		CDPAP_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '675'

/* -------------------------------------------------------------------------------------------------------
580: CONSUMER DIRECTED PERSONAL ASSISTANT LEVEL 2

Level 2: Under the supervision of the consumer, the live-in Consumer Directed Personal Assistant performs 
all necessary personal care, home health and nursing tasks. 
Per Hour

IF Provider_Specialty_Code = '676'  then CDPAP_LVL2 = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 580
,		CDPAP_LVL1 = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '676'


/* -------------------------------------------------------------------------------------------------------
590: OUTPATIENT SERVICES: HEALTH HOMES - ADULT

Report all Health Home costs and utilization under this category of service. Health
Homes designated to serve adults must bill at the adult rate.
Per Visit Administrative

IF Provider_Specialty_Code = '371'  then HEALTH_HOMES = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 590
,		HEALTH_HOMES = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '371' 

/* -------------------------------------------------------------------------------------------------------
600: OUTPATIENT SERVICES: HEALTH HOMES – CHILD

Report all health comes costs and utilization under this category of service. Only Health Homes designated 
to serve children may bill at children's rate. Health Homes that enroll children but are not designated for 
children must bill at the adult rate.
Per Visit
IF Provider_Specialty_Code IN('371')  then HEALTH_HOMES = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 600
,		HEALTH_HOMES = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '371'


/* -------------------------------------------------------------------------------------------------------
620: DOULA SERVICES

A doula is a non-medical birth coach who assists a woman during the prenatal period, labor, delivery, 
and post childbirth.
The Medicaid doula pilot will be implemented through a phased-in approach in order to ensure access to this 
new benefit. Phase 1 of the pilot will launch in Erie County. Medicaid eligible pregnant women who reside 
in the selected zip codes (Erie) would be eligible to receive doula services.
Per Visit

IF Provider_Specialty_Code = '755' then OTHER_MEDICAL = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 620
,		OTHER_MEDICAL = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '755'

/* -------------------------------------------------------------------------------------------------------
630: OUTPATIENT SUD: OUTPATIENT SUD CLINIC

Report all outpatient costs and utilization under this category of service Unit of Measurement
Per Visit

IF Provider_Specialty_Code IN('984','986') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 630
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('984', '986')

/* -------------------------------------------------------------------------------------------------------
640: OUTPATIENT SUD: OUTPATIENT SUD REHABILITATION

Report all outpatient rehabilitation costs and utilization under this category of service
Per Visit
IF Provider_Specialty_Code = '987' then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 640
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '987'

/* -------------------------------------------------------------------------------------------------------
650: OUTPATIENT SUD: OUTPATIENT SUD OPIATE TREATMENT PROGRAM

Report all outpatient opiate treatment program costs and utilization under this category of service.
Per Visit

IF Provider_Specialty_Code = ('751', '922', '321') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 650
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('751', '922', '321')

/* -------------------------------------------------------------------------------------------------------
660: OUTPATIENT SUD: OUTPATIENT SUD INTEGRATED OPIATE TREATMENT PROGRAM

Report all outpatient opiate treatment program costs and utilization under this category of service
Per Visit

IF Provider_Specialty IN(751') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 660
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code  = '751'

/* -------------------------------------------------------------------------------------------------------
670: OUTPATIENT SUD: OUTPATIENT SUD INTEGRATED CLINIC

Report all outpatient costs and utilization under this category of service.
Per Visit

IF Provider_Specialty_Code = '984' then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 670
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code  = '984'

/* -------------------------------------------------------------------------------------------------------
680: OUTPATIENT SUD: OUTPATIENT SUD DETOXIFICATION

Report all outpatient detoxification costs and utilization under this category of service 
Per Visit

IF Provider_Specialty_Code IN('357', '989') then  OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 680
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code  IN('357','989')


/* -------------------------------------------------------------------------------------------------------
690: OUTPATIENT SUD: OFFICE-BASED OUTPATIENT SUD

Report all outpatient costs and utilization under this category of service.
Per Visit

IF Provider_Specialty_Code IN('198', '282') then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 690
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('198','282')

/* -------------------------------------------------------------------------------------------------------
700: OUTPATIENT SUD: OTHER SUD OUTPATIENT SERVICES
Report all outpatient detoxification costs and utilization under this category of service.
Per Visit

IF Provider_Specialty_Code = '749' then OUTPATIENT_SUD = 1;

*/
UPDATE	E
SET		ServiceTypeCode = 700
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code = '749'

/* -------------------------------------------------------------------------------------------------------
710: OUTPATIENT MENTAL HEALTH: OFFICE-BASED MENTAL HEALTH SERVICES

This category includes services provided by psychologists, psychiatrists and other mental health providers. 
Report each time a patient receives mental health services regardless of the number of procedures or 
clinicians seen.
Per Visit
IF Provider_Specialty_Code IN('057', '187'. '191', '192', '195', '196', '197', '281', '283', '320', '328', 
'331', '780', '945', '946', '947', '948', '963', '964') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 710
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('057', '187', '191', '192', '195', '196', '197', '281', '283', '320', '328', 
										'331', '780', '945', '946', '947', '948', '963', '964') 

/* -------------------------------------------------------------------------------------------------------
720: OUTPATIENT MENTAL HEALTH: OUTPATIENT MENTAL HEALTH CLINIC

Services provided in OMH-licensed free-standing and hospital-based clinics; voluntary, county (LGU), and state-operated. 
Per Visit (procedure-based)
IF Provider_Specialty_Code IN('310','311',315',316',971',974') then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 720
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Provider_Specialty_Code IN('310','311','315','316','971','974') 

UPDATE	E
SET		MMCORCostReportCategoryId = 
		CASE	WHEN NEWBORN = 1 THEN 1 				-- Inpatient Newborn Births (> = 1 THEN 0 >=1200g weight)
				WHEN LBW_NEWBORN = 1 THEN 2 			-- Inpatient Newborn Births – Low Birth Weight <1200g weight
				WHEN MATERNITY = 1 THEN 3 				-- Inpatient Maternity Delivery
				WHEN PYSCHSA = 1 THEN 4 				-- Inpatient Mental Health & Substance Abuse
				WHEN MEDSURG = 1 THEN 5 				-- Inpatient Medical Surgical
				WHEN HOSPICE = 1 THEN 6 				-- Hospice
				WHEN NH = 1 THEN 7 						-- Nursing Facility
				WHEN ER = 1 THEN 8						-- Emergency Room
				WHEN FAMILY_PLANNING = 1 THEN 9 		-- Family Planning
				WHEN PRENATAL_POSTPARTUM = 1 THEN 10	-- Prenatal/Postpartum
				WHEN AMBULATORY_SURGERY = 1 THEN 11		-- Ambulatory Surgery
				WHEN HH_AIDE = 1 THEN 12 				-- Home Health Care (Level 3: Home Home Health Care Aide)
				WHEN HH_MED_SOCIAL_SRVS = 1 THEN 13 	--  (Medical Social Services)Home Health Care
				WHEN HH_NURSING = 1 THEN 14 			--  (Nursing)Home Health Care
				WHEN HH_OT = 1 THEN 15 					--  (Occupational Therapy)Home Health Care
				WHEN HH_PT = 1 THEN 16 					--  (Physical Therapy)Home Health Care
				WHEN HH_RESP_THRPY = 1 THEN 17 			--  (Respiratory Therapy)Home Health Care
				WHEN HH_SPEECH = 1 THEN 18 				--  (Speech Therapy)Home Health Care
				WHEN HH_SOCIAL_EVIRON_SPPTS = 1 THEN 19	--  (Social and Environmental Supports)Home Health Care
				WHEN NUTRITION = 1 THEN 20 				--  (Nutrition)Home Health Care
				WHEN HH_SGN_LNG_ORAL_INTRPTER = 1 THEN 21 	--  (Sign Language/Oral Interpreter)Home Health care
				WHEN DENTAL = 1 THEN 22 				-- Dental
				WHEN PRIMARY_CARE = 1 THEN 23 			-- Primary Care
				WHEN PHYSICIAN_SPEC = 1 THEN 24 		-- Specialty Care
				WHEN DX_LAB_XRAY = 1 THEN 25 			-- Diagnostic Testing, Laboratory, X-Ray
				WHEN PERS = 1 THEN 26 					-- Personal Emergency Response System (PERS)
				WHEN DME = 1 THEN 27 					-- Durable Medical Equipment
				WHEN AUDIOLOGY = 1 THEN 28 				--  (Audiology and Hearing Aid Services)Other Professional
				WHEN ER_TRANS = 1 THEN 29 				-- Transportation - Emergent
				WHEN NON_ER_TRANS = 1 THEN 30 			-- Transportation – Non-Emergent
				WHEN OUTPATIENT_SUD = 1 THEN 31 		-- Outpatient SUD Treatment
				WHEN OUTPATIENT_MENTAL_HEALTH = 1 THEN 32 	-- Outpatient Mental Health
				WHEN RX = 1 THEN 33 					-- Pharmacy
				WHEN MEALS = 1 THEN 34 					--  (Home Delivered or Congregated Meals)Other Medical
				WHEN REHAB = 1 THEN 35 					-- Outpatient Physical Rehab/Therapy
				WHEN PODIATRY = 1 THEN 36				-- Foot Care
				WHEN VISION = 1 THEN 37					-- Vision Care Inc. Eyeglasses
				WHEN PERSONAL_CARE_LVL1 = 1 THEN 38		-- (Paraprofessional Services Level 1: Homemaker/Housekeeper)Personal Care
				WHEN PERSONAL_CARE_LVL2 = 1 THEN 39		-- (Paraprofessional Services Level 2: Personal Care)Personal Care
				WHEN ADULT_DAYCARE = 1 THEN 40			-- (Adult Day Health Care)Other Medical
				WHEN AIDS_ADULT_DAYCARE = 1 THEN 41		-- (AIDS Adult Day Health Care)Other Medical
				WHEN SOCIAL_DAYCARE = 1 THEN 42			-- (Social Day Care)Other Professional Services
				WHEN REN_DIALYSIS = 1 THEN 43			-- (Chronic Renal Dialysis)Other Medical
				WHEN OTHER_MEDICAL = 1 THEN 44			-- Other Medical
				WHEN OTHER_PROFESSIONAL = 1 THEN 45		-- Other Professional Services
				WHEN OTHER = 1 THEN 46					-- Other Outpatient Unclassified
				WHEN CDPAP_LVL1 = 1 THEN 47				-- (Consumer Directed Personal Care: Level 1)Personal Care
				WHEN CDPAP_LVL2 = 1 THEN 48				-- (Consumer Directed Personal Care: Level 2)Personal Care
				WHEN OUTPATIENT_HOSPICE = 1 THEN 49		-- Other Medical
				WHEN HCBS_Services = 1 THEN 50			-- Behavioral Health HCBS Services
				ELSE 0
		END
FROM	dbo.tblEncounters AS E
WHERE	E.MMCORCostReportCategoryId = 0

-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- 5. HEADER LEVEL– Primary Diagnosis Code
-- ==================================================================================================================================================
-- ==================================================================================================================================================
-- ==================================================================================================================================================

/* -------------------------------------------------------------------------------------------------------
220: PRENATAL/POSTPARTUM CARE

Physician or Clinic services with a pregnancy related diagnosis or procedure code. Do not include 
laboratory and diagnostic testing procedures with pregnancy-related diagnosis.
Per Visit
*/
UPDATE	E
SET		ServiceTypeCode = 220
,		PRENATAL_POSTPARTUM = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		ISNULL(E.DIAG_LABS,0) <> 1
AND		E.Primary_Dx_Code IN('O021', 'O080', 'O0090', 'O0933', 'O09219', 'O09292', 'O09293', 'O133', 'O10012', 'O10013'
			, 'O26613' ,'O26849', 'O26841', 'O26842', 'O26843', 'O24111', 'O24112', 'O24410' ,'O24419', 'O283', 'O0010', 'O034'
			, 'O039', 'O30009', 'O30001', 'O30002', 'O30003', 'O30042' ,'O30043', 'O30109', 'O30102', 'O30103', 'O30101'
			, 'O30209', 'O30201', 'O30202', 'O30203', 'O3110X0', 'O3131X0', 'O3132X0', 'O3133X0', 'O30809', 'O30801'
			, 'O30802', 'O30803', 'O318X10', 'O318X20', 'O318X30', 'O3090', 'O318X90', 'O3091', 'O3092', 'O3093', 'O320XX0'
			, 'O321XX0', 'O322XX0', 'O323XX0', 'O324XX0', 'O329XX0', 'O328XX0', 'O326XX0', 'O330', 'O331', 'O332', 'O333XX0'
			, 'O334XX0', 'O335XX0', 'O336XX0', 'O337', 'O338', 'O339', 'O3400', 'O3401', 'O3402', 'O3403', 'O3410', 'O3411'
			, 'O3412', 'O3413', 'O3421', '034211', '034219', 'O34519', 'O34539', 'O34511', 'O34512', 'O34513', 'O34531'
			, 'O34532', 'O34533', 'O34529', 'O34599', 'O34521', 'O34522', 'O34523', 'O34591', 'O34592', 'O34593', 'O34521'
			, 'O34522', 'O34523', 'O3430', 'O3431', 'O3432', 'O3433', 'O3440', 'O3441', 'O3442', 'O3443', 'O3460', 'O3461'
			, 'O3462', 'O3463', 'O3470', 'O3471', 'O3472', 'O3473', 'O3480', 'O3490', 'O3429', 'O3481', 'O3482', 'O3483'
			, 'O3491', 'O3492', 'O3493', 'O3429', 'O350XX0', 'O351XX0', 'O352XX0', 'O353XX0', 'O354XX0', 'O355XX0', 'O356XX0'
			, 'O358XX1', 'O368120', 'O368130', 'O368190', 'O358XX0', 'O359XX0', 'O43019', 'O43011', 'O360190', 'O360990'
			, 'O360110', 'O360120', 'O360130', 'O360910', 'O360920', 'O360930', 'O361190', 'O361990', 'O361110', 'O361120'
			, 'O361130', 'O361910', 'O361920', 'O361930', 'O68', 'O364XX0', 'O365190', 'O365990', 'O365110', 'O365120'
			, 'O365130', 'O365910', 'O365920', 'O365930', 'O3660X0', 'O3661X0', 'O3662X0', 'O3663X0', 'O43199', 'O43819'
			, 'O43101', 'O43102', 'O43103', 'O43811', 'O43812', 'O43813', 'O4391', 'O4392', 'O4393', 'O480', 'O365939'
			, 'O368990', 'O68', 'O368910', 'O368920', 'O368930', 'O770', 'O3690X0', 'O3691X0', 'O3692X0', 'O3693X0'
			, 'O409XX0', 'O401XX0', 'O402XX0', 'O403XX0', 'O4100X0', 'O4101X0', 'O4102X0', 'O4103X0', 'O4200', 'O42011'
			, 'O42012', 'O42013', 'O4202', 'O4210', 'O42111', 'O42112', 'O42113', 'O4212', 'O471', 'O755', 'O411090'
			, 'O411290', 'O411490', 'O411010', 'O411020', 'O411030', 'O411210', 'O99212', 'O99213', 'O99013', 'O900'
			, 'O6003', 'O411220', 'O411230', 'O411410', 'O411420', 'O411430', 'O418X90', 'O418X10', 'O418X20', 'O418X30'
			, 'O4190X0', 'O4191X0', 'O4192X0', 'O4193X0','O611', 'O610', 'O619', 'O752', 'O753', 'O0940', 'O0941', 'O0942'
			, 'O0943', 'O09519', 'O09511', 'O09512', 'O09513', 'O09529', 'O09521', 'O09522', 'O09523', 'O76', 'O7589'
			, 'O759', 'O649XX0', 'O654', 'O655', 'O659', 'O640XX0', 'O660', 'O661', 'O6640', 'O665', 'O668', 'O669'
			, 'O620', 'O621', 'O622', 'O623', 'O624', 'O629', 'O630', 'O639', 'O631', 'O632', 'O690XX0', 'O691XX0'
			, 'O692XX0', 'O6981X0', 'O6982X0', 'O6989X0', 'O693XX0', 'O694XX0', 'O695XX0', 'O6989X0', 'O699XX0'
			, 'O700', 'O701', 'O702', 'O703', 'O709', 'O717', 'O704', 'O7182', 'O719','O7100', 'O7102', 'O7103'
			, 'O711', 'O712', 'O713', 'O714', 'O715', 'O716', 'O717', 'O7189', 'O719', 'O720', 'O43211', 'O43212'
			, 'O43213', 'O43221', 'O43222', 'O43223', 'O43231', 'O43232', 'O43233', 'O721', 'O722', 'O723', 'O43239'
			, 'O730', 'O43231', 'O731', 'O741', 'O8909', 'O742', 'O891', 'O743', 'O892', 'O748', 'O898', 'O749', 'O899'
			, 'O750', 'O751', 'O2650', 'O2651', 'O2652', 'O2653', 'O904', 'O754', 'O665', 'O641XX0', 'O82', 'O7581', 'O7589'
			, 'O759', 'Z331','Z3480','Z3490','O0900', 'O0910', 'O09291', 'O0940', 'O09211', 'O0930', 'O09511', 'O09521'
			, 'O09611', 'O09621', 'O09819', 'O09821', 'O09822', 'O09823', 'O09829', 'O3680X0', 'O09891', 'O09892','O09893'
			,'O09899','O0990','O0991','O0992','O0993', 'Z390', 'Z391',' Z392','Z370','Z372','Z373','Z3759','Z3769','Z379','Z36')


/* -------------------------------------------------------------------------------------------------------
690: OUTPATIENT SUD: OFFICE-BASED OUTPATIENT SUD

Report all outpatient costs and utilization under this category of service.
Per Visit

IF ('291' <= Primary_Dx_Code <= '29299') 
OR ('303' <= Primary_Dx_Code <= '30699') 
Or ('F10' <= Primary_Dx_Code <= 'F16999') 
OR ('F18' <= Primary_Dx_Code <= 'F19999') Then OUTPATIENT_SUD = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 690
,		OUTPATIENT_SUD = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		(	E.Primary_Dx_Code BETWEEN '291' AND '29299'
			OR E.Primary_Dx_Code BETWEEN '303' AND '30699'
			OR E.Primary_Dx_Code BETWEEN 'F10' AND 'F16999'
			OR E.Primary_Dx_Code BETWEEN 'F18' AND 'F19999'
		)


/* -------------------------------------------------------------------------------------------------------
710: OUTPATIENT MENTAL HEALTH: OFFICE-BASED MENTAL HEALTH SERVICES

This category includes services provided by psychologists, psychiatrists and other mental health providers. 
Report each time a patient receives mental health services regardless of the number of procedures or 
clinicians seen.
Per Visit
IF Primary_Dx_Code (in the list - page 117-118) then OUTPATIENT_MENTAL_HEALTH = 1;
*/
UPDATE	E
SET		ServiceTypeCode = 710
,		OUTPATIENT_MENTAL_HEALTH = 1
FROM	dbo.tblEncounters AS E
WHERE	MMCORCostReportCategoryId = 0
AND		E.Primary_Dx_Code in ('F0390', 'F05', 'F0150', 'F0151', 'F062', 'F060', 'F0630', 'F064', 'F061', 'F53', 'F068'
, 'F04', 'F0280', 'F0281', 'F0391', 'F2089', 'F201', 'F202', 'F200', 'F2081', 'F205', 'F259', 'F209', 'F3010', 'F3011'
, 'F3012', 'F3013', 'F302', 'F303', 'F304', 'F302', 'F329', 'F320', 'F321', 'F322', 'F323', 'F324', 'F325', 'F339', 'F330'
, 'F331', 'F332', 'F333', 'F3341', 'F3342', 'F3110', 'F3111', 'F3112', 'F3113', 'F312', 'F3173', 'F3174', 'F3130', 'F3131'
, 'F3132', 'F314', 'F315', 'F3175', 'F3176', 'F3160', 'F3161', 'F3162', 'F3163', 'F3164', 'F3177', 'F3178', 'F319', 'F308'
, 'F328','F3181', 'F39', 'F348', 'F22', 'F24', 'F23', 'F28', 'F4489', 'F29', 'F840', 'F843', 'F845', 'F848', 'F849', 'F419'
, 'F410', 'F411', 'F418', 'F449', 'F444', 'F446', 'F440', 'F441', 'F4481', 'F6811', 'F688', 'F409', 'F4001', 'F4002', 'F4010'
, 'F40218', 'F40240', 'F40241', 'F408', 'F42', 'F488', 'F481', 'F4521', 'F4522', 'F450', 'F451', 'F459', 'F458', 'F489', 'F99'
, 'F600', 'F340', 'F6089', 'F341', 'F601', 'F21', 'F603', 'F605', 'F604', 'F6812', 'F604', 'F607', 'F602', 'F6081', 'F606'
, 'F609', 'F66', 'F6589', 'F654', 'F651', 'F652', 'F641', 'Z87890', 'F642', 'R37', 'F520', 'F5221', 'F528', 'F5231', 'F5232'
, 'F524', 'F526', 'F521', 'F650', 'F653', 'F6551', 'F6552', 'F6581', 'F659', 'F458', 'F525', 'F59', 'F985', 'F5000', 'F959'
, 'F950', 'F951', 'F952', 'F984', 'F519', 'F5102', 'F5109', 'F5101', 'F5103', 'F5119', 'F5111', 'F5112', 'F518', 'F513', 'F509'
, 'F502', 'F983', 'F9821', 'F508', 'F9829', 'F980', 'F981', 'F4541', 'G44209', 'F4542', 'F633', 'R451', 'F430', 'R457', 'F4321'
, 'F930', 'F948', 'F4322', 'F4323', 'F4329', 'F4324', 'F4325', 'F4310', 'F4312', 'F438', 'F4320', 'F070', 'F0781', 'F482', 'F0789'
, 'F09', 'F329', 'F911', 'F918', 'F912', 'F639', 'F630', 'F632', 'F631', 'F6381', 'F6389', 'F919', 'F938', 'F940', 'F913', 'F941'
, 'F988', 'F939', 'F989', 'F909', 'F900', 'F901', 'F902', 'F908', 'F810', 'R480', 'F8181', 'F812', 'F8189', 'F801', 'F802', 'H9325'
, 'F804', 'F8081', 'F800', 'F8089', 'F82', 'F88', 'F819', 'F89', 'F54')

UPDATE	E
SET		MMCORCostReportCategoryId = 
		CASE	WHEN NEWBORN = 1 THEN 1 				-- Inpatient Newborn Births (> = 1 THEN 0 >=1200g weight)
				WHEN LBW_NEWBORN = 1 THEN 2 			-- Inpatient Newborn Births – Low Birth Weight <1200g weight
				WHEN MATERNITY = 1 THEN 3 				-- Inpatient Maternity Delivery
				WHEN PYSCHSA = 1 THEN 4 				-- Inpatient Mental Health & Substance Abuse
				WHEN MEDSURG = 1 THEN 5 				-- Inpatient Medical Surgical
				WHEN HOSPICE = 1 THEN 6 				-- Hospice
				WHEN NH = 1 THEN 7 						-- Nursing Facility
				WHEN ER = 1 THEN 8						-- Emergency Room
				WHEN FAMILY_PLANNING = 1 THEN 9 		-- Family Planning
				WHEN PRENATAL_POSTPARTUM = 1 THEN 10	-- Prenatal/Postpartum
				WHEN AMBULATORY_SURGERY = 1 THEN 11		-- Ambulatory Surgery
				WHEN HH_AIDE = 1 THEN 12 				-- Home Health Care (Level 3: Home Home Health Care Aide)
				WHEN HH_MED_SOCIAL_SRVS = 1 THEN 13 	--  (Medical Social Services)Home Health Care
				WHEN HH_NURSING = 1 THEN 14 			--  (Nursing)Home Health Care
				WHEN HH_OT = 1 THEN 15 					--  (Occupational Therapy)Home Health Care
				WHEN HH_PT = 1 THEN 16 					--  (Physical Therapy)Home Health Care
				WHEN HH_RESP_THRPY = 1 THEN 17 			--  (Respiratory Therapy)Home Health Care
				WHEN HH_SPEECH = 1 THEN 18 				--  (Speech Therapy)Home Health Care
				WHEN HH_SOCIAL_EVIRON_SPPTS = 1 THEN 19	--  (Social and Environmental Supports)Home Health Care
				WHEN NUTRITION = 1 THEN 20 				--  (Nutrition)Home Health Care
				WHEN HH_SGN_LNG_ORAL_INTRPTER = 1 THEN 21 	--  (Sign Language/Oral Interpreter)Home Health care
				WHEN DENTAL = 1 THEN 22 				-- Dental
				WHEN PRIMARY_CARE = 1 THEN 23 			-- Primary Care
				WHEN PHYSICIAN_SPEC = 1 THEN 24 		-- Specialty Care
				WHEN DX_LAB_XRAY = 1 THEN 25 			-- Diagnostic Testing, Laboratory, X-Ray
				WHEN PERS = 1 THEN 26 					-- Personal Emergency Response System (PERS)
				WHEN DME = 1 THEN 27 					-- Durable Medical Equipment
				WHEN AUDIOLOGY = 1 THEN 28 				--  (Audiology and Hearing Aid Services)Other Professional
				WHEN ER_TRANS = 1 THEN 29 				-- Transportation - Emergent
				WHEN NON_ER_TRANS = 1 THEN 30 			-- Transportation – Non-Emergent
				WHEN OUTPATIENT_SUD = 1 THEN 31 		-- Outpatient SUD Treatment
				WHEN OUTPATIENT_MENTAL_HEALTH = 1 THEN 32 	-- Outpatient Mental Health
				WHEN RX = 1 THEN 33 					-- Pharmacy
				WHEN MEALS = 1 THEN 34 					--  (Home Delivered or Congregated Meals)Other Medical
				WHEN REHAB = 1 THEN 35 					-- Outpatient Physical Rehab/Therapy
				WHEN PODIATRY = 1 THEN 36				-- Foot Care
				WHEN VISION = 1 THEN 37					-- Vision Care Inc. Eyeglasses
				WHEN PERSONAL_CARE_LVL1 = 1 THEN 38		-- (Paraprofessional Services Level 1: Homemaker/Housekeeper)Personal Care
				WHEN PERSONAL_CARE_LVL2 = 1 THEN 39		-- (Paraprofessional Services Level 2: Personal Care)Personal Care
				WHEN ADULT_DAYCARE = 1 THEN 40			-- (Adult Day Health Care)Other Medical
				WHEN AIDS_ADULT_DAYCARE = 1 THEN 41		-- (AIDS Adult Day Health Care)Other Medical
				WHEN SOCIAL_DAYCARE = 1 THEN 42			-- (Social Day Care)Other Professional Services
				WHEN REN_DIALYSIS = 1 THEN 43			-- (Chronic Renal Dialysis)Other Medical
				WHEN OTHER_MEDICAL = 1 THEN 44			-- Other Medical
				WHEN OTHER_PROFESSIONAL = 1 THEN 45		-- Other Professional Services
				WHEN OTHER = 1 THEN 46					-- Other Outpatient Unclassified
				WHEN CDPAP_LVL1 = 1 THEN 47				-- (Consumer Directed Personal Care: Level 1)Personal Care
				WHEN CDPAP_LVL2 = 1 THEN 48				-- (Consumer Directed Personal Care: Level 2)Personal Care
				WHEN OUTPATIENT_HOSPICE = 1 THEN 49		-- Other Medical
				WHEN HCBS_Services = 1 THEN 50			-- Behavioral Health HCBS Services
				ELSE 0
		END
FROM	dbo.tblEncounters AS E

END

-- *** END OF LEVEL 5 ***

End
