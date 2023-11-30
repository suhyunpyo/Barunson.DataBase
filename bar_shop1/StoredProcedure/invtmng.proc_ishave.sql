IF OBJECT_ID (N'invtmng.proc_ishave', N'P') IS NOT NULL DROP PROCEDURE invtmng.proc_ishave
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROC [invtmng].[proc_ishave]
@card_seq int,
@ishave_change int,
@desc varchar(200),
@admin_id varchar(15)
AS

update card set ishave_num = ishave_num+@ishave_change where card_seq=@card_seq and ishave='0'
insert into card_ishave_history(card_seq,ishave_change,admin_id,description) values(@card_seq,@ishave_change,@admin_id,@desc)

GO
