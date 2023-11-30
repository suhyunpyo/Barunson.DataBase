USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_INSERT_LOG_MST]    Script Date: 2023-10-12 ���� 8:06:16 ******/
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
    
    --���� DBó�� ���н� SMS �߼�
    IF @SUB_LOCATION = 'LF_CustomOrder_Pay_Insert() ����' BEGIN

        SET @SmsMsg = 'DB ���� ó�� ����!! LOG_MST Ȯ�� ���. (SEQ = '+CAST(@Seq AS VARCHAR)+')'
        EXEC SP_SEND_SMS_TO_DEVELOPERS '������^01093702902|������^01089738286|�����^01067640922|������^01099149603', @SmsMsg
    END
END

GO


