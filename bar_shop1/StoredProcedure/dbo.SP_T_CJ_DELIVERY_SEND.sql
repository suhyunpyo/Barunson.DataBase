IF OBJECT_ID (N'dbo.SP_T_CJ_DELIVERY_SEND', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_CJ_DELIVERY_SEND
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_CJ_DELIVERY_SEND]
/***************************************************************
작성자	:	표수현
작성일	:	2021-08-15
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


DECLARE @START_DATE AS VARCHAR(10)
DECLARE @END_DATE AS VARCHAR(10)

SET @START_DATE = CONVERT(VARCHAR(10), GETDATE(), 120)
SET @END_DATE = CONVERT(VARCHAR(10), GETDATE() + 1, 120)


EXEC SP_EXEC_DELIVERY_RECEIPT_FOR_CJ_NEW_API_VER2  @START_DATE, @END_DATE
GO
