
IF OBJECT_ID ('dbo.tblPPIEncounters') IS NOT NULL DROP TABLE dbo.tblPPIEncounters

CREATE TABLE dbo.tblPPIEncounters (
-- ===================================================================================================
-- INPUT FIELDS:
	ClaimNum varchar(12) NULL,
	ClaimNumber varchar(14) NULL,
	Line Int NULL,
	ClaimFrequencyTypeCode Int NULL,
	SubmittedDate DateTime NULL,
	LOB char(4) NULL,
	StartDate DateTime NULL,
	EndDate DateTime NULL,
	ProviderNPI varchar(12) NULL,
    ProcedureCodeTypeId tinyint NULL,
	ClaimType char(1) NULL,
	ClaimLinePaidIndicator varchar(6) NULL,
	AdmissionDate DateTime NULL,
	BillType varchar(3) NULL,
	COSDescription varchar(50) NULL,
	ECN varchar(12) NULL,
	RemitICNFromNYS varchar(12) NULL,
	ParentClaimNumber varchar(16) NULL,
	PaidAmount Money Null,
	MedicarePaidAmount Money Null,
	MedicaidPaidAmount Money Null,
	EncounterStatus  varchar(8) NULL,
	ClaimStatusCode char(2) NULL,
	RejectReason char(2) NULL,
	InvoiceID varchar(16) NULL,
	BatchID varchar(16) NULL,
	CrosswalkID varchar(16) NULL

-- REQUIRED FOR MMCOR
,	Category_of_Service CHAR(2) NULL
,	AP_DRG_Code CHAR(4) NULL		-- Left zerofill
,	AP_DRG_Type_Code INT NULL
,	NewBorn_Flag TINYINT NULL		-- Newborn set to 1, else 0
,	Birthweight INT NULL			-- If Birthweight is unknown leave as NULL
,	Rate_Code CHAR(4) NULL
,	Provider_Specialty_Code CHAR(3) NULL
,	Revenue_Code CHAR(4) NULL		-- Left zerofill
,	Ins_Type_Bill_1_2 CHAR(2) NULL	-- First 2 characters of Type of Bill
,	Hospital_Indicator INT NULL		-- 1 = Hospital
,	Procedure_Code VARCHAR(8) NULL
,	Modifier_1 CHAR(2) NULL
,	Modifier_2 CHAR(2) NULL
,	Modifier_3 CHAR(2) NULL
,	Modifier_4 CHAR(2) NULL
,	MMIS_Provider_ID_No CHAR(16) NULL
,	Primary_Dx_Code CHAR(8) NULL

-- For your own tracking/auditing/testing
,	MemberId INT NULL
,	ProviderId INT NULL
,	ClaimLineAdjustmentNumber INT NULL
,	DatePaid DATETIME NULL
,	NAMI MONEY NULL						-- Net Available Monthly Income

-- END OF INPUT FIELDS
-- =================================================================================================

--	These codes and flags below will be populated by usp_UpdateServiceTypeCode
,	ServiceTypeCode INT NULL				-- This indicates the detailed criteria used (luMMCORServiceType)
,	MMCORCostReportCategoryId INT NULL		-- MMCOR Cost Report Category (luMMCORCostReportCategory)

-- CATEGORY FLAGS used by usp_UpdateServiceTypeCode
-- INPATIENT
,	NEWBORN TINYINT NULL		-- 10: INPATIENT NEWBORN > = 1200 grams
,	LBW_NEWBORN TINYINT NULL	-- 20: INPATIENT NEWBORN – LOW BIRTH WEIGHT (<1200 grams)
,	MATERNITY TINYINT NULL		-- 30: INPATIENT MATERNITY
,	PYSCHSA TINYINT NULL		-- 40: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: INPATIENT MENTAL HEALTH
								-- 50: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD DETOXIFICATION: MEDICALLY MANAGED WITHDRAWAL
								-- 60: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD DETOXIFICATION: MEDICALLY SUPERVISED WITHDRAWAL
								-- 70: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD INPATIENT REHABILITATION
								-- 80: INPATIENT MENTAL HEALTH and SUBSTANCE ABUSE: OASAS RESIDENTIAL TREATMENT PER DIEM
,	MEDSURG TINYINT NULL		-- 90: INPATIENT MEDICAL SURGICAL
,	HOSPICE TINYINT NULL		-- 100: HOSPICE
,	NH TINYINT NULL				-- 110: SKILLED NURSING FACILITY (SNF) - NON-SPECIALTY
								-- 120: SKILLED NURSING FACILITY (SNF) - SPECIALTY

-- OUTPATIENT
,	ER TINYINT NULL						-- 200: EMERGENCY ROOM
,	FAMILY_PLANNING TINYINT NULL		-- 210: FAMILY PLANNING
,	PRENATAL_POSTPARTUM TINYINT NULL	-- 220: PRENATAL/POSTPARTUM CARE
,		DIAG_LABS TINYINT NULL				-- Note: DIAG_LABS used in 220: PRENATAL/POSTPARTUM CARE criteria
,	AMBULATORY_SURGERY TINYINT NULL		-- 230: AMBULATORY SURGERY
,		AMB_Surgery_Center TINYINT NULL		-- Note: AMB_Surgery_Center used in 230: AMBULATORY SURGERY
,	HH_AIDE TINYINT NULL				-- 240: HOME HEALTH CARE: LEVEL 3 HOME HEALTH CARE AIDE
,	HH_MED_SOCIAL_SRVS TINYINT NULL		-- 250: HOME HEALTH CARE: MEDICAL SOCIAL SERVICES
,	HH_NURSING TINYINT NULL				-- 260: HOME HEALTH CARE: NURSING
,	HH_OT TINYINT NULL					-- 270: HOME HEALTH CARE: OCCUPATIONAL THERAPY
,	HH_PT TINYINT NULL					-- 280: HOME HEALTH CARE: PHYSICAL THERAPY
,	HH_RESP_THRPY TINYINT NULL			-- 290: HOME HEALTH CARE: RESPIRATORY THERAPY
,	HH_SPEECH TINYINT NULL				-- 300: HOME HEALTH CARE: SPEECH THERAPY
,	HH_SOCIAL_EVIRON_SPPTS TINYINT NULL	-- 310: HOME HEALTH CARE: SOCIAL AND ENVIRONMENTAL SUPPORTS
,	NUTRITION TINYINT NULL				-- 320: Home Health Care
,	HH_SGN_LNG_ORAL_INTRPTER TINYINT NULL -- 330: Home Health Care
,	DENTAL TINYINT NULL					-- 340: Dental
,	PRIMARY_CARE TINYINT NULL			-- 350: Primary Care
,	PHYSICIAN_SPEC TINYINT NULL			-- 360: Specialty Care
,	DX_LAB_XRAY TINYINT NULL			-- 370: Diagnostic Testing, Laboratory, X-Ray
,	PERS TINYINT NULL					-- 380: Personal Emergency Response System (PERS)
,	DME TINYINT NULL					-- 390: Durable Medical Equipment
,	AUDIOLOGY TINYINT NULL				-- 400: Other Professional
,	ER_TRANS TINYINT NULL				-- 410: Transportation - Emergent
,	NON_ER_TRANS TINYINT NULL			-- 420: Transportation – Non-Emergent
,	OUTPATIENT_SUD TINYINT NULL			-- 630: OUTPATIENT SUD: OUTPATIENT SUD CLINIC
										-- 640: OUTPATIENT SUD: OUTPATIENT SUD REHABILITATION
										-- 650: OUTPATIENT SUD: OUTPATIENT SUD OPIATE TREATMENT PROGRAM
										-- 660: OUTPATIENT SUD: OUTPATIENT SUD INTEGRATED OPIATE TREATMENT PROGRAM
										-- 670: OUTPATIENT SUD: OUTPATIENT SUD INTEGRATED CLINIC
										-- 680: OUTPATIENT SUD: OUTPATIENT SUD DETOXIFICATION
										-- 690: OUTPATIENT SUD: OFFICE-BASED OUTPATIENT SUD
										-- 700: OUTPATIENT SUD: OTHER SUD OUTPATIENT SERVICES Description
,	OUTPATIENT_MENTAL_HEALTH TINYINT NULL -- 710: OUTPATIENT MENTAL HEALTH: OFFICE-BASED MENTAL HEALTH SERVICES
										-- 720: OUTPATIENT MENTAL HEALTH: OUTPATIENT MENTAL HEALTH CLINIC
										-- 730: OUTPATIENT MENTAL HEALTH: OMH ASSERTIVE COMMUNITY TREATMENT
										-- 740: OUTPATIENT MENTAL HEALTH: OMH CONTINUING DAY TREATMENT
										-- 750: OUTPATIENT MENTAL HEALTH: OMH COMPREHENSIVE PSYCHIATRIC EMERGENCY PROGRAM
										-- 760: OUTPATIENT MENTAL HEALTH: OMH INTENSIVE PSYCHIATRIC REHABILITATION TREATMENT PROGRAM
										-- 770: OUTPATIENT MENTAL HEALTH: OMH PARTIAL HOSPITALIZATION
										-- 780: OUTPATIENT MENTAL HEALTH: OMH PERSONALIZED RECOVERY ORIENTED SERVICES
										-- 790: OUTPATIENT MENTAL HEALTH: CRISIS INTERVENTION
										-- 800: OUTPATIENT MENTAL HEALTH: OMH LICENSED BEHAVIORAL HEALTH PRACTITIONER (LBHP)
										-- 810: OUTPATIENT MENTAL HEALTH: OTHER LICENSED PRACTITIONER - KIDS
										-- 820: OUTPATIENT MENTAL HEALTH: COMMUNITY PSYHCIATRIC SUPPORT AND TREATMENT
										-- 830: OUTPATIENT MENTAL HEALTH: PYSCHOSOCIAL REHABILITATION
,	RX TINYINT NULL						-- 430: Outpatient Pharmacy
,	MEALS TINYINT NULL					-- 440: Other Medical
,	REHAB TINYINT NULL					-- 450: Outpatient Physical Rehab/Therapy
,	PODIATRY TINYINT NULL				-- 460: Foot Care
,	VISION TINYINT NULL					-- 470: Vision Care Inc. Eyeglasses
,	PERSONAL_CARE_LVL1 TINYINT NULL		-- 480: Personal Care
,	PERSONAL_CARE_LVL2 TINYINT NULL		-- 490: Personal Care
,	ADULT_DAYCARE TINYINT NULL			-- 500: Other Medical
,	AIDS_ADULT_DAYCARE TINYINT NULL		-- 510: Other Medical
,	SOCIAL_DAYCARE TINYINT NULL			-- 520: Other Professional Services
,	REN_DIALYSIS TINYINT NULL			-- 530: Other Medical
,	OTHER_MEDICAL TINYINT NULL			-- 540: Other Medical
										-- 610: HARM REDUCTION SERVICES
										-- 620: DOULA SERVICES
,	OTHER_PROFESSIONAL TINYINT NULL		-- 550: Other Professional Services
,	OTHER TINYINT NULL					-- 560: Other Outpatient Unclassified
,		SUM_OF_OTHER INT NULL				-- Note: SUM_OF_OTHER used in 230: AMBULATORY SURGERY	
,	CDPAP_LVL1 TINYINT NULL				-- 570: Personal Care
,	CDPAP_LVL2 TINYINT NULL				-- 580: Personal Care
,	OUTPATIENT_HOSPICE TINYINT NULL		-- Page 11 ??? TBD
,	HCBS_Services TINYINT NULL			-- 840: HARP HCBS

,	DRUG_ALCOHOL TINYINT NULL			-- Page 96 ??? TBD
,	MENTAL_HEALTH TINYINT NULL			-- Page 96 ??? TBD
,	HEALTH_HOMES TINYINT NULL			-- 590: OUTPATIENT SERVICES: HEALTH HOMES - ADULT
										-- 600: OUTPATIENT SERVICES: HEALTH HOMES – CHILD
)

CREATE INDEX ix_ClaimNumber ON tblPPIEncounters(ClaimNumber)
CREATE INDEX ix_Line ON tblPPIEncounters(Line)
CREATE INDEX ix_Rate_Code ON tblPPIEncounters(Rate_Code)
CREATE INDEX ix_Provider_Specialty_Code ON tblPPIEncounters(Provider_Specialty_Code)
CREATE INDEX ix_Procedure_Code ON tblPPIEncounters(Procedure_Code)
CREATE INDEX ix_Primary_Dx_Code ON tblPPIEncounters(Primary_Dx_Code)
