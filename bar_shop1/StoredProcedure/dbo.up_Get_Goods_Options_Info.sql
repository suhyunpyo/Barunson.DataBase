IF OBJECT_ID (N'dbo.up_Get_Goods_Options_Info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Get_Goods_Options_Info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-11-24
-- Description:	카드 옵션 정보

-- =============================================
CREATE PROCEDURE [dbo].[up_Get_Goods_Options_Info]
	
	@card_seq INT

AS
BEGIN	
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	--DECLARE @card_seq int=34696

	--DECLARE @Acc1_seq INT
	DECLARE @Acc1_GroupSeq INT


	SELECT	@Acc1_GroupSeq = Acc1_GroupSeq					
	FROM S2_CardDetail	
	WHERE Card_Seq = @card_seq 
	
	
	SELECT   CardItemGroup_Seq
			,CardItemGroup
	FROM S2_CardItemGroupInfo 
	WHERE CardItemGroup_Seq = @Acc1_GroupSeq
	
	
	SELECT   isDigitalColor
			,isColorInpaper
	FROM S2_CardOption 
	WHERE Card_Seq = @card_seq	
	
END

GO
