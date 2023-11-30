IF OBJECT_ID (N'dbo.up_Select_S4_Poll_User_Reply_Statics_For_NewCardBestEvent', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_S4_Poll_User_Reply_Statics_For_NewCardBestEvent
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-08-25
-- Description:	프론트, 설문 통계, s4_poll_user_reply

-- EXEC up_Insert_S4_Poll_User_Reply 14, 92, 'bhandstest'
-- =============================================
create proc [dbo].[up_Select_S4_Poll_User_Reply_Statics_For_NewCardBestEvent]

	@poll_seq			int
	, @top_cnt			int
	
as


set nocount on;

select top (@top_cnt) s2c.card_code, s2c.card_seq, s2c.card_name
from
(
select s4pur.poll_seq, s4pur.poll_item_seq, s4pi.item_title as card_code, count(*) as cnt
from s4_poll_user_reply s4pur
inner join s4_poll_item s4pi
on s4pur.poll_item_seq = s4pi.seq
where s4pur.poll_seq = @poll_seq
group by s4pur.poll_seq, s4pur.poll_item_seq, s4pi.item_title
) as T
inner join s2_card s2c
on s2c.card_code = T.card_code
order by T.cnt desc

















GO
