IF OBJECT_ID (N'dbo.up_select_thumbnail_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thumbnail_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-31
-- Description:	제품 LIST 화면 - 제품 확대 thumb_nail LIST
-- TEST : up_select_thumbnail_list 34892, 5007  
-- =============================================
CREATE PROCEDURE [dbo].[up_select_thumbnail_list]
	
	@card_seq		int,		
	@company_seq	int	

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
		
	
	--DECLARE @card_seq int = 34892
	--DECLARE @company_seq int = 5007    

    -- 카드 thumbnail 이미지(최대 10개)

	if @company_seq = 5007
		begin
			SELECT TOP 10 cardimage_wsize
						 ,cardimage_hsize
						 ,cardimage_filename				 
			FROM S2_CardImage
			WHERE card_seq = @card_seq 
			  AND cardimage_div = 'B'
			  AND company_seq = @company_seq
			  AND cardimage_filename <> '' 
			  AND cardimage_filename IS NOT NULL
			ORDER BY cardimage_filename
		end 
	else 
		begin
			SELECT TOP 6 cardimage_wsize
						 ,cardimage_hsize
						 ,cardimage_filename
						 ,(select card_code from s2_card where card_seq = c.card_seq) card_name				 
			FROM S2_CardImage c
			WHERE card_seq = @card_seq 
			  AND cardimage_div = 'B'
			  AND company_seq = @company_seq
			  AND cardimage_filename <> '' 
			  AND cardimage_filename IS NOT NULL
			ORDER BY cardimage_filename
		end 
	
	
END		
GO
