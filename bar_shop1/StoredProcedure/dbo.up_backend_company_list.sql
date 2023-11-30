IF OBJECT_ID (N'dbo.up_backend_company_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_company_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:26    14:10]  JJH: 
	관련페이지 : shopadm/custom/SQM/cust_qa_mng.asp
	내용	   : 제휴사 목록
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_company_list]
	@STAT 		varchar(20) ='S2'
,	@JAEHU_KIND	varchar(2)   ='W'
as
	SELECT *
	FROM dbo.COMPANY WHERE ONOFF='Y'	AND  STATUS = @STAT 
						AND JAEHU_KIND = @JAEHU_KIND

GO
