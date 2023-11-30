IF OBJECT_ID (N'dbo.up_front_Xbbsarticle_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_Xbbsarticle_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:22    12:35]  JJH: 
	관련페이지 : wedd_main.asp
	내용	   : 바른손소식 리스트
	
	수정정보   : 
*/
Create Procedure  [dbo].[up_front_Xbbsarticle_list]
as
SELECT TOP 4 BA.* FROM dbo.xbbs_article BA WHERE BA.XI_SEQ=1 ORDER BY BA.XA_SEQ DESC

GO
