IF OBJECT_ID (N'dbo.SP_INSERT_CUSTOM_SAMPLE_ORDER_FOR_ADD_FREE_SAMPLE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_CUSTOM_SAMPLE_ORDER_FOR_ADD_FREE_SAMPLE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_INSERT_CUSTOM_SAMPLE_ORDER_FOR_ADD_FREE_SAMPLE]  
 @P_SAMPLE_ORDER_SEQ AS INT  
,   @P_COMPANY_SEQ      AS INT  
,   @P_SALES_GUBUN      AS VARCHAR(10)  
,   @P_MEMBER_ID        AS VARCHAR(50)  
AS  
BEGIN  
  
DECLARE @USE_YN AS CHAR(1)  
  
/* 샘플실에서 지시서 2장 뽑는게 힘들다는 이유로 중지 15.04.22 */   
SET @USE_YN = 'N'  
   
  
  
IF @USE_YN = 'Y'  
    BEGIN  
  
  
  
        /* 비핸즈카드 */  
        IF @P_COMPANY_SEQ = 5006   
            BEGIN  
  
                INSERT INTO CUSTOM_SAMPLE_ORDER_ITEM (CARD_SEQ, SAMPLE_ORDER_SEQ, CARD_PRICE, md_recommend)  
  
                SELECT  CARD_SEQ, @P_SAMPLE_ORDER_SEQ, 0, 'Y'  
                FROM    SAMPLE_ADDON  
                WHERE   1 = 1  
                AND     CARD_SEQ NOT IN (  
                                            SELECT  CSOI.CARD_SEQ  
                                            FROM    CUSTOM_SAMPLE_ORDER CSO  
                                            JOIN    CUSTOM_SAMPLE_ORDER_ITEM CSOI ON CSO.SAMPLE_ORDER_SEQ = CSOI.SAMPLE_ORDER_SEQ  
                                            WHERE   1  =1  
                                            AND     MEMBER_ID = @P_MEMBER_ID  
                                            AND     CSO.COMPANY_SEQ = @P_COMPANY_SEQ  
                                            AND     CSO.SALES_GUBUN = @P_SALES_GUBUN  
                                            AND     CSO.STATUS_SEQ IN (4, 10, 11, 12)  
                                        )  
                AND     COMPANY_SEQ = @P_COMPANY_SEQ  
                AND     USE_YN = 'Y'  
  
            END  
  
  
  
        /* 바른손카드 */  
        IF @P_COMPANY_SEQ = 5001  
            BEGIN  
  
                INSERT INTO CUSTOM_SAMPLE_ORDER_ITEM (CARD_SEQ, SAMPLE_ORDER_SEQ, CARD_PRICE, md_recommend)  
  
                SELECT  CARD_SEQ, @P_SAMPLE_ORDER_SEQ, 0, 'Y'  
                FROM    SAMPLE_ADDON  
                WHERE   1 = 1  
                AND     CARD_SEQ NOT IN (  
                                            SELECT  CSOI.CARD_SEQ  
                                            FROM    CUSTOM_SAMPLE_ORDER CSO  
                                            JOIN    CUSTOM_SAMPLE_ORDER_ITEM CSOI ON CSO.SAMPLE_ORDER_SEQ = CSOI.SAMPLE_ORDER_SEQ  
                                            WHERE   1  =1  
                                            AND     MEMBER_ID = @P_MEMBER_ID  
                                            AND     CSO.COMPANY_SEQ = @P_COMPANY_SEQ  
                                            AND     CSO.SALES_GUBUN = @P_SALES_GUBUN  
                                            AND     CSO.STATUS_SEQ IN (4, 10, 11, 12)  
                                        )  
                AND     COMPANY_SEQ = @P_COMPANY_SEQ  
                AND     USE_YN = 'Y'  
  
            END  
  
    END   
  
  
END 
GO
