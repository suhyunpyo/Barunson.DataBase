IF OBJECT_ID (N'dbo.up_front_comment_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_comment_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	작성정보   : [2003:07:22    12:35]  JJH: 
	관련페이지 : wedd_main.asp
	내용	   : afternote 리스트
	
	수정정보   : 
*/
CREATE Procedure  [dbo].[up_front_comment_list]
as
	SELECT TOP 4 CUC.* 
			, CA.CARD_TITLE 
			, CA.CARD_NAME
			, CONVERT(varchar(10),CUC.REGDATE,120) as REG_DT
								 FROM Ewedd_After_Note CUC , ewed_CARD_INFO CA 
							WHERE 	CUC.DIV='1' 
							AND	CUC.CARD_SEQ = CA.CARD_SEQ	
						ORDER BY CUC.CMT_SEQ DESC
GO
