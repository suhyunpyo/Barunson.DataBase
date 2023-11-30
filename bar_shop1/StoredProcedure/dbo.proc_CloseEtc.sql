IF OBJECT_ID (N'dbo.proc_CloseEtc', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_CloseEtc
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--38560081847
--proc_CloseEtc 3199787
select DELIVERY_CODE,* from CUSTOM_ETC_ORDER where order_seq = 3199787
SELECT * FROM    CJ_DELCODE WHERE  codeseq = 38560081847  

update CUSTOM_ETC_ORDER set DELIVERY_CODE = NULL where order_seq = 3199787
update  CJ_DELCODE set  ISUSE='0' where codeseq = 38560081847  

*/
CREATE Procedure [dbo].[proc_CloseEtc]  
@order_seq int  
as  
begin  
 Declare @id bigint,@del_code varchar(15)  
   
 --새로운 송장코드 하나 가져와서 배송정보에 셋팅한다.  
  
  
  
    DECLARE @DELIVERY_COMPANY_SHORT_NAME AS VARCHAR(10)  
    SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'  
  
  BEGIN TRAN TR_ETC_DELCODE

    /* 2015-08-03 이후 CJ택배로 변경 */  
    IF GETDATE() >= '2015-08-03 00:00:00'  
        BEGIN  
              
            SET @DELIVERY_COMPANY_SHORT_NAME = 'CJ'  
  
        END  
    ELSE  
        BEGIN  
              
            SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'  
  
        END  
  
  
  
  
 UPDATE  CJ_DELCODE   
 SET     ISUSE='1'   
  ,   @ID = A.CODESEQ  
  ,   @DEL_CODE = A.CODE  
 FROM    CJ_DELCODE A  
 WHERE   CODESEQ IN (   
                            SELECT TOP 1 CODESEQ   
                            FROM    CJ_DELCODE    
                            WHERE   ISUSE='3'   
                            ORDER BY CODESEQ   
                        )  
  
 UPDATE  CUSTOM_ETC_ORDER   
    SET     DELIVERY_COM = @DELIVERY_COMPANY_SHORT_NAME  
        ,   DELIVERY_CODE = @DEL_CODE  
        ,   STATUS_SEQ = 10  
        ,   PREPARE_DATE = GETDATE()   
    WHERE   ORDER_SEQ = @ORDER_SEQ  
  
  
IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN TR_ETC_DELCODE
	END
ELSE
	BEGIN
		COMMIT TRAN TR_ETC_DELCODE
	END

  
END
GO
