IF OBJECT_ID (N'dbo.IMP_UNLINKED_PART_IMPOSITION_FORMAT', N'P') IS NOT NULL DROP PROCEDURE dbo.IMP_UNLINKED_PART_IMPOSITION_FORMAT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		송지웅
-- Create date: <Create Date,,>
-- Description:	파트 코드와 IMPOSITION FORMAT 정보(판배열 제어 수치값)를 연결한것을 삭제한다.
-- =============================================
CREATE PROCEDURE [dbo].[IMP_UNLINKED_PART_IMPOSITION_FORMAT]
	-- Add the parameters for the stored procedure here
	@p_part_cd nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DELETE
	FROM
	dbo.IMPOSITION_PART_LINKED_FORMAT_MST
	WHERE PART_CD = @p_part_cd;
END
GO
