IF OBJECT_ID (N'dbo.FN_GET_DATE_FOR_CHOAN_SMS', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_DATE_FOR_CHOAN_SMS', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_DATE_FOR_CHOAN_SMS', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_DATE_FOR_CHOAN_SMS', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_DATE_FOR_CHOAN_SMS', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_GET_DATE_FOR_CHOAN_SMS
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[FN_GET_DATE_FOR_CHOAN_SMS] (@TARGET_DATE AS DATETIME, @INCREMENT AS INT)
RETURNS DATETIME
AS
BEGIN 

	DECLARE @RESULT_DATE AS DATETIME

	SET @TARGET_DATE = DATEADD(DAY, @INCREMENT, @TARGET_DATE)

	SET @RESULT_DATE = 
	
	(

		SELECT	CASE                                                                                                                                                                                                                                                       

				/* 공휴일 주문건이면 휴일 끝나는 다음날 23:59:59 까지 등록되야함 */                                                                                                                                                                                                        
				WHEN (SELECT ISNULL(END_DATE, '') FROM S4_HOLIDAY WHERE START_DATE <= @TARGET_DATE AND END_DATE >= @TARGET_DATE) <> '' THEN (SELECT DATEADD(DD, 1, END_DATE) FROM S4_HOLIDAY WHERE START_DATE <= @TARGET_DATE AND END_DATE >= @TARGET_DATE) 

				/* 일요일 주문건이면 +1일 월요일 23:59:59 까지 등록되야함 */                                                                                                                                                                                                         
				WHEN DATEPART(DW, @TARGET_DATE) = 1 THEN DATEADD(DD, 1, @TARGET_DATE)
   
				/* 토요일 주문건이면 +2일 월요일 23:59:59 까지 등록되야함 */                                                                                                                                                                                                         
				WHEN DATEPART(DW, @TARGET_DATE) = 7 THEN DATEADD(DD, 2, @TARGET_DATE)

				ELSE @TARGET_DATE                                                                         

				END AS TARGET_DATE
	
	)

	RETURN @RESULT_DATE

END
GO
