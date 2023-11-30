IF OBJECT_ID (N'dbo.up_insert_today_view', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_today_view
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-10
-- Description:	오늘 본 상품 저장
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_today_view]
		
	@uid VARCHAR(16), 
	@view_date VARCHAR(10), 
	@card_seq INT
			
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	
	IF NOT EXISTS 
	(
		SELECT *
		FROM S5_TodayViewItems
		WHERE uid = @uid
		  AND view_date = @view_date
		  AND card_seq = @card_seq 	
	)
		BEGIN
			
			INSERT INTO S5_TodayViewItems 
			( uid, view_date, card_seq ) 
			VALUES 
			( @uid, @view_date, @card_seq )
			
		END
			
	
END
GO
