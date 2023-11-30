IF OBJECT_ID (N'dbo.up_select_event_s5', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_s5
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2015.03.06
-- Description: 카드뒤집기이벤트  조회
-- exec up_select_event_s5 5006, 1, ''
-- =============================================
CREATE PROCEDURE [dbo].[up_select_event_s5]
	@company_seq		int,
	@event_idx			int,
	@uid				varchar(20)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	
	DECLARE	@idx	INT
	DECLARE	@rot_title	NVARCHAR(50)
	DECLARE	@sDate	DATETIME
	DECLARE	@eDate	DATETIME
	DECLARE	@limit_price INT
	DECLARE	@order_seq INT
	DECLARE	@order_cnt INT	
	DECLARE	@use_cnt INT	
	
	SET @order_seq = null
	SET @order_cnt = 0
	SET @use_cnt = 0
	SET @sDate = '2015-03-01'
	set @eDate = '2015-04-09'
	set @limit_price = 120000
	
	SELECT @order_cnt = COUNT(order_seq)
	FROM custom_order 
	WHERE 
		member_id=@uid AND company_seq=@company_seq AND up_order_seq IS NULL AND settle_status=2
		AND order_date BETWEEN @sDate AND @eDate
		AND settle_price >= @limit_price
		AND member_id NOT IN (SELECT CEM_UID FROM S5_Event_Member WHERE CEM_UID=@uid)
		AND member_id <> ''

	SET @use_cnt = (SELECT COUNT(CEM_Idx) FROM S5_Event_Member WHERE CEM_UID=@uid)
	
	--SELECT rot_title, rot_sDate, rot_Edate, @order_seq AS order_seq, @order_cnt AS order_cnt, @use_cnt AS use_cnt FROM Roulette_Main 
	--WHERE rot_company_seq=@company_seq AND rot_idx=@rot_idx AND rot_status=0 	
	

	select @order_cnt as order_cnt, @use_cnt as use_cnt 
END

GO
