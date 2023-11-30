IF OBJECT_ID (N'dbo.up_select_map_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_map_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[up_select_map_list]
	@wedd_idx			AS int,	
	@colormap			AS int	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		COUNT(*) AS total_count
	FROM 
		dbo.weddinghall_image 
	WHERE 
		wedd_idx = @wedd_idx and isCorel=1 and isColor=@colormap

	SELECT 
		imgFolder, ImgName, WeddImg_IDX, Wedd_IDX, imgWidth, imgHeight, isCorel
	FROM 
		dbo.weddinghall_image 
	WHERE 
		wedd_idx = @wedd_idx and isCorel=1 and isColor=@colormap
	ORDER BY lsort
END

GO
