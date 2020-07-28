-- health.ny.gov/regulations/hcra/provider/provider.htm

IF OBJECT_ID ('dbo.luHospitals') IS NOT NULL DROP TABLE dbo.luHospitals

CREATE TABLE dbo.luHospitals (
	Hospital_MMIS_Provider_ID_No VarChar(8) Not Null
,	[Type] VarChar(128) NULL
,	[Name] VarChar(128) Not Null
,	[Address] VarChar(128) Not Null
,	City VarChar(32) Not Null
,	[State] Char(2) Not Null
,	Zip VarChar(10) Not Null
,	[Status] VarChar(128) Not Null
)

CREATE Index ix_Hospital_MMIS_Provider_ID_No On dbo.luHospitals(Hospital_MMIS_Provider_ID_No)
CREATE Index ix_Status On dbo.luHospitals([Status])
