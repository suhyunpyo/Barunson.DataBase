IF OBJECT_ID (N'dbo.SP_S_USER_GUESTBOOK_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_USER_GUESTBOOK_LIST
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
CREATE PROCEDURE [dbo].[SP_S_USER_GUESTBOOK_LIST]
	@InvitationID int,
	@Type Varchar(20) = 'all',
	@GuestBookId int = 0,
	@Size integer = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @Type = 'all' BEGIN
		select 
			GuestBook_ID,
			Invitation_ID,
			Name,
			Message,
			Regist_DateTime
		from TB_GuestBook
		where Invitation_ID = @InvitationID
			and Display_YN = 'Y'
		order by GuestBook_ID desc
	END 

	else if @Type = 'next' BEGIN

		if @GuestBookId = 0 BEGIN
			select 
				@GuestBookId = MAX(GuestBook_ID) + 1
			from TB_GuestBook
		where Invitation_ID = @InvitationID
			and Display_YN = 'Y'
		END

		select 
			TOP (@Size)
			GuestBook_ID,
			Invitation_ID,
			Name,
			Message,
			Regist_DateTime
		from TB_GuestBook
		where Invitation_ID = @InvitationID
			and Display_YN = 'Y'
			and GuestBook_ID < @GuestBookId
		order by GuestBook_ID desc

	END


END
GO
