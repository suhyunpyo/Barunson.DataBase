IF OBJECT_ID (N'dbo.pro_replyok2', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_replyok2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_replyok2]
@sid int,
@grp int,
@seq int,
@lev int,
@subject varchar(80),
@content text,
@name varchar(80),
@pass varchar(10),
@visit int,
@stime char(10),
@tag char(1)
AS
set nocount on
UPDATE dbo.board SET seq=seq +1  --순서를 1 뒤로 물린다
      WHERE grp =@grp --같은 그룹내에서
      AND seq >=@seq --나보다 크거나 같은 순서를 가진 레코드 중에서
insert into board
values(@sid,@grp,@seq,@lev,@subject,@content,@name,@pass,@visit,@stime,@tag) 
set nocount off

GO
