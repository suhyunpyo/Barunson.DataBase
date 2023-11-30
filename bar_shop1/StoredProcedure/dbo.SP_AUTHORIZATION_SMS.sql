IF OBJECT_ID (N'dbo.SP_AUTHORIZATION_SMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_AUTHORIZATION_SMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		황새롬
-- Create date: 2018-01-05
-- Description:	바른손카드 샘플 비회원 인증 

-- EXEC dbo.[SP_AUTHORIZATION_SMS] GUID, HPHONE, 'SEND' 문자보내기
-- EXEC dbo.[SP_AUTHORIZATION_SMS] GUID, HPHONE, 'CONFIRM' 인증확인
-- /order/sample/step1.asp
-- =============================================

CREATE PROCEDURE [dbo].[SP_AUTHORIZATION_SMS]
	@GUID 					            AS      VARCHAR(50) ,
	@HPHONE								AS      VARCHAR(50) ,
	@SMS_TYPE   						AS      VARCHAR(10) ,
    @SMS_NUM                            AS      INT
AS
BEGIN
   -- 인증번호 전송
    IF @SMS_TYPE = 'SEND'
    BEGIN

        DECLARE     @CALLBACK       AS  VARCHAR(20)     =   '16440708' , 
                    @MSG            AS  VARCHAR(50)

        -- 랜덤번호 생성
        DECLARE     @START_LIMIT    AS  INT  =  100000 ,
                    @END_LIMIT      AS  INT  =  999999 ,
                    @RND            AS  INT
		
		DECLARE @DEST_INFO     VARCHAR(50)
		SET @DEST_INFO = 'AA^' + @HPHONE

        SET @RND = ROUND((@END_LIMIT - @START_LIMIT + 1) * RAND() + @START_LIMIT , 0, 1);
        
        SET @MSG = '[바른손카드] 인증번호는 ' + CAST(@RND AS VARCHAR(10)) + '입니다.';
        
	    -- Authrization_SMS 테이블 INSERT
        INSERT INTO Authorization_SMS (GUID, HPHONE, SMS_NUM, REG_DATE) VALUES  (@GUID, @HPHONE, @RND, GETDATE());

        -- SMS 전송
		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MSG, '', @CALLBACK, 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
		/*
        INSERT INTO invtmng.SC_TRAN (TR_ID, TR_SENDSTAT, TR_RSLTSTAT, TR_ETC1, TR_SENDDATE, TR_PHONE, TR_CALLBACK, TR_MSG) 
        VALUES ('SM136890_001', '0', '00', '샘플비회원인증 - SP_AUTHORIZATION_SMS', GETDATE(), @HPHONE, @CALLBACK, @MSG);
		*/
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

/****** Object:  StoredProcedure [dbo].[sp_select_coupon_checknsubmit]    Script Date: 2020-11-23 오후 2:38:12 ******/
SET ANSI_NULLS ON
GO
