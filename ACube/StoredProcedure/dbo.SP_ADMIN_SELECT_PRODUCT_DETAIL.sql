IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PRODUCT_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PRODUCT_DETAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PRODUCT_DETAIL]
	-- Add the parameters for the stored procedure here
	@p_prod_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	PM.*,
	TYPE_CC.DTL_NAME AS TYPE_DTL_NAME,
	TYPE_CC.DTL_DESC AS TYPE_DTL_DESC,
	STUFF(
		(
			SELECT  
			',' + '{' 
				+ 'ADDON_SEQ' + '|:|' + CONVERT(nvarchar, PAM.ADDON_SEQ) + '|+|'	
				+ 'PROD_SEQ' + '|:|' + CONVERT(nvarchar,PAM.ADDON_PROD_SEQ) + '|+|' 
				+ 'PROD_CODE' + '|:|' + PAM_PM.PROD_CODE + '|+|' 
				+ 'PROD_TYPE_CODE' + '|:|' + PAM_PM.PROD_TYPE_CODE + '|+|'
				+ 'PROD_TYPE_NAME' + '|:|' + PAM_TYPE_CC.DTL_NAME + '|+|'
				+ 'PROD_TYPE_DESC' + '|:|' + PAM_TYPE_CC.DTL_DESC 
				+ '}'
			FROM PROD_ADDON_MST PAM
			LEFT JOIN PROD_MST PAM_PM ON PAM.ADDON_PROD_SEQ = PAM_PM.PROD_SEQ
			LEFT JOIN COMMON_CODE PAM_TYPE_CC ON PAM_TYPE_CC.CMMN_CODE = PAM_PM.PROD_TYPE_CODE
			WHERE PAM.PROD_SEQ = PM.PROD_SEQ
			ORDER BY PAM_PM.PROD_TYPE_CODE ASC
			FOR XML PATH('')
		), 1, 1, ''
	) AS ADDON_PROD_INFO_LIST
	FROM PROD_MST PM 
	LEFT JOIN COMMON_CODE TYPE_CC ON TYPE_CC.CMMN_CODE = PM.PROD_TYPE_CODE
	WHERE PM.PROD_SEQ = @p_prod_seq
END

GO
