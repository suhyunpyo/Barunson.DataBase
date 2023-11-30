IF OBJECT_ID (N'dbo.up_update_today_view', N'P') IS NOT NULL DROP PROCEDURE dbo.up_update_today_view
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-11
-- Description:	오늘 본 상품 기록 Data의 로그인 시 동기화
-- =============================================
CREATE PROCEDURE [dbo].[up_update_today_view]
		
	@uid VARCHAR(50),
	@sid VARCHAR(50), 
	@view_date VARCHAR(10)	
			
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	--update S5_TodayViewItems set view_date = '2014-12-10'
	--where view_date = '2014-12-11' and uid = '118584630'
	
	/*
	DECLARE @uid VARCHAR(16)='palaoh'
	DECLARE @sid VARCHAR(16)='118584630'
	DECLARE @view_date VARCHAR(10)='2014-12-10'
	*/
	
	/*
	SELECT *
	FROM S5_TodayViewItems
	*/
	
	UPDATE S5_TodayViewItems SET uid = @uid	
	WHERE 1 = 1
	  AND uid = @sid
	  AND view_date = @view_date	  
	  AND card_seq NOT IN (
							SELECT card_seq
							FROM S5_TodayViewItems
							WHERE uid = @uid
							  AND view_date = @view_date
						  )			
	
END
GO
