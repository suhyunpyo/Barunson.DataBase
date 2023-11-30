IF OBJECT_ID (N'dbo.SP_EXEC_COUPON_ISSUE_FOR_SAMPLEBOOK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_COUPON_ISSUE_FOR_SAMPLEBOOK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    EXEC SP_EXEC_COUPON_ISSUE_FOR_SAMPLEBOOK '5001', 'SB', 's4guest'
*/
CREATE PROCEDURE [dbo].[SP_EXEC_COUPON_ISSUE_FOR_SAMPLEBOOK]
		@COMPANY_SEQ			AS INT
	,	@SALES_GUBUN			AS VARCHAR(50)
	,   @USER_ID				AS VARCHAR(50)
AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @COUPON_MST_SEQ		AS INT
		,	@RESULT_CODE		AS VARCHAR(4)	= '0000'
		,	@RESULT_MESSAGE		AS VARCHAR(500)	= ''

    -- 해당사이트에 발급방식이 '샘플북 회수시 발급'
   DECLARE cur_AutoInsert_For_CouponIssue CURSOR FAST_FORWARD      
   FOR      
        SELECT @COMPANY_SEQ, @SALES_GUBUN, @USER_ID, CD.COUPON_CODE
        FROM COUPON_DETAIL CD
        WHERE CD.COUPON_MST_SEQ IN (
                                        SELECT TOP 5 CM.COUPON_MST_SEQ
                                        FROM    COUPON_MST CM
                                            JOIN COUPON_APPLY_SITE CAS 
                                                    ON CM.COUPON_MST_SEQ = CAS.COUPON_MST_SEQ AND COMPANY_SEQ  = @COMPANY_SEQ
                                        WHERE DOWNLOAD_KIND_ETC_CODE = '130003' 
                                  )
     OPEN cur_AutoInsert_For_CouponIssue      

     DECLARE @P_USER_ID VARCHAR(100)      
     DECLARE @P_SALES_GUBUN VARCHAR(100)      
     DECLARE @P_COMPANY_SEQ INT      
     DECLARE @P_COUPON_CODE VARCHAR(50)      
     
     FETCH NEXT FROM cur_AutoInsert_For_CouponIssue INTO @P_COMPANY_SEQ, @P_SALES_GUBUN, @P_USER_ID, @P_COUPON_CODE
      
     WHILE @@FETCH_STATUS = 0   
     BEGIN      
        
      --쿠폰발급      
      --EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @P_COMPANY_SEQ, @P_SALES_GUBUN, @P_USER_ID, @P_COUPON_CODE
      
      FETCH NEXT FROM cur_AutoInsert_For_CouponIssue INTO  @P_COMPANY_SEQ, @P_SALES_GUBUN, @P_USER_ID, @P_COUPON_CODE
     END      
      
    CLOSE cur_AutoInsert_For_CouponIssue      
   DEALLOCATE cur_AutoInsert_For_CouponIssue      

END
GO
