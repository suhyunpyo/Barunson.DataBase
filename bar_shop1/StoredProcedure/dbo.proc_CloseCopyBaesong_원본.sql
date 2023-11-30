IF OBJECT_ID (N'dbo.proc_CloseCopyBaesong_원본', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_CloseCopyBaesong_원본
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    Procedure [dbo].[proc_CloseCopyBaesong_원본]  
@order_seq int,  
@del_id int  
as  
begin  
 Declare @id bigint,@del_code varchar(15)  
   
 --새로운 송장코드 하나 가져와서 배송정보에 셋팅한다.  
  
    DECLARE @DELIVERY_COMPANY_SHORT_NAME AS VARCHAR(10)  
    SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'  
  
    /* 2015-08-03 이후 CJ택배로 변경 */  
    IF GETDATE() >= '2015-08-03 00:00:00'  
        BEGIN  
              
            SET @DELIVERY_COMPANY_SHORT_NAME = 'CJ'  
  
        END  
    ELSE  
        BEGIN  
              
            SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'  
  
        END  
  
 --UPDATE  CJ_DELCODE  
 --SET     ISUSE='1'   
 -- ,   @ID = A.CODESEQ  
 -- ,   @DEL_CODE = A.CODE  
 --FROM    CJ_DELCODE A  
 --WHERE   CODESEQ IN ( SELECT TOP 1 CODESEQ FROM CJ_DELCODE  WHERE ISUSE='0' ORDER BY CODESEQ )  
   
 --UPDATE  DELIVERY_INFO   
 --   SET     DELIVERY_COM = @DELIVERY_COMPANY_SHORT_NAME  
 --       ,   DELIVERY_CODE_NUM = @DEL_CODE   
 --   WHERE   ID = @DEL_ID  
   
 --   insert into DELIVERY_INFO_DELCODE(order_seq,delivery_id,delivery_code_num,delivery_com) values(@order_seq,@del_id,@del_code, @DELIVERY_COMPANY_SHORT_NAME)  
  
  
 EXEC [dbo].[SP_CJ_DELEVERY] 'DELIVERY_INFO_DELCODE|DELIVERY_INFO|', @order_seq, @del_id, @DELIVERY_COMPANY_SHORT_NAME, @DEL_CODE OUTPUT  
  
end  
  
GO
