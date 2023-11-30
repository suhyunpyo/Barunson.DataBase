IF OBJECT_ID (N'dbo.SP_SELECT_SMARTAD_USER_LOGIN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SMARTAD_USER_LOGIN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC SP_SELECT_SMARTAD_USER_LOGIN 's4guest', 'ysmguest1'  
CREATE PROCEDURE [dbo].[SP_SELECT_SMARTAD_USER_LOGIN]  
  @P_UID AS VARCHAR(100) = ''    -- I : 진행중, E :만료  
  ,@P_PASSWORD AS VARCHAR(100) = ''    -- I : 진행중, E :만료  
AS  
BEGIN  
  
 SET NOCOUNT ON  
  
 DECLARE @EXIST_CNT INT;  
 DECLARE @LOGIN_YORN VARCHAR(1);  
  
 IF ISNULL(@P_UID,'') = ''   
  BEGIN  
   SET @LOGIN_YORN = 'E'  
  END   
 ELSE IF ISNULL(@P_PASSWORD,'') = ''   
  BEGIN  
   SET @LOGIN_YORN = 'E'  
  END   
  
 ELSE  
  BEGIN  
   --회원정보 검색  
   SELECT top 1   
      uid    as Id  
     , pwd    as Password  
     , uname  as userName  
     , HPHONE as userHphone  
     , umail  as userEmail  
     ,   DupInfo as DupInfo  
   FROM VW_USER_INFO  
   WHERE 1 = 1  
   AND  UID = @P_UID  
   AND  PWDCOMPARE(@P_PASSWORD, CONVERT(VARBINARY(200), PWD, 1)) = 1  
  
   ----로그인 아이디가 존재할경우  
   --IF @EXIST_CNT > 0   
   -- BEGIN  
   --  SET @LOGIN_YORN = 'Y'  
   -- END  
   --ELSE  
   -- BEGIN  
   --  SET @LOGIN_YORN = 'N'  
   -- END   
  END   
   
  --SELECT @LOGIN_YORN  
END  
  
GO
