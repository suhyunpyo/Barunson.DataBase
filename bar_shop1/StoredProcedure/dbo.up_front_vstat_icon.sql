IF OBJECT_ID (N'dbo.up_front_vstat_icon', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_vstat_icon
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
 작성정보   :   [2006.8.18 김수경
 내용    :       바탕화면 바로가기 접속 카운트
   
 수정정보   :   
*/  
CREATE Procedure [dbo].[up_front_vstat_icon]
	@ip		varchar(20)
as

	insert into VSTAT_ICON(usrIP) values(@ip)
GO
