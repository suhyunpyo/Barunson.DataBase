IF OBJECT_ID (N'dbo.up_delete_sample_basket_all_GUEST', N'P') IS NOT NULL DROP PROCEDURE dbo.up_delete_sample_basket_all_GUEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================  
-- Author:  김덕중  
-- Create date: 2015-01-15  
-- Description: MyPage 샘플장바구니 전체삭제  
-- TEST : up_delete_sample_basket  
-- =============================================  
CREATE PROCEDURE [dbo].[up_delete_sample_basket_all_GUEST]   
  
 @card_seq INT,  
 @uid nvarchar(30),  
 @GUID nvarchar(300),  
 @result_code INT = 0 OUTPUT,  
 @result_cnt  INT = 0 OUTPUT   
  
AS  
BEGIN  
   
   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
   
 SET NOCOUNT ON;  
  
   
    IF @UID <> ''
    BEGIN
        DELETE FROM S2_SampleBasket WHERE card_seq = @card_seq and uid=@uid  
    END
    ELSE
    BEGIN
        DELETE FROM S2_SampleBasket WHERE card_seq = @card_seq and GUID=@GUID AND UID = ''  
    END
   
 SET @result_cnt = @@ROWCOUNT --변경된 rowcount  
 SET @result_code = @@Error  --에러발생 cnt  
    
 RETURN @result_code  
 RETURN @result_cnt   
  
        
END  
  
  
  
-- select * from S2_SampleBasket where seq = @seq  
  
  
GO
