IF OBJECT_ID (N'dbo.up_select_style_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_style_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-04
-- Description:	Style code & name 목록
-- up_select_style_list
-- =============================================
CREATE PROCEDURE [dbo].[up_select_style_list]	
AS
BEGIN
	
	SELECT   CardStyle_Seq
			,CardStyle
	FROM S2_CardStyleItem 
	WHERE cardstyle_site = 'T' 
	  AND cardstyle_category = 'B'
	ORDER BY CardStyle_Num ASC
	  	
END
GO
