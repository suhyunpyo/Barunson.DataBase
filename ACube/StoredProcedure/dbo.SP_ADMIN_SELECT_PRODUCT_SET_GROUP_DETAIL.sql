IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PRODUCT_SET_GROUP_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PRODUCT_SET_GROUP_DETAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PRODUCT_SET_GROUP_DETAIL]
	-- Add the parameters for the stored procedure here
	@p_prod_set_group_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
    PSGM.*,
    
    GROUP_TYPE_CC.DTL_NAME,
    GROUP_TYPE_CC.DTL_DESC,
    STUFF
	(
		(
			SELECT 
				',' + '{' 
				+ 'REF_SEQ' + '|:|' + CONVERT(nvarchar,PSGRM.REF_SEQ) + '|+|' 
				+ 'PROD_SEQ' + '|:|' + CONVERT(nvarchar,PM.PROD_SEQ) + '|+|' 
				+ 'PROD_CODE' + '|:|' + PM.PROD_CODE + '|+|' 
				+ 'PROD_TYPE_CODE' + '|:|' + PM.PROD_TYPE_CODE + '|+|' 
				+ 'PROD_TYPE_NAME' + '|:|' + TYPE_CC.DTL_NAME + '|+|' 
				+ 'PROD_TYPE_DESC' + '|:|' + TYPE_CC.DTL_DESC + '|+|' 
				+ 'REF_TYPE_CODE' + '|:|' + PSGRM.REF_TYPE_CODE + '|+|' 
				+ 'REF_TYPE_NAME' + '|:|' + REF_TYPE_CC.DTL_NAME + '|+|' 
				+ 'REF_TYPE_DESC' + '|:|' + REF_TYPE_CC.DTL_DESC + '|+|' 
				+ 'PROD_PRICE_UNIT' + '|:|' +  CONVERT(nvarchar,PM.PRICE_UNIT) + '|+|' 
				+ 'PROD_PART_PRICE_UNIT' + '|:|' +  CONVERT(nvarchar,PM.PART_CASE_PRICE_UNIT) + '|+|' 
				+ '}'
			FROM PROD_SET_GROUP_REF_MST  PSGRM
			LEFT JOIN PROD_MST PM ON PSGRM.PROD_SEQ = PM.PROD_SEQ
			LEFT JOIN COMMON_CODE TYPE_CC ON PM.PROD_TYPE_CODE = TYPE_CC.CMMN_CODE
			LEFT JOIN COMMON_CODE REF_TYPE_CC ON REF_TYPE_CC.CMMN_CODE = PSGRM.REF_TYPE_CODE
			WHERE PSGRM.PROD_SET_GROUP_SEQ = PSGM.PROD_SET_GROUP_SEQ
			ORDER BY PSGRM.REF_SEQ ASC
			FOR XML PATH('')
		), 1, 1, ''
	) AS PROD_INFO_LIST
    FROM PROD_SET_GROUP_MST PSGM
    LEFT JOIN COMMON_CODE GROUP_TYPE_CC ON GROUP_TYPE_CC.CMMN_CODE = PSGM.SET_GROUP_TYPE_CODE
    WHERE PSGM.PROD_SET_GROUP_SEQ = @p_prod_set_group_seq;
END

GO
