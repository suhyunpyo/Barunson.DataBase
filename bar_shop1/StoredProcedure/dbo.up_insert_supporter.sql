IF OBJECT_ID (N'dbo.up_insert_supporter', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_supporter
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2015.04.15
-- Description:	서포터즈 추가
-- exec : exec up_insert_supporter 5007, 'http://www.naver.com', 'palaoh', 0
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_supporter]
	-- Add the parameters for the stored procedure here
	@company_seq		AS		INT,
	@support_URL			AS		NVARCHAR(250),
	@UID					AS		NVARCHAR(20),
	@result					AS		INT=0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			
			declare @ucount	int;
			declare @id	int;

			select @ucount = count(SP_Idx) from S5_Supporters_User where SP_Company_seq=@company_seq and SP_UserID=@UID

			if @ucount = 0
				begin 
					insert into S5_Supporters_User (SP_Company_seq, SP_UserID, SP_URL) values (@company_seq, @UID, @support_URL)
				end
			
			set @id = SCOPE_IDENTITY()

			set @result = '0'
			set @result = @@Error
			IF (@result <> 0) GOTO PROBLEM
			COMMIT TRAN


			PROBLEM:
			IF (@result <> 0) BEGIN
				ROLLBACK TRAN
			END
			
			return @result
END
GO
