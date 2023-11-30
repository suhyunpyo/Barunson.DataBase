IF OBJECT_ID (N'dbo.sp_Total_Report', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_Total_Report
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Report] 

	@Gubun char(1), 
	@BDate  char(8),
	@EDate  char(8),
	@Msg    nvarchar(55) = null OUTPUT
AS

	IF @Gubun = 'Z'  --전체검색
		SELECT gubun, Sum(Settle_price) FROM (
			--청첩장
			SELECT '청첩장' as gubun, order_seq, pg_tid, settle_price, Convert(char(8),src_send_date,112) as 'src_send_date', 
			settle_status ,Case When settle_status =5 Then '결제취소('+Convert(char(8),Settle_cancel_date,112)+')' Else '결제(' + Convert(char(8),Settle_date,112)+')' End as 'settle_code' 
			FROM custom_order 
			WHERE Convert(char(8),src_send_date,112) between @BDate and @EDate 
			and settle_status >= 2 and settle_date is not null 
			and sales_gubun in ('W','T','U','A','J','B')
			
			union
			
			--샘플
			SELECT '샘플' as gubun, sample_order_seq, pg_tid, settle_price, Convert(char(8),delivery_date,112) as 'src_send_date', 
			status_seq , Case When status_seq =5 Then '결제취소('+Convert(char(8),cancel_date,112)+')' Else '결제(' + Convert(char(8),Settle_date,112)+')' End as 'settle_code' 
			FROM custom_sample_order 
			WHERE Convert(char(8),settle_Date,112) between @BDate  and @EDate
			and status_seq >= 2 and settle_date is not null 
			and sales_gubun in ('W','T','U','A','J','B')
			
			union
			
			--e청첩장
	
	
			SELECT 'e청첩장' as gubun,order_id, pg_tid, settle_price, Convert(char(8),settle_date,112) as 'src_send_date' ,
			settle_status, Case When status_seq =4 Then '결제취소('+Convert(char(8),settle_cancel_date,112)+')' Else '결제(' + Convert(char(8),Settle_date,112)+')' End as 'settle_code' 
			from the_ewed_order 
			where 
			AC_STATE='P' and settle_Status=2 and status_Seq=2 and order_result in ('3','4') 
			and settle_date>= @BDate and settle_Date<= @EDate 
			and sales_gubun in ('W','T','U','A','J','B')
			
			union
			
			--식권
			SELECT '식권' as gubun, order_seq, pg_tid, settle_price, Convert(char(8),delivery_date,112) as 'src_send_date', 
			status_seq ,Case When status_seq =5 Then '결제취소('+Convert(char(8),Settle_cancel_date,112)+')' Else '결제(' + Convert(char(8),Settle_date,112)+')' End as 'settle_code' 
			FROM custom_etc_order 
			WHERE Convert(char(8),delivery_date,112) between @BDate and @EDate
			and status_seq>=4 and settle_date is not null 
			and sales_gubun in ('W','T','U','A','J','B')
		)  a
		GROUP BY gubun


	ELSE
		SELECT gubun, Sum(Settle_price) FROM (
			--청첩장
			SELECT '청첩장' as gubun, order_seq, pg_tid, settle_price, Convert(char(8),src_send_date,112) as 'src_send_date', 
			settle_status ,Case When settle_status =5 Then '결제취소('+Convert(char(8),Settle_cancel_date,112)+')' Else '결제(' + Convert(char(8),Settle_date,112)+')' End as 'settle_code' 
			FROM custom_order 
			WHERE Convert(char(8),src_send_date,112) between @BDate and @EDate 
			and sales_gubun =@Gubun  
			and settle_status >= 2 and settle_date is not null 
			
			union
			
			--샘플
			SELECT '샘플' as gubun, sample_order_seq, pg_tid, settle_price, Convert(char(8),delivery_date,112) as 'src_send_date', 
			status_seq , Case When status_seq =5 Then '결제취소('+Convert(char(8),cancel_date,112)+')' Else '결제(' + Convert(char(8),Settle_date,112)+')' End as 'settle_code' 
			FROM custom_sample_order 
			WHERE Convert(char(8),settle_Date,112) between @BDate  and @EDate
			and sales_gubun =@Gubun and status_seq >= 2 and settle_date is not null 
			
			union
			
			--e청첩장
	
	
			SELECT 'e청첩장' as gubun,order_id, pg_tid, settle_price, Convert(char(8),settle_date,112) as 'src_send_date' ,
			settle_status, Case When status_seq =4 Then '결제취소('+Convert(char(8),settle_cancel_date,112)+')' Else '결제(' + Convert(char(8),Settle_date,112)+')' End as 'settle_code' 
			from the_ewed_order 
			where 
			AC_STATE='P' and settle_Status=2 and status_Seq=2 and order_result in ('3','4') 
			and settle_date>= @BDate and settle_Date<= @EDate 
			and sales_gubun = @Gubun
		
			union
			
			--식권
			SELECT '식권' as gubun, order_seq, pg_tid, settle_price, Convert(char(8),delivery_date,112) as 'src_send_date', 
			status_seq ,Case When status_seq =5 Then '결제취소('+Convert(char(8),Settle_cancel_date,112)+')' Else '결제(' + Convert(char(8),Settle_date,112)+')' End as 'settle_code' 
			FROM custom_etc_order 
			WHERE Convert(char(8),delivery_date,112) between @BDate and @EDate
			and sales_gubun =@Gubun and status_seq>=4 and settle_date is not null 

		)  a
		GROUP BY gubun

GO
