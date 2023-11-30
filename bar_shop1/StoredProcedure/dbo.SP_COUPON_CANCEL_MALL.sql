IF OBJECT_ID (N'dbo.SP_COUPON_CANCEL_MALL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_COUPON_CANCEL_MALL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Author		:	황새롬
	Create date	:	2017-07-19
	Description	:	쿠폰취소

	EXEC SP_COUPON_CANCEL 2586663, 's4guest';
*/
CREATE PROCEDURE [dbo].[SP_COUPON_CANCEL_MALL]
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
		,   @COUPON_SEQ							AS VARCHAR(50)
		,   @ADDITION_COUPONSEQ					AS VARCHAR(50)
		
			
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
			
            /*  
                2018.02.01   
                요청자      : 온라인사업1팀 정미진
                요청사항    : 바른손카드 취소건일 경우 발급한 식전영상쿠폰을 삭제하고, 사용전 상태로 변경한다.
             */
            IF @SALES_GUBUN = 'SB'
                BEGIN
                    
                    DECLARE @T_COUPON_DETAIL TABLE  
                    (  
                        COUPON_DETAIL_SEQ INT  
                    )  
   
                    INSERT INTO @T_COUPON_DETAIL (COUPON_DETAIL_SEQ)  
                    SELECT  CI.COUPON_DETAIL_SEQ
                    FROM    COUPON_ISSUE CI
                    JOIN    COUPON_DETAIL CD ON CI.COUPON_DETAIL_SEQ = CD.COUPON_DETAIL_SEQ
                    WHERE   1 = 1
                    AND     UID = @MEMBER_ID
                    AND     CD.COUPON_MST_SEQ = 117
                    AND     CI.ACTIVE_YN = 'Y'

                    IF EXISTS   (SELECT * FROM @T_COUPON_DETAIL)
                        BEGIN
                            
                            DELETE  COUPON_ISSUE 
                            WHERE   COUPON_DETAIL_SEQ IN (SELECT COUPON_DETAIL_SEQ FROM @T_COUPON_DETAIL)

                        END
                END
			ELSE IF @SALES_GUBUN = 'B' OR @SALES_GUBUN = 'H' OR @SALES_GUBUN = 'C'
				BEGIN
					
					SELECT @COUPON_SEQ = ISNULL(COUPONSEQ,''), @ADDITION_COUPONSEQ = ISNULL(ADDITION_COUPONSEQ,'') , @COMPANY_SEQ = COMPANY_SEQ 
					FROM CUSTOM_ORDER 
					WHERE ORDER_SEQ = @ORDER_SEQ

					IF @COUPON_SEQ <> '' 
					BEGIN
						UPDATE S4_MYCOUPON SET ismyyn ='Y' WHERE COUPON_CODE = @COUPON_SEQ AND UID = @MEMBER_ID AND COMPANY_SEQ IN (5006, @COMPANY_SEQ) AND ISMYYN ='N'
					END
					
					IF @ADDITION_COUPONSEQ <> ''
					BEGIN
						UPDATE S4_MYCOUPON SET ismyyn ='Y' WHERE COUPON_CODE = @ADDITION_COUPONSEQ AND UID = @MEMBER_ID AND COMPANY_SEQ IN (5006, @COMPANY_SEQ) AND ISMYYN ='N'
					END
					 
					 
				END
			ELSE
				BEGIN
					/*커서를 이용하여 해당되는 고객정보를 얻는다.*/
					DECLARE cur_Auto_Coupon_Cancel CURSOR FAST_FORWARD
					FOR
						-- 주문 시 사용되었던 쿠폰 조회
						SELECT	COC.COUPON_ISSUE_SEQ
						FROM	CUSTOM_ORDER_COUPON COC
						JOIN	CUSTOM_ORDER CO ON CO.ORDER_SEQ = COC.ORDER_SEQ
						WHERE	1=1
						AND		COC.ORDER_SEQ = @ORDER_SEQ
						AND		CO.MEMBER_ID = @UID

						OPEN cur_Auto_Coupon_Cancel

						DECLARE @COUPON_ISSUE_SEQ INT

						FETCH NEXT FROM cur_Auto_Coupon_Cancel INTO @COUPON_ISSUE_SEQ
						WHILE @@FETCH_STATUS = 0

						BEGIN
							-- 쿠폰보관함에 쿠폰을 사용상태로 변경
							UPDATE	COUPON_ISSUE 
							SET		ACTIVE_YN = 'Y'
							WHERE	COUPON_ISSUE_SEQ = @COUPON_ISSUE_SEQ
							FETCH NEXT FROM cur_Auto_Coupon_Cancel INTO @COUPON_ISSUE_SEQ
						END

						-- 주문 시 사용 쿠폰 삭제
						--DELETE FROM CUSTOM_ORDER_COUPON
						--WHERE ORDER_SEQ = @ORDER_SEQ

						CLOSE cur_Auto_Coupon_Cancel

					DEALLOCATE cur_Auto_Coupon_Cancel
				END
			SET @RESULT_CODE	= '0000'
			SET @RESULT_MESSAGE = '쿠폰이 정상적으로 취소되었습니다.'		
		END

    SELECT  @RESULT_CODE	AS RESULT_CODE
		,	@RESULT_MESSAGE AS RESULT_MESSAGE
END
GO
