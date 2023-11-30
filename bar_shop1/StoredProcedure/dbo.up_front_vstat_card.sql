IF OBJECT_ID (N'dbo.up_front_vstat_card', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_vstat_card
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/*  
 작성정보   :   [2005:01:25    13:28] 김수경:   
 내용    :       상품 뷰카운트
   
 수정정보   :   
*/  
CREATE Procedure [dbo].[up_front_vstat_card]
	@card_type		varchar(1)
,	@card_seq		INT
,	@vdate	varchar(10)
,	@company_seq smallint
as

IF EXISTS (select vcnt from VSTAT_CARD where card_seq=@card_seq and vdate=@vdate and card_type=@card_type and company_seq=@company_seq)
-- 해당 상품열이 없을때 INSERT 처리

	update VSTAT_CARD set vcnt = vcnt + 1 where card_seq = @card_seq and vdate = @vdate and card_type = @card_type and company_seq=@company_seq
ELSE						-- 이미 해당상품 열이 입력되어 있을때 UPDATE 처리
	insert into VSTAT_CARD(card_seq,vdate,card_type) values(@card_seq,@vdate,@card_type)
GO
