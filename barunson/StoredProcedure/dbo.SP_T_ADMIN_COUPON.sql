IF OBJECT_ID (N'dbo.SP_T_ADMIN_COUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_ADMIN_COUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_ADMIN_COUPON]
/***************************************************************
작성자	:	표수현
작성일	:	2021-05-06
DESCRIPTION	:	
SPECIAL LOGIC	:
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN			CHAR(2) = NULL,
 @ID OBJECTTYPE READONLY -- 테이블 반환 매개변수
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	-- 쿠폰 삭제 
	DELETE FROM TB_COUPON
			FROM TB_COUPON A INNER JOIN 
			@ID B ON A.COUPON_ID = B.ID

GO
