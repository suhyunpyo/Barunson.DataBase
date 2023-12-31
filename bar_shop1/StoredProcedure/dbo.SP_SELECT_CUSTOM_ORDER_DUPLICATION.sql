IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_ORDER_DUPLICATION', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_ORDER_DUPLICATION
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_ORDER_DUPLICATION]

AS
BEGIN

SET NOCOUNT ON



SELECT	DISTINCT
		CASE WHEN A.ORDER_SEQ < B.ORDER_SEQ THEN A.ORDER_SEQ ELSE B.ORDER_SEQ END A_ORDER_SEQ
	,	CASE WHEN A.ORDER_SEQ < B.ORDER_SEQ THEN A.MEMBER_ID ELSE B.MEMBER_ID END A_MEMBER_ID
	,	CASE WHEN A.ORDER_SEQ < B.ORDER_SEQ THEN A.ORDER_NAME ELSE B.ORDER_NAME END A_ORDER_NAME
	,	CASE WHEN A.ORDER_SEQ < B.ORDER_SEQ THEN A.ORDER_HPHONE ELSE B.ORDER_HPHONE END A_ORDER_HPHONE
	
	,	CASE WHEN A.ORDER_SEQ > B.ORDER_SEQ THEN A.ORDER_SEQ ELSE B.ORDER_SEQ END B_ORDER_SEQ
	,	CASE WHEN A.ORDER_SEQ > B.ORDER_SEQ THEN A.MEMBER_ID ELSE B.MEMBER_ID END B_MEMBER_ID
	,	CASE WHEN A.ORDER_SEQ > B.ORDER_SEQ THEN A.ORDER_NAME ELSE B.ORDER_NAME END B_ORDER_NAME
	,	CASE WHEN A.ORDER_SEQ > B.ORDER_SEQ THEN A.ORDER_HPHONE ELSE B.ORDER_HPHONE END B_ORDER_HPHONE
	
FROM	(
			SELECT	ORDER_SEQ AS ORDER_SEQ, MEMBER_ID AS MEMBER_ID, ORDER_NAME AS ORDER_NAME
				,	REPLACE(ORDER_HPHONE, '-', '') ORDER_HPHONE
			FROM	CUSTOM_ORDER
			WHERE	STATUS_SEQ = 10 
			AND		SALES_GUBUN <> 'XB'
		) A

JOIN	(
			SELECT	ORDER_SEQ AS ORDER_SEQ, MEMBER_ID AS MEMBER_ID, ORDER_NAME AS ORDER_NAME
				,	REPLACE(ORDER_HPHONE, '-', '') ORDER_HPHONE
			FROM	CUSTOM_ORDER
			WHERE	STATUS_SEQ = 10 
			AND		SALES_GUBUN <> 'XB'
		) B 
		
ON	A.ORDER_SEQ <> B.ORDER_SEQ 
AND (
			(A.ORDER_NAME = B.ORDER_NAME AND A.ORDER_NAME <> '' AND B.ORDER_NAME <> '' AND A.ORDER_NAME IS NOT NULL AND B.ORDER_NAME IS NOT NULL)
		OR	(A.MEMBER_ID = b.MEMBER_ID AND A.MEMBER_ID <> '' AND B.MEMBER_ID <> '' AND A.MEMBER_ID IS NOT NULL AND A.MEMBER_ID IS NOT NULL)
		OR	(A.ORDER_HPHONE = B.ORDER_HPHONE AND A.ORDER_HPHONE <> '' AND B.ORDER_HPHONE <> '' AND A.ORDER_HPHONE IS NOT NULL AND B.ORDER_HPHONE IS NOT NULL )
	)



END




GO
