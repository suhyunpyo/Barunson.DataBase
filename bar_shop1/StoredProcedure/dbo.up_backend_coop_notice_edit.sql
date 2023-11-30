IF OBJECT_ID (N'dbo.up_backend_coop_notice_edit', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_notice_edit
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   :   [2003:07:30    12:17]  JJH: 
	관련페이지 : shopadm/custom/A_Info/admin_notice.asp
	내용	   :  공지사항 등록/편집
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_notice_edit]
	@KIND		varchar(20)
,	@IID		INT
,	@ADMIN_NM	varchar(100)
,	@TEL_NO	varchar(100)
,	@E_MAIL		varchar(100)
,	@TITLE		varchar(100)
,	@CONTENT	varchar(4000)
,	@ADMIN_ID	varchar(20)
as
IF @KIND = 'ADD'
	BEGIN
		INSERT INTO dbo.ADMIN_NOTICE (
					ADMIN_NM
					,TEL_NO
					,E_MAIL
					,TITLE
					,CONTENT
					,REG_ID)	
			VALUES(		
					@ADMIN_NM
					,@TEL_NO
					,@E_MAIL
					,@TITLE
					,@CONTENT
					,@ADMIN_ID)	
	END
IF @KIND = 'UPDATE'
	BEGIN
		UPDATE dbo.ADMIN_NOTICE SET TITLE  	=  @TITLE
					,CONTENT	=  @CONTENT
					,ADMIN_NM	= @ADMIN_NM
					,TEL_NO		= @TEL_NO
					,E_MAIL		= @E_MAIL
				WHERE IID = @IID
	END
IF @KIND = 'DEL'
	BEGIN
		DELETE dbo.ADMIN_NOTICE  WHERE  IID = @IID
	END

GO
