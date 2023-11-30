IF OBJECT_ID (N'dbo.up_front_card_vstat', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_card_vstat
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   :   [2004.6.21]  김수경: 
	관련페이지 : /wedd/display/wedd_det.asp
	내용	   :  상품 뷰카운트 관리
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_front_card_vstat]
	@KIND		varchar(20)
,	@card_seq		INT
,	@vdate	varchar(10)
as
IF @KIND = 'ADD'
	BEGIN
		insert into CARD_VSTAT(card_seq,vdate) values(@card_seq,@vdate)
	END
IF @KIND = 'UPDATE'
	BEGIN
		update CARD_VSTAT set vcnt = vcnt + 1 where card_seq = @card_seq and vdate = @vdate
	END


GO
