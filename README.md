# NYS_MMCOR
Contains T-SQL criteria for determining the category of service for healthcare encounters per the <br/>
<b>NYSDOH</b> (NEW YORK STATE DEPARTMENT OF HEALTH OFFICE OF HEALTH INSURANCE PROGRAMS)<br/>
<b>MEDICAID ENCOUNTER DATA REPORTING FOR APD AND MMCOR CATEGORY OF SERVICE</b>
<br/>Service Utilization and Cost Reporting Guide.<br/>
<br/>
1. Execute these to create and populate the look up tables:<br/>
<br/>
	These 2 tables can be used to do a lookup by MMIS id to determine if the provider of service is an Ambulatory Surgery Center or a Hospital<br/>
	CreateAndPopulate_luAmbulatorySurgeryCenter.sql<br/>
	CreateAndPopulate_luHospitals.sql<br/>
<br/>
	These 3 tables are used for reporting:<br/>
	CreateAndPopulate_luCategoryOfService.sql<br/>
	CreateAndPopulate_luMMCORCostReportCategory.sql<br/>
	CreateAndPopulate_luServiceType.sql<br/>
	<br/>
2. Create tbl_Encounters.  This is where you will populate your encounters.<br/>
	Create_tblEncounters.sql<br/>
	<br/>
3. Use Populate_tblEncounters.sql as a template to insert your own encounters into tbl_Encounters.<br/>
<br/>
4. Create and execute usp_UpdateServiceTypeCode.sql<br/>
<br/>
