IF OBJECT_ID (N'dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_20210708', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_20210708
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
/*
exec SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST @P_COMPANY_TYPE_CODE=N'',@P_SITE_TYPE_CODE=N'',@P_ORDER_TYPE_CODE=N'',@P_ORDER_SUB_TYPE_CODE=N'',@P_ERP_PART_TYPE_CODE=N'',@P_SEARCH_TYPE_CODE=N'1',@P_SEARCH_VALUE=N'',@P_START_DATE=N'2020-08-27',@P_END_DATE=N'2020-08-27'
*/

CREATE PROCEDURE [dbo].[SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_20210708]
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
		/* 2021-06-11 디지털 카드 내부 전환으로 구분 표시 요청으로 추가.
		   몇 달뒤 태산에서 인쇄가 모두 빠지면 해당 코드 필요 없음 */
		, CASE 
			WHEN C.CARD_CODE IS NOT NULL AND (A.COMPANY_TYPE_CODE = '107012' OR A.COMPANY_TYPE_CODE = '107014') THEN '내부전환' 
			WHEN C.CARD_CODE IS NOT NULL AND A.COMPANY_TYPE_CODE = '107008' THEN '내부미전환' 
			ELSE '' 
		END DIGITAL_COMPANY
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
		, A.MEMO_EX
    FROM    VW_OUTSOURCING_ORDER_MST AS A
		LEFT OUTER JOIN CUSTOM_ORDER AS B
			ON A.ORDER_SEQ = B.ORDER_SEQ
		/* 2021-06-11 디지털 카드 내부 전환으로 구분 표시 요청으로 추가.
		   몇 달뒤 태산에서 인쇄가 모두 빠지면 해당 코드 필요 없음 */
		LEFT JOIN (
			SELECT 
				card_seq,
				card_code
			FROM s2_card
			WHERE card_code in (
				'BH0701',
				'BH6701',
				'BH6702',
				'BH6748',
				'BH6752',
				'BH6756',
				'BH7720',
				'BH7721',
				'BH7728',
				'BH7820',
				'BH7821',
				'BH8783',
				'BH8915',
				'BH9702',
				'DDC003',
				'DDC004',
				'DDC005',
				'DDC017',
				'DDC018',
				'DDC023',
				'DDC025',
				'DDC0254',
				'DDC0259',
				'DDC026',
				'DDC0260',
				'DDC0262',
				'DDC0264',
				'DDC0267',
				'DDC0267M',
				'DDC0268',
				'DDC0268M',
				'DDC0269',
				'DDC0269M',
				'DDC0284',
				'DDC034',
				'DDC035',
				'DDC043-1',
				'DDC043-1-G',
				'DDC055',
				'DDC060-1',
				'DDC060-2',
				'DDC062',
				'DDC066',
				'DDC068',
				'DDC069',
				'DDC072',
				'DDC084',
				'DDC085',
				'DDC086',
				'DDC088',
				'DDC805',
				'DDC812',
				'DDC814',
				'DDC816',
				'DDC820',
				'DDC822',
				'DDC825',
				'DDC826',
				'DDC827',
				'DDC828',
				'DDC832',
				'DDC833',
				'DDC833_K',
				'DDC901-1',
				'DDC901-2',
				'DDC901-3',
				'DDC901-4',
				'DDC903-1',
				'DDC903_I1',
				'DDC903-2',
				'DDC903_I2',
				'DDC903-3',
				'DDC903_I3',
				'DDC905-1',
				'DDC905-2',
				'DDC907',
				'DDC915',
				'DDC916',
				'DDC916_I',
				'DDC919-1',
				'DDC919-2',
				'DDC922-1',
				'DDC922_acc',
				'DDC922-2',
				'DDC923',
				'DDC925-1',
				'DDC925-2',
				'DDC925-3',
				'DDC935-1',
				'DDC935-1_I',
				'DDC935-2',
				'DDC935-2_I',
				'DDC935-3',
				'DDC935-3_I',
				'DDC936',
				'DDC936_I'
			)
		) AS C
			ON a.CARD_CODE = c.Card_Code
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
