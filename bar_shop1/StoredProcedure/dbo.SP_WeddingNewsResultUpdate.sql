IF OBJECT_ID (N'dbo.SP_WeddingNewsResultUpdate', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_WeddingNewsResultUpdate
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		임승인
-- Create date: 2023-03-04
-- Description:	웨딩뉴스 결과저장
-- =============================================

CREATE PROCEDURE [dbo].[SP_WeddingNewsResultUpdate]
	@WeddingNewsIdx int,
	@Title nvarchar(150),
	@Url nchar(300),
	@RejectCommentType nchar(1),
	@RejectComment nvarchar(300),	
	@Content nvarchar(MAX),
	@Status nchar(10),
	@RESULT			INT=0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @COUNT INT
	DECLARE @REJECT_COUNT INT
	DECLARE @ISNEWS INT

	SELECT @ISNEWS = ISNULL(COUNT(*),0) FROM WeddingNews WHERE WeddingNewsIdx = @WeddingNewsIdx
	
	SELECT @COUNT = ISNULL(COUNT(*),0) FROM WeddingNewsResult WHERE WeddingNewsIdx = @WeddingNewsIdx

	SELECT @REJECT_COUNT = ISNULL(COUNT(*),0)+1 FROM WeddingNewsResultLog WHERE WeddingNewsIdx = @WeddingNewsIdx AND STATUS='N'

	IF @ISNEWS = 0
	BEGIN
		RETURN @RESULT
	END

	BEGIN TRY		
		BEGIN TRAN		

		IF @COUNT > 0 
			BEGIN
			 IF @Status = 'N'
			 BEGIN
				UPDATE [WeddingNewsResult]
				   SET 
					  [Title] = @Title
					  ,[Url] = @Url
					  ,[RejectCommentType] = @RejectCommentType
					  ,[RejectComment] = @RejectComment
					  ,[RejectCount] = @REJECT_COUNT
					  ,[ModDate] = GETDATE()
					  ,[Content] = @Content
				 WHERE WeddingNewsIdx = @WeddingNewsIdx
			END
			ELSE
			BEGIN
				UPDATE [WeddingNewsResult]
				   SET 
					  [Title] = @Title
					  ,[Url] = @Url			 
					  ,[ModDate] = GETDATE()
					  ,[Content] = @Content
				 WHERE WeddingNewsIdx = @WeddingNewsIdx		 
			END
			END

		ELSE

		BEGIN

			INSERT INTO [WeddingNewsResult]
				   ([WeddingNewsIdx]
				   ,[Title]
				   ,[Url]
				   ,[RejectCommentType]
				   ,[RejectComment]
				   ,[RejectCount]
				   ,[ModDate]
				   ,[Content])
			VALUES
				   (@WeddingNewsIdx,
					@Title,
					@Url,
					@RejectCommentType,
					@RejectComment,
					@REJECT_COUNT,
					GETDATE(),
					@Content
					)	
		END

		UPDATE [WeddingNews] SET Status=@Status,ModDate=GETDATE() WHERE WeddingNewsIdx=@WeddingNewsIdx

		INSERT INTO [WeddingNewsResultLog]
           ([WeddingNewsIdx]
           ,[RegDate]
           ,[Status]
           ,[Title]
           ,[Url]
           ,[RejectCommentType]
           ,[RejectComment]
           ,[Content])
		VALUES
           (@WeddingNewsIdx,
		   GETDATE(),
		    @Status,
			@Title,
			@Url,
			@RejectCommentType,
			@RejectComment,		
			@Content
			)	

		
		--알림톡발송
		IF @Status = 'N'
		BEGIN
			EXEC [SP_WeddingNewsBiztalk] @WeddingNewsIdx, 'BH0157'
		END
		ELSE
		BEGIN
			EXEC [SP_WeddingNewsBiztalk] @WeddingNewsIdx, 'BH0156'
		END
	
		SET @RESULT = 1 

		COMMIT TRAN
	
	END TRY

	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		BEGIN
				ROLLBACK TRAN

				SET @RESULT = 0
		END
	END CATCH

	RETURN @RESULT 

END
GO
