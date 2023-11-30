IF OBJECT_ID (N'dbo.SP_ISMCARDABLE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ISMCARDABLE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		엄예지
-- Create date: 2016.08.29
-- Description:	빠른손:고객센터>회원정보조회>M청첩장 무료사용가능하도록 수정한 고객들 custom_order에 정보입력하기
--              7096 : http://wed.bhandscard.com/b2b 사이트에서 사용가능하도록. 비핸즈제휴만 해당됨 
-- =============================================
CREATE PROCEDURE [dbo].[SP_ISMCARDABLE]
	@V_MEMBER_ID					VARCHAR(50),	--고객id 또는 email
	@V_SALES_GUBUN					VARCHAR(2),				
	@V_COMPANY_SEQ					INT,					

	@R_ORDER_SEQ					INT		OUTPUT	-- 생성된 주문번호
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CNT BIGINT
	DECLARE @UNAME VARCHAR(50)
    
	
	--빠른손작업이 있었는지 확인
	--SELECT @CNT = COUNT(UID) ,@UNAME = MAX(UNAME)
	--FROM S2_USERINFO
	--WHERE UID = @V_MEMBER_ID
	--AND SITE_DIV = @V_SALES_GUBUN
	--AND ISMCARDABLE = '1'
	SELECT @CNT = UID ,@UNAME = UNAME
	FROM (
			SELECT  COUNT(UID) UID , MAX(UNAME) UNAME
			FROM S2_USERINFO
			WHERE UID = @V_MEMBER_ID
			AND SITE_DIV =  @V_SALES_GUBUN
			AND (ISMCARDABLE = '1')
			UNION ALL
			SELECT  COUNT(UID) , MAX(UNAME)
			FROM S2_USERINFO_BHANDS
			WHERE UID = @V_MEMBER_ID
			AND SITE_DIV = @V_SALES_GUBUN
			AND (ISMCARDABLE = '1')
			UNION ALL
			SELECT  COUNT(UID) , MAX(UNAME)
			FROM S2_USERINFO_BHANDS
			WHERE UID = @V_MEMBER_ID
			AND SITE_DIV = 'B' 
			AND (ISMCARDABLE = '1')
			UNION ALL
			SELECT  COUNT(UID) , MAX(UNAME)
			FROM S2_USERINFO_THECARD
			WHERE UID = @V_MEMBER_ID
			AND SITE_DIV = @V_SALES_GUBUN
			AND (ISMCARDABLE = '1')
		) A
	WHERE UID = 1

	IF @V_COMPANY_SEQ  = 7096
		BEGIN
			SET @CNT = 1;
		END
	
	--M청첩장 무료사용가능하면
	IF @CNT > 0 
		BEGIN
			--이미 생성된 주문번호가 있는지 확인
			SELECT @CNT = COUNT(ORDER_SEQ) 
			FROM CUSTOM_ORDER
			WHERE MEMBER_ID = @V_MEMBER_ID
			AND SALES_GUBUN = @V_SALES_GUBUN
			AND COMPANY_SEQ = @V_COMPANY_SEQ
			AND ISNULL(SETTLE_STATUS, 0) = 0 
			AND CARD_SEQ IS NULL

			--없으면 INSERT 있으면 생성된 주문번호 반환해준다.
			IF @CNT = 0 
                
                DECLARE @tbSeq TABLE(Seq INT)
                INSERT @tbSeq EXEC SP_GET_ORDER_SEQ 'C'                

				BEGIN
					insert into custom_order (ORDER_SEQ, member_id, SALES_GUBUN , COMPANY_SEQ , ORDER_NAME) 
					SELECT SEQ , @V_MEMBER_ID , @V_SALES_GUBUN  , @V_COMPANY_SEQ  , @UNAME FROM @tbSeq 
				END


			SELECT @R_ORDER_SEQ = ORDER_SEQ
			FROM CUSTOM_ORDER
			WHERE MEMBER_ID = @V_MEMBER_ID
			AND SALES_GUBUN = @V_SALES_GUBUN
			AND COMPANY_SEQ = @V_COMPANY_SEQ
			AND ISNULL(SETTLE_STATUS, 0) = 0 
			AND CARD_SEQ IS NULL

		END

END
GO
