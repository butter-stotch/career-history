
				/*UPDATE [tmp].[PriorityNotes] 
				SET [Feedback_Cleaned_Stopwords] = TRIM(REPLACE(CONCAT(' ',[Feedback_Cleaned_Stopwords], ' '),
				SUBSTRING(CONCAT(' ',[Feedback_Cleaned_Stopwords], ' '),PATINDEX('% _'+@CurrentStopword+'_ %', CONCAT(' ',[Feedback_Cleaned_Stopwords], ' ')),LEN(@CurrentStopword)+3) , ''))
				
				UPDATE [tmp].[PriorityNotes] 
				SET [Feedback_Cleaned_Stopwords] = TRIM(REPLACE(CONCAT(' ',[Feedback_Cleaned_Stopwords], ' '),
				SUBSTRING(CONCAT(' ',[Feedback_Cleaned_Stopwords], ' '),PATINDEX('% '+@CurrentStopword+'_ %', CONCAT(' ',[Feedback_Cleaned_Stopwords], ' ')),LEN(@CurrentStopword)+2) , ''))
				
				UPDATE [tmp].[PriorityNotes] 
				SET [Feedback_Cleaned_Stopwords] = TRIM(REPLACE(CONCAT(' ',[Feedback_Cleaned_Stopwords], ' '),
				SUBSTRING(CONCAT(' ',[Feedback_Cleaned_Stopwords], ' '),PATINDEX('% _'+@CurrentStopword+' %', CONCAT(' ',[Feedback_Cleaned_Stopwords], ' ')),LEN(@CurrentStopword)+2) , ''))
				*/