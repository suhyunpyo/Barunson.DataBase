IF OBJECT_ID (N'dbo.SP_SELECT_SAMPLE_GROUP_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SAMPLE_GROUP_LIST
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
CREATE PROCEDURE [dbo].[SP_SELECT_SAMPLE_GROUP_LIST]
	@p_sample_group_seq int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	SGM.*,
	STUFF(
		(
			SELECT ',' + CAST(ISGIM.PROD_SEQ AS NVARCHAR)
			FROM SAMPLE_GROUP_ITEM_MST ISGIM
			WHERE ISGIM.SAMPLE_GROUP_SEQ = SGM.SAMPLE_GROUP_SEQ 
			ORDER BY ISGIM.PROD_SEQ ASC
			FOR XML PATH('')
		)
	, 1, 1, '') AS PROD_SEQ_LIST,
	STUFF(
		(
			SELECT ',' + IPM.PROD_CODE
			FROM SAMPLE_GROUP_ITEM_MST ISGIM
			LEFT JOIN PROD_MST IPM ON ISGIM.PROD_SEQ = IPM.PROD_SEQ
			WHERE ISGIM.SAMPLE_GROUP_SEQ = SGM.SAMPLE_GROUP_SEQ 
			ORDER BY ISGIM.PROD_SEQ ASC
			FOR XML PATH('')
		)
	, 1, 1, '') AS PROD_CODE_LIST,
	STUFF(
			(
				SELECT ',' + IPM.PROD_TITLE
				FROM SAMPLE_GROUP_ITEM_MST ISGIM
				LEFT JOIN PROD_MST IPM ON ISGIM.PROD_SEQ = IPM.PROD_SEQ
				WHERE ISGIM.SAMPLE_GROUP_SEQ = SGM.SAMPLE_GROUP_SEQ 
				ORDER BY ISGIM.PROD_SEQ ASC
				FOR XML PATH('')
			)
		, 1, 1, '') AS PROD_TITLE_LIST
	FROM SAMPLE_GROUP_MST SGM
	WHERE
		SGM.SAMPLE_GROUP_SEQ = 
		(
			CASE @p_sample_group_seq 
			WHEN -1 THEN SGM.SAMPLE_GROUP_SEQ
			ELSE @p_sample_group_seq
			END
		)
	ORDER BY SGM.SORT_RATE ASC, SGM.SAMPLE_GROUP_SEQ ASC;
END


GO
