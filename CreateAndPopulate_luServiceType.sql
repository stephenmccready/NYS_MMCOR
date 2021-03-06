IF OBJECT_ID('dbo.luServiceType') IS NOT NULL Drop Table dbo.luServiceType
CREATE TABLE dbo.luServiceType (
	ServiceTypeCode INT PRIMARY KEY
,	ServiceType VARCHAR(100)
)

Create Index ix_ServiceTypeCode On luServiceType(ServiceTypeCode)

Insert Into luServiceType Select 10,'INPATIENT NEWBORN > = 1200 grams'
Insert Into luServiceType Select 20,'INPATIENT NEWBORN – LOW BIRTH WEIGHT (<1200 grams)'
Insert Into luServiceType Select 30,'INPATIENT MATERNITY'
Insert Into luServiceType Select 40,'INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: INPATIENT MENTAL HEALTH'
Insert Into luServiceType Select 50,'INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD DETOXIFICATION: MEDICALLY MANAGED WITHDRAWAL'
Insert Into luServiceType Select 60,'INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD DETOXIFICATION: MEDICALLY SUPERVISED WITHDRAWAL'
Insert Into luServiceType Select 70,'INPATIENT MENTAL HEALTH AND SUBSTANCE ABUSE: SUD INPATIENT REHABILITATION'
Insert Into luServiceType Select 80,'INPATIENT MENTAL HEALTH and SUBSTANCE ABUSE: OASAS RESIDENTIAL TREATMENT PER DIEM'
Insert Into luServiceType Select 90,'INPATIENT MEDICAL SURGICAL'
Insert Into luServiceType Select 100,'HOSPICE'
Insert Into luServiceType Select 110,'SKILLED NURSING FACILITY (SNF) - NON-SPECIALTY'
Insert Into luServiceType Select 120,'SKILLED NURSING FACILITY (SNF) - SPECIALTY'
Insert Into luServiceType Select 200,'EMERGENCY ROOM'
Insert Into luServiceType Select 210,'FAMILY PLANNING'
Insert Into luServiceType Select 220,'PRENATAL/POSTPARTUM CARE'
Insert Into luServiceType Select 230,'AMBULATORY SURGERY'
Insert Into luServiceType Select 240,'HOME HEALTH CARE: LEVEL 3 HOME HEALTH CARE AIDE'
Insert Into luServiceType Select 250,'HOME HEALTH CARE: MEDICAL SOCIAL SERVICES'
Insert Into luServiceType Select 260,'HOME HEALTH CARE: NURSING'
Insert Into luServiceType Select 270,'HOME HEALTH CARE: OCCUPATIONAL THERAPY'
Insert Into luServiceType Select 280,'HOME HEALTH CARE: PHYSICAL THERAPY'
Insert Into luServiceType Select 290,'HOME HEALTH CARE: RESPIRATORY THERAPY'
Insert Into luServiceType Select 300,'HOME HEALTH CARE: SPEECH THERAPY'
Insert Into luServiceType Select 310,'HOME HEALTH CARE: SOCIAL AND ENVIRONMENTAL SUPPORTS'
Insert Into luServiceType Select 320,'HOME HEALTH CARE: NUTRITIONAL COUNSELING'
Insert Into luServiceType Select 330,'HOME HEALTH CARE: SIGN LANGUAGE/ORAL INTERPRETER'
Insert Into luServiceType Select 340,'DENTAL SERVICES'
Insert Into luServiceType Select 350,'PRIMARY CARE'
Insert Into luServiceType Select 360,'PHYSICIAN SPECIALIST'
Insert Into luServiceType Select 370,'DIAGNOSTIC TESTING, LABORATORY, X-RAY SERVICES'
Insert Into luServiceType Select 380,'PERSONAL EMERGENCY RESPONSE SYSTEM (PERS)'
Insert Into luServiceType Select 390,'DME, MEDICAL/SURGICAL SUPPLIES, PROSTHESES AND ORTHOTICS'
Insert Into luServiceType Select 400,'AUDIOLOGY AND HEARING AID SERVICES'
Insert Into luServiceType Select 410,'EMERGENCY TRANSPORTATION'
Insert Into luServiceType Select 420,'NON-EMERGENCY TRANSPORTATION'
Insert Into luServiceType Select 430,'OUTPATIENT PHARMACY (Including Mental Health and SUD Pharmacy)'
Insert Into luServiceType Select 440,'HOME DELIVERED OR CONGREGATE MEALS'
Insert Into luServiceType Select 450,'OUTPATIENT REHABILITATION THERAPIES: PHYSICAL THERAPY, OCCUPATIONAL THERAPY, SPEECH THERAPY'
Insert Into luServiceType Select 460,'PODIATRY'
Insert Into luServiceType Select 470,'VISION CARE'
Insert Into luServiceType Select 480,'PARAPROFESSIONAL SERVICES: Level 1 – HOMEMAKER / HOUSEKEEPER'
Insert Into luServiceType Select 490,'PARAPROFESSIONAL SERVICES: LEVEL 2 – PERSONAL CARE'
Insert Into luServiceType Select 500,'ADULT DAY HEALTH CARE'
Insert Into luServiceType Select 510,'AIDS ADULT DAY HEALTH CARE'
Insert Into luServiceType Select 520,'SOCIAL DAY CARE'
Insert Into luServiceType Select 530,'CHRONIC RENAL DIALYSIS'
Insert Into luServiceType Select 540,'OTHER MEDICAL'
Insert Into luServiceType Select 550,'OTHER PROFESSIONAL SERVICES'
Insert Into luServiceType Select 560,'OTHER OUTPATIENT UNCLASSIFIED'
Insert Into luServiceType Select 570,'CONSUMER DIRECTED PERSONAL ASSISTANT LEVEL I'
Insert Into luServiceType Select 580,'CONSUMER DIRECTED PERSONAL ASSISTANT LEVEL 2'
Insert Into luServiceType Select 590,'OUTPATIENT SERVICES: HEALTH HOMES - ADULT'
Insert Into luServiceType Select 600,'OUTPATIENT SERVICES: HEALTH HOMES – CHILD'
Insert Into luServiceType Select 610,'HARM REDUCTION SERVICES'
Insert Into luServiceType Select 620,'DOULA SERVICES'
Insert Into luServiceType Select 630,'OUTPATIENT SUD: OUTPATIENT SUD CLINIC'
Insert Into luServiceType Select 640,'OUTPATIENT SUD: OUTPATIENT SUD REHABILITATION'
Insert Into luServiceType Select 650,'OUTPATIENT SUD: OUTPATIENT SUD OPIATE TREATMENT PROGRAM'
Insert Into luServiceType Select 660,'OUTPATIENT SUD: OUTPATIENT SUD INTEGRATED OPIATE TREATMENT PROGRAM'
Insert Into luServiceType Select 670,'OUTPATIENT SUD: OUTPATIENT SUD INTEGRATED CLINIC'
Insert Into luServiceType Select 680,'OUTPATIENT SUD: OUTPATIENT SUD DETOXIFICATION'
Insert Into luServiceType Select 690,'OUTPATIENT SUD: OFFICE-BASED OUTPATIENT SUD'
Insert Into luServiceType Select 700,'OUTPATIENT SUD: OTHER SUD OUTPATIENT SERVICES'
Insert Into luServiceType Select 710,'OUTPATIENT MENTAL HEALTH: OFFICE-BASED MENTAL HEALTH SERVICES'
Insert Into luServiceType Select 720,'OUTPATIENT MENTAL HEALTH: OUTPATIENT MENTAL HEALTH CLINIC'
Insert Into luServiceType Select 730,'OUTPATIENT MENTAL HEALTH: OMH ASSERTIVE COMMUNITY TREATMENT'
Insert Into luServiceType Select 740,'OUTPATIENT MENTAL HEALTH: OMH CONTINUING DAY TREATMENT'
Insert Into luServiceType Select 750,'OUTPATIENT MENTAL HEALTH: OMH COMPREHENSIVE PSYCHIATRIC EMERGENCY PROGRAM'
Insert Into luServiceType Select 760,'OUTPATIENT MENTAL HEALTH: OMH INTENSIVE PSYCHIATRIC REHABILITATION TREATMENT PROGRAM'
Insert Into luServiceType Select 770,'OUTPATIENT MENTAL HEALTH: OMH PARTIAL HOSPITALIZATION'
Insert Into luServiceType Select 780,'OUTPATIENT MENTAL HEALTH: OMH PERSONALIZED RECOVERY ORIENTED SERVICES'
Insert Into luServiceType Select 790,'OUTPATIENT MENTAL HEALTH: CRISIS INTERVENTION'
Insert Into luServiceType Select 800,'OUTPATIENT MENTAL HEALTH: OMH LICENSED BEHAVIORAL HEALTH PRACTITIONER (LBHP)'
Insert Into luServiceType Select 810,'OUTPATIENT MENTAL HEALTH: OTHER LICENSED PRACTITIONER - KIDS'
Insert Into luServiceType Select 820,'OUTPATIENT MENTAL HEALTH: COMMUNITY PSYHCIATRIC SUPPORT AND TREATMENT'
Insert Into luServiceType Select 830,'OUTPATIENT MENTAL HEALTH: PYSCHOSOCIAL REHABILITATION'
Insert Into luServiceType Select 840,'HARP HCBS'

Select * From dbo.luServiceType
