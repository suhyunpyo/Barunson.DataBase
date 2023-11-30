IF OBJECT_ID (N'dbo.SP_S_MEMBER_CAED_PURCHASE_SITEGUBUN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_MEMBER_CAED_PURCHASE_SITEGUBUN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_MEMBER_CAED_PURCHASE_SITEGUBUN]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 어드민 - 회원당 종이모초 구매한 사이트 리스트 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @ID						USERIDTYPE READONLY		-- 테이블 반환 매개변수 
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	SELECT MEMBER_ID, 
		  gubun =  CASE WHEN A.SALES_GUBUN = 'BM' THEN 'M' 
											WHEN A.SALES_GUBUN = 'SB' THEN '바른손' 
											WHEN A.SALES_GUBUN = 'SA' THEN '비핸즈' 
											WHEN A.SALES_GUBUN = 'ST' THEN '더카드' 
											WHEN A.SALES_GUBUN = 'SS' THEN '프리미어' 
											WHEN A.SALES_GUBUN = 'B' OR A.SALES_GUBUN = 'H' THEN '바른손몰' 	
												ELSE '' END

		FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
			 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
		WHERE STATUS_SEQ >= 9 and member_id  in (select UserID  from @ID)
		GROUP BY MEMBER_ID, A.SALES_GUBUN
	


	
GO
