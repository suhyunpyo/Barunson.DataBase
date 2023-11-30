IF OBJECT_ID (N'dbo.IMP_SAVE_DIGITAL_IMPOSITION_FORMAT', N'P') IS NOT NULL DROP PROCEDURE dbo.IMP_SAVE_DIGITAL_IMPOSITION_FORMAT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		송지웅
-- Create date: <Create Date,,>
-- Description:	DIGITAL PRINT TYPE의 IMPOSITION FORMAT 정보(판배열 제어 수치값)를 저장한다.
-- =============================================
CREATE PROCEDURE [dbo].[IMP_SAVE_DIGITAL_IMPOSITION_FORMAT]
	@p_save_name nvarchar(max),
	@p_stage_width float,
	@p_stage_height float,
	@p_stage_top_padding float,
	@p_stage_left_padding float,
	@p_tile_width float,
	@p_tile_height float,
	@p_crop_width float,
	@p_crop_height float,
	@p_crop_top_margin float,
	@p_crop_left_margin float,
	@p_trim_line_stroke_width float,
	@p_trim_line_length float,
	@p_trim_line_top_gap float,
	@p_trim_line_left_gap float,
	@p_trim_line_right_gap float,
	@p_trim_line_bottom_gap float,
	@p_rotation_type_code nvarchar(6),
	@p_split_area_type_code nvarchar(6),
	@p_split_area_count int,
	@p_row_count int,
	@p_cell_count int,
	@p_barcode_position_type_code nvarchar(6),
	@p_barcode_rotation_type_code nvarchar(6),
	@p_barcode_visible_type_code nvarchar(6),
	@p_barcode_coodinate float
AS
BEGIN
	DECLARE @t_max_format_code int,
	@t_current_format_code int;
	
	SET @t_current_format_code = (SELECT IMPOSITION_FORMAT_CODE	FROM dbo.IMPOSITION_FORMAT_MST WHERE SAVE_NAME = @p_save_name)
	
	IF(@t_current_format_code IS NULL)
		BEGIN
		
		SET @t_max_format_code = (SELECT	MAX(IMPOSITION_FORMAT_CODE) FROM dbo.IMPOSITION_FORMAT_MST);
		IF(@t_max_format_code IS NULL)
			SET @t_max_format_code = 1;
		ELSE
			SET @t_max_format_code = @t_max_format_code + 1;
		
		INSERT INTO [dbo].[IMPOSITION_FORMAT_MST]
			   (
			   [IMPOSITION_FORMAT_CODE]
			   ,[SAVE_NAME]
			   ,[PRINT_TYPE_CODE]
			   ,[STAGE_WIDTH]
			   ,[STAGE_HEIGHT]
			   ,[STAGE_TOP_PADDING]
			   ,[STAGE_LEFT_PADDING]
			   ,[TILE_WIDTH]
			   ,[TILE_HEIGHT]
			   ,[CROP_WIDTH]
			   ,[CROP_HEIGHT]
			   ,[CROP_TOP_MARGIN]
			   ,[CROP_LEFT_MARGIN]
			   ,[TRIM_LINE_STROKE_WIDTH]
			   ,[TRIM_LINE_LENGTH]
			   ,[TRIM_LINE_TOP_GAP]
			   ,[TRIM_LINE_LEFT_GAP]
			   ,[TRIM_LINE_RIGHT_GAP]
			   ,[TRIM_LINE_BOTTOM_GAP]
			   ,[ROTATION_TYPE_CODE]
			   ,[SPLIT_AREA_TYPE_CODE]
			   ,[SPLIT_AREA_COUNT]
			   ,[ROW_COUNT]
			   ,[CELL_COUNT]
			   ,[BARCODE_POSITION_TYPE_CODE]
			   ,[BARCODE_ROTATION_TYPE_CODE]
			   ,[BARCODE_VISIBLE_TYPE_CODE]
			   ,[BARCODE_COODINATE]
			   ,[REG_DATE]
			   )
		 VALUES
			   (
			   @t_max_format_code
			   ,@p_save_name
			   ,'100001'
			   ,@p_stage_width
			   ,@p_stage_height
			   ,@p_stage_top_padding
			   ,@p_stage_left_padding
			   ,@p_tile_width
			   ,@p_tile_height
			   ,@p_crop_width
			   ,@p_crop_height
			   ,@p_crop_top_margin
			   ,@p_crop_left_margin
			   ,@p_trim_line_stroke_width
			   ,@p_trim_line_length
			   ,@p_trim_line_top_gap
			   ,@p_trim_line_left_gap
			   ,@p_trim_line_right_gap
			   ,@p_trim_line_bottom_gap
			   ,@p_rotation_type_code
			   ,@p_split_area_type_code
			   ,@p_split_area_count
			   ,@p_row_count
			   ,@p_cell_count
			   ,@p_barcode_position_type_code
			   ,@p_barcode_rotation_type_code
			   ,@p_barcode_visible_type_code
			   ,@p_barcode_coodinate
			   ,GETDATE()
			   )
		

		END
	ELSE
		BEGIN
			UPDATE [dbo].[IMPOSITION_FORMAT_MST]
		   SET [PRINT_TYPE_CODE] = '100001'
			  ,[PRINT_DETAIL_TYPE_CODE] = NULL
			  ,[THERMOGRAPHY_COLOR_CODE] = NULL
			  ,[STAGE_WIDTH] = @p_stage_width
			  ,[STAGE_HEIGHT] = @p_stage_height
			  ,[STAGE_TOP_PADDING] = @p_stage_top_padding
			  ,[STAGE_LEFT_PADDING] = @p_stage_left_padding
			  ,[STAGE_BOTTOM_PADDING] = NULL
			  ,[TILE_WIDTH] = @p_tile_width
			  ,[TILE_HEIGHT] = @p_tile_height
			  ,[CROP_WIDTH] = @p_crop_width
			  ,[CROP_HEIGHT] = @p_crop_height
			  ,[CROP_TOP_MARGIN] = @p_crop_top_margin
			  ,[CROP_LEFT_MARGIN] = @p_crop_left_margin
			  ,[TRIM_LINE_STROKE_WIDTH] = @p_trim_line_stroke_width
			  ,[TRIM_LINE_LENGTH] = @p_trim_line_length
			  ,[TRIM_LINE_TOP_GAP] = @p_trim_line_top_gap
			  ,[TRIM_LINE_LEFT_GAP] = @p_trim_line_left_gap
			  ,[TRIM_LINE_RIGHT_GAP] = @p_trim_line_right_gap
			  ,[TRIM_LINE_BOTTOM_GAP] = @p_trim_line_bottom_gap
			  ,[ROTATION_TYPE_CODE] = @p_rotation_type_code
			  ,[SPLIT_AREA_TYPE_CODE] = @p_split_area_type_code
			  ,[SPLIT_AREA_COUNT] = @p_split_area_count
			  ,[ROW_COUNT] = @p_row_count
			  ,[CELL_COUNT] = @p_cell_count
			  ,[BARCODE_POSITION_TYPE_CODE] = @p_barcode_position_type_code
			  ,[BARCODE_ROTATION_TYPE_CODE] = @p_barcode_rotation_type_code
			  ,[BARCODE_VISIBLE_TYPE_CODE] = @p_barcode_visible_type_code
			  ,[BARCODE_COODINATE] = @p_barcode_coodinate
			  ,[REG_DATE] = GETDATE()
			 WHERE IMPOSITION_FORMAT_CODE = @t_current_format_code

		END
END
GO
