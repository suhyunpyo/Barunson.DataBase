IF OBJECT_ID (N'invtmng.sp_photobook_ccnt', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_photobook_ccnt
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
	작성정보   : [2009.6,22 김수경]
	관련페이지 : 포토북 prod_list.asp
	내용	   :이용후기 갯수 가져오기.
	
	수정정보   : 
*/
Create  Procedure [invtmng].[sp_photobook_ccnt]
	@prod_code		varchar(20)
	,@site_code		varchar(1)
as
	select count(*) from photobook_comment where prod_code=@prod_code and site_code=@site_code

GO
