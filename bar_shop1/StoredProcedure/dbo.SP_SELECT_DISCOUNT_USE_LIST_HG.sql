IF OBJECT_ID (N'dbo.SP_SELECT_DISCOUNT_USE_LIST_HG', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_DISCOUNT_USE_LIST_HG
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC SP_SELECT_DISCOUNT_USE_LIST_HG 126, 100, 1, 'SEQ', 'DESC'
*/

CREATE PROCEDURE [dbo].[SP_SELECT_DISCOUNT_USE_LIST_HG]
		@P_DISCOUNT_SEQ AS INT
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
													CASE WHEN @P_ORDER_BY_NAME = 'SEQ'					THEN C.CardDiscountSeq						ELSE 0 END ASC
												,	C.CardDiscountSeq ASC
													
											) AS ROW_NUM
					,	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'DESC'					THEN C.CardDiscountSeq						ELSE 0 END DESC
												,	C.CardDiscountSeq DESC
													
											) AS ROW_NUM_DESC
					,	*
				FROM	(
							SELECT	  SC.Card_Name as CardName
									, SC.Card_Code as CardCode
									, Company_Seq  as CompanySeq
									, CASE WHEN Company_Seq = 5006 THEN '비핸즈카드' 
										   WHEN Company_Seq = 5007 THEN '더카드'
										   WHEN Company_Seq = 5000 THEN '바른손몰'
										   WHEN Company_Seq = 5001 THEN '바른손'
										   WHEN Company_Seq = 5003 THEN '프리미어페이퍼'
									  END SaleSite
									, IsDisplay
									, CASE WHEN IsDisplay = '1' THEN '전시' 
										   ELSE '미전시'
									  END DisplayName
									, SCSS.CardDiscount_Seq as CardDiscountSeq
                                    , ISNULL(SCES.PRODUCTION_STATUS_NAME, '') AS ERP_PRODUCTION_STATUS_NAME	
							FROM	S2_CardSalesSite SCSS
								JOIN S2_CARD SC ON SCSS.card_seq = SC.Card_Seq
   							    LEFT JOIN	S2_CARD_ERP_STOCK SCES ON SC.CARD_CODE = SCES.CARD_CODE AND SC.CARD_ERPCODE = SCES.CARD_CODE_ERP

							WHERE	1 =	1
							AND		SCSS.CardDiscount_Seq = @P_DISCOUNT_SEQ

						) C

			) A

	WHERE	1 = 1
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END > (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE
		
	ORDER BY 
		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END ASC
	
END
GO
