IF OBJECT_ID('dbo.luMMCORCostReportCategory') IS NOT NULL Drop Table dbo.luMMCORCostReportCategory
CREATE TABLE dbo.luMMCORCostReportCategory (
	MMCORCostReportCategoryId INT PRIMARY KEY
,	MMCORServiceCategoryDefinition VARCHAR(80)
,	MMCORTable6LineNumber CHAR(4)
,	ServiceCategoryDescription VARCHAR(80)
,	MMCORCostReportCategory VARCHAR(80) NULL
)

INSERT INTO luMMCORCostReportCategory SELECT 0,'Unknown','0000','Unknown','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 1,'NEWBORN','0011','Inpatient Newborn Births (>= 1200g weight)','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 2,'LBW NEWBORN','0088','Inpatient Newborn Births – Low Birth Weight <1200g weight','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 3,'MATERNITY','0060','Inpatient Maternity Delivery','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 4,'PYSCHSA','0010','Inpatient Mental Health & Substance Abuse','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 5,'MEDSURG','0009','Inpatient Medical Surgical','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 6,'HOSPICE','0028','Hospice','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 7,'NH','0069','Nursing Facility','5. Nursing Facility'
INSERT INTO luMMCORCostReportCategory SELECT 8,'ER','0017','Emergency Room','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 9,'FAMILY_PLANNING','0026','Family Planning','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 10,'PRENATAL_POSTPARTUM','0045','Prenatal/Postpartum','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 11,'AMBULATORY_SURGERY','0015','Ambulatory Surgery','7. Non – Covered Service'
-- Home Health
INSERT INTO luMMCORCostReportCategory SELECT 12,'HH_AIDE (Level 3: Home Health Care Aide)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 13,'HH_MED_SOCIAL_SRVS (Medical Social Services)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 14,'HH_NURSING (Nursing)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 15,'HH_OT (Occupational Therapy)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 16,'HH_PT (Physical Therapy)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 17,'HH_RESP_THRPY (Respiratory Therapy)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 18,'HH_SPEECH (Speech Therapy)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 19,'SOCIAL_ENVIRON_SPPTS (Social and Environmental Supports)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 20,'NUTRITION (Nutrition)','0022','Home Health Care','3. Home Health Care'
INSERT INTO luMMCORCostReportCategory SELECT 21,'HH_SGN_LNG_ORAL_INTRPTER (Sign Language/Oral Interpreter)','0022','Home Health care','3. Home Health Care'

INSERT INTO luMMCORCostReportCategory SELECT 22,'DENTAL','0020','Dental','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 23,'PRIMARY_CARE','0013','Primary Care','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 24,'PHYSICIAN_SPEC','0014','Specialty Care','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 25,'DX_LAB_XRAY','0025','Diagnostic Testing, Laboratory, X-Ray','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 26,'PERS','0095','Personal Emergency Response System (PERS)','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 27,'DME','0046','Durable Medical Equipment','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 28,'AUDIOLOGY (Audiology and Hearing Aid Services)','0016','Other Professional','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 29,'ER_TRANS','0023','Transportation - Emergent','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 30,'NON_ER_TRANS','0024','Transportation – Non-Emergent','4. NEMT'
INSERT INTO luMMCORCostReportCategory SELECT 31,'OUTPATIENT SUD','0019','Outpatient SUD Treatment','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 32,'OUTPATIENT MENTAL HEALTH','0018','Outpatient Mental Health','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 33,'RX','0021','Pharmacy','7. Non – Covered Service'
INSERT INTO luMMCORCostReportCategory SELECT 34,'MEALS (Home Delivered or Congregated Meals)','0028','Other Medical','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 35,'REHAB','0092','Outpatient Physical Rehab/Therapy','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 36,'PODIATRY','0093','Foot Care','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 37,'VISION','0027','Vision Care Inc. Eyeglasses','6. Other Core Medical Expense'
-- PCA
INSERT INTO luMMCORCostReportCategory SELECT 38,'PERSONAL_CARE_LVL1 (Paraprofessional Services Level 1: Homemaker/Housekeeper)','0094','Personal Care','2. Personal Care'
INSERT INTO luMMCORCostReportCategory SELECT 39,'PERSONAL_CARE_LVL2 (Paraprofessional Services Level 2: Personal Care)','0094','Personal Care','2. Personal Care'

INSERT INTO luMMCORCostReportCategory SELECT 40,'ADULT_DAYCARE (Adult Day Health Care)','0028','Other Medical','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 41,'AIDS_ADULT_DAY_CARE (AIDS Adult Day Health Care)','0028','Other Medical','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 42,'SOCIAL_DAYCARE (Social Day Care)','0016','Other Professional Services','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 43,'REN_DIALYSIS (Chronic Renal Dialysis)','0028','Other Medical','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 44,'OTHER_MEDICAL','0028','Other Medical','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 45,'OTHER_PROFESSIONAL','0016','Other Professional Services','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 46,'OTHER','0000','Other Outpatient Unclassified','7. Non – Covered Service'
-- CDPAS
INSERT INTO luMMCORCostReportCategory SELECT 47,'CDPAP_LVL1 (Consumer Directed Personal Care: Level 1)','0094','Personal Care','1. CDPAS'
INSERT INTO luMMCORCostReportCategory SELECT 48,'CDPAP_LVL2 (Consumer Directed Personal Care: Level 2)','0094','Personal Care','1. CDPAS'

INSERT INTO luMMCORCostReportCategory SELECT 49,'OUTPATIENT HOSPICE','0028','Other Medical','6. Other Core Medical Expense'
INSERT INTO luMMCORCostReportCategory SELECT 50,'HCBS Services','0047','Behavioral Health HCBS Services','7. Non – Covered Service'
 
 -- TBD
 --INSERT INTO luMMCORCostReportCategory SELECT '?','????','Outpatient Drug and Alcohol Treatment','7. Non – Covered Service'

 Select *
 From	luMMCORCostReportCategory
 Order	By MMCORCostReportCategoryId
