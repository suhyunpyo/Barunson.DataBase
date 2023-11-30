IF OBJECT_ID (N'dbo.pcS4_EventManagerProc', N'P') IS NOT NULL DROP PROCEDURE dbo.pcS4_EventManagerProc
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		송해선
-- Create date: 2012.09.21	
-- Description:	이벤트매니저
-- =============================================
CREATE PROCEDURE [dbo].[pcS4_EventManagerProc]
	@Action varchar(10), @Seq int, @EventName varchar(100),@company_seq int, @EventUrl varchar(100), @StartDate datetime, @EndDate datetime
	, @EventKind tinyint, @ManagerComment varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	If @Action = 'writeproc'
	BEGIN
		INSERT INTO invtmng.S4_EventManager( EventName, EventUrl, company_seq, StartDate, EndDate, EventKind, ManagerComment )
		VALUES( @EventName, @EventUrl, @company_seq, @StartDate, @EndDate, @EventKind, @ManagerComment )
		Set @Seq = IDENT_CURRENT('S4_EventManager')	
	END
	
	IF @Action = 'editproc'
	BEGIN
		UPDATE invtmng.S4_EventManager
		SET
			EventName	= @EventName,
			EventUrl	= @EventUrl,
			StartDate	= @StartDate,
			EndDate		= @EndDate,
			EventKind	= @EventKind,
			ManagerComment	= @ManagerComment
		WHERE seq = @seq
	END
		
	IF @Action = 'deleteproc'
	BEGIN
		UPDATE invtmng.S4_EventManager Set isDeleted = 1 where Seq = @Seq
	END
	
	Select @Seq;
	
	SET NOCOUNT OFF
END
GO
