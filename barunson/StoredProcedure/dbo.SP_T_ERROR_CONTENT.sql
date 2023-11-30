IF OBJECT_ID (N'dbo.SP_T_ERROR_CONTENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_ERROR_CONTENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_ERROR_CONTENT]
/*****************************************************************
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @ERROR_CONTENT	TEXT,
 @ID VARCHAR(50),
 @USER_NAME  NVARCHAR(100),
 @METHOD_NAME VARCHAR(50)
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

 INSERT TB_ERROR_CONTENT(ERROR_CONTENT, ID, [USER_NAME], REG_DATE, METHOD_NAME)
 VALUES (@ERROR_CONTENT, @ID, @USER_NAME, GETDATE(), @METHOD_NAME)

GO
