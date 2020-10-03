USE [Staging]
GO
/****** Object:  StoredProcedure [FLR].[usp_PopulateDependentExcelData]    Script Date: 6/20/2020 6:44:26 PM ******/
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
	  
	DROP TABLE IF EXISTS [FLR].[ItemForecast];  
	DROP TABLE IF EXISTS [FLR].[ItemHistoricalSales];  
	DROP TABLE IF EXISTS [FLR].[OpenPOs]; 
	DROP TABLE IF EXISTS [FLR].[Inventory]; 
	
	DECLARE @Current DATE = (SELECT MIN([Period]) FROM [dbo].[FactForecastDemand] WITH (NOLOCK))    
	DECLARE @End DATE = (SELECT DATEADD(WEEK,23,@Current))    
	DECLARE @Start DATE = (SELECT DATEADD(WEEK,-12,@Current))
	DECLARE @StartColumn INT = 5 
	
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
	 ,SUM(ISNULL([Pos].[OpenPOQty],0)) AS OpenQty                               
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
	SELECT SKU,PlanningRegion
			,ISNULL([1],0) AS [T]  
			,ISNULL([2],0) AS [T+1]  
			,ISNULL([3],0) AS [T+2]  
			,ISNULL([4],0) AS [T+3]  
			,ISNULL([5],0) AS [T+4]  
			,ISNULL([6],0) AS [T+5]  
			,ISNULL([7],0) AS [T+6]  
			,ISNULL([8],0) AS [T+7]  
			,ISNULL([9],0) AS [T+8]  
			,ISNULL([10],0) AS [T+9]  
			,ISNULL([11],0) AS [T+10] 
			,ISNULL([12],0) AS [T+11] 
			,ISNULL([13],0) AS [T+12] 
			,ISNULL([14],0) AS [T+13] 
			,ISNULL([15],0) AS [T+14] 
			,ISNULL([16],0) AS [T+15] 
			,ISNULL([17],0) AS [T+16] 
			,ISNULL([18],0) AS [T+17] 
			,ISNULL([19],0) AS [T+18] 
			,ISNULL([20],0) AS [T+19] 
			,ISNULL([21],0) AS [T+20] 
			,ISNULL([22],0) AS [T+21] 
			,ISNULL([23],0) AS [T+22] 
			,ISNULL([24],0) AS [T+23] 
	INTO [FLR].[OpenPOs] 
	FROM 
	(
	SELECT CellID,SKU,PlanningRegion,SUM(ISNULL(OpenQty,0)) AS OpenQty
	FROM CTE_OpenPOS COP WITH (NOLOCK)
	JOIN 
		CTE_PODates AS POD WITH (NOLOCK) 
		ON POD.FiscalWeekStartDate = COP.FiscalWeekStartDate 
	GROUP BY SKU,COP.FiscalWeekStartDate,PlanningRegion,CellID
	) pos_to_pivot
	PIVOT(
	    SUM([OpenQty]) 
	    FOR CellID IN (
			[1]
			,[2]
			,[3]
			,[4]
			,[5]
			,[6]
			,[7]
			,[8]
			,[9]
			,[10]
			,[11]
			,[12]
			,[13]
			,[14]
			,[15]
			,[16]
			,[17]
			,[18]
			,[19]
			,[20]
			,[21]
			,[22]
			,[23]
			,[24]
			)
	) AS pivot_pos;
	 
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
	,SUM(ISNULL(OnHandQty,0)) AS Qty
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
	SELECT SKU,PlanningRegion,
			 ISNULL([2],0) AS [T-12]
			,ISNULL([3],0) AS [T-11]
			,ISNULL([4],0) AS [T-10]
			,ISNULL([5],0) AS [T-9] 
			,ISNULL([6],0) AS [T-8] 
			,ISNULL([7],0) AS [T-7] 
			,ISNULL([8],0) AS [T-6] 
			,ISNULL([9],0) AS [T-5] 
			,ISNULL([10],0) AS [T-4] 
			,ISNULL([11],0) AS [T-3] 
			,ISNULL([12],0) AS [T-2] 
			,ISNULL([13],0) AS [T-1] 
	INTO [FLR].[Inventory]
	FROM
	(
	SELECT I.CellID,SKU,PlanningRegion,SUM(ISNULL(Qty,0)) AS Qty
	FROM CTE_Inventory AS I WITH (NOLOCK)
	GROUP BY PlanningRegion,SKU,I.CellID
	) inventory_to_pivot 
	PIVOT(
	    SUM([Qty]) 
	    FOR CellID IN (
			 [2]
			,[3]
			,[4]
			,[5]
			,[6]
			,[7]
			,[8]
			,[9]
			,[10]
			,[11]
			,[12]
			,[13]
			)
	) AS pivot_inventory;
	
	--Get Historical Sales data
	;WITH CTE_SalesHistDates AS 
	(
	SELECT DISTINCT CalendarDate AS WeekDates,ROW_NUMBER() OVER(ORDER BY CalendarDate) AS CellID
	FROM mer.vwDimCalendar WITH (NOLOCK)
	WHERE FiscalWeekStartDate = CalendarDate
	AND FiscalWeekStartDate >= @Start AND FiscalWeekStartDate<@Current  
	)
	SELECT PlanningRegion,Channel,SKU
			,ISNULL([1],0) AS [T-12]
			,ISNULL([2],0) AS [T-11]
			,ISNULL([3],0) AS [T-10]
			,ISNULL([4],0) AS [T-9] 
			,ISNULL([5],0) AS [T-8] 
			,ISNULL([6],0) AS [T-7] 
			,ISNULL([7],0) AS [T-6] 
			,ISNULL([8],0) AS [T-5] 
			,ISNULL([9],0) AS [T-4] 
			,ISNULL([10],0) AS [T-3] 
			,ISNULL([11],0) AS [T-2] 
			,ISNULL([12],0) AS [T-1] 
	INTO [FLR].[ItemHistoricalSales]
	FROM
	(
	SELECT  c.PlanningRegion,SD.CellID,SKU,  
			CASE WHEN UL.Channel = 'Digital' THEN 'Online'
				ELSE 'B&M' END AS Channel
			,SUM(ISNULL(UL.Quantity,0)) AS Quantity
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
	 ) sales_to_pivot
	 PIVOT(
	    SUM([Quantity]) 
	    FOR CellID IN (
	        [1]
			,[2]
			,[3]
			,[4]
			,[5]
			,[6]
			,[7]
			,[8]
			,[9]
			,[10]
			,[11]
			,[12]
			)
	) AS pivot_sales;

	--Get Forecast Demand data
	;WITH CTE_ForecastDates AS  
	(  
	SELECT DISTINCT FiscalWeekStartDate AS WeekDates,ROW_NUMBER() OVER(ORDER BY CalendarDate) AS CellID
	FROM mer.vwDimCalendar WITH (NOLOCK)
	WHERE FiscalWeekStartDate = CalendarDate
	AND FiscalWeekStartDate >= @Current AND FiscalWeekStartDate<=@End
	) 
	SELECT PlanningRegion,Channel,ItemID
			,ISNULL([1],0) AS [T]  
			,ISNULL([2],0) AS [T+1]  
			,ISNULL([3],0) AS [T+2]  
			,ISNULL([4],0) AS [T+3]  
			,ISNULL([5],0) AS [T+4]  
			,ISNULL([6],0) AS [T+5]  
			,ISNULL([7],0) AS [T+6]  
			,ISNULL([8],0) AS [T+7]  
			,ISNULL([9],0) AS [T+8]  
			,ISNULL([10],0) AS [T+9]  
			,ISNULL([11],0) AS [T+10] 
			,ISNULL([12],0) AS [T+11] 
			,ISNULL([13],0) AS [T+12] 
			,ISNULL([14],0) AS [T+13] 
			,ISNULL([15],0) AS [T+14] 
			,ISNULL([16],0) AS [T+15] 
			,ISNULL([17],0) AS [T+16] 
			,ISNULL([18],0) AS [T+17] 
			,ISNULL([19],0) AS [T+18] 
			,ISNULL([20],0) AS [T+19] 
			,ISNULL([21],0) AS [T+20] 
			,ISNULL([22],0) AS [T+21] 
			,ISNULL([23],0) AS [T+22] 
			,ISNULL([24],0) AS [T+23] 
	INTO [FLR].[ItemForecast]
	FROM
	(
	SELECT WD.CellID,DC.PlanningRegion,FD.ItemID,FD.Channel,SUM(ISNULL(FD.Forecast,0)) AS Forecast
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
	) forecast_to_pivot
	PIVOT(
	    SUM([Forecast]) 
	    FOR CellID IN (
			[1]
			,[2]
			,[3]
			,[4]
			,[5]
			,[6]
			,[7]
			,[8]
			,[9]
			,[10]
			,[11]
			,[12]
			,[13]
			,[14]
			,[15]
			,[16]
			,[17]
			,[18]
			,[19]
			,[20]
			,[21]
			,[22]
			,[23]
			,[24]
			)
	) AS pivot_forecast;

	CREATE NONCLUSTERED INDEX NCIX_ItemForecast ON [FLR].[ItemForecast]  ([ItemID]) INCLUDE(PlanningRegion);  
	CREATE NONCLUSTERED INDEX NCIX_ItemHistoricalSales ON [FLR].[ItemHistoricalSales] ([SKU]);  
	CREATE NONCLUSTERED INDEX NCIX_OpenPOs ON [FLR].[OpenPOs] ([SKU]) INCLUDE(PlanningRegion);   
	CREATE NONCLUSTERED INDEX NCIX_Inventory ON [FLR].[Inventory] ([SKU]) INCLUDE(PlanningRegion); 
	
END   