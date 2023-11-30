IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_SAMPLE_ITEM_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_SAMPLE_ITEM_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_SAMPLE_ITEM_LIST]
	@p_sample_group_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
    SGIM.*,
    PM.PROD_CODE,
    PM.PROD_TITLE
    FROM
    SAMPLE_GROUP_ITEM_MST SGIM
    LEFT JOIN PROD_MST PM ON SGIM.PROD_SEQ = PM.PROD_SEQ
    WHERE SGIM.SAMPLE_GROUP_SEQ = @p_sample_group_seq
    ORDER BY SGIM.SORT_RATE ASC, SGIM.SAMPLE_GROUP_ITEM_SEQ ASC;
END

GO
