IF OBJECT_ID (N'dbo.IMP_RENAME_IMPOSITION_FORMAT', N'P') IS NOT NULL DROP PROCEDURE dbo.IMP_RENAME_IMPOSITION_FORMAT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		송지웅
-- Create date: <Create Date,,>
-- Description:	데이터 베이스에 등록되어있는 IMPOSITION FORMAT 정보(판배열 제어 수치값)의 저장이름을 다른이름으로 변경한다.
-- =============================================
CREATE PROCEDURE [dbo].[IMP_RENAME_IMPOSITION_FORMAT]
	-- Add the parameters for the stored procedure here
	@p_begin_save_name nvarchar(max),
	@p_rename nvarchar(max)
AS
BEGIN
	DECLARE @t_current_format_code int;
	SET @t_current_format_code = (SELECT IMPOSITION_FORMAT_CODE	FROM dbo.IMPOSITION_FORMAT_MST WHERE SAVE_NAME = @p_begin_save_name)
	IF(@t_current_format_code IS NOT NULL)
		BEGIN
		UPDATE dbo.IMPOSITION_FORMAT_MST
		SET SAVE_NAME = @p_rename
		WHERE IMPOSITION_FORMAT_CODE = @t_current_format_code
		END
END
GO
