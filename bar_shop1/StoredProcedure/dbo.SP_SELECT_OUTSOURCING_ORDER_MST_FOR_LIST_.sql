IF OBJECT_ID (N'dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
/*
exec SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_ @P_COMPANY_TYPE_CODE=N'',@P_SITE_TYPE_CODE=N'',@P_ORDER_TYPE_CODE=N'',@P_ORDER_SUB_TYPE_CODE=N'',@P_ERP_PART_TYPE_CODE=N'',@P_SEARCH_TYPE_CODE=N'1',@P_SEARCH_VALUE=N'',@P_START_DATE=N'2020-08-27',@P_END_DATE=N'2020-08-27'

*/

CREATE PROCEDURE [dbo].[SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_]
    @P_COMPANY_TYPE_CODE AS VARCHAR(200)
,   @P_SITE_TYPE_CODE AS VARCHAR(6)
,   @P_ORDER_TYPE_CODE AS VARCHAR(6)
,   @P_ORDER_SUB_TYPE_CODE AS VARCHAR(6)
,   @P_ERP_PART_TYPE_CODE AS VARCHAR(6)
,   @P_SEARCH_TYPE_CODE AS VARCHAR(200)
,   @P_SEARCH_VALUE AS VARCHAR(200)
,   @P_START_DATE AS VARCHAR(20)
,   @P_END_DATE AS VARCHAR(20)
AS
BEGIN
    
    SELECT  ROW_NUMBER() OVER(ORDER BY A.REG_DATE ASC) AS ROW_NUM
		--,   A.* 
		, A.OUTSOURCING_ORDER_SEQ
		, A.ORDER_STATUS_CODE
		, CASE WHEN B.isCCG = 'Y' THEN '컨' ELSE '' END
		+ 
		CASE WHEN B.pay_Type = '4' THEN '사' + CONVERT(NVARCHAR, A.ORDER_SEQ)
			   ELSE 
					CASE WHEN B.UP_ORDER_SEQ IS NOT NULL THEN 
							CASE WHEN B.ORDER_ADD_FLAG = '1' THEN '수' + CONVERT(NVARCHAR, A.ORDER_SEQ)
									ELSE '기' + CONVERT(NVARCHAR, A.ORDER_SEQ)
							END
						 ELSE CONVERT(NVARCHAR, A.ORDER_SEQ)
					END
		  END AS ORDER_SEQ
		, A.CARD_CODE
		, A.ORDER_NAME
		, A.ORDER_QTY
		, A.PAPER_TYPE_NAME
		, A.PAPER_SIZE
		, A.PAGES_PER_SHEET_VALUE
		, A.PRINT_LOSS_VALUE
		, A.BOTH_SIDE_YORN
		, A.OSI_YORN
		, A.CUTOUT_YORN
		, A.GLOSSY_YORN
		, A.PRESS_YORN
		, A.FOIL_TYPE_NAME
		, A.LASER_CUT_YORN
		, A.REQUESTOR_NAME
		, A.COMPANY_TYPE_CODE
		, A.DELIVERY_TYPE_CODE
		, A.PRINT_FILE_URL
		, A.IMAGE_FILE_URL
		, A.RECEIPT_DATE
		, A.REG_DATE
		, A.ORDER_STATUS_CODE_NAME
		, A.COMPANY_TYPE_NAME
		, A.DELIVERY_TYPE_NAME
		, A.SITE_TYPE_NAME
		, A.SITE_TYPE_CODE
		, A.ORDER_TYPE_CODE
		, A.ERP_PART_TYPE_CODE
		, A.ERP_PART_TYPE_NAME
		, A.ERP_PART_SUB_TYPE_CODE
        , A.ORDER_SUB_TYPE_CODE
		, A.ORDER_SUB_TYPE_NAME
        , CEILING(A.ORDER_QTY / CASE WHEN A.PAGES_PER_SHEET_VALUE = 0 THEN 1 ELSE A.PAGES_PER_SHEET_VALUE END) AS TOTAL_PRINT_QTY
		, B.PAY_TYPE
		, B.UP_ORDER_SEQ
		, B.ORDER_ADD_FLAG
        , A.MEMO
        , A.EDGE_YORN
        , A.EDGE_COLOR
		, A.PRINT_CHASU
    FROM    VW_OUTSOURCING_ORDER_MST AS A
		LEFT OUTER JOIN CUSTOM_ORDER AS B
			ON A.ORDER_SEQ = B.ORDER_SEQ
    WHERE   1 = 1
	AND ISNULL(A.DEV_FLAG,'N') = 'N'
    AND  A.REG_DATE >= @P_START_DATE + ' 00:00:00'
    AND  A.REG_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, CAST(@P_END_DATE AS DATETIME)), 120) + ' 00:00:00'

	--AND		A.COMPANY_TYPE_CODE LIKE '10700%'
	AND		A.COMPANY_TYPE_CODE NOT IN ('107010','107011','107013')

    AND     A.COMPANY_TYPE_CODE LIKE (CASE WHEN @P_COMPANY_TYPE_CODE <> '' THEN @P_COMPANY_TYPE_CODE ELSE '%' END)

    AND     (
                CASE WHEN @P_SITE_TYPE_CODE = '' THEN '' ELSE A.SITE_TYPE_CODE END
            )
                =
            (
                CASE WHEN @P_SITE_TYPE_CODE = '' THEN '' ELSE @P_SITE_TYPE_CODE END
            )

    AND     (
                CASE WHEN @P_ORDER_TYPE_CODE = '' THEN '' ELSE A.ORDER_TYPE_CODE END
            )
                =
            (
                CASE WHEN @P_ORDER_TYPE_CODE = '' THEN '' ELSE @P_ORDER_TYPE_CODE END
            )

	AND     (
                CASE WHEN @P_ORDER_SUB_TYPE_CODE = '' THEN '' ELSE A.ORDER_SUB_TYPE_CODE END
            )
                =
            (
                CASE WHEN @P_ORDER_SUB_TYPE_CODE = '' THEN '' ELSE @P_ORDER_SUB_TYPE_CODE END
            )


    AND     (
                CASE WHEN @P_ERP_PART_TYPE_CODE = '' THEN '' ELSE A.ERP_PART_TYPE_CODE END
            )
                =
            (
                CASE WHEN @P_ERP_PART_TYPE_CODE = '' THEN '' ELSE @P_ERP_PART_TYPE_CODE END
            )

    AND     (
                CASE    
                        WHEN @P_SEARCH_TYPE_CODE = '1' AND @P_SEARCH_VALUE <> '' THEN CONVERT(VARCHAR(50), ISNULL(A.ORDER_SEQ, ''))
                        WHEN @P_SEARCH_TYPE_CODE = '2' AND @P_SEARCH_VALUE <> '' THEN A.ORDER_NAME
  WHEN @P_SEARCH_TYPE_CODE = '3' AND @P_SEARCH_VALUE <> '' THEN A.CARD_CODE
                        WHEN @P_SEARCH_TYPE_CODE = '4' AND @P_SEARCH_VALUE <> '' THEN A.REQUESTOR_NAME
                        ELSE ''
                END
            ) 
                = 
            (
                CASE    
                        WHEN @P_SEARCH_TYPE_CODE IN ('1','2','3','4') AND @P_SEARCH_VALUE <> '' THEN CONVERT(VARCHAR(50), @P_SEARCH_VALUE)
                        ELSE ''
                END
            )

    ORDER BY A.REG_DATE DESC

    

END
GO
