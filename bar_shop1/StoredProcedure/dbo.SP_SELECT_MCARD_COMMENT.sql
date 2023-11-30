IF OBJECT_ID (N'dbo.SP_SELECT_MCARD_COMMENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_MCARD_COMMENT
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

/*

EXEC [SP_SELECT_MCARD_COMMENT] 2076, '', '', 1, 10, 'N'

*/


CREATE PROCEDURE [dbo].[SP_SELECT_MCARD_COMMENT]
	
	@P_INVITATION_ID AS INT
,	@P_INVITATION_CODE AS VARCHAR(10)
,	@P_USER_ID AS VARCHAR(50)
,	@P_PAGE_NUMBER AS INT
,	@P_PAGE_SIZE AS INT
,	@P_ORDER_BY_ASCENDING_YORN AS VARCHAR(1)

AS
BEGIN

	SELECT	*
	FROM	(
				SELECT	ROW_NUMBER() OVER( ORDER BY MC.CommentID ASC ) AS ROW_NUM_ASC
					,	ROW_NUMBER() OVER( ORDER BY MC.CommentID DESC ) AS ROW_NUM_DESC
					,	MC.CommentID
					,	MC.InvitationID
					,	MC.InvitationCode
					,	MC.GuestName
					,	MC.Password
					,	MC.Commentary
					,	MC.RegisterTime
					,	MC.RegisterIP
				FROM	MCARD_COMMENT MC
				JOIN	MCARD_INVITATION MI ON MC.INVITATIONID = MI.INVITATIONID
				WHERE	1 = 1

				AND		CASE WHEN @P_INVITATION_ID > 0 THEN MC.INVITATIONID ELSE 0 END
						=
						CASE WHEN @P_INVITATION_ID > 0 THEN @P_INVITATION_ID ELSE 0 END

				AND		CASE WHEN @P_INVITATION_ID = 0 AND @P_INVITATION_CODE <> '' THEN MC.INVITATIONCODE ELSE '' END
						=
						CASE WHEN @P_INVITATION_ID = 0 AND @P_INVITATION_CODE <> '' THEN @P_INVITATION_CODE ELSE '' END

				AND		CASE WHEN @P_INVITATION_ID = 0 AND @P_INVITATION_CODE = '' AND @P_USER_ID <> '' THEN MI.AUTHCODE ELSE '' END
						=
						CASE WHEN @P_INVITATION_ID = 0 AND @P_INVITATION_CODE = '' AND @P_USER_ID <> '' THEN @P_USER_ID ELSE '' END		

				AND		CASE WHEN @P_INVITATION_ID > 0 OR @P_INVITATION_CODE <> '' OR @P_USER_ID <> '' THEN 1 ELSE 0 END = 1

			) A
	WHERE	1 = 1
	AND		CASE WHEN @P_ORDER_BY_ASCENDING_YORN = 'Y' THEN ROW_NUM_ASC ELSE ROW_NUM_DESC END > ((@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE)
	AND		CASE WHEN @P_ORDER_BY_ASCENDING_YORN = 'Y' THEN ROW_NUM_ASC ELSE ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE

	ORDER BY CASE WHEN @P_ORDER_BY_ASCENDING_YORN = 'Y' THEN ROW_NUM_ASC ELSE ROW_NUM_DESC END ASC

END
GO
