IF OBJECT_ID (N'dbo.SP_SM_MEMBERSHIP_REG', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SM_MEMBERSHIP_REG
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*  
EXEC [SP_SM_MEMBERSHIP_REG]  'rlawldus'   
삼성멤버쉽 수동 가입   
  
*/  
  
CREATE PROCEDURE [dbo].[SP_SM_MEMBERSHIP_REG]  
    @USER_ID    AS VARCHAR(50)  
  
AS  
  
BEGIN  
      
 declare @UID_CNT AS INT  
 declare @RESULT_MESSAGE AS VARCHAR(50)  
   
 SELECT @UID_CNT = ISNULL(COUNT(UID), 0)   
  FROM VW_USER_INFO WHERE UID = @USER_ID  
   
 IF @UID_CNT > 0   
  BEGIN  
   update S2_UserInfo_TheCard set   
   chk_smembership = 'Y'  
   , smembership_reg_date = GETDATE()  
   , smembership_chk_flag = 'Y'  
   , chk_smembership_per = 'Y'
   , chk_smembership_coop = 'Y'
   , smembership_inflow_route = 'JOIN'  
   where uid= @USER_ID  
  
  
   update S2_UserInfo set   
   chk_smembership = 'Y'  
   , smembership_reg_date = GETDATE()  
   , smembership_chk_flag = 'Y'  
   , chk_smembership_per = 'Y'
   , chk_smembership_coop = 'Y'
   , smembership_inflow_route = 'JOIN'  
   where uid= @USER_ID  
  
  
   update S2_UserInfo_bhands set   
   chk_smembership = 'Y'  
   , smembership_reg_date = GETDATE()  
   , smembership_chk_flag = 'Y'  
   , chk_smembership_per = 'Y'
   , chk_smembership_coop = 'Y'
   , smembership_inflow_route = 'JOIN'  
   where uid= @USER_ID  
    
    
   SET @RESULT_MESSAGE = '삼성멤버쉽 가입되었습니다.'  
  
  END  
  
   
 ELSE  
   
  BEGIN  
          
   SET @RESULT_MESSAGE = '존재하지 않은 ID입니다.'  
  
  END  
  
  SELECT  @RESULT_MESSAGE AS RESULT_MESSAGE  
  
END   
GO
