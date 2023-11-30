IF OBJECT_ID (N'dbo.sp_wedd_frm01', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_wedd_frm01
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:30    11:58]  
	관련페이지 : wedd_frm01.asp
	내용	   : 해당카테고리에서 선택된상품번호 추출
	
	수정정보   : 
*/
CREATE Procedure [dbo].[sp_wedd_frm01] 
(@CARD_SEQ int)
as
SELECT  card_code,card_price_customer FROM dbo.card  where card_seq = @CARD_SEQ

GO
