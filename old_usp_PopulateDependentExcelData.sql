USE [Staging]
GO
/****** Object:  StoredProcedure [FLR].[usp_PopulateDependentExcelData]    Script Date: 6/20/2020 3:11:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ========================================================================================            
Author: MAQ Software  
Create date: Jun 12, 2020
Description: Read data for Future Lot Forecast Add in
  
Project Name: Merch BI                                                                                                                        
                                                                                                                                                                    
Module Name:  [FLR].[usp_PopulateDependentExcelData]
                                                                                                                                                                    
Purpose:                                                                                                                                                        
 To read data for Future Lot Forecast Add in for excel
                                                                                                                                                                    
Parameter Info:                                                                                                                                              
 No parameter                                                                                                                                                 
                                                                                                                                                                    
Return Info:                                                                                                                                                  
EXcel Data for grids in pivoted format  
                                                                                                                                                                    
Output:
EXcel Data returned for required grids  
                                                                                                                                                                    
Test Script: EXECUTE [FLR].[usp_PopulateDependentExcelData]

Revision History:                                                                                                                                              
Id		Date			Author				Description                                                                                                   
==========================================================================================                
NA		Jun 12, 2020	fareast\v-arjain	Created
==========================================================================================*/

ALTER PROCEDURE [FLR].[usp_PopulateDependentExcelData]    
AS     
BEGIN    
SET NOCOUNT ON;

	DECLARE @Current DATE = (SELECT MIN([Period]) FROM [dbo].[FactForecastDemand] WITH (NOLOCK))    
	DECLARE @End DATE = (SELECT DATEADD(WEEK,23,@Current))    
	DECLARE @Start DATE = (SELECT DATEADD(WEEK,-12,@Current))
	DECLARE @StartColumn INT = 5   
	  
	DROP TABLE IF EXISTS [FLR].[ItemForecast];  
	DROP TABLE IF EXISTS [FLR].[ItemHistoricalSales];  
	DROP TABLE IF EXISTS [FLR].[OpenPOs]; 
	DROP TABLE IF EXISTS [FLR].[Inventory]; 
	
	-- Populate Open POs table
	;WITH CTE_PODates AS
	(
	SELECT DISTINCT FiscalWeekStartDate,ROW_NUMBER() OVER(ORDER BY CalendarDate) AS CellID
	FROM mer.vwDimCalendar WITH (NOLOCK)
	WHERE FiscalWeekStartDate = CalendarDate
	AND FiscalWeekStartDate >= @Current AND FiscalWeekStartDate<=@End
	)
	,CTE_OpenPOS AS(                    
	SELECT
	  CASE WHEN CDSOTBRegionName = 'EMEA' THEN 'EOC'
	  WHEN CDSOTBRegionName IN ('GCR','ASIA') THEN 'APOC'
	  WHEN CDSOTBRegionName = 'North America' THEN 'AOC'
	  END AS PlanningRegion
	  ,DC.FiscalWeekStartDate              
	 ,[Pos].[SKU]                    
	 ,SUM([Pos].[OpenPOQty]) AS OpenQty                               
	FROM [dbo].[FactOpenPOs_MAX] as [Pos] WITH (NOLOCK)   
	JOIN 
	  FLR.ForecastCategorization AS CI WITH (NOLOCK)
	  ON CI.ItemID = [Pos].SKU  
	JOIN  
	  dbo.vwDimSupplyLocation_MAX AS spl WITH (NOLOCK)  
	  ON pos.[SupplyLocationCode] = spl.[SupplyLocationCode]                       
	JOIN  
	  [dbo].[DimProductHierarchy_allSKUs_KDW]  as skd WITH  (NOLOCK)                      
	  ON pos.[SKU] = skd.[SKU]                    
	JOIN  
	  mer.vwDimCalendar AS DC WITH (NOLOCK)                   
	  ON DC.CalendarDate = CONVERT(DATE,[Pos].[LastRequestedDeliveryDate])
	JOIN  
	  vwDimGeographyHierarchy_KDW AS DGH WITH (NOLOCK)                   
	  ON DGH.SubsidiaryName = ( CASE                    
	    WHEN SPL.CountryName = 'India' THEN 'India SC'                    
	    WHEN SPL.CountryName = 'Hong Kong SAR' THEN 'Hong Kong'                    
	    ELSE SPL.CountryName end )                    
	GROUP BY 
	  DGH.CDSOTBRegionName
	  ,DC.FiscalWeekStartDate               
	 ,[Pos].[SKU]                                      
	) 
	SELECT CellID,SKU,PlanningRegion
	,CASE WHEN CellID=1  THEN SUM(OpenQty) ELSE 0 END AS [T]   
	 ,CASE WHEN CellID=2  THEN SUM(OpenQty) ELSE 0 END AS [T+1]   
	 ,CASE WHEN CellID=3  THEN SUM(OpenQty) ELSE 0 END AS [T+2]   
	 ,CASE WHEN CellID=4  THEN SUM(OpenQty) ELSE 0 END AS [T+3]   
	 ,CASE WHEN CellID=5  THEN SUM(OpenQty) ELSE 0 END AS [T+4]   
	 ,CASE WHEN CellID=6  THEN SUM(OpenQty) ELSE 0 END AS [T+5]   
	 ,CASE WHEN CellID=7  THEN SUM(OpenQty) ELSE 0 END AS [T+6]   
	 ,CASE WHEN CellID=8  THEN SUM(OpenQty) ELSE 0 END AS [T+7]   
	 ,CASE WHEN CellID=9  THEN SUM(OpenQty) ELSE 0 END AS [T+8]   
	 ,CASE WHEN CellID=10 THEN SUM(OpenQty) ELSE 0 END AS [T+9]   
	 ,CASE WHEN CellID=11 THEN SUM(OpenQty) ELSE 0 END AS [T+10]  
	 ,CASE WHEN CellID=12 THEN SUM(OpenQty) ELSE 0 END AS [T+11]  
	 ,CASE WHEN CellID=13 THEN SUM(OpenQty) ELSE 0 END AS [T+12]  
	 ,CASE WHEN CellID=14 THEN SUM(OpenQty) ELSE 0 END AS [T+13]  
	 ,CASE WHEN CellID=15 THEN SUM(OpenQty) ELSE 0 END AS [T+14]  
	 ,CASE WHEN CellID=16 THEN SUM(OpenQty) ELSE 0 END AS [T+15]  
	 ,CASE WHEN CellID=17 THEN SUM(OpenQty) ELSE 0 END AS [T+16]  
	 ,CASE WHEN CellID=18 THEN SUM(OpenQty) ELSE 0 END AS [T+17]  
	 ,CASE WHEN CellID=19 THEN SUM(OpenQty) ELSE 0 END AS [T+18]  
	 ,CASE WHEN CellID=20 THEN SUM(OpenQty) ELSE 0 END AS [T+19]  
	 ,CASE WHEN CellID=21 THEN SUM(OpenQty) ELSE 0 END AS [T+20]  
	 ,CASE WHEN CellID=22 THEN SUM(OpenQty) ELSE 0 END AS [T+21]  
	 ,CASE WHEN CellID=23 THEN SUM(OpenQty) ELSE 0 END AS [T+22]  
	 ,CASE WHEN CellID=24 THEN SUM(OpenQty) ELSE 0 END AS [T+23]
	INTO [FLR].[OpenPOs]
	FROM CTE_OpenPOS COP WITH (NOLOCK)
	JOIN 
		CTE_PODates AS POD WITH (NOLOCK) 
		ON POD.FiscalWeekStartDate = COP.FiscalWeekStartDate 
	GROUP BY SKU,COP.FiscalWeekStartDate,PlanningRegion,CellID
	 
	 --Populate Inventory table
	 ;WITH CTE_InventoryDates AS
	(
	SELECT DISTINCT DateKey,CalendarDate,ROW_NUMBER() OVER(ORDER BY CalendarDate) AS CellID
	FROM mer.vwDimCalendar WITH (NOLOCK)
	WHERE FiscalWeekStartDate = CalendarDate
	AND FiscalWeekStartDate >= @Start AND FiscalWeekStartDate<=@Current
	)
	,CTE_Inventory AS (
	SELECT 
	ID.CellID
	,SKU
	,CASE WHEN Region IN ('APOC','APAC') THEN 'APOC'
	WHEN Region IN ('EOC','EMEA') THEN 'EOC'
	WHEN Region = ('AOC') THEN 'AOC'
	END AS PlanningRegion
	,SUM(OnHandQty) AS Qty
	FROM [Tab].[InventoryOnHandSnapshot_Tab] AS I WITH (NOLOCK)
	JOIN 
		CTE_InventoryDates AS ID WITH (NOLOCK) 
		ON ID.DateKey = I.SnapshotDateKey
	JOIN 
		FLR.ForecastCategorization AS CI WITH (NOLOCK) 
		ON CI.ItemID = I.SKU
	WHERE Region IS NOT NULL AND Region <>''
	GROUP BY CalendarDate,Region,SKU,ID.CellID
	)
	SELECT I.CellID,SKU,PlanningRegion,
	CASE WHEN I.CellID=2 THEN  SUM(Qty) ELSE 0 END AS [T-12]     
	,CASE WHEN I.CellID=3 THEN  SUM(Qty) ELSE 0 END AS [T-11]     
	,CASE WHEN I.CellID=4 THEN  SUM(Qty) ELSE 0 END AS [T-10]     
	,CASE WHEN I.CellID=5 THEN  SUM(Qty) ELSE 0 END AS [T-9]     
	,CASE WHEN I.CellID=6 THEN  SUM(Qty) ELSE 0 END AS [T-8]     
	,CASE WHEN I.CellID=7 THEN  SUM(Qty) ELSE 0 END AS [T-7]     
	,CASE WHEN I.CellID=8 THEN  SUM(Qty) ELSE 0 END AS [T-6]     
	,CASE WHEN I.CellID=9 THEN  SUM(Qty) ELSE 0 END AS [T-5]     
	,CASE WHEN I.CellID=10 THEN SUM(Qty) ELSE 0 END AS [T-4]     
	,CASE WHEN I.CellID=11 THEN SUM(Qty) ELSE 0 END AS [T-3]    
	,CASE WHEN I.CellID=12 THEN SUM(Qty) ELSE 0 END AS [T-2]    
	,CASE WHEN I.CellID=13 THEN SUM(Qty) ELSE 0 END AS [T-1]  
	INTO [FLR].[Inventory]
	FROM CTE_Inventory AS I WITH (NOLOCK)
	GROUP BY PlanningRegion,SKU,I.CellID
	
	--Get Historical Sales data
	;WITH CTE_SalesHistDates AS 
	(
	SELECT DISTINCT CalendarDate AS WeekDates,ROW_NUMBER() OVER(ORDER BY CalendarDate) AS CellID
	FROM mer.vwDimCalendar WITH (NOLOCK)
	WHERE FiscalWeekStartDate = CalendarDate
	AND FiscalWeekStartDate >= @Start AND FiscalWeekStartDate<@Current  
	)
	, CTE_Sales AS (
	SELECT  c.PlanningRegion,SD.CellID,
			CASE WHEN UL.Channel = 'Digital' THEN 'Online'
			ELSE 'B&M' END AS Channel
	,SKU   
	,CASE WHEN SD.CellID=1 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-12]     
	,CASE WHEN SD.CellID=2 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-11]     
	,CASE WHEN SD.CellID=3 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-10]     
	,CASE WHEN SD.CellID=4 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-9]     
	,CASE WHEN SD.CellID=5 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-8]     
	,CASE WHEN SD.CellID=6 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-7]     
	,CASE WHEN SD.CellID=7 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-6]     
	,CASE WHEN SD.CellID=8 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-5]     
	,CASE WHEN SD.CellID=9 THEN  SUM(UL.Quantity) ELSE 0 END AS [T-4]     
	,CASE WHEN SD.CellID=10 THEN SUM(UL.Quantity) ELSE 0 END AS [T-3]    
	,CASE WHEN SD.CellID=11 THEN SUM(UL.Quantity) ELSE 0 END AS [T-2]    
	,CASE WHEN SD.CellID=12 THEN SUM(UL.Quantity) ELSE 0 END AS [T-1]  
	FROM dbo.UlyssesDailyGrainData_Cube AS UL WITH (NOLOCK)
	 JOIN 
		tab.vwDimCountry AS c WITH (NOLOCK) 
		ON ul.SubsidiaryKey = c.SubsidiaryKey 
	 JOIN 
		mer.vwDimCalendar AS DC WITH (NOLOCK) 
		ON DC.DateKey = UL.DateKey AND Dc.FiscalWeekStartDate>= @Start AND DC.FiscalWeekStartDate <= @Current
	 JOIN 
		CTE_SalesHistDates AS SD WITH (NOLOCK) 
		ON DC.FiscalWeekStartDate = SD.Weekdates
	 JOIN 
		FLR.ForecastCategorization AS CI WITH (NOLOCK) 
		ON CI.ItemID = UL.SKU
	 GROUP BY c.PlanningRegion,UL.Channel,SD.CellID,SKU
	 )
	 SELECT SKU,Channel
	,SUM([T-12]) AS  [T-12]
	,SUM([T-11]) AS  [T-11]
	,SUM([T-10]) AS  [T-10]
	,SUM([T-9])  AS  [T-9]
	,SUM([T-8])  AS  [T-8]
	,SUM([T-7])  AS  [T-7]
	,SUM([T-6])  AS  [T-6]
	,SUM([T-5])  AS  [T-5]
	,SUM([T-4])  AS  [T-4]
	,SUM([T-3])  AS  [T-3]
	,SUM([T-2])  AS  [T-2]
	,SUM([T-1])  AS  [T-1]
	INTO [FLR].[ItemHistoricalSales]
	FROM CTE_Sales WITH (NOLOCK)
	GROUP BY SKU,Channel
	
	--Get Forecast Demand data
	;WITH CTE_ForecastDates AS  
	(  
	SELECT DISTINCT FiscalWeekStartDate AS WeekDates,ROW_NUMBER() OVER(ORDER BY CalendarDate) AS CellID
	FROM mer.vwDimCalendar WITH (NOLOCK)
	WHERE FiscalWeekStartDate = CalendarDate
	AND FiscalWeekStartDate >= @Current AND FiscalWeekStartDate<=@End
	) 
	SELECT WD.CellID,DC.PlanningRegion,FD.ItemID,FD.Channel  
	,CASE WHEN WD.CellID=1 THEN SUM(FD.Forecast) ELSE 0 END AS [T]   
	,CASE WHEN WD.CellID=2 THEN SUM(FD.Forecast) ELSE 0 END AS [T+1]   
	,CASE WHEN WD.CellID=3 THEN SUM(FD.Forecast) ELSE 0 END AS [T+2]   
	,CASE WHEN WD.CellID=4 THEN SUM(FD.Forecast) ELSE 0 END AS [T+3]   
	,CASE WHEN WD.CellID=5 THEN SUM(FD.Forecast) ELSE 0 END AS [T+4]   
	,CASE WHEN WD.CellID=6 THEN SUM(FD.Forecast) ELSE 0 END AS [T+5]   
	,CASE WHEN WD.CellID=7 THEN SUM(FD.Forecast) ELSE 0 END AS [T+6]   
	,CASE WHEN WD.CellID=8 THEN SUM(FD.Forecast) ELSE 0 END AS [T+7]   
	,CASE WHEN WD.CellID=9 THEN SUM(FD.Forecast) ELSE 0 END AS [T+8]   
	,CASE WHEN WD.CellID=10 THEN SUM(FD.Forecast) ELSE 0 END AS [T+9]   
	,CASE WHEN WD.CellID=11 THEN SUM(FD.Forecast) ELSE 0 END AS [T+10]  
	,CASE WHEN WD.CellID=12 THEN SUM(FD.Forecast) ELSE 0 END AS [T+11]  
	,CASE WHEN WD.CellID=13 THEN SUM(FD.Forecast) ELSE 0 END AS [T+12]  
	,CASE WHEN WD.CellID=14 THEN SUM(FD.Forecast) ELSE 0 END AS [T+13]  
	,CASE WHEN WD.CellID=15 THEN SUM(FD.Forecast) ELSE 0 END AS [T+14]  
	,CASE WHEN WD.CellID=16 THEN SUM(FD.Forecast) ELSE 0 END AS [T+15]  
	,CASE WHEN WD.CellID=17 THEN SUM(FD.Forecast) ELSE 0 END AS [T+16]  
	,CASE WHEN WD.CellID=18 THEN SUM(FD.Forecast) ELSE 0 END AS [T+17]  
	,CASE WHEN WD.CellID=19 THEN SUM(FD.Forecast) ELSE 0 END AS [T+18]  
	,CASE WHEN WD.CellID=20 THEN SUM(FD.Forecast) ELSE 0 END AS [T+19]  
	,CASE WHEN WD.CellID=21 THEN SUM(FD.Forecast) ELSE 0 END AS [T+20]  
	,CASE WHEN WD.CellID=22 THEN SUM(FD.Forecast) ELSE 0 END AS [T+21]  
	,CASE WHEN WD.CellID=23 THEN SUM(FD.Forecast) ELSE 0 END AS [T+22]  
	,CASE WHEN WD.CellID=24 THEN SUM(FD.Forecast) ELSE 0 END AS [T+23] 
	INTO [FLR].[ItemForecast]
	FROM [dbo].[FactForecastDemand] AS FD WITH (NOLOCK)  
	JOIN 
		tab.vwDimCountry AS DC WITH (NOLOCK) 
		ON DC.CountryCode =FD.CountryCode   
	JOIN 
		CTE_ForecastDates AS WD WITH (NOLOCK) 
		ON WD.Weekdates = FD.[Period] 
	JOIN 
		FLR.ForecastCategorization AS CI WITH (NOLOCK) 
		ON CI.ItemID = FD.ItemID
	WHERE FD.[Period]>= @Current AND FD.[Period] <= @End 
	GROUP BY WD.CellID,DC.PlanningRegion,FD.ItemID,FD.Channel  

	CREATE NONCLUSTERED INDEX NCIX_ItemForecast ON [FLR].[ItemForecast]  ([ItemID]) INCLUDE(PlanningRegion);  
	CREATE NONCLUSTERED INDEX NCIX_ItemHistoricalSales ON [FLR].[ItemHistoricalSales] ([SKU]);  
	CREATE NONCLUSTERED INDEX NCIX_OpenPOs ON [FLR].[OpenPOs] ([SKU]) INCLUDE(PlanningRegion);   
	CREATE NONCLUSTERED INDEX NCIX_Inventory ON [FLR].[Inventory] ([SKU]) INCLUDE(PlanningRegion); 
	
END   