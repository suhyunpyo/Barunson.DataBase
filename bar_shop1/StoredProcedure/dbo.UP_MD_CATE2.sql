IF OBJECT_ID (N'dbo.UP_MD_CATE2', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_MD_CATE2
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
CREATE PROCEDURE [dbo].[UP_MD_CATE2]
	-- Add the parameters for the stored procedure here
	@company_seq	int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
		begin
			select CM_Idx, CM_SiteID, CM_Code1, CM_Code2, CM_Code3, CM_Code_Merge, CM_Name, CM_Status, CM_Regdate
		    , (select count(cm_idx)-1 from Category_Manage AS B where B.CM_Code_merge like '%'+A.CM_Code_Merge+'%'), LEN(cm_code_merge), CM_banner from Category_Manage AS A
			where cm_siteid = '5007' and CM_Status=1 order by CM_Code1, CM_Code2, CM_Code3 
		end
END

GO
