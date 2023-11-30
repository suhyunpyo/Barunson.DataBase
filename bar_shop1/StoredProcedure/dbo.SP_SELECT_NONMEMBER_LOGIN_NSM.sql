IF OBJECT_ID (N'dbo.SP_SELECT_NONMEMBER_LOGIN_NSM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_NONMEMBER_LOGIN_NSM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
  
EXEC SP_SELECT_NONMEMBER_LOGIN '시스템테스트', 'sharniel@nate.com', 5001  
  
*/  
CREATE PROCEDURE [dbo].[SP_SELECT_NONMEMBER_LOGIN_NSM]  
      
    @USER_NAME AS VARCHAR(50)  
,   @USER_EMAIL AS VARCHAR(50)  
,   @COMPANY_SEQ AS INT  
  
  
AS  
DECLARE @H_COMPANY_SEQ   INT --바른손몰통합(비핸즈제휴 + 프리미어제휴)으로 인해 비회원주문 조회시 프페도 주문조회 하기 위해 추가함.(2016.12.29)  
 DECLARE @strQuery   NVARCHAR(MAX);  
 DECLARE @parmDefinition_itm NVARCHAR(500)    
  
BEGIN  
  
 SELECT @H_COMPANY_SEQ = ISNULL((SELECT COMPANY_SEQ FROM COMPANY WHERE LOGIN_ID = A.LOGIN_ID AND SALES_GUBUN IN ( 'B','C','H') AND     STATUS = 'S2' AND COMPANY_SEQ <> A.COMPANY_SEQ) , 0)  
 FROM    COMPANY a  
 WHERE   SALES_GUBUN in ( 'B','C','H')  
 AND     STATUS = 'S2'  
 and COMPANY_SEQ = @COMPANY_SEQ  
 ORDER BY SALES_GUBUN  
  
  
 set @parmDefinition_itm = N'@IN_COMPANY_SEQ int ,@IN_USER_NAME varchar(50) ,@IN_USER_EMAIL varchar(50), @IN_H_COMPANY_SEQ int'  
  
 SET @strQuery = N''    
      
 SET @strQuery = @strQuery + ' SELECT TOP 1 IS_NONMEMBER'  
 SET @strQuery = @strQuery + ' FROM ('  
 SET @strQuery = @strQuery + '  SELECT  ISNULL(MAX(A.IS_NONMEMBER), ''False'') AS IS_NONMEMBER'  
 SET @strQuery = @strQuery + '  FROM    ('  
 SET @strQuery = @strQuery + '     SELECT  ''True'' AS IS_NONMEMBER '  
 SET @strQuery = @strQuery + '     FROM    CUSTOM_ORDER '  
 SET @strQuery = @strQuery + '     WHERE   COMPANY_SEQ = @IN_COMPANY_SEQ'  
 SET @strQuery = @strQuery + '     AND     ORDER_NAME = @IN_USER_NAME '  
 SET @strQuery = @strQuery + '     AND     ORDER_EMAIL = @IN_USER_EMAIL'  
 SET @strQuery = @strQuery + ' '  
 SET @strQuery = @strQuery + '     UNION ALL'  
 SET @strQuery = @strQuery + ' '  
 SET @strQuery = @strQuery + '     SELECT  ''True'' AS IS_NONMEMBER '  
 SET @strQuery = @strQuery + '     FROM    CUSTOM_SAMPLE_ORDER '  
 SET @strQuery = @strQuery + '     WHERE   COMPANY_SEQ = @IN_COMPANY_SEQ'  
 SET @strQuery = @strQuery + '     AND     MEMBER_NAME = @IN_USER_NAME '  
 SET @strQuery = @strQuery + '     AND     MEMBER_EMAIL = @IN_USER_EMAIL'  
 SET @strQuery = @strQuery + ' '  
 SET @strQuery = @strQuery + '     UNION ALL'  
 SET @strQuery = @strQuery + ' '  
 SET @strQuery = @strQuery + '     SELECT  ''True'' AS IS_NONMEMBER '  
 SET @strQuery = @strQuery + '     FROM    CUSTOM_ETC_ORDER '  
 SET @strQuery = @strQuery + '     WHERE   COMPANY_SEQ = @IN_COMPANY_SEQ'  
 SET @strQuery = @strQuery + '     AND     ORDER_NAME = @IN_USER_NAME '  
 SET @strQuery = @strQuery + '     AND     ORDER_EMAIL = @IN_USER_EMAIL'  
 SET @strQuery = @strQuery + ' '  
 SET @strQuery = @strQuery + '    ) A '  
  
 IF @H_COMPANY_SEQ <> 0  
 BEGIN  
  SET @strQuery = @strQuery + ' UNION ALL'  
  SET @strQuery = @strQuery + ' SELECT  ISNULL(MAX(A.IS_NONMEMBER), ''False'') AS IS_NONMEMBER'  
  SET @strQuery = @strQuery + ' FROM    ('  
  SET @strQuery = @strQuery + ' '  
  SET @strQuery = @strQuery + '   SELECT  ''True'' AS IS_NONMEMBER '  
  SET @strQuery = @strQuery + '   FROM    CUSTOM_ORDER '  
  SET @strQuery = @strQuery + '   WHERE   COMPANY_SEQ = @IN_H_COMPANY_SEQ'  
  SET @strQuery = @strQuery + '   AND     ORDER_NAME = @IN_USER_NAME '  
  SET @strQuery = @strQuery + '   AND     ORDER_EMAIL = @IN_USER_EMAIL'  
  SET @strQuery = @strQuery + ' '  
  SET @strQuery = @strQuery + '   UNION ALL'  
  SET @strQuery = @strQuery + ' '  
  SET @strQuery = @strQuery + '   SELECT  ''True'' AS IS_NONMEMBER '  
  SET @strQuery = @strQuery + '   FROM    CUSTOM_SAMPLE_ORDER '  
  SET @strQuery = @strQuery + '   WHERE   COMPANY_SEQ = @IN_H_COMPANY_SEQ'  
  SET @strQuery = @strQuery + '   AND     MEMBER_NAME = @IN_USER_NAME '  
  SET @strQuery = @strQuery + '   AND     MEMBER_EMAIL = @IN_USER_EMAIL'  
  SET @strQuery = @strQuery + ' '  
  SET @strQuery = @strQuery + '   UNION ALL'  
  SET @strQuery = @strQuery + ' '  
  SET @strQuery = @strQuery + '   SELECT  ''True'' AS IS_NONMEMBER '  
  SET @strQuery = @strQuery + '   FROM    CUSTOM_ETC_ORDER '  
  SET @strQuery = @strQuery + '   WHERE   COMPANY_SEQ = @IN_H_COMPANY_SEQ'  
  SET @strQuery = @strQuery + '   AND     ORDER_NAME = @IN_USER_NAME '  
  SET @strQuery = @strQuery + '   AND     ORDER_EMAIL = @IN_USER_EMAIL'  
  SET @strQuery = @strQuery + ' '  
  SET @strQuery = @strQuery + ' ) A '  
 END  
  
  
 SET @strQuery = @strQuery + ' ) a'  
 SET @strQuery = @strQuery + ' ORDER BY IS_NONMEMBER DESC';  
  
     
 PRINT @strQuery;  
 exec sp_executesql @strQuery  ,@parmDefinition_itm, @COMPANY_SEQ ,@USER_NAME ,@USER_EMAIL , @H_COMPANY_SEQ   
    
    
  
END
GO
