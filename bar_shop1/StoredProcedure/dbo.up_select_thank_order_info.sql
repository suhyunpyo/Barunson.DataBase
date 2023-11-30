IF OBJECT_ID (N'dbo.up_select_thank_order_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thank_order_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-08
-- Description:	답례장 주문 정보 
-- TEST : up_select_thank_order_info 34800, 5007, 'palaoh'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_thank_order_info]
	
	@order_seq		int,
	@company_seq	int,
	@uid			varchar(16)

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	-- rs1 --
	SELECT   order_Seq		--0					
			,card_seq 		--1		
			,order_name 	--2			
			,order_type		--3
			,order_phone	--4
			,order_hphone	--5
			,order_email	--6
			,order_count	--7
			,isContAdd		--8
			,isEnvAdd		--9	
			,order_count	--10	
			,env_price		--11
			,printW_status	--12
			,isinpaper		--13
			,ishandmade		--14
			,isenvInsert	--15	
			,isLiningJaebon	--16
			,isembo			--17
			,print_color	--18	
			,iscorel		--19
			,envInsert_price	--20
			,jebon_price	--21
			,embo_price		--22
			,order_total_price	--23
	FROM Custom_Order 
	WHERE order_seq = @order_seq 
	  AND company_seq = @company_seq
	  AND status_seq = 0
	  AND member_id = @uid
	
	
	-- rs2 --
	SELECT   ftype
			,fetype
			,event_year
			,event_month
			,event_day
			,etc_comment
			,etc_file	
			,greeting_content
			,groom_name
			,bride_name
			,groom_tail
	FROM Custom_Order_WeddInfo
	WHERE order_seq = @order_seq
				
	  
END
GO
