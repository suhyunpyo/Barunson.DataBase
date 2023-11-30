IF OBJECT_ID (N'dbo.up_select_ranking1_web_new2', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking1_web_new2
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
CREATE PROCEDURE [dbo].[up_select_ranking1_web_new2]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@tabgubun    AS nvarchar(20),
	@brand       AS nvarchar(20),
	@code	     AS nvarchar(20),
	@tot		 int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE	@T_CNT	INT
	DECLARE	@SQL	nvarchar(1000)
	DECLARE	@SQL2	nvarchar(1000)
	
	IF @company_seq IS NULL or @company_seq=''
		begin
			set @company_seq='1'
		end
			declare @data_arry nvarchar(2000)
			declare @data_arry_title nvarchar(2000)
			select @data_arry=ST_Card_Code_Arry, @data_arry_title=ST_Title from S4_Ranking_Sort where ST_company_seq=@company_seq and ST_Code=@code ;
			
			if @brand = 'ALL' 
				begin 
					select @t_cnt = COUNT(itemvalue) from dbo.fn_SplitIn3Rows(@data_arry,@data_arry_title,',') AS A
					inner join S2_CardSalesSite AS B with(nolock) on A.itemvalue = B.Card_Seq
					and B.Company_Seq=@company_seq
					and B.IsDisplay=1
					join s2_cardkind AS I on B.card_seq = I.Card_Seq
					join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
					and J.CardKind_Seq=1

				end
			else
				begin
					select @t_cnt = COUNT(itemvalue) from dbo.fn_SplitIn3Rows(@data_arry,@data_arry_title,',') AS A
					inner join S2_Card AS B with(nolock) on A.itemvalue = B.Card_Seq and CardBrand=@brand	
					join S2_CardSalesSite AS C with(nolock) on B.Card_Seq = C.card_seq
					and C.IsDisplay=1
					join s2_cardkind AS I on C.card_seq = I.Card_Seq
					join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
					and J.CardKind_Seq=1
				end
			
			set @tot = @t_cnt
			return @tot
			
			
END
GO
