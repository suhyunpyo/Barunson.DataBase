IF OBJECT_ID (N'dbo.up_Select_Md_Choice_For_Weeklyhotdeal_I', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_Md_Choice_For_Weeklyhotdeal_I
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-05-27
-- Description:	관리자, MD전시 > 위클리핫딜 상품 저장

-- exec dbo.up_Select_Md_Choice_For_Weeklyhotdeal_I 
-- =============================================
CREATE proc [dbo].[up_Select_Md_Choice_For_Weeklyhotdeal_I]

	@md_seq				int
	, @sorting_num		int
	, @card_seq			int
	, @admin_id			varchar(16)

as

set nocount on;

declare @choice_seq int, @hotdeal_price int

-- MD 상품 등록
Insert into S4_MD_Choice 
(
	md_seq,sorting_num,card_seq,admin_id
) 
Values 
(
	@md_seq,@sorting_num,@card_seq,@admin_id
)
set @choice_seq = @@IDENTITY

-- MD 상품 위클리 핫딜가격 조회(최초 소비자가격으로 셋팅
select @hotdeal_price = CardSet_Price
from S2_Card WITH(NOLOCK)  
where Card_Seq = @card_seq

-- MD 상품 위클리 핫딜 정보 등록
insert into S4_MD_Choice_weeklyhotdeal
(
	choice_seq, hotdeal_price
)
values
(
	@choice_seq, @hotdeal_price
)












GO
