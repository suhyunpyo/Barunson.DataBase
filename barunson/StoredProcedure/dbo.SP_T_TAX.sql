IF OBJECT_ID (N'dbo.SP_T_TAX', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_TAX
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_TAX]
/***************************************************************
작성자	:	표수현
작성일	:	2021-08-15
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @INVITATION_ID INT = 1
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 /* 가장 최근 등록된 TB_TAX 테이블의 ID값을 가져와서 TB_INVITATION_TAX 테이블에 인서트 */
 DECLARE @TAX_ID ID 
 SELECT @TAX_ID = TAX_ID 
 FROM TB_TAX 
 WHERE REGIST_DATETIME = (SELECT MAX(REGIST_DATETIME) FROM TB_TAX)

 
 INSERT TB_INVITATION_TAX(INVITATION_ID, TAX_ID, REGIST_DATETIME)
 VALUES (@INVITATION_ID, @TAX_ID, GETDATE())
 
GO
