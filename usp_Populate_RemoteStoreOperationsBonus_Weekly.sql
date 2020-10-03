/* ================================================================ 
Project Name: VOC  
  
Module Name: [dbo].[usp_Populate_RemoteStoreOperationsBonus_Weekly]
  
Purpose:       
To update future weeks in [RemoteStoreOperations].[Bonus] for users
who haven't updated their status in current week.
  
Parameter Info  
None  

Return Info  
None  
  
Output:
[RemoteStoreOperations].[Bonus] is updated with latest data.
  
Test Scripts:
	EXEC [dbo].[usp_Populate_RemoteStoreOperationsBonus_Weekly]

CHANGE HISTORY
===================================================================
ID		DESCRIPTION						AUTHOR			DATE
*****	***********						********		**********	
4623	Created							v-arjain		04/08/2020
===================================================================*/
ALTER PROCEDURE [dbo].[usp_Populate_RemoteStoreOperationsBonus_Weekly]
AS
BEGIN
	BEGIN TRY

		WITH CTE_NextWeek
		AS 
		(SELECT DISTINCT EMAIL FROM RemoteStoreOperations.Bonus 
		WHERE WeekFilter = CONVERT(NVARCHAR, GETDATE()+1, 101) +'-'+CONVERT(NVARCHAR, GETDATE()+7, 101)
		)

		INSERT INTO RemoteStoreOperations.Bonus
		SELECT 
		[Name]
		,[Email]
		,[Store]
		,[OptInStatus]
		,[Assignment]
		,[BonusEligibility]	
		,NULL AS [BonusAwarded]
		,DATEADD(minute,DATEDIFF(minute,[UTCCreatedDate],[CreatedDate]),GETUTCDATE()) AS [CreatedDate]
		,[CreatedBy]
		,CONVERT(NVARCHAR, GETDATE()+1, 101) +'-'+CONVERT(NVARCHAR, GETDATE()+7, 101) AS [WeekFilter]
		,GETUTCDATE() AS [UTCCreatedDate]
		FROM 
		(
		SELECT *, ROW_NUMBER () OVER(PARTITION BY [Email] ORDER BY ID DESC) AS RowNumber FROM 
			[RemoteStoreOperations].[bonus] (NOLOCK)
		) AS B
		WHERE RowNumber=1
		AND Email NOT IN (SELECT Email FROM CTE_NextWeek)

	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return 
		RAISERROR (
				@ErrorMessage
				,-- Message text
				@ErrorSeverity
				,-- Severity
				@ErrorState -- State
				);
	END CATCH
END