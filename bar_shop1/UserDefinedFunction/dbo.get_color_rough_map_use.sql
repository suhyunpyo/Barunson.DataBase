IF OBJECT_ID (N'dbo.get_color_rough_map_use', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_color_rough_map_use', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_color_rough_map_use', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_color_rough_map_use', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_color_rough_map_use', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.get_color_rough_map_use
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
1. [get_color_rough_map_use]
카드번호로 컬러약도 카드인지 구분

--컬러약도인 카드
카드 카테고리에서 [커스텀 디지탈카드]
카드 정책에서 [내지칼러인쇄],[커스텀디지탈인쇄] 인카드

select dbo.get_color_rough_map_use('34252')



*/
CREATE function [dbo].[get_color_rough_map_use] (  
 @card_seq nvarchar(15)   
)
 
RETURNS varchar(20)   

AS 
BEGIN 

	DECLARE @color_rough_map_use1 varchar(20)
	DECLARE @color_rough_map_use2 varchar(20)
	DECLARE @color_rough_map_use3 varchar(20)   
	
	DECLARE @color_rough_map_use_result varchar(20)   
	
	
	-- 카드 카테고리에서 [커스텀 디지탈카드]
	select @color_rough_map_use1  = count(*) from s2_cardkindinfo A 
	left outer join s2_cardkind B on A.cardkind_seq = B.cardkind_seq and B.card_seq = @card_seq
	where A.cardkind ='커스텀 디지탈카드' and B.card_Seq is not null
	
	
	-- 카드 정책에서 [내지칼러인쇄]
	--select @color_rough_map_use2 = iscolorinpaper from S2_Cardoption where card_seq = @card_seq
	
	-- 카드 정책에서 [커스텀디지탈인쇄]
	--select @color_rough_map_use3 = iscustomdcolor from S2_Cardoption where card_seq = @card_seq
	
	
	
	if @color_rough_map_use1 = 1 or @color_rough_map_use2 = 1 or @color_rough_map_use3 = 1
		select @color_rough_map_use_result = '1'
	
	
	else
		select @color_rough_map_use_result = '0'

	RETURN @color_rough_map_use_result 

END 

GO
