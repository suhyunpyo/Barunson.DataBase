IF OBJECT_ID (N'dbo.SP_SELECT_DISCOUNT_RATE_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_DISCOUNT_RATE_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_DISCOUNT_RATE_LIST '','','', 100, 1, 'SEQ', 'DESC'

*/

CREATE PROCEDURE [dbo].[SP_SELECT_DISCOUNT_RATE_LIST]
		@P_SITE_DIV AS VARCHAR(50)
	,	@P_BRAND AS VARCHAR(50)
	,	@P_SEARCH_VALUE AS VARCHAR(50)
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
													CASE WHEN @P_ORDER_BY_NAME = 'SEQ'					THEN C.CardDiscountSeq						ELSE 0 END DESC
												,	C.CardDiscountSeq DESC
													
											) AS ROW_NUM_DESC
					,	*
				FROM	(
							SELECT	DISTINCT 
									SCD.CardDiscount_Seq  AS CardDiscountSeq
								,	SCD.CardDiscount_Code  AS CardDiscountCode
								,	SCD.CardDiscount_Div  AS CardDiscountDiv
								,	SCD.CardDiscount_Status  AS CardDiscountStatus
								,	MC.code_type  AS CodeType
								,	MC.code  AS Code
								,	MC.code_value  AS CodeValue
							FROM	S2_CardDiscountInfo SCD
								LEFT JOIN manage_code MC ON SCD.CardDiscount_Div = MC.code AND MC.code_type = 'cardbrand'
							WHERE	1 = 1
							--AND		SC.CARD_GROUP IN ( 'I' )

							AND		(
										CASE WHEN ISNULL(@P_BRAND, '') = '' THEN '' ELSE MC.code END =  @P_BRAND
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
