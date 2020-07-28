IF OBJECT_ID('dbo.luCategoryOfService') IS NOT NULL Drop Table dbo.luCategoryOfService

Create Table dbo.luCategoryOfService (
	COSCode char(2)
,	COSDescription varchar(64)
,	ETI char(1)	-- Encounter Type Indicator
,	ETIDescription varchar(64)
,	FormType_EDI varchar(16)
)

Create Index ix_COSCode On dbo.luCategoryOfService(COSCode)

Insert Into luCategoryOfService Select '01' As COSCode, 'Physician Services' As COSDescription, 'P' As ETI, 'Professional' As ETIDescription, 'CMS-1500 / 837P' As FormType_EDI
Insert Into luCategoryOfService Select '03','Podiatry','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '04','Psychology','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '05','Eye Care / Vision','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '06','Rehabilitation Therapy','I','Institutional','UB-92 / 837I'
Insert Into luCategoryOfService Select '07','Nursing','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '11','Inpatient','I','Institutional','UB-92 / 837I'
Insert Into luCategoryOfService Select '12','Institutional LTC','I','Institutional','UB-92 / 837I'
Insert Into luCategoryOfService Select '13','Dental','T','Dental','ADA / 837D'
Insert Into luCategoryOfService Select '14','Pharmacy','D','Pharmacy/DME','NCPDP'
Insert Into luCategoryOfService Select '15','Home Health Care/Non-Institutional Long Term Care','I','Institutional','UB-92 / 837I'
Insert Into luCategoryOfService Select '16','Laboratories','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '19','Transportation','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '22','DME and Hearing Aids','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '28','Intermediate Care Facilities','I','Institutional','UB-92 / 837I'
Insert Into luCategoryOfService Select '41','NPs/Midwives','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '73','Hospice','I','Institutional','UB-92 / 837I'
Insert Into luCategoryOfService Select '75','Clinical Social Worker','P','Professional','CMS-1500 / 837P'
Insert Into luCategoryOfService Select '85','Freestanding Clinic','I','Institutional','UB-92 / 837I'
Insert Into luCategoryOfService Select '87','Hospital OP/ER Room','I','Institutional','UB-92 / 837I'

Select * From luCategoryOfService
