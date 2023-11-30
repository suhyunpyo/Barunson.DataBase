IF OBJECT_ID (N'dbo.proc_InsS2ECard', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_InsS2ECard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     Procedure [dbo].[proc_InsS2ECard]
@company_seq	int,
@addr	varchar(50),
@worder_seq	int,
@order_name	varchar(50),
@order_email	varchar(50),
@groom_name	varchar(30),
@bride_name	varchar(30),
@event_year	varchar(4),
@event_month	varchar(2),
@event_day	varchar(2),
@event_weekname	varchar(10),
@event_ampm	varchar(5),
@event_hour	varchar(12),
@event_minute	varchar(2),
@wedd_name	varchar(100),
@wedding_seq	int,
@uid varchar(50),
@order_seq int output
as
begin

	insert into S2_eCardOrder(company_seq,addr,uid,order_name,order_email,groomName,brideName,event_year,event_month,event_day,event_weekname,event_ampm,event_hour,event_minute,weddinghall,wedding_seq,worder_seq) 
	values(@company_seq,@addr,@uid,@order_name,@order_email,@groom_name,@bride_name,@event_year,@event_month,@event_day,@event_weekname,@event_ampm,@event_hour,@event_minute,@wedd_name,@wedding_seq,@worder_seq)
	set @order_seq = @@identity
END

GO
