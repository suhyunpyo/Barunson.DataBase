IF OBJECT_ID (N'dbo.SP_SELECT_SMARTAD_AD_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SMARTAD_AD_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_SMARTAD_AD_LIST '','','','','','', 9999, 1, 'AD_TYPE', 'DESC'

*/

CREATE PROCEDURE [dbo].[SP_SELECT_SMARTAD_AD_LIST]
		@P_SEARCH_VALUE AS VARCHAR(100) = ''    -- I : 진행중, E :만료
	,	@P_SEARCH_USEYN AS VARCHAR(100) = ''
	,	@P_SEARCH_ADTYPE AS VARCHAR(100) = ''
	,	@P_SEARCH_EXPIRETYPE AS VARCHAR(100) = ''
	,	@P_SEARCH_START_DATE AS VARCHAR(10) = ''
	,	@P_SEARCH_END_DATE AS VARCHAR(10) = ''
	,	@P_PAGE_SIZE AS INT
	,	@P_PAGE_NUMBER AS INT
	,	@P_ORDER_BY_NAME AS VARCHAR(50)
	,	@P_ORDER_BY_TYPE AS VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON


	SELECT	*
	FROM	(
				SELECT	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REG_DATE						ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'promotionType'			THEN C.AD_TYPE	ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'useYn'					THEN C.DISPLAY_YN	ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'PartnerName'				THEN C.PARTNER_NAME	ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'couponDt'					THEN C.START_DATE	ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'couponYN'					THEN C.COUPONDT	ELSE '' END ASC
												,	C.AD_SEQ ASC
													
											) AS ROW_NUM
					,	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REG_DATE			ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'promotionType'			THEN C.AD_TYPE	ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'useYn'					THEN C.DISPLAY_YN	ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'PartnerName'				THEN C.PARTNER_NAME	ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'couponDt'					THEN C.START_DATE	ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'couponYN'					THEN C.COUPONDT	ELSE '' END DESC
												,	C.AD_SEQ DESC
													
											) AS ROW_NUM_DESC
					,	*
				FROM	(
							SELECT	 
									SPA.AD_SEQ
								,	SPA.PARTNER_SEQ
								,	SPA.AD_TYPE
								,	SPA.CONTENT1
								,	SPA.CONTENT2
								,	SPA.CONTENT3
								,	SPA.PROMOTION_TYPE
								,	SPA.COUPON_CODE
								,	SPA.START_DATE
								,	SPA.END_DATE
								,	SPA.DIRECTION_MSG
								,	SPA.CAUTION_MSG
								,	SPA.REG_DATE
								,	SPA.UPD_DATE
								,	SPA.UPD_ID
								,	SPA.DISPLAY_YN
								,	SPA.PRIORITY
								,	SP.PARTNER_NAME

								,	CASE 
											WHEN SPA.START_DATE <= GETDATE() AND SPA.END_DATE > GETDATE() THEN '진행중'
											WHEN SPA.START_DATE > GETDATE() THEN '전시예정'
											ELSE '기간만료'
									END AS COUPONDT

							FROM	SmartAD_Partner_AD SPA
								LEFT JOIN SmartAD_Partner SP ON SPA.PARTNER_SEQ = SP.PARTNER_SEQ
							WHERE	1 = 1
							AND	 	(@P_SEARCH_USEYN = '' OR SPA.DISPLAY_YN = @P_SEARCH_USEYN)
							AND	 	(@P_SEARCH_ADTYPE = '' OR SPA.AD_TYPE = @P_SEARCH_ADTYPE)	 		
							AND		(
										@P_SEARCH_EXPIRETYPE = '' 
										OR (@P_SEARCH_EXPIRETYPE = 'I' AND GETDATE() BETWEEN SPA.START_DATE AND SPA.END_DATE) 
										OR (@P_SEARCH_EXPIRETYPE = 'E' AND GETDATE() > SPA.END_DATE)
										OR (@P_SEARCH_EXPIRETYPE = 'W' AND GETDATE() < SPA.START_DATE)
									)
							AND		(
										@P_SEARCH_VALUE = '' 
										OR (SP.PARTNER_NAME LIKE '%' + @P_SEARCH_VALUE +'%') 
									)
							AND     ( 
										(@P_SEARCH_START_DATE = '' AND  @P_SEARCH_END_DATE = '') OR  (SPA.START_DATE >= @P_SEARCH_START_DATE AND SPA.END_DATE <= @P_SEARCH_END_DATE) 
									)

						) C 
			) A

	WHERE	1 = 1
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END > (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE
		
	ORDER BY 
		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END ASC
	
END



GO
