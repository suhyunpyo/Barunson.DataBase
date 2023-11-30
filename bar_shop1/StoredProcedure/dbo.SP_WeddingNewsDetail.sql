IF OBJECT_ID (N'dbo.SP_WeddingNewsDetail', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_WeddingNewsDetail
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		임승인
-- Create date: 2023-02-23
-- Description:	관리자 웨딩뉴스 상세
-- =============================================


CREATE PROCEDURE [dbo].[SP_WeddingNewsDetail]
	@WeddingNewsIdx varchar(10)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
		a.WeddingNewsIdx,TemplateIdx,UserId,UserName,Convert(Varchar(10),RegDate,121) RegDate,ImgMode,UpImgName,
		CASE Status WHEN 'W' THEN '작성중' WHEN 'U' THEN '수정 접수' WHEN 'Y' THEN '완료' WHEN 'N' THEN '반려'  WHEN 'I' THEN '기사전송' END Status,
		a.TITLE,a.Content,AdminMemo,isnull(RejectCount,0) RejectCount,RejectComment,Url as NewsUrl,
		CASE RejectCommentType WHEN '1' THEN '이미지불충분' WHEN '2' THEN '텍스트오류' WHEN '3' THEN '내용불충분' WHEN '4' THEN '기타' END as RejectCommentType
	FROM WeddingNews a LEFT JOIN WeddingNewsResult b ON a.WeddingNewsIdx=b.WeddingNewsIdx
	WHERE a.WeddingNewsIdx = @WeddingNewsIdx 
	
END
GO
