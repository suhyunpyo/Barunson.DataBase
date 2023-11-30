IF OBJECT_ID (N'dbo.up_select_order_wed_seq', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_order_wed_seq
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  김덕중  
-- Create date: 2014-04-29  
-- Description: 청첩장 오더1 프로세스1  
-- =============================================  



CREATE PROCEDURE [dbo].[up_select_order_wed_seq]  
 -- Add the parameters for the stored procedure here  
 @company_seq AS int,  
 @uid   AS nvarchar(50),  --회원의 경우 회원ID, 비회원의 경우 email주소 사용  
 @order_seq  AS nvarchar(1000),  
 @loginYN  AS nvarchar(1)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
   
   
  select   
  order_Seq,card_seq,order_name,order_type,order_phone,order_hphone,order_email,card_opt,  
  order_count,isContAdd,isEnvAdd,order_count,env_price,printW_status,isembo,print_color,  
  isColorInpaper,cont_price,iscorel,order_total_price,isVar, isnull(isLanguage,'0') as isLanguage   
  , isnull(isPerfume,'0') as isPerfume, isnull(perfume_price  , '0') as perfume_price
  , isnull(sealing_sticker_price, 0) SealingS_price
  from custom_order with(nolock) where   
  order_seq = @order_seq and company_seq=@company_seq   
  -- and status_seq=0   
  and  
  (  
   CASE @loginYN  
   WHEN 'Y' THEN member_id  --회원일경우 ID로 조회  
   ELSE order_email    --비회원일경우 이메일로 조회  
   END  
  ) = @uid  
    
    
END 
GO
