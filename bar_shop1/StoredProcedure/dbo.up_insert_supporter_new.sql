IF OBJECT_ID (N'dbo.up_insert_supporter_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_supporter_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2015.04.27
-- Description:	서포터즈 추가
-- exec : exec up_insert_supporter 5007, 'http://www.naver.com', 'palaoh', 0
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_supporter_new]
	-- Add the parameters for the stored procedure here
	@company_seq			AS		INT,
	@support_URL			AS		NVARCHAR(250),
	@UID					AS		NVARCHAR(20),
	@sp_title				AS		varchar(150),
	@sp_contents			AS		varchar(4000),
	@sp_SeasonNo			AS		INT,
	@result					AS		INT=0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			
			declare @ucount	int;
			declare @id	int;

			--select @ucount = count(SP_Idx) from S5_Supporters_User where SP_Company_seq=@company_seq and SP_UserID=@UID

			--if @ucount = 0
			--	begin 
					insert into S5_Supporters_User (SP_Company_seq, SP_UserID, SP_URL, SP_Title, SP_Contents, SP_SeasonNo) values (@company_seq, @UID, @support_URL, @sp_title, @sp_contents, @sp_SeasonNo)
				--end
			
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
