IF OBJECT_ID (N'dbo.SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_SITE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_SITE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER '2016-01', '2016-12', ''

*/
CREATE PROCEDURE [dbo].[SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_SITE]
		@P_START_DATE AS VARCHAR(7)
	,	@P_END_DATE AS VARCHAR(7)
	,	@P_SALES_GUBUN AS VARCHAR(100)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @T_MONTH TABLE
    (
		[MONTH] VARCHAR(7)
	)	

	INSERT INTO @T_MONTH ([MONTH])

	SELECT	CONVERT(VARCHAR(7), DATEADD(D, NUMBER, @P_START_DATE + '-01'), 120) [MONTH]
	FROM	MASTER..SPT_VALUES
	WHERE	TYPE = 'P' 
	AND		NUMBER <= DATEDIFF(D, @P_START_DATE + '-01', CONVERT(VARCHAR(4), DATEADD(YEAR, 1, SUBSTRING(@P_END_DATE, 1, 4)), 120) + '-12-01')
	GROUP BY CONVERT(VARCHAR(7), DATEADD(D,NUMBER,@P_START_DATE + '-01'), 120)

	

	SET @P_SALES_GUBUN = CASE WHEN @P_SALES_GUBUN = 'SB|SA|ST|SS|B|H|C' THEN '' ELSE @P_SALES_GUBUN END



	SELECT	A.SAMPLE_DELIVERY_DATE																		AS SampleDeliveryMonth
		,	TM.MONTH																					AS ConversionMonth
		,	MAX(CASE WHEN A.CUSTOM_DELIVERY_DATE = TM.MONTH THEN A.WEDDING_INVITATION_QNT ELSE 0 END)	AS WeddingInvitationCount
		,	MAX(A.SAMPLE_ORDER_QNT)																		AS SampleCount
		,	ROUND
			(	1.0 
				* MAX(CASE WHEN A.CUSTOM_DELIVERY_DATE = TM.MONTH THEN A.WEDDING_INVITATION_QNT ELSE 0 END) 
				/ MAX(A.SAMPLE_ORDER_QNT) * 100
				, 2
			)	AS Rate

	FROM	(
	
				SELECT	CSO.SAMPLE_DELIVERY_DATE
					,	CO.CUSTOM_DELIVERY_DATE
					,	CSO.SAMPLE_ORDER_QNT
					,	CO.WEDDING_INVITATION_QNT
				FROM	(

							SELECT	CONVERT(VARCHAR(7), DELIVERY_DATE, 120)			AS SAMPLE_DELIVERY_DATE
								,	COUNT(*)										AS SAMPLE_ORDER_QNT
							FROM	CUSTOM_SAMPLE_ORDER
							WHERE	1 = 1
							AND		STATUS_SEQ = 12
							--AND		ISNULL(MEMBER_ID, '') <> ''

							AND		(@P_SALES_GUBUN = '' OR SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))
							AND		DELIVERY_DATE >= @P_START_DATE + '-01 00:00:00'
							AND		DELIVERY_DATE < DATEADD(MM, 1, @P_END_DATE + '-01 00:00:00')		
							GROUP BY CONVERT(VARCHAR(7), DELIVERY_DATE, 120)

						) AS CSO
				LEFT
				JOIN	(			

							SELECT	CONVERT(VARCHAR(7), CSO.DELIVERY_DATE, 120)				AS SAMPLE_DELIVERY_DATE
								,	CONVERT(VARCHAR(7), CO.SRC_SEND_DATE, 120)				AS CUSTOM_DELIVERY_DATE
								,	SUM(CASE WHEN CO.MEMBER_ID IS NULL THEN 0 ELSE 1 END)	AS WEDDING_INVITATION_QNT
							FROM	CUSTOM_SAMPLE_ORDER CSO
							LEFT
							JOIN	CUSTOM_ORDER CO 
								--ON		CSO.MEMBER_ID = CO.MEMBER_ID 
                                ON      CSO.MEMBER_EMAIL = CO.order_email
                                --ON      CSO.MEMBER_HPHONE = CO.order_hphone
								AND		CO.SRC_SEND_DATE IS NOT NULL
								AND		CSO.DELIVERY_DATE <= CO.SRC_SEND_DATE
								AND		(@P_SALES_GUBUN = '' OR CO.SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))
								AND		CO.STATUS_SEQ = 15
								AND		CO.SRC_SEND_DATE >= @P_START_DATE + '-01 00:00:00'
                                --AND		CO.SRC_SEND_DATE < DATEADD(MM, 1, @P_END_DATE + '-01 00:00:00')
								AND		CO.ORDER_TYPE IN (1,3,6,7)

							WHERE	1 = 1
							AND		CSO.STATUS_SEQ = 12
							--AND		ISNULL(CSO.MEMBER_ID, '') <> ''

							AND		(@P_SALES_GUBUN = '' OR CSO.SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))
							AND		CSO.DELIVERY_DATE >= @P_START_DATE + '-01 00:00:00'
							AND		CSO.DELIVERY_DATE < DATEADD(MM, 1, @P_END_DATE + '-01 00:00:00')

							GROUP BY CONVERT(VARCHAR(7), CSO.DELIVERY_DATE, 120), CONVERT(VARCHAR(7), CO.SRC_SEND_DATE, 120)

						) AS CO ON CSO.SAMPLE_DELIVERY_DATE = CO.SAMPLE_DELIVERY_DATE
			) A
	LEFT
	JOIN	@T_MONTH TM ON 1 = 1

	WHERE	1 = 1

	GROUP BY A.SAMPLE_DELIVERY_DATE, TM.MONTH
	ORDER BY A.SAMPLE_DELIVERY_DATE ASC, TM.MONTH ASC



END
GO
