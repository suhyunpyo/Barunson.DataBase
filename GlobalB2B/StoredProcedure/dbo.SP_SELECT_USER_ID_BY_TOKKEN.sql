IF OBJECT_ID (N'dbo.SP_SELECT_USER_ID_BY_TOKKEN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_USER_ID_BY_TOKKEN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SELECT_USER_ID_BY_TOKKEN]
	@p_tokken_code nvarchar(40)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT UM.USER_ID FROM USER_TOKKEN_MST UFTM
    LEFT JOIN USER_MST UM ON UFTM.USER_SEQ = UM.USER_SEQ
    WHERE UFTM.TOKKEN_CODE = @p_tokken_code AND UFTM.EXPIRE_YORN = 'N';
END
GO
