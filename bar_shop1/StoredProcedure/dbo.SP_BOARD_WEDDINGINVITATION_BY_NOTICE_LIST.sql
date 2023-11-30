IF OBJECT_ID (N'dbo.SP_BOARD_WEDDINGINVITATION_BY_NOTICE_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BOARD_WEDDINGINVITATION_BY_NOTICE_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_BOARD_WEDDINGINVITATION_BY_NOTICE_LIST]
		@P_SEARCH_VALUE		AS VARCHAR(100)
	,	@P_SALES_GUBUN		AS VARCHAR(100)
	,	@P_START_DATE		AS VARCHAR(10)
	,	@P_END_DATE			AS VARCHAR(10)
	,	@P_DATE_TYPE		AS VARCHAR(50)
	,	@P_PAGE_SIZE		AS INT
	,	@P_PAGE_NUMBER		AS INT
	,	@P_ORDER_BY_NAME	AS VARCHAR(50)
	,	@P_ORDER_BY_TYPE	AS VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON

	SELECT	*
	FROM
			(
				SELECT	
						ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'				THEN C.REG_DATE						ELSE 0 END ASC
												,	C.SEQ ASC
													
											) AS ROW_NUM
					,	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'				THEN C.REG_DATE						ELSE 0 END DESC
												,	C.SEQ DESC
													
											) AS ROW_NUM_DESC
					,	CASE 
								WHEN C.SALES_GUBUN = 'SB' THEN '바른손카드' 
								WHEN C.SALES_GUBUN = 'SA' THEN '비핸즈카드' 
								WHEN C.SALES_GUBUN = 'ST' THEN '더카드' 
								WHEN C.SALES_GUBUN = 'SS' THEN '프리미어페이퍼' 
								WHEN C.SALES_GUBUN = 'B'  THEN '바른손몰' 
								WHEN C.SALES_GUBUN = 'C'  THEN '바른손몰' 
								WHEN C.SALES_GUBUN = 'H'  THEN '프리미어 제휴' 
								ELSE '기타' 
						END	AS COMPANY_NAME
					, *		
				FROM	(
							SELECT 
									SN.seq
									,SN.sales_gubun
									,SN.company_seq
									,SN.writer
									,SN.title
									,SN.contents
									,SN.viewcnt
									,SN.notice_div
									,SN.start_date
									,SN.end_date
									,SN.reg_date
									,SN.blank_
							FROM    S2_NOTICE SN
							WHERE	1 = 1
							AND		CASE 
											WHEN @P_DATE_TYPE = 'REG_DATE' 
											THEN SN.REG_DATE 
											ELSE SN.START_DATE 
									END >= CONVERT(DATETIME, @P_START_DATE + ' 00:00:00')
							AND		CASE 
											WHEN @P_DATE_TYPE = 'REG_DATE' 
											THEN SN.REG_DATE 
											ELSE SN.END_DATE
									END < DATEADD(DAY, 1, CONVERT(DATETIME, @P_END_DATE + ' 00:00:00'))
							AND		SN.SALES_GUBUN IN (SELECT CAST(VALUE AS VARCHAR(20)) FROM dbo.[ufn_SplitTable] (@P_SALES_GUBUN, '|'))
						) C	
			)A	

	WHERE	1 = 1 		
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END > (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE

	ORDER BY 
		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END ASC
END


GO
