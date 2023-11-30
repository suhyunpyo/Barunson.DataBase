IF OBJECT_ID (N'dbo.IMP_REMOVE_IMPOSITION_FORMAT', N'P') IS NOT NULL DROP PROCEDURE dbo.IMP_REMOVE_IMPOSITION_FORMAT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		송지웅
-- Create date: <Create Date,,>
-- Description:	데이터 베이스에 등록되어있는 IMPOSITION FORMAT 정보(판배열 제어 수치값)를 삭제한다.
-- =============================================
CREATE PROCEDURE [dbo].[IMP_REMOVE_IMPOSITION_FORMAT]
	@p_save_name nvarchar(max)
AS
BEGIN
	DECLARE @t_current_format_code int;
	
	SET @t_current_format_code = (SELECT IMPOSITION_FORMAT_CODE	FROM dbo.IMPOSITION_FORMAT_MST WHERE SAVE_NAME = @p_save_name)
	
	
	IF(@t_current_format_code IS NOT NULL)
		BEGIN
			DELETE FROM dbo.IMPOSITION_PART_LINKED_FORMAT_MST WHERE IMPOSITION_FORMAT_CODE = @t_current_format_code;
			DELETE FROM dbo.IMPOSITION_FORMAT_MST WHERE IMPOSITION_FORMAT_CODE = @t_current_format_code;
		END
	
END
GO
