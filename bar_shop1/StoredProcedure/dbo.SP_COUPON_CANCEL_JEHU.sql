IF OBJECT_ID (N'dbo.SP_COUPON_CANCEL_JEHU', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_COUPON_CANCEL_JEHU
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Author		:	황새롬
	Create date	:	2017-07-19
	Description	:	쿠폰취소

	'// 
	EXEC SP_COUPON_CANCEL_JEHU 2920831, 's4guest';
	리본웨딩 쿠폰 살려주자! (2020.07.31)

*/
CREATE PROCEDURE [dbo].[SP_COUPON_CANCEL_JEHU]
		@ORDER_SEQ					AS INT
	,	@UID						AS VARCHAR(100)
AS
BEGIN
	
    SET NOCOUNT ON;

    DECLARE @RESULT_CODE	AS VARCHAR(4)	= '0000'
		,	@RESULT_MESSAGE AS VARCHAR(500)	= ''

	DECLARE	@MEMBER_ID							AS VARCHAR(100)
        ,   @COMPANY_SEQ                        AS INT
        ,   @SALES_GUBUN                        AS VARCHAR(100)
		,   @ADDITION_COUPONSEQ					AS VARCHAR(50) 
		,   @COUPONSEQ							AS VARCHAR(50)		
			
	SELECT	@MEMBER_ID							= MEMBER_ID
        ,   @SALES_GUBUN                        = SALES_GUBUN
	FROM	CUSTOM_ORDER
	WHERE	1 = 1
	AND		ORDER_SEQ							= @ORDER_SEQ

	/* 주문자 확인 */
	IF @MEMBER_ID <> @UID
		BEGIN
			SET @RESULT_CODE	= '9999'
			SET @RESULT_MESSAGE = '주문정보가 일치하지 않습니다.'
		END
	ELSE
		BEGIN
			

			IF @SALES_GUBUN = 'B' OR @SALES_GUBUN = 'H'
				BEGIN
					/* 중복쿠폰만 원복 */
					SELECT @ADDITION_COUPONSEQ = ISNULL(ADDITION_COUPONSEQ,'') , @COMPANY_SEQ = COMPANY_SEQ, @COUPONSEQ =  ISNULL(COUPONSEQ,'')
					FROM CUSTOM_ORDER 
					WHERE ORDER_SEQ = @ORDER_SEQ
					
					IF @ADDITION_COUPONSEQ <> ''
					BEGIN
						UPDATE S4_MYCOUPON SET ismyyn ='Y' WHERE COUPON_CODE = @ADDITION_COUPONSEQ AND UID = @MEMBER_ID AND COMPANY_SEQ IN (5006, @COMPANY_SEQ) AND ISMYYN ='N'
					END

					/* 일반쿠폰 원복(리본웨딩쿠폰을 찾자 */
					IF @COUPONSEQ <> ''
					BEGIN
						UPDATE S4_MYCOUPON SET ismyyn ='Y' WHERE COUPON_CODE = @COUPONSEQ AND UID = @MEMBER_ID AND COMPANY_SEQ IN (5006, @COMPANY_SEQ) AND ISMYYN ='N' AND COUPON_CODE LIKE 'BMRIB%'
					END
										 			 
				END

			SET @RESULT_CODE	= '0000'
			SET @RESULT_MESSAGE = '쿠폰이 정상적으로 취소되었습니다.'		
		END

    SELECT  @RESULT_CODE	AS RESULT_CODE
		,	@RESULT_MESSAGE AS RESULT_MESSAGE
END
GO
