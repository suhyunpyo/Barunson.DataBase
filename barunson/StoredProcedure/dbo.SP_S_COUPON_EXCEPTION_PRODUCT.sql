IF OBJECT_ID (N'dbo.SP_S_COUPON_EXCEPTION_PRODUCT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_COUPON_EXCEPTION_PRODUCT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_COUPON_EXCEPTION_PRODUCT]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 카테고리 전체 리스트 
SPECIAL LOGIC	: 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @PRODUCT_CODE VARCHAR(6) = NULL
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SELECT COUNT(*) 
 FROM TB_COUPON_EXCEPTION_PRODUCT
 WHERE PRODUCT_CODE = @PRODUCT_CODE

GO
