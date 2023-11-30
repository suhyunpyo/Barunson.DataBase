IF OBJECT_ID (N'dbo.sp_CardDisrate_New', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CardDisrate_New
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec sp_CardDisrate_New 400

CREATE Proc [dbo].[sp_CardDisrate_New]
	@card_num as smallint
	AS

    SET NOCOUNT ON
	
	--자료 Reporting을 위한 임시 테이블 생성      
	Declare @Report  Table  (      
							sales_site		   nvarchar(20)  NOT NULL ,      
							card_code          nvarchar(20)  NOT NULL ,  
							disrate_type       char(1)  NOT NULL,    
							card_price         int NOT NULL,
							discount_rate	   smallint NOT NULL,
							display_yes_or_no  nvarchar(1) NOT NULL 
							)

	
	--직영사이트 가격대별 할인율
	INSERT INTO @Report (sales_site,card_code,disrate_type,card_price,discount_rate,display_yes_or_no)
				SELECT 
				sales_site = Case
								When a.card_group = '0' Then '바른손카드'
								When a.card_group = '1' Then '더카드'
								When a.card_group = '2' Then '투유카드'
								When a.card_group = '3' Then '티아라카드'
								When a.card_group = '5' Then '스토리오브러브' 
							 End,
				a.card_code,b.disrate_type,a.card_price_customer,b.discount_rate,
				display_yes_or_no = Case
										When IsNull(a.display_yes_or_no,4) = 1 Then '●'
										When IsNull(a.display_yes_or_no,4) = 2 Then '▲'
										When IsNull(a.display_yes_or_no,4) = 0 Then '△'
										Else 'X'
									End
				FROM card a JOIN card_discount_rate b 
				ON A.card_group = B.card_Group and A.company=B.company and A.card_price_customer = B.card_price
				WHERE a.card_group in (0,1,2,3,5) and left(a.card_cate,1)='I' and a.disrate_type ='P' and b.disrate_type ='P'    
				and min_count = @card_num
				
	
	--직영사이트 제품별 할인율
	INSERT INTO @Report (sales_site,card_code,disrate_type,card_price,discount_rate,display_yes_or_no)
				SELECT 
				sales_site = Case
								When a.card_group = '0' Then '바른손카드'
								When a.card_group = '1' Then '더카드'
								When a.card_group = '2' Then '투유카드'
								When a.card_group = '3' Then '티아라카드'
								When a.card_group = '5' Then '스토리오브러브' 
							 End,
				a.card_code,b.disrate_type,a.card_price_customer,b.discount_rate,
				display_yes_or_no = Case
										When IsNull(a.display_yes_or_no,4) = 1 Then '●'
										When IsNull(a.display_yes_or_no,4) = 2 Then '▲'
										When IsNull(a.display_yes_or_no,4) = 0 Then '△'
										Else 'X'
									End
				FROM card a JOIN card_discount_rate b 
				ON A.card_seq = B.card_price
				WHERE a.card_group in (0,1,2,3,5) and left(a.card_cate,1)='I' and a.disrate_type ='I' and b.disrate_type ='I'    
				and min_count = @card_num


	
	
	--제휴사이트 가격대별 할인율
	INSERT INTO @Report (sales_site,card_code,disrate_type,card_price,discount_rate,display_yes_or_no)
				SELECT 
				sales_site = c.company_name,
				a.card_code,b.disrate_type,a.card_price_customer,b.discount_rate,
				display_yes_or_no = Case
										When IsNull(a.display_yes_or_no,4) = 1 Then '●'
										When IsNull(a.display_yes_or_no,4) = 2 Then '▲'
										When IsNull(a.display_yes_or_no,4) = 0 Then '△'
										Else 'X'
									End
				FROM card a JOIN BRANCH_CARD_DISCOUNT_RATE b 
				ON A.card_group = B.company_seq and A.company=B.company and A.card_price_customer = B.card_price
				JOIN company c ON a.card_group = c.company_seq 
				WHERE a.card_group not in (0,1,2,3,5) and left(a.card_cate,1)='I' and a.disrate_type ='P' and b.disrate_type ='P'    
				and min_count = @card_num
	
	
	--제휴사이트 제품별 할인율
	INSERT INTO @Report (sales_site,card_code,disrate_type,card_price,discount_rate,display_yes_or_no)
				SELECT 
				sales_site = c.company_name,
				a.card_code,b.disrate_type,a.card_price_customer,b.discount_rate,
				display_yes_or_no = Case
										When IsNull(a.display_yes_or_no,4) = 1 Then '●'
										When IsNull(a.display_yes_or_no,4) = 2 Then '▲'
										When IsNull(a.display_yes_or_no,4) = 0 Then '△'
										Else 'X'
									End
				FROM card a JOIN BRANCH_CARD_DISCOUNT_RATE b 
				ON A.card_group = B.company_seq and A.company=B.company and A.card_price_customer = B.card_price
				JOIN company c ON a.card_group = c.company_seq 
				WHERE a.card_group not in (0,1,2,3,5) and left(a.card_cate,1)='I' and a.disrate_type ='I' and b.disrate_type ='I'    
				and min_count = @card_num

	SELECT * FROM @Report ORDER BY card_code desc,sales_site
GO
