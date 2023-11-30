IF OBJECT_ID (N'dbo.SP_SELECT_CHOAN_OBJECT_COMMON_CODE_LIST_FOR_GROUP_NAME', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CHOAN_OBJECT_COMMON_CODE_LIST_FOR_GROUP_NAME
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_SELECT_CHOAN_OBJECT_COMMON_CODE_LIST_FOR_GROUP_NAME]  
@P_GROUP_NAME AS NVARCHAR(50)  
AS  
BEGIN  
  
    SELECT  *  
    FROM    CHOAN_OBJECT_COMMON_CODE  
    WHERE   1 = 1  
    AND     GROUP_NAME = @P_GROUP_NAME
    AND     USE_YORN = 'Y'
	ORDER	BY OBJ_CODE ASC
  
END  
GO
