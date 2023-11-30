IF OBJECT_ID (N'dbo.IMP_SAVE_COMMENT_HISTORY', N'P') IS NOT NULL DROP PROCEDURE dbo.IMP_SAVE_COMMENT_HISTORY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		송지웅
-- Create date: <Create Date,,>
-- Description:	판배열결과물의 정보란에 삽입되는 Comment 에 대한 히스토리 저장
-- =============================================
CREATE PROCEDURE [dbo].[IMP_SAVE_COMMENT_HISTORY]
	-- Add the parameters for the stored procedure here
	@p_comment_value nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[IMPOSITION_COMMENT_HISTORY_MST]
           (
           [COMMENT_VALUE]
           ,[REG_DATE]
           )
     VALUES
           (
           @p_comment_value
           ,GETDATE()
           )



END
GO
