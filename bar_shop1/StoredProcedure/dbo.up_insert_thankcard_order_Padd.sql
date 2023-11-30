IF OBJECT_ID (N'dbo.up_insert_thankcard_order_Padd', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_thankcard_order_Padd
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-22
-- Description:	답례장 주문 1단계 정보 저장/수정 
-- up_insert_thankcard_order_Padd

-- =============================================
CREATE PROCEDURE [dbo].[up_insert_thankcard_order_Padd]
	
	@order_seq			int,				-- 이벤트 목록 종류 (진행 중, 지난)		
	@greeting_content	text,				-- 페이지 번호
	@groom_name			varchar(50),
	@bride_name			varchar(50),
	@groom_tail			varchar(30),
	@event_year			varchar(4),
	@event_month		varchar(2),
	@event_day			varchar(2)
	
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	DECLARE @pid int
	
	SELECT @pid = id
	FROM Custom_Order_Plist 
	WHERE order_seq = @order_seq
	  AND print_type = 'C'
	  --AND title LIKE '카드추가인쇄'
	  AND isBasic = 0
	
	BEGIN TRAN
	
		DELETE FROM Custom_Order_PlistAddG WHERE pid = @pid
		DELETE FROM Custom_Order_PlistAddN WHERE pid = @pid
		DELETE FROM Custom_Order_PlistAddD WHERE pid = @pid
		
		INSERT INTO Custom_Order_PlistAddG ( pid, greeting_content ) VALUES ( @pid, @greeting_content )

		INSERT INTO Custom_Order_PlistAddN ( pid, groom_name, bride_name, groom_tail ) VALUES ( @pid, @groom_name, @bride_name, @groom_tail )

		INSERT INTO Custom_Order_PlistAddD ( pid, event_year, event_month, event_day ) VALUES ( @pid, @event_year, @event_month, @event_day )
	
	--SET @result_cnt = @@ROWCOUNT	-- 변경된 rowcount
	--SET @result_code = @@Error	-- 에러발생 cnt
	
	IF (@@Error <> 0) GOTO PROBLEM
	COMMIT TRAN

	PROBLEM:
	IF (@@Error <> 0) BEGIN
		ROLLBACK TRAN
	END
	
	
END
GO
