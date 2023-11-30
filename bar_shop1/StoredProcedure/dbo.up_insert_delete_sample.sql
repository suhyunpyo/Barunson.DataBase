IF OBJECT_ID (N'dbo.up_insert_delete_sample', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_delete_sample
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  김덕중  
-- Create date: 2014-04-04  
-- Description: 샘플신청 등록 및 삭제  
-- =============================================  
CREATE PROCEDURE [dbo].[up_insert_delete_sample]  
 -- Add the parameters for the stored procedure here  
 @company_seq AS int,  
 @uid AS nvarchar(300),  
 @card_seq AS nvarchar(2000),  
 @site_div AS nvarchar(10),  
 @method  AS nvarchar(10),  
 @result_code  int = 0 OUTPUT,  
 @result_cnt  int = 0 OUTPUT  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
   
 BEGIN TRAN  
   
    if @method = 'insert' --샘플 리스트 등록  
  begin  
   insert into S2_SampleBasket (uid, card_seq, sales_gubun, company_seq)  
   select @uid, ItemValue, @site_div, @company_seq from dbo.fn_SplitIn2Rows(@card_seq, ',')  
   where ItemValue not in (select card_seq from S2_SampleBasket where uid=@uid and company_seq=@company_seq and sales_gubun=@site_div)  
  end  
 else if @method = 'delete' --샘플 리스트 삭제  
  begin  
   delete from S2_SampleBasket  
   where uid=@uid and company_seq=@company_seq and sales_gubun=@site_div  
   and card_seq in (select ItemValue from dbo.fn_SplitIn2Rows(@card_seq, ','))  
  end  
   
 set @result_cnt = @@ROWCOUNT --변경된 rowcount  
 set @result_code = @@Error  --에러발생 cnt  
 IF (@result_code <> 0) GOTO PROBLEM  
 COMMIT TRAN  
  
 PROBLEM:  
 IF (@result_code <> 0) BEGIN  
  ROLLBACK TRAN  
 END  
   
 return @result_code  
 return @result_cnt  
END  
GO
