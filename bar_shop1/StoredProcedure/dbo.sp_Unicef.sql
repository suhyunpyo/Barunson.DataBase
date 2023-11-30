IF OBJECT_ID (N'dbo.sp_Unicef', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_Unicef
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec sp_Unicef '20100515','20100915'

CREATE  PROC [dbo].[sp_Unicef]
	@sDate  char(8),
	@eDAte  char(8)
AS
	SELECT A.order_Seq,A.order_name,Convert(char(8),a.settle_date,112) as settle_date,a.order_email,a.order_hphone
		   ,Convert(char(8),a.src_cancel_date,112) as src_cancel_date, a.unicef_price, b.isjumin,jumin,
		   Case
			When a.status_seq = 5 Then '1'
			Else '0'
		   End iscancel
	FROM Custom_order a JOIN Custom_Order_Unicef b ON a.order_seq = b.order_seq
	WHERE A.unicef_price > 0 
		  and (Convert(char(8), settle_date, 112) Between @sDate and @eDate
		      or Convert(char(8), src_cancel_date, 112) Between @sDate and @eDate)
GO
