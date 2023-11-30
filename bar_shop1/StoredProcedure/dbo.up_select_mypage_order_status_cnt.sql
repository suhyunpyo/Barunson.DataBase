IF OBJECT_ID (N'dbo.up_select_mypage_order_status_cnt', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_mypage_order_status_cnt
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-17
-- Description:	주문결제 리스트 상태 갯수 
-- TEST : up_select_mypage_order_status_cnt 5007, 'palaoh'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_mypage_order_status_cnt]
	
	@company_seq	int,
	@uid			nvarchar(16)	

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;

	
	--DECLARE @company_seq INT=5007
	--DECLARE @uid VARCHAR(16)='palaoh'
	
	
	SELECT  ISNULL(SUM(CASE step WHEN 's1' THEN cnt END), 0) AS '입금대기'
	       ,ISNULL(SUM(CASE step WHEN 's2' THEN cnt END), 0) AS '결제완료'
	       ,ISNULL(SUM(CASE step WHEN 's3' THEN cnt END), 0) AS '초안완료'
	       ,ISNULL(SUM(CASE step WHEN 's4' THEN cnt END), 0) AS '인쇄'
	       ,ISNULL(SUM(CASE step WHEN 's5' THEN cnt END), 0) AS '포장'
	       ,ISNULL(SUM(CASE step WHEN 's6' THEN cnt END), 0) AS '배송'
	       ,ISNULL(SUM(CASE step WHEN 's7' THEN cnt END), 0) AS '주문취소'
	FROM
	(	
		SELECT O.step, COUNT(O.step) as cnt	
		FROM Custom_Order_Group G
		INNER JOIN
		(	
			SELECT   order_g_seq
					,status_seq
					,settle_status
					,'C' AS kind
					,(CASE status_seq   WHEN 0 THEN ''
										WHEN 1 THEN 
													CASE settle_status WHEN 0 THEN ''
																	   WHEN 1 THEN 's1'
																	   ELSE 's2'
													END														
										WHEN 3 THEN 's7'	--주문취소 (주문취소)													
										WHEN 5 THEN 's7'	--주문취소 (결제취소)
										WHEN 6 THEN 's2'	--결제완료 (재초안작업중)
										WHEN 7 THEN 's3'	--초안완료 (초안확인요청) 	
										WHEN 8 THEN 's3'	--초안완료 (재초안확인요청)
										WHEN 9 THEN 's4'	--인쇄 (초안 고객확인완료)
										WHEN 10 THEN 's4'	--인쇄 (인쇄준비중)
										WHEN 11 THEN 's4'	--인쇄 (인쇄중)
										WHEN 12 THEN 's4'	--인쇄 (인쇄중)
										WHEN 13 THEN 's4'	--인쇄 (인쇄중)
										WHEN 14 THEN 's5'	--포장 (포장완료)
										WHEN 15 THEN 's6'	--배송 (발송처리완료)
					 END) AS step				    
			FROM Custom_Order
			WHERE 1 = 1
			 AND status_Seq >= 0 
			 AND pay_type <> '4' 
			 AND order_type <> '4'
			 AND member_id = @uid
			 AND company_seq = @company_seq	

			UNION ALL

			SELECT   order_g_seq
					,status_seq
					,'' AS settle_status
					,'S' AS kind
					,(CASE status_seq WHEN 1 THEN 's1'	--입금대기
									  WHEN 3 THEN 's7'	--주문취소											
									  WHEN 4 THEN 's2'	--결제완료
									  WHEN 5 THEN 's7'	--주문취소 (결제취소)											
									  WHEN 10 THEN 's5'	--포장											
									  WHEN 12 THEN 's6'	--배송											
					  END) AS step  
			FROM Custom_Etc_Order
			WHERE 1 = 1
			 AND status_seq >= 1
			 AND member_id = @uid
			 AND company_seq = @company_seq	
			  
			UNION ALL

			SELECT   order_g_seq
					,status_seq
					,'' AS settle_status
					,'S' AS kind
					,(CASE status_seq WHEN 1 THEN 's1'	--입금대기
									  WHEN 3 THEN 's7'	--주문취소											
									  WHEN 4 THEN 's2'	--결제완료
									  WHEN 5 THEN 's7'	--주문취소 (결제취소)	 										
									  WHEN 10 THEN 's5'	--포장											
									  WHEN 12 THEN 's6'	--배송											
					  END) AS step 
			FROM Custom_Sample_Order
			WHERE 1 = 1
			 AND member_id = @uid
			 AND company_seq = @company_seq
			 AND status_seq >= 1	
		) O ON G.order_g_seq = O.order_g_seq
		
		WHERE G.company_seq = @company_seq
		  AND G.member_id = @uid
		
		GROUP BY O.step
		
	) Result
	
	--GROUP BY step	
	

END
GO
