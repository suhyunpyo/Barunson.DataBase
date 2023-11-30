IF OBJECT_ID (N'dbo.up_select_userinfo_for_restock_alimi', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_userinfo_for_restock_alimi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-11-27
-- Description:	재 입고 알리미 개인정보
-- TEST : up_select_userinfo_for_restock_alimi 34671, 'danielkim'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_userinfo_for_restock_alimi]
		
	@uid		 varchar(16),
	@company_seq int,
	@card_seq	 int
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;


	IF EXISTS (
				SELECT *
				FROM S4_Stock_Alarm 
				WHERE 1 = 1
				  AND uid = @uid
				  AND company_seq = @company_seq
				  AND card_seq = @card_seq
				  AND isAlarm_send = 'N'	-- SMS가 발송되지 않은 상태
			  )
		BEGIN
			-- 이미 재입고 알림 신청을 한 상태	
			SELECT   'Y' AS result
					,'' AS hand_phone1
					,'' AS hand_phone2
					,'' AS hand_phone3
					
		END
	
	ELSE
		
		BEGIN
			-- 해당 상품에 대해 재입고 알림 신청을 하지 않은 상태이므로 휴대폰 정보를 가져 온다	
			SELECT   'N' AS result 
					,hand_phone1
					,hand_phone2
					,hand_phone3 
			FROM S2_UserInfo_TheCard 
			WHERE uid = @uid
		
		END

END
GO
