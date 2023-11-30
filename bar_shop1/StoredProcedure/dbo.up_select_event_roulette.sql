IF OBJECT_ID (N'dbo.up_select_event_roulette', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_roulette
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015.01.30
-- Description: 룰렛이벤트  조회
-- exec up_select_event_roulette 5007, 1, 201503071230
-- =============================================
CREATE PROCEDURE [dbo].[up_select_event_roulette]
	@company_seq		int,
	@rot_idx			int,
	@uid				varchar(20)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	
	DECLARE	@idx	INT
	DECLARE	@rot_title	NVARCHAR(50)
	DECLARE	@rot_sDate	DATETIME
	DECLARE	@rot_Edate	DATETIME
	DECLARE	@rot_limit_price INT
	DECLARE	@order_seq INT
	DECLARE	@order_cnt INT	
	DECLARE	@use_cnt INT	
	
	SET @order_seq = null
	SET @order_cnt = 0
	SET @use_cnt = 0
	
	SELECT @idx = rot_idx, @rot_title = rot_title, @rot_sDate = rot_sDate, @rot_Edate = rot_Edate, @rot_limit_price = rot_limit_price FROM Roulette_Main 
	WHERE rot_company_seq=@company_seq AND rot_idx=@rot_idx AND rot_status=0 
	
	IF LEN(@idx) > 0 
	BEGIN
		IF LEN(@uid) > 0 
		BEGIN  
			SELECT @order_cnt = COUNT(order_seq), @order_seq = MAX(order_seq)
			FROM custom_order 
			WHERE 
				member_id=@uid AND company_seq=@company_seq AND up_order_seq IS NULL AND status_seq >= 10 
				AND order_date BETWEEN @rot_sDate AND @rot_Edate
				AND order_price >= @rot_limit_price
				AND order_seq NOT IN (SELECT rotm_order_seq FROM Roulette_Member WHERE rotm_rot_idx = @rot_idx AND rotm_UID=@uid)

			SET @use_cnt = (SELECT COUNT(rotm_Idx) FROM Roulette_Member WHERE rotm_rot_idx = @rot_idx AND rotm_UID=@uid)
		END
						
	END 

	SELECT rot_title, rot_sDate, rot_Edate, @order_seq AS order_seq, @order_cnt AS order_cnt, @use_cnt AS use_cnt FROM Roulette_Main 
	WHERE rot_company_seq=@company_seq AND rot_idx=@rot_idx AND rot_status=0 	
END
GO
