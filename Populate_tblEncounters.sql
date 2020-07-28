Truncate Table dbo.tblEncounters

Insert	Into dbo.tblEncounters
Select	Distinct SubString(E.ClaimNumber,2,12) As ClaimNum
,		Cast(E.ClaimNumber As VarChar(14)) As ClaimNumber
,		Cast(E.LineItem As Int) AS Line
,		Cast(E.ClaimFrequencyTypeCode As Int) As ClaimFrequencyTypeCode
,		Cast(E.SubmittedDate As DateTime) As SubmittedDate
,		Cast(E.LOB As Char(4))
,		Cast(E.[Start Date] As DateTime) As StartDate
,		Cast(E.[End Date] As DateTime) As EndDate
,		Cast(E.[Provider NPI] As VarChar(12)) As ProviderNPI
,		Null As ProcedureCodeTypeId
,		Cast(E.ClaimType As Char(1)) As ClaimType
,		Cast(E.ClaimLinePaidIndicator As VarChar(6)) As ClaimLinePaidIndicator
,		Cast(E.[Admission Date] As DateTime) As AdmissionDate
,		Cast(E.BillType As Char(3)) As BillType
,		Cast(E.[COS Description] As VarChar(50)) As COSDescription
,		Cast(E.ECN As VarChar(12)) As ECN
,		Cast(E.RemitICNFromNYS As VarChar(12)) As RemitICNFromNYS
,		Cast(E.ParentClaimNumber As VarChar(16)) As ParentClaimNumber
,		Cast(E.PaidAmount As Money) As PaidAmount
,		Cast(0 AS Money) As MedicaidAmount
,		Cast(0 AS Money) As MedicareAmount
,		Cast(E.[Encounter Status] As VarChar(8)) As EncounterStatus
,		Cast(E.ClaimStatusCode As char(2)) As ClaimStatusCode
,		Cast(E.RejectReason As char(2)) As RejectReason
,		Cast(E.InvoiceID As varchar(16)) As InvoiceID
,		Cast(E.BatchID As varchar(16)) As BatchID
,		Cast(E.CrosswalkID As varchar(16)) As CrosswalkID
,		SubString(E.[COS],1,2) As Category_of_Service
,		Null As AP_DRG_Code
,		Null As AP_DRG_Type_Code
,		Null As NewBorn_Flag
,		Null As Birthweight
,		Case When Len(E.ProcedureCode) = 4 Then SubString(E.ProcedureCode,1,4) Else '' End  As Rate_Code
,		SubString(E.SpecialtyCode,1,3) As Specialty_Code
,		SubString(E.RevenueCode,1,4) As RevenueCode
,		SubString(E.BillType,1,2) As Ins_Type_Bill_1_2
,		Cast(0 AS Int) As Hospital_Indicator
,		SubString(E.ProcedureCode,1,8)
,		SubString(E.Modifier1,1,2) As Modifier_1
,		SubString(E.Modifier2,1,2) As Modifier_2
,		SubString(E.Modifier3,1,2) As Modifier_3
,		SubString(E.Modifier4,1,2) As Modifier_4
,		'' As MMIS_Provider_ID_No
,		SubString(E.PrimaryDiagnosis,1,8) As Primary_Dx_Cod

,		Cast(0 As Int) As MemberId
,		Cast(0 As Int) As ProviderId
,		Cast(0 As Int) As ClaimLineAdjustmentNumber
,		CasT(Null As DateTime) As DatePaid
,		Cast(0 As Money) As NAMI

--	These codes and flags below will be populated by usp_UpdateServiceTypeCode
,	0 As ServiceTypeCode
,	0 As MMCORCostReportCategoryId

-- CATEGORY FLAGS:
-- INPATIENT
,	0 As NEWBORN					-- 10: INPATIENT NEWBORN > = 1200 grams
,	0 As LBW_NEWBORN				-- 20: INPATIENT NEWBORN – LOW BIRTH WEIGHT (<1200 grams)
,	0 As MATERNITY					-- 30: INPATIENT MATERNITY
,	0 As PYSCHSA					-- 40: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: INPATIENT MENTAL HEALTH
									-- 50: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD DETOXIFICATION: MEDICALLY MANAGED WITHDRAWAL
									-- 60: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD DETOXIFICATION: MEDICALLY SUPERVISED WITHDRAWAL
									-- 70: INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD INPATIENT REHABILITATION
									-- 80: INPATIENT MENTAL HEALTH and SUBSTANCE ABUSE: OASAS RESIDENTIAL TREATMENT PER DIEM
