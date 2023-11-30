USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_INSERT_LOG_MST]    Script Date: 2023-10-12 오전 8:06:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_INSERT_LOG_MST]
    @GUID               AS  VARCHAR(40)
,   @SITE               AS  VARCHAR(50)
,   @LOCATION           AS  VARCHAR(500)
,   @SUB_LOCATION       AS  VARCHAR(500)
,   @LOG_TYPE_NAME      AS  VARCHAR(500)
,   @MSG                AS  NVARCHAR(MAX)
,   @USER_ID            AS  VARCHAR(50)


AS
BEGIN
    DECLARE @Seq INT = 0;    
    DECLARE @SmsMsg VARCHAR(200);

    INSERT INTO LOG_MST (GUID, SITE, LOCATION, SUB_LOCATION, LOG_TYPE_NAME, MSG, USER_ID)
	VALUES (@GUID, @SITE, @LOCATION, @SUB_LOCATION, @LOG_TYPE_NAME, @MSG, @USER_ID)
    
    SET @Seq = @@IDENTITY
    
    --결제 DB처리 실패시 SMS 발송
    IF @SUB_LOCATION = 'LF_CustomOrder_Pay_Insert() 실패' BEGIN

        SET @SmsMsg = 'DB 결제 처리 실패!! LOG_MST 확인 요망. (SEQ = '+CAST(@Seq AS VARCHAR)+')'
        EXEC SP_SEND_SMS_TO_DEVELOPERS '변미정^01093702902|박혜림^01089738286|차재원^01067640922|김은석^01099149603', @SmsMsg
    END
END

GO


