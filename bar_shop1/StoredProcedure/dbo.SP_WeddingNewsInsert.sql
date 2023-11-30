IF OBJECT_ID (N'dbo.SP_WeddingNewsInsert', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_WeddingNewsInsert
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		임승인
-- Create date: 2023-02-20
-- Description:	웨딩뉴스 저장
-- =============================================

CREATE PROCEDURE [dbo].[SP_WeddingNewsInsert]
	@TemplateIdx int,
	@OrderSeq int,
	@Status nchar(1),
	@UserId varchar(50),
	@UserName nvarchar(50),	
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

	INSERT INTO [dbo].[WeddingNews]
	 ([TemplateIdx]
           ,[OrderSeq]
           ,[Status]
           ,[UserId]
           ,[UserName]
           ,[Title]
           ,[GroomAge]
           ,[BrideAge]
           ,[FatherJob]
           ,[Company]
           ,[Position]
           ,[ImgMode]
           ,[StudioName]
           ,[ImgName]
           ,[UpImgName]
           ,[Mode]
           ,[RegDate]
           ,[ModDate]
           ,[Content]
           ,[RadioYnText])
	VALUES
           (@TemplateIdx,
			@OrderSeq,
			@Status,
			@UserId,
			@UserName,
			@Title,
			@GroomAge,
			@BrideAge,
			@FatherJob,
			@Company,
			@Position,
			@ImgMode,
			@StudioName,
			@ImgName,
			@UpImgName,
			@Mode,
			GETDATE(),
			'',
			@Content,
			@RadioYnText
			)	
	
END
GO
