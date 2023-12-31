IF OBJECT_ID (N'dbo.SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_WEDDING_V2_FOR_DATE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_WEDDING_V2_FOR_DATE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: <2018.09.19>
-- Description:	<샘플 주문 예식율 날짜기준 검색>
-- EXEC SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_WEDDING_V2_FOR_DATE '2018-06-01', '2018-07-01', 'SB|SA|ST'
-- =============================================

CREATE PROCEDURE [dbo].[SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_WEDDING_V2_FOR_DATE]
		@P_START_DATE AS VARCHAR(10)
	,	@P_END_DATE AS VARCHAR(10)
	,	@P_SALES_GUBUN AS VARCHAR(100)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @T_MONTH TABLE
    (
		[MONTH] VARCHAR(7)
	)	

	INSERT INTO @T_MONTH ([MONTH])

	SELECT	CONVERT(VARCHAR(7), DATEADD(D, NUMBER, @P_START_DATE), 120) [MONTH]
	FROM	MASTER..SPT_VALUES
	WHERE	TYPE = 'P' 
	AND		NUMBER <= DATEDIFF(D, @P_START_DATE, CONVERT(VARCHAR(4), DATEADD(YEAR, 1, SUBSTRING(@P_END_DATE, 1, 4)), 120) + '-12-01')
	GROUP BY CONVERT(VARCHAR(7), DATEADD(D,NUMBER,@P_START_DATE), 120)

	

	SET @P_SALES_GUBUN = CASE WHEN @P_SALES_GUBUN = 'SB|SA|ST|SS|B|H|C' THEN '' ELSE @P_SALES_GUBUN END



    SELECT      Z.SAMPLE_DELIVERY_DATE	AS SampleDeliveryMonth
		    ,	T.MONTH					AS ConversionMonth
		    ,	MAX(CASE WHEN Z.CUSTOM_WEDDING_DATE = T.MONTH THEN Z.WEDDING_INVITATION_QNT ELSE 0 END)	AS WeddingInvitationCount
		    ,	SUM(Z.NON_SAMPLE_QTY + Z.SAMPLE_QTY)													AS SampleCount
		    ,	SUM(Z.NON_SAMPLE_QTY)													                AS SampleNonRegCount
		    ,	SUM(Z.SAMPLE_QTY)													                AS SampleRegCount
		    ,	ROUND(1.0 * MAX(CASE WHEN Z.CUSTOM_WEDDING_DATE = T.MONTH THEN Z.WEDDING_INVITATION_QNT ELSE 0 END) / SUM(Z.NON_SAMPLE_QTY + Z.SAMPLE_QTY) * 100, 2) AS Rate
		    ,	MAX(CASE WHEN Z.CUSTOM_WEDDING_DATE = T.MONTH THEN Z.NON_SAMPLE_QTY ELSE 0 END)	AS NonRegQtyCount
		    ,	MAX(CASE WHEN Z.CUSTOM_WEDDING_DATE = T.MONTH THEN Z.SAMPLE_QTY ELSE 0 END)	AS RegQtyCount
    FROM
    (
                    
    
        SELECT	A.SAMPLE_DELIVERY_DATE
				,	A.CUSTOM_WEDDING_DATE
				,	SUM(A.WEDDING_INVITATION_QNT)	AS WEDDING_INVITATION_QNT
				,	SUM(A.SAMPLE_QTY)			    AS SAMPLE_QTY
				,	SUM(A.NON_SAMPLE_QTY)			AS NON_SAMPLE_QTY
                        
        FROM (


                    SELECT	    (CASE WHEN NON_REG_WEDD_DATE  <> '' THEN NON_REG_WEDD_DATE ELSE CONVERT(VARCHAR(7), ISNULL(VUI.WEDDING_DAY,''), 120) END ) AS CUSTOM_WEDDING_DATE
                            ,   SAMPLE_DELIVERY_DATE                                                                    AS SAMPLE_DELIVERY_DATE
							,	1														                                AS WEDDING_INVITATION_QNT
							,	(CASE WHEN NON_REG_WEDD_DATE <> '' THEN 1 ELSE 0 END)                                   AS NON_SAMPLE_QTY
							,	(CASE WHEN VUI.WEDDING_DAY IS NOT NULL AND NON_REG_WEDD_DATE = '' THEN 1 ELSE 0 END)    AS SAMPLE_QTY
				    FROM	( 
							    SELECT	CSO.SAMPLE_ORDER_SEQ
								    ,	MAX(CONVERT(VARCHAR(7), CSO.DELIVERY_DATE, 120))		        AS SAMPLE_DELIVERY_DATE
                                    ,   MAX(CONVERT(VARCHAR(7), ISNULL(CSO.WEDD_DATE,''), 120))	        AS NON_REG_WEDD_DATE
                                    ,   MAX(MEMBER_ID)                                                  AS MEMBER_ID
							    FROM	CUSTOM_SAMPLE_ORDER CSO
							    WHERE   1 = 1
                                AND 	CSO.STATUS_SEQ = 12
							    AND		(ISNULL(@P_SALES_GUBUN, '') = '' OR CSO.SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))
							    AND		CSO.DELIVERY_DATE >= @P_START_DATE + ' 00:00:00'
							    AND		CSO.DELIVERY_DATE <= @P_END_DATE + ' 23:59:59'

							    GROUP BY CSO.SAMPLE_ORDER_SEQ
                        ) CSOCO 
                    LEFT JOIN  VW_USER_INFO VUI
                        ON CSOCO.MEMBER_ID  = VUI.UID 
                        AND CSOCO.NON_REG_WEDD_DATE IS NOT NULL                
                        AND VUI.site_div = 'SB'
            ) A
            GROUP BY  A.SAMPLE_DELIVERY_DATE,  A.CUSTOM_WEDDING_DATE
    ) Z
    LEFT 
	JOIN	@T_MONTH T ON 1 = 1

	GROUP BY Z.SAMPLE_DELIVERY_DATE, T.MONTH
	ORDER BY Z.SAMPLE_DELIVERY_DATE ASC, T.MONTH ASC
END
GO
