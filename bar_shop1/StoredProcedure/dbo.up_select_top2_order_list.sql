IF OBJECT_ID (N'dbo.up_select_top2_order_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_top2_order_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-06
-- Description:	쇼핑캐스트 - 주문/배송 TOP 2 LIST
-- TEST : up_select_top2_order_list 5007, 'palaoh'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_top2_order_list]	
	
	@company_seq	int,
	@uid			nvarchar(16)		

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	

	--DECLARE @uid varchar(16)='palaoh'
	--DECLARE @company_seq int=5007


	SELECT  TOP 2 O.*
	             ,G.order_date
	FROM Custom_Order_Group G
	INNER JOIN
	(
		SELECT  
					 A.status_seq 
					,A.settle_status										 
					,B.card_code
					,B.card_name 
					,B.card_image
					,A.order_seq				
					,A.order_g_seq
					,A.member_id					
					,'C' AS kind
					,0 AS sample_cnt 			
		FROM Custom_Order A 
		INNER JOIN S2_Card B ON A.card_seq = B.card_seq 
		WHERE A.status_Seq >= 0 
		  AND A.pay_type <> '4' 
		  AND A.order_type <> '4'
		  AND A.company_seq = @company_seq
		  AND A.member_id = @uid  

		UNION ALL

		SELECT   
					  A.status_seq 
					 ,'' AS settle_status				  
					 ,B.card_code
					 ,B.card_name
					 ,B.card_image				
					 ,A.order_seq
					 ,A.order_g_seq
					 ,A.member_id					 
					 ,'E' AS kind
					 ,0 AS sample_cnt  			 
		FROM Custom_Etc_Order A 
		INNER JOIN Custom_Etc_Order_Item I ON A.order_seq = I.order_seq
		INNER JOIN S2_Card B ON I.card_seq = B.card_seq 
		WHERE A.member_id = @uid
		  AND A.company_seq = @company_seq
		  AND A.status_seq >= 1
		     

		UNION ALL
		
		SELECT   status_seq 
				,settle_status			 
				,card_code
				,card_name  						
				,card_image
				,order_seq
				,order_g_seq
				,member_id					 
				,kind
				,sample_cnt
		FROM
		(
			SELECT   ROW_NUMBER() OVER (PARTITION BY SAMPLE_ORDER_SEQ ORDER BY card_seq) AS row_num
					,A.*
			FROM
			(
				SELECT        A.status_seq 
							 ,'' AS settle_status			 
							 ,B.card_code
							 ,B.card_name  						
							 ,B.card_image
							 ,A.sample_order_seq AS order_seq
							 ,A.order_g_seq
							 ,A.member_id					 
							 ,'S' AS kind
							 ,C.cnt AS sample_cnt
							 ,I.card_seq
							 ,I.SAMPLE_ORDER_SEQ   			  
				FROM Custom_Sample_Order A
				INNER JOIN Custom_Sample_Order_Item I ON A.sample_order_seq = I.sample_order_seq
				INNER JOIN S2_Card B ON I.card_seq = B.card_seq
				LEFT OUTER JOIN (
									SELECT sample_order_seq, COUNT(sample_order_seq) AS cnt
									FROM Custom_Sample_Order_Item 
									GROUP BY sample_order_seq				
								) C ON A.sample_order_seq = C.sample_order_seq
				WHERE A.member_id = @uid
				  AND A.company_seq = @company_seq
				  AND A.status_seq >= 1
			) A
		) Result
		WHERE row_num = 1 
	  
	) O ON G.order_g_seq = O.order_g_seq AND G.member_id = O.member_id

	ORDER BY G.order_date DESC


END





				   
				   
				   
          
	      	
	      	
	      	

GO
