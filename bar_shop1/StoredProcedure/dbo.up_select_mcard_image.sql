IF OBJECT_ID (N'dbo.up_select_mcard_image', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_mcard_image
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-09
-- Description:	모바일 청첩장 갤리리 조회
-- TEST : up_select_mcard_image 'M', 6
-- =============================================
CREATE PROCEDURE [dbo].[up_select_mcard_image]
	@method			char(1),
	@order_seq		int	
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	
	IF @method = 'M'
		BEGIN
			SELECT TOP 1
				T3.order_seq							-- 0
				,T3.FileIndex							-- 1
				,T3.FileName AS filename_big			-- 2
				,T3.imageSizeW AS imageSizeW_big		-- 3
				,T3.imageSizeH AS imageSizeH_big		-- 4
				,T4.FileName AS filename_small			-- 5
				,T4.imageSizeW AS imageSizeW_small		-- 6
				,T4.imageSizeH AS imageSizeH_small		-- 7
				,T7.FileName AS filename_320			-- 8
				,T7.imageSizeW AS imageSizeW_320		-- 9
				,T7.imageSizeH AS imageSizeH_320		-- 10
				,T8.FileName AS filename_640			-- 11
				,T8.imageSizeW AS imageSizeW_640		-- 12
				,T8.imageSizeH AS imageSizeH_640		-- 13
			FROM 
				S5_nmCardImageInfo T3
				LEFT OUTER JOIN S5_nmCardImageInfo T4 ON T3.Order_Seq=T4.Order_Seq AND T3.FileIndex=T4.FileIndex AND T4.FileType=4
				LEFT OUTER JOIN S5_nmCardImageInfo T7 ON T3.Order_Seq=T7.Order_Seq AND T3.FileIndex=T7.FileIndex AND T7.FileType=7
				LEFT OUTER JOIN S5_nmCardImageInfo T8 ON T3.Order_Seq=T8.Order_Seq AND T3.FileIndex=T8.FileIndex AND T8.FileType=8
			WHERE 
				T3.order_seq=@order_seq AND T3.filetype=3
			ORDER BY T3.FileIndex ASC	
		END
	ELSE
		BEGIN	
			SELECT 
				T1.order_seq 
				,T1.FileIndex
				,T1.FileName AS filename_big
				,T1.imageSizeW AS imageSizeW_big
				,T1.imageSizeH AS imageSizeH_big
				,T2.FileName AS filename_small
				,T2.imageSizeW AS imageSizeW_small
				,T2.imageSizeH AS imageSizeH_small
				,T5.FileName AS filename_320
				,T5.imageSizeW AS imageSizeW_320
				,T5.imageSizeH AS imageSizeH_320
				,T6.FileName AS filename_640
				,T6.imageSizeW AS imageSizeW_640
				,T6.imageSizeH AS imageSizeH_640
			FROM 
				S5_nmCardImageInfo T1
				LEFT OUTER JOIN S5_nmCardImageInfo T2 ON T1.Order_Seq=T2.Order_Seq AND T1.FileIndex=T2.FileIndex AND T2.FileType=2
				LEFT OUTER JOIN S5_nmCardImageInfo T5 ON T1.Order_Seq=T5.Order_Seq AND T1.FileIndex=T5.FileIndex AND T5.FileType=5
				LEFT OUTER JOIN S5_nmCardImageInfo T6 ON T1.Order_Seq=T6.Order_Seq AND T1.FileIndex=T6.FileIndex AND T6.FileType=6
			WHERE 
				T1.order_seq=@order_seq AND T1.filetype=1
			ORDER BY T1.FileIndex
		END				
	
END
GO
