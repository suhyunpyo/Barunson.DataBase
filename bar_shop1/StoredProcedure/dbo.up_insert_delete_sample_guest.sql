IF OBJECT_ID (N'dbo.up_insert_delete_sample_guest', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_delete_sample_guest
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- AUTHOR:  김덕중  
-- CREATE DATE: 2014-04-04  
-- DESCRIPTION: 샘플신청 등록 및 삭제  
-- =============================================  
CREATE PROCEDURE [dbo].[up_insert_delete_sample_guest]  
        @COMPANY_SEQ    AS  INT
    ,   @UID            AS  NVARCHAR(16)
    ,   @CARD_SEQ       AS  NVARCHAR(2000)
    ,   @SITE_DIV       AS  NVARCHAR(10)
    ,   @METHOD         AS  NVARCHAR(10)
    ,   @GUID           AS  VARCHAR(300)
    ,   @RESULT_CODE    INT = 0 OUTPUT
    ,   @RESULT_CNT     INT = 0 OUTPUT  
AS  
BEGIN  
-- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM  
-- INTERFERING WITH SELECT STATEMENTS.  
    SET NOCOUNT ON;  

    BEGIN TRAN  
        IF @METHOD = 'INSERT' --샘플 리스트 등록  
        BEGIN  
            IF @UID <> ''   --회원일때
            BEGIN
                INSERT INTO S2_SAMPLEBASKET (UID, CARD_SEQ, SALES_GUBUN, COMPANY_SEQ, GUID)  
                SELECT @UID, ITEMVALUE, @SITE_DIV, @COMPANY_SEQ, @GUID FROM DBO.FN_SPLITIN2ROWS(@CARD_SEQ, ',')  
                WHERE ITEMVALUE NOT IN (SELECT CARD_SEQ FROM S2_SAMPLEBASKET WHERE UID=@UID AND COMPANY_SEQ=@COMPANY_SEQ AND SALES_GUBUN=@SITE_DIV)     
            END
            ELSE
            BEGIN           --비회원일때
                INSERT INTO S2_SAMPLEBASKET (UID, CARD_SEQ, SALES_GUBUN, COMPANY_SEQ, GUID)  
                SELECT '', ITEMVALUE, @SITE_DIV, @COMPANY_SEQ, @GUID FROM DBO.FN_SPLITIN2ROWS(@CARD_SEQ, ',')  
                WHERE ITEMVALUE NOT IN (SELECT CARD_SEQ FROM S2_SAMPLEBASKET WHERE UID='' AND COMPANY_SEQ=@COMPANY_SEQ AND SALES_GUBUN=@SITE_DIV AND GUID=@GUID)    
            END
        END  
        ELSE IF @METHOD = 'DELETE' --샘플 리스트 삭제  
        BEGIN  
            IF @UID <> ''   --회원일때
            BEGIN
                DELETE FROM S2_SAMPLEBASKET  
                WHERE UID=@UID 
                AND COMPANY_SEQ=@COMPANY_SEQ 
                AND SALES_GUBUN=@SITE_DIV  
                AND CARD_SEQ IN (SELECT ITEMVALUE FROM DBO.FN_SPLITIN2ROWS(@CARD_SEQ, ','))  
            END
            ELSE
            BEGIN           --비회원일때
                DELETE FROM S2_SAMPLEBASKET  
                WHERE UID='' 
                AND COMPANY_SEQ=@COMPANY_SEQ 
                AND SALES_GUBUN=@SITE_DIV  
                AND CARD_SEQ IN (SELECT ITEMVALUE FROM DBO.FN_SPLITIN2ROWS(@CARD_SEQ, ','))  
                AND GUID = @GUID
            END

    END  
   
    SET @RESULT_CNT = @@ROWCOUNT --변경된 ROWCOUNT  

    SET @RESULT_CODE = @@ERROR  --에러발생 CNT  
    IF (@RESULT_CODE <> 0) GOTO PROBLEM  
    COMMIT TRAN  
  
    PROBLEM:  
    IF (@RESULT_CODE <> 0) BEGIN  
        ROLLBACK TRAN  
    END  
   
    RETURN @RESULT_CODE  
    RETURN @RESULT_CNT  
END  
GO
