IF OBJECT_ID (N'dbo.Up_Select_S4_MD_Choice_Data', N'P') IS NOT NULL DROP PROCEDURE dbo.Up_Select_S4_MD_Choice_Data
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-08-03
-- Description:	프론트, S4_MD_Choice Data 조회

-- EXEC Up_Select_S4_MD_Choice_Data 381, 'Y', 'Y'
-- =============================================
CREATE proc [dbo].[Up_Select_S4_MD_Choice_Data]

	@md_seq int
	, @view_div char(1)
	, @jehu_view_div char(1)

as

	
set nocount on;

select count(*) as cnt
from S4_MD_Choice 
where md_seq = @md_seq 
	and 1 = 
		(
			select 1 where @view_div = ''
			union all
			select 1 where @view_div <> '' and view_div = @view_div
		)
	and 1 = 
		(
			select 1 where @jehu_view_div = ''
			union all
			select 1 where @jehu_view_div <> '' and jehu_view_div = @jehu_view_div
		)

select seq, imgfile_path, isnull(link_url, '') as url, card_text as title, LINK_TARGET
from S4_MD_Choice 
where md_seq = @md_seq 
	and 1 = 
		(
			select 1 where @view_div = ''
			union all
			select 1 where @view_div <> '' and view_div = @view_div
		)
	and 1 = 
		(
			select 1 where @jehu_view_div = ''
			union all
			select 1 where @jehu_view_div <> '' and jehu_view_div = @jehu_view_div
		)

order by sorting_num asc
GO
