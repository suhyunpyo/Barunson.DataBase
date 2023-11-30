IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_PRODUCT_SET_GROUP_REF', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_PRODUCT_SET_GROUP_REF
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_PRODUCT_SET_GROUP_REF]
	-- Add the parameters for the stored procedure here
	@p_ref_seq int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM PROD_SET_GROUP_REF_MST WHERE REF_SEQ = @p_ref_seq;
END

GO
