IF OBJECT_ID (N'dbo.sp_sendtNeoMail_wedd', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_sendtNeoMail_wedd
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_sendtNeoMail_wedd]
@sname varchar(50),
@smail varchar(100),		-- 보내는 사람 메일 주소
@rname varchar(50),
@rmail varchar(100),		-- 받는 사람 메일주소
@email_title varchar(100),		-- 메일 제목
@email_contents text

as
    -- 2022-07-29 김광호, 아래 테이블 사용하지 않음. 주석 처리
	--INSERT INTO tNeo_Queue (barid,sname,smail,rname,rmail,mtitle,mcontent,mdate,c_site,c_category,cardno,org_date) 
	--   VALUES ('[stepMail]', @sname,@smail,@rname,@rmail,@email_title,@email_contents, getdate(), 'M', 'A','wedd', getdate())
	

GO
