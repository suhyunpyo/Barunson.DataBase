IF OBJECT_ID (N'dbo.up_select_usereid_check', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_usereid_check
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-04
-- Description:	회원가입시  ID체크
-- =============================================
CREATE PROCEDURE [dbo].[up_select_usereid_check]
	-- Add the parameters for the stored procedure here
	@uid	AS nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select uid from S2_UserInfo with(nolock) where uid=@uid 
	union 
	select uid from S2_UserInfo_Thecard with(nolock)  where uid=@uid 
	union 
	select uid from S2_UserInfo_BHands with(nolock)  where uid=@uid 
	union 
	select uid from Tiara_Member with(nolock)  where uid=@uid 
	union 
	select uid from THE_MEMBER_OUT with(nolock)  where uid=@uid 
	
END
GO
