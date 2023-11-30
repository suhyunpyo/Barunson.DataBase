IF OBJECT_ID (N'dbo.up_insert_userinfo_for_restock_alimi', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_userinfo_for_restock_alimi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-11-27
-- Description:	재 입고 알리미 신청
-- TEST : 
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_userinfo_for_restock_alimi]
	
	@company_seq	AS int,
	@card_seq		AS int,
	@uid			AS varchar(16),
	@uname			AS varchar(50),
	@umail			AS varchar(100),
	@hand_phone1	AS varchar(3),
	@hand_phone2	AS varchar(4),
	@hand_phone3	AS varchar(4)
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	/*
	DECLARE @company_seq	AS int=5007
	DECLARE @card_seq		AS int=34671
	DECLARE @uid			AS varchar(16)='danielkim'
	DECLARE @uname			AS varchar(50)='김더준'
	DECLARE @umail			AS varchar(100)='danielkim@naver.com'
	DECLARE @hand_phone1	AS varchar(3)='010'
	DECLARE @hand_phone2	AS varchar(4)='1234'
	DECLARE @hand_phone3	AS varchar(4)='5678'
	*/
	
	DECLARE @cnt int

	SELECT @cnt = COUNT(*)
	FROM S4_Stock_Alarm
	WHERE company_seq = @company_seq
	  AND card_seq = @card_seq 
	  AND isAlarm_send = 'N'
	  AND hand_phone1 = @hand_phone1
	  AND hand_phone2 = @hand_phone2
	  AND hand_phone3 = @hand_phone3
	
	
	SELECT @cnt
	
	
	IF @cnt = 0 BEGIN
		INSERT S4_Stock_Alarm 
		(
			company_seq, card_seq, uid, uname, umail, hand_phone1, hand_phone2, hand_phone3, reg_date
		) 
		VALUES 
		(
			@company_seq, @card_seq, @uid, @uname, @umail, @hand_phone1, @hand_phone2, @hand_phone3, GETDATE()
		)
	END
	
	
	--SELECT @cnt

END



  --select * from S4_Stock_Alarm order by reg_date desc
GO
