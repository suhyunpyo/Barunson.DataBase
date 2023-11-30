IF OBJECT_ID (N'dbo.up_Select_S4_Poll_User_Reply_Status_By_Id', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_S4_Poll_User_Reply_Status_By_Id
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-08-25
-- Description:	프론트, 가을 신상품투표참여 확인 후, 쿠폰문자 보내기

-- EXEC up_Select_S4_Poll_User_Reply_Status_By_Id 'bhandstest'
-- =============================================
/*

SELECT	*
FROM	S4_POLL_USER_REPLY

*/
CREATE PROC [dbo].[up_Select_S4_Poll_User_Reply_Status_By_Id]

	@UID			VARCHAR(100)
,	@POLL_1			INT = 14
,	@POLL_2			INT = 15
,	@POLL_3			INT = 16
,	@POLL_4			INT = 17
	
AS

SET NOCOUNT ON;

SELECT 
		CASE 
				WHEN EXISTS (SELECT TOP 1 SEQ FROM S4_POLL_USER_REPLY WHERE POLL_SEQ = @POLL_1 AND UID = @UID) THEN 'Y' 
				ELSE 'N'
		END		POLL1JOIN
	
	,	CASE 
				WHEN EXISTS (SELECT TOP 1 SEQ FROM S4_POLL_USER_REPLY WHERE POLL_SEQ = @POLL_2 AND UID = @UID) THEN 'Y' 
				ELSE 'N' 
		END		POLL2JOIN
	
	,	CASE	WHEN EXISTS (SELECT TOP 1 SEQ FROM S4_POLL_USER_REPLY WHERE POLL_SEQ = @POLL_3 AND UID = @UID) THEN 'Y' 
				ELSE 'N' 
		END		POLL3JOIN

	,	CASE	WHEN EXISTS (SELECT TOP 1 SEQ FROM S4_POLL_USER_REPLY WHERE POLL_SEQ = @POLL_4 AND UID = @UID) THEN 'Y' 
				ELSE 'N' 
		END		POLL4JOIN

--select @rtnResult as result, @rtnMsg as msg














GO
