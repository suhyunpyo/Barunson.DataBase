IF OBJECT_ID (N'dbo.Up_Insert_SurveyResponse', N'P') IS NOT NULL DROP PROCEDURE dbo.Up_Insert_SurveyResponse
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		박동혁
-- Create date: 2015.08.25
-- Description: 설문 결과 입력
-- =============================================
CREATE PROCEDURE [dbo].[Up_Insert_SurveyResponse]
	@SurveyNo				INT,
	@QuestionNo				INT,
	@ReplyAnswerNo			INT,
	@MemberID				VARCHAR(50),
	@Comment				VARCHAR(4000)
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO SurveyResponse
	(
		SurveyNo
		, QuestionNo
		, ReplyAnswerNo
		, MemberID
		, Comment
		, RegDT
	)
	VALUES
	(
		@SurveyNo
		, @QuestionNo
		, @ReplyAnswerNo
		, @MemberID
		, @Comment
		, GETDATE()
	)
		
			
END
GO
