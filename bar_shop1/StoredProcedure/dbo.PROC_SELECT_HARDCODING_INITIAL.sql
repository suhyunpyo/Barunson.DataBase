USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[PROC_SELECT_HARDCODING_INITIAL]    Script Date: 2023-06-21 오전 8:38:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[PROC_SELECT_HARDCODING_INITIAL] (
	@P_JUMUN INT = 1,
	@P_DISPLAY INT = 1,
	@P_COMPANY_SEQ VARCHAR(50) = '5000,5001,5003', /*미사용 : 삭제 및 프로그램 수정 예정*/
	@P_SD_YN CHAR(1)= 'Y',
	@P_HG_YN CHAR(1)= 'Y',
	@P_SG_YN CHAR(1)= 'Y'
)
AS      
SET NOCOUNT ON      
BEGIN


select 
*
from (
		select 
			c.card_seq CardSeq,
			c.card_code CardCode, 
			co.PrintMethod, /* 특수인쇄 값 */
			mc.code_value PmValue, /* 박 종류 */
			substring(co.PrintMethod, 1, 1) Pm, /* 박 */
			case substring(co.PrintMethod, 2, 1) when '1' then '●' else '' end  Pm1, /* 광 */
			case substring(co.PrintMethod, 3, 1) when '1' then '●' else '' end  Pm2, /* 압 */
			case when h1.HardUse is null and h2.HardUse is null then 'Y' else 'N' end SdUse, /* 삼성동판 */
			isnull(h1.HardUse, 'N') HgUse, /* 현대금박 */
			isnull(h2.HardUse, 'N') SgUse, /* 삼성금박 */
			case when s.barunson = 2 then '●' when s.barunson = 1 then '○' else '' end Barunson,
			case when s.mall = 2 then '●'  when s.mall = 1 then '○' else '' end Mall, 
			case when s.premier =2 then '●' when s.premier =1 then '○' else '' end Premier
		from s2_card as c
			join s2_cardoption co
				on c.card_seq = co.Card_Seq
			left join (
				select 
					card_seq,
					sum(barunsoncard) barunson,
					sum(barunsonmall) mall,
					sum(premierpaper) premier
				from (
						select 
							card_seq,
							case when company_seq = 5000 and IsDisplay=1 then 2 when company_seq = 5000 then 1 else 0 end barunsonmall,
							case when company_seq = 5001 and IsDisplay=1 then 2 when company_seq = 5001 then 1 else 0 end barunsoncard,
							case when company_seq = 5003 and IsDisplay=1 then 2 when company_seq = 5003 then 1 else 0 end premierpaper
						from S2_CardSalesSite
						/*
						where IsJumun = @P_JUMUN  
							and IsDisplay =  @P_DISPLAY 
						*/
					) a
				group by card_seq
			) s
				on co.Card_Seq = s.card_seq
			left join HardCodingList h1
				on c.Card_Code = h1.HardCode and h1.HardID = 'HYUNDAI_GOLDFOIL'
			left join HardCodingList h2
				on c.Card_Code = h2.HardCode and h2.HardID = 'SAMSUNG_GOLDFOIL'
			left join manage_code mc 
				on left(co.PrintMethod,1) = mc.code and code_type = 'print_mount'
		where co.PrintMethod <> '000'
			and (barunson > 0 or mall > 0 or premier > 0 or CardBrand = 'X')
			
	) AS A
WHERE SdUse = @P_SD_YN
	or HgUse = @P_HG_YN
	or SgUse = @P_SG_YN
order by CardCode asc

END
