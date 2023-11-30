IF OBJECT_ID (N'dbo.UP_MD_CATE', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_MD_CATE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UP_MD_CATE]
	-- Add the parameters for the stored procedure here
	@company_seq	int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if @company_seq = 0
		begin
			WITH tree_query  AS (
			  SELECT 
					md_seq, md_text, md_upper_code, company_seq
					, convert(varchar(255), md_seq) sort 
				FROM S4_MD_Choice_Str
				WHERE md_upper_code=0 
				UNION ALL
				SELECT
					  B.md_seq
					, B.md_text
					, B.md_upper_code
					, B.company_seq
					, convert(varchar(255), convert(nvarchar,C.sort) + ' > ' +  convert(varchar(255), B.md_seq)) sort
				FROM  S4_MD_Choice_Str B, tree_query C
				WHERE B.md_upper_code = C.md_seq and B.md_upper_code <> 0
			) 

			SELECT  D.md_seq, md_text, md_upper_code, company_seq, used_yn, st_seq FROM tree_query  AS D with(nolock)
			join S4_MD_Choice_Str_UsedYN AS E with(nolock)
			on D.md_seq = E.md_seq
			left outer join S4_Ranking_Sort AS F with(nolock)
			on D.md_seq = F.ST_MD_SEQ
			where company_seq in (5001, 5003, 5006, 5007) order by company_seq, sort, D.md_seq
		end
	else
		begin
			WITH tree_query  AS (
			  SELECT 
					md_seq, md_text, md_upper_code, company_seq
					, convert(varchar(255), md_seq) sort 
				FROM S4_MD_Choice_Str
				WHERE md_upper_code=0 
				UNION ALL
				SELECT
					  B.md_seq
					, B.md_text
					, B.md_upper_code
					, B.company_seq
					, convert(varchar(255), convert(nvarchar,C.sort) + ' > ' +  convert(varchar(255), B.md_seq)) sort
				FROM  S4_MD_Choice_Str B, tree_query C
				WHERE B.md_upper_code = C.md_seq and B.md_upper_code <> 0
			) 
			SELECT  D.md_seq, md_text, md_upper_code, company_seq, used_yn, st_seq FROM tree_query  AS D with(nolock)
			join S4_MD_Choice_Str_UsedYN AS E with(nolock)
			on D.md_seq = E.md_seq
			left outer join S4_Ranking_Sort AS F with(nolock)
			on D.md_seq = F.ST_MD_SEQ
			where company_seq = @company_seq order by company_seq, sort, D.md_seq
		end
END
GO
