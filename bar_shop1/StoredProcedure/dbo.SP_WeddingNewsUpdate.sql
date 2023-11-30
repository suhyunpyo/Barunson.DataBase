IF OBJECT_ID (N'dbo.SP_WeddingNewsUpdate', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_WeddingNewsUpdate
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		임승인
-- Create date: 2023-03-06
-- Description:	웨딩뉴스 수정
-- =============================================

CREATE PROCEDURE [dbo].[SP_WeddingNewsUpdate]
	@WeddingNewsIdx int,
	@TemplateIdx int,
	@Status nchar(1),
	@Title nvarchar(150),
	@GroomAge int,
	@BrideAge int,
	@FatherJob nvarchar(20),
	@Company nvarchar(50),
	@Position nvarchar(30),
	@ImgMode tinyint,
	@StudioName nvarchar(50),
	@ImgName nvarchar(100),
	@UpImgName nvarchar(100),
	@Mode nvarchar(2),
	@Content nvarchar(max),
	@RadioYnText nvarchar(20)
AS
BEGIN


	SET NOCOUNT ON;

	UPDATE  WeddingNews
	SET 
          TemplateIdx=@TemplateIdx,
		Status = 'U',		
		GroomAge = @GroomAge,
		BrideAge = @BrideAge,
		FatherJob = @FatherJob,
		Company = @Company,
		Position = @Position,
		ImgMode = @ImgMode,
		StudioName = @StudioName,
		ImgName = @ImgName,
		UpImgName = @UpImgName,
		Mode = @Mode,
		ModDate = GETDATE(),
		Title = @Title,
		Content = @Content,
		RadioYnText = @RadioYnText	
	WHERE
		WeddingNewsIdx = @WeddingNewsIdx	
END

GO
