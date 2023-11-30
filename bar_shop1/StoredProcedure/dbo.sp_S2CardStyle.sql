IF OBJECT_ID (N'dbo.sp_S2CardStyle', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardStyle
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--Exec sp_S2CardStyle 'T',30755
CREATE Proc [dbo].[sp_S2CardStyle]
	@CardBrand char(1),
	@Card_Seq int
AS
	SELECT * FROM S2_CardStyle a (NOLOCK) JOIN S2_CardStyleItem b (NOLOCK) ON a.CardStyle_Seq = b.CardStyle_Seq
	WHERE CardStyle_Site = @CardBrand and Card_Seq = @Card_Seq and CardStyle_Category in ('F','M')
	ORDER BY CardStyle_Category,CardStyle_Num
	
GO
