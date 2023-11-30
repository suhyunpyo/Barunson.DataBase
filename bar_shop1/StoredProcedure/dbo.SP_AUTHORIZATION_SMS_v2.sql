IF OBJECT_ID (N'dbo.SP_AUTHORIZATION_SMS_v2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_AUTHORIZATION_SMS_v2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2018-01-05
-- Description:	바른손카드 샘플 비회원 인증 

-- EXEC dbo.[SP_AUTHORIZATION_SMS] GUID, HPHONE, 'SEND' 문자보내기
-- EXEC dbo.[SP_AUTHORIZATION_SMS] GUID, HPHONE, 'CONFIRM' 인증확인
-- /order/sample/step1.asp
-- 더카드
-- =============================================

CREATE PROCEDURE [dbo].[SP_AUTHORIZATION_SMS_v2]
	@GUID 					            AS      VARCHAR(50) ,
	@HPHONE								AS      VARCHAR(50) ,
	@SMS_TYPE   						AS      VARCHAR(10) ,
    @SMS_NUM                            AS      INT ,
	@SALES_GUBUN                        AS      VARCHAR(2)
AS
BEGIN
   -- 인증번호 전송
    IF @SMS_TYPE = 'SEND'
    BEGIN
        DECLARE     @CALLBACK       AS  VARCHAR(20)
        DECLARE     @MSG            AS  VARCHAR(50)
		DECLARE		@BRAND_NAME		AS  VARCHAR(50) --브랜드명  
		DECLARE		@DEST_INFO		AS	VARCHAR(50)

		IF @SALES_GUBUN = 'SB'
		  BEGIN
			SET @BRAND_NAME = '[바른손카드]'
			SET @CALLBACK = '1644-0708'
		  END
		
		ELSE IF @SALES_GUBUN = 'ST'	
		  BEGIN
				SET @BRAND_NAME = '[더카드]'
			SET @CALLBACK = '1644-7998'	
		  END

		ELSE IF @SALES_GUBUN = 'SS'	
		  BEGIN
				SET @BRAND_NAME = '[프리미어페이퍼]'
			SET @CALLBACK = '1644-8796'	
		  END

		ELSE IF @SALES_GUBUN = 'B' OR @SALES_GUBUN = 'H'
		  BEGIN
				SET @BRAND_NAME = '[바른손몰]'
			SET @CALLBACK = '1644-7413'	
		  END

        -- 랜덤번호 생성
        DECLARE     @START_LIMIT    AS  INT  =  100000 ,
                    @END_LIMIT      AS  INT  =  999999 ,
                    @RND            AS  INT

        SET @RND = ROUND((@END_LIMIT - @START_LIMIT + 1) * RAND() + @START_LIMIT , 0, 1);
        
        SET @MSG = + @BRAND_NAME+' 인증번호는 ' + CAST(@RND AS VARCHAR(10)) + '입니다.';
        
	    -- Authrization_SMS 테이블 INSERT
        INSERT INTO Authorization_SMS (GUID, HPHONE, SMS_NUM, REG_DATE) VALUES  (@GUID, @HPHONE, @RND, GETDATE());

		SET @DEST_INFO = 'AA^'+@HPHONE;

		EXEC PROC_SMS_MMS_SEND '', 0, '', @MSG, '', @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SALES_GUBUN, '', '', '', '', '', '', '', '', '', ''

    END
    -- 인증번호 확인
    ELSE IF @SMS_TYPE = 'CONFIRM'
    BEGIN

        SELECT  TOP 1 *
        FROM    Authorization_SMS
        WHERE   GUID = @GUID
        AND     SMS_NUM = @SMS_NUM
        AND     DATEDIFF(S, REG_DATE, GETDATE()) < 160

    END
END
GO