,	0 As MEDSURG					-- 90: INPATIENT MEDICAL SURGICAL
,	0 As HOSPICE					-- 100: HOSPICE
,	0 As NH							-- 110: SKILLED NURSING FACILITY (SNF) - NON-SPECIALTY
									-- 120: SKILLED NURSING FACILITY (SNF) - SPECIALTY

-- OUTPATIENT
,	0 As ER 						-- 200: EMERGENCY ROOM
,	0 As FAMILY_PLANNING 			-- 210: FAMILY PLANNING
,	0 As PRENATAL_POSTPARTUM 		-- 220: PRENATAL/POSTPARTUM CARE
,		0 As DIAG_LABS 				-- Note: DIAG_LABS used in 220: PRENATAL/POSTPARTUM CARE criteria
,	0 As AMBULATORY_SURGERY 		-- 230: AMBULATORY SURGERY
,		0 As AMB_Surgery_Center 	-- Note: AMB_Surgery_Center used in 230: AMBULATORY SURGERY
,	0 As HH_AIDE 					-- 240: HOME HEALTH CARE: LEVEL 3 HOME HEALTH CARE AIDE
,	0 As HH_MED_SOCIAL_SRVS 		-- 250: HOME HEALTH CARE: MEDICAL SOCIAL SERVICES
,	0 As HH_NURSING 				-- 260: HOME HEALTH CARE: NURSING
,	0 As HH_OT 						-- 270: HOME HEALTH CARE: OCCUPATIONAL THERAPY
,	0 As HH_PT 						-- 280: HOME HEALTH CARE: PHYSICAL THERAPY
,	0 As HH_RESP_THRPY 				-- 290: HOME HEALTH CARE: RESPIRATORY THERAPY
,	0 As HH_SPEECH 					-- 300: HOME HEALTH CARE: SPEECH THERAPY
,	0 As HH_SOCIAL_EVIRON_SPPTS 	-- 310: HOME HEALTH CARE: SOCIAL AND ENVIRONMENTAL SUPPORTS
,	0 As NUTRITION 					-- Home Health Care
,	0 As HH_SGN_LNG_ORAL_INTRPTER	-- Home Health Care
,	0 As DENTAL						-- Dental
,	0 As PRIMARY_CARE				-- Primary Care
,	0 As PHYSICIAN_SPEC				-- Specialty Care
,	0 As DX_LAB_XRAY				-- Diagnostic Testing, Laboratory, X-Ray
,	0 As PERS  						-- Personal Emergency Response System (PERS)
,	0 As DME  						-- Durable Medical Equipment
,	0 As AUDIOLOGY  				-- Other Professional
,	0 As ER_TRANS  					-- Transportation - Emergent
,	0 As NON_ER_TRANS 				-- Transportation – Non-Emergent
,	0 As OUTPATIENT_SUD  			-- Outpatient SUD Treatment
,	0 As OUTPATIENT_MENTAL_HEALTH	-- Outpatient Mental Health
,	0 As RX  						-- Pharmacy
,	0 As MEALS  					-- Other Medical
,	0 As REHAB  					-- Outpatient Physical Rehab/Therapy
,	0 As PODIATRY  					-- Foot Care
,	0 As VISION  					-- Vision Care Inc. Eyeglasses
,	0 As PERSONAL_CARE_LVL1			-- Personal Care
,	0 As PERSONAL_CARE_LVL2			-- Personal Care
,	0 As ADULT_DAYCARE				-- Other Medical
,	0 As AIDS_ADULT_DAYCARE			-- Other Medical
,	0 As SOCIAL_DAYCARE				-- Other Professional Services
,	0 As REN_DIALYSIS				-- Other Medical
,	0 As OTHER_MEDICAL				-- Other Medical
,	0 As OTHER_PROFESSIONAL			-- Other Professional Services
,	0 As OTHER						-- Other Outpatient Unclassified
,	0 As SUM_OF_OTHER
,	0 As CDPAP_LVL1  				-- Personal Care
,	0 As CDPAP_LVL2  				-- Personal Care
,	0 As OUTPATIENT_HOSPICE			-- Other Medical
,	0 As HCBS_Services				-- Behavioral Health HCBS Services

,	0 As DRUG_ALCOHOL
,	0 As MENTAL_HEALTH
,	0 As HEALTH_HOMES
From	dbo.MyEncountersTable As E
