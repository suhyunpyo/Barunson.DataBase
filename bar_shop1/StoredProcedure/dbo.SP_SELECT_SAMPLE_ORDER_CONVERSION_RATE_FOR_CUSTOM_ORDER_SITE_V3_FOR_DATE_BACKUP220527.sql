IF OBJECT_ID (N'dbo.SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_SITE_V3_FOR_DATE_BACKUP220527', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_SITE_V3_FOR_DATE_BACKUP220527
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: <2018.09.19>
-- Description:	<샘플 주문 전환율(사이트) 날짜기준 검색>
-- EXEC SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_SITE_V3_FOR_DATE '2022-04-01', '2022-04-30', 'SB|SA|ST|SS|B|C|H'
-- =============================================

CREATE PROCEDURE [dbo].[SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_SITE_V3_FOR_DATE_BACKUP220527]
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



    SELECT	sample_order_seq AS Order_Seq
    INTO #OrderSeqTemp
    FROM	CUSTOM_SAMPLE_ORDER
    WHERE	1 = 1
    AND		STATUS_SEQ = 12
    AND		(@P_SALES_GUBUN = '' OR SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))
    AND		DELIVERY_DATE >= @P_START_DATE + ' 00:00:00'
    AND		DELIVERY_DATE <= @P_END_DATE + ' 23:59:59'

    UNION ALL

    SELECT  DISTINCT CEO.order_seq
    FROM    CUSTOM_ETC_ORDER CEO
    --JOIN CUSTOM_ETC_ORDER_ITEM CEOI ON CEO.ORDER_sEQ = CEOI.ORDER_SEQ 
    WHERE   CEO.status_seq >= 12
    AND		(@P_SALES_GUBUN = '' OR CEO.SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))   -- 검색조건 사이트구분
    AND     CEO.ORDER_TYPE = 'U' --CEOI.card_seq = 36154                                                                               -- 샘플북 코드
    AND     ISNULL(CEO.member_id, '' ) <> ''                                                                    -- 회원만가능
    AND		CEO.DELIVERY_DATE >= @P_START_DATE + ' 00:00:00'
    AND		CEO.DELIVERY_DATE <= @P_END_DATE + ' 23:59:59'




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


                            SELECT      CONVERT(VARCHAR(7), A.SAMPLE_DELIVERY_DATE, 120) AS SAMPLE_DELIVERY_DATE
                                    ,   SUM(A.SAMPLE_ORDER_QNT) AS SAMPLE_ORDER_QNT
                            FROM (


                                        SELECT	CONVERT(VARCHAR(7), DELIVERY_DATE, 120)			AS SAMPLE_DELIVERY_DATE
	                                        ,	COUNT(*)										AS SAMPLE_ORDER_QNT
                                        FROM	CUSTOM_SAMPLE_ORDER A
                                        JOIN    #OrderSeqTemp B ON A.sample_order_seq = B.Order_Seq
                                        WHERE	1 = 1
                                        
                                        GROUP BY CONVERT(VARCHAR(7), DELIVERY_DATE, 120)

                                        UNION ALL

                                        SELECT  CONVERT(VARCHAR(7), CEO.delivery_date, 120) AS SAMPLE_DELIVERY_DATE, COUNT(*) AS SAMPLE_ORDER_QNT
                                        FROM    CUSTOM_ETC_ORDER CEO
                                        JOIN    CUSTOM_ETC_ORDER_ITEM CEOI ON CEO.ORDER_sEQ = CEOI.ORDER_SEQ 
                                        JOIN    #OrderSeqTemp B ON CEO.order_seq = B.Order_Seq
                                        WHERE   CEO.status_seq >= 12                                        
                                        GROUP BY CONVERT(VARCHAR(7), DELIVERY_DATE, 120)


                            ) A
                            GROUP BY CONVERT(VARCHAR(7), A.SAMPLE_DELIVERY_DATE, 120)



				) AS CSO
				LEFT
				JOIN	(			

                            SELECT	    CONVERT(VARCHAR(7), T1.DELIVERY_DATE, 120)				AS SAMPLE_DELIVERY_DATE
		                            ,	CONVERT(VARCHAR(7), CO.SRC_SEND_DATE, 120)				AS CUSTOM_DELIVERY_DATE
		                            ,	SUM(CASE WHEN CO.MEMBER_ID IS NULL THEN 0 ELSE 1 END)	AS WEDDING_INVITATION_QNT
                            FROM
                            (
                                SELECT	CSO.DELIVERY_DATE AS DELIVERY_DATE
                                        , CSO.MEMBER_EMAIL AS MEMBER_EMAIL 
                                        , CSO.SALES_GUBUN AS SALES_GUBUN
                                FROM	CUSTOM_SAMPLE_ORDER CSO
                                JOIN    #OrderSeqTemp B ON CSO.sample_order_seq = B.Order_Seq
                                WHERE	1 = 1
                                    AND		CSO.STATUS_SEQ = 12

                                UNION ALL

                                SELECT  CEO.DELIVERY_DATE AS DELIVERY_DATE, CEO.ORDER_EMAIL AS MEMBER_EMAIL, CEO.SALES_GUBUN AS SALES_GUBUN
                                FROM    CUSTOM_ETC_ORDER CEO 
                                LEFT JOIN CUSTOM_ETC_ORDER_ITEM CEOI ON CEO.ORDER_sEQ = CEOI.ORDER_SEQ 
                                JOIN    #OrderSeqTemp B ON CEO.order_seq = B.Order_Seq
                                WHERE   CEO.status_seq >= 12


                            ) AS T1
                            LEFT
                            JOIN	CUSTOM_ORDER CO 
                                ON      T1.MEMBER_EMAIL = CO.order_email
	                            AND		CO.SRC_SEND_DATE IS NOT NULL
	                            AND		T1.DELIVERY_DATE <= CO.SRC_SEND_DATE
	                            AND		(@P_SALES_GUBUN = '' OR CO.SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))
	                            AND		CO.STATUS_SEQ = 15
	                            AND		CO.SRC_SEND_DATE >= @P_START_DATE + ' 00:00:00'
	                            AND		CO.ORDER_TYPE IN (1,3,6,7)
                            GROUP BY CONVERT(VARCHAR(7), T1.DELIVERY_DATE, 120), CONVERT(VARCHAR(7), CO.SRC_SEND_DATE, 120)

						) AS CO ON CSO.SAMPLE_DELIVERY_DATE = CO.SAMPLE_DELIVERY_DATE
			) A
	LEFT
	JOIN	@T_MONTH TM ON 1 = 1

	WHERE	1 = 1

	GROUP BY A.SAMPLE_DELIVERY_DATE, TM.MONTH
	ORDER BY A.SAMPLE_DELIVERY_DATE ASC, TM.MONTH ASC

END
GO
