IF OBJECT_ID (N'dbo.pro_insert', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_insert
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[pro_insert]
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
as 
insert into dbo.board
values(@sid,@grp,@seq,@lev,@subject,@content,@name,@pass,@visit,@stime,@tag)

GO
