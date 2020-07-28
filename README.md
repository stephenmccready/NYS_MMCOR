# NYS_MMCOR
Contains T-SQL criteria for determining the category of service for healthcare encounters per the <br/>
<b>NYSDOH</b> (New York State Department of Health)<br/>
<b>MEDICAID ENCOUNTER DATA REPORTING FOR APD (All Payer Database) AND MMCOR (Medicaid Managed Care Operating Report) CATEGORY OF SERVICE</b>
<br/><b>Service Utilization and Cost Reporting Guide.</b><br/>
<i>Commonly know as the MMCOR guide</i><br/>
<br/>
1. Execute these scripts to create and populate the look up tables:<br/>
&nbsp;These 2 tables can be used to do a lookup by MMIS id to determine if the provider of service is an Ambulatory Surgery Center or a Hospital<br/>
&nbsp;CreateAndPopulate_luAmbulatorySurgeryCenter.sql<br/>
&nbsp;CreateAndPopulate_luHospitals.sql<br/>
&nbsp;These 3 tables are used for reporting:<br/>
&nbsp;CreateAndPopulate_luCategoryOfService.sql<br/>
&nbsp;CreateAndPopulate_luMMCORCostReportCategory.sql<br/>
&nbsp;CreateAndPopulate_luServiceType.sql<br/>
	<br/>
2. Create tbl_Encounters.  This is where you will populate your encounters.<br/>
&nbsp;Create_tblEncounters.sql<br/>
	<br/>
3. Use Populate_tblEncounters.sql as a template to insert your own encounters into tbl_Encounters.<br/>
<br/>
4. Create and execute the stored procedure: usp_UpdateServiceTypeCode.sql This will allocate an MMCOR category (MMCORCostReportCategoryId) to each encounter<br/>
<br/>
