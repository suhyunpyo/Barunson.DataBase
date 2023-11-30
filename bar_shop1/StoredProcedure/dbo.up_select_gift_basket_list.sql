IF OBJECT_ID (N'dbo.up_select_gift_basket_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_gift_basket_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-15
-- Description:	답례품 장바구리 리스트 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_gift_basket_list]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@uid	AS nvarchar(16),
	@order_type	AS nvarchar(10)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
			select COUNT(seq) from S2_UsrBasket AS A with(nolock) 
			where A.uid=@uid 
			and A.company_seq=@company_seq
			and A.order_Type=@order_type
			
		
			select 
			A.seq,A.card_seq,A.option_str,shop_name,
			B.card_code,B.card_name,B.card_image,
			(A.option_price+B.card_price) as card_price,A.order_cnt,C.min_onum 
			from S2_UsrBasket A with(nolock)
			inner join S2_Card B with(nolock) on A.card_seq = B.card_seq 
			join S2_CardDetailEtc C with(nolock) on A.card_Seq = C.card_seq 
			join (select A.code, (select B.code_value from manage_code AS B where B.code=A.code and  code_type='etcprod' ) AS shop_name from manage_code AS A
			where code_type='etcprod' 
			and LEN(code) = '1') AS D
			on A.order_type = D.code
			where A.uid=@uid 
			and A.company_seq=@company_seq
			and A.order_Type=@order_type
			order by A.seq DESC

	
END
GO
