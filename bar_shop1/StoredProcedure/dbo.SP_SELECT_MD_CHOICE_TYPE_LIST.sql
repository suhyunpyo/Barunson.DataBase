IF OBJECT_ID (N'dbo.SP_SELECT_MD_CHOICE_TYPE_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_MD_CHOICE_TYPE_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SELECT_MD_CHOICE_TYPE_LIST]
	@CompanySeq int
AS
BEGIN


	select 
		type_desc AS TypeDesc,
		type_code As TypeCode,
		type_image As TypeImage,
		md_seq As MdSeq, 
		company_seq As CompanySeq
	from (
			select 
				case 
					when lower(link_url) = '/MD/PRODUCTS.ASP' then '상품목록형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BANNER_IMAGE.ASP' then '배너형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/MBHANDS_EVENT_BANNER.ASP' then '배너형-['+convert(varchar,m.company_seq)+']'+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/MPREMIERPAPER_EVENT_BANNER.ASP' then '배너형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BANNER_IMAGE_NEW.ASP' then '배너형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/MAIN_EVT_LIST.ASP' then '이벤트형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/PRODUCT_SELECTOR.ASP' then '랭킹형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/PRODUCT_SELECTOR_BHANDS_NEW.ASP' then '랭킹형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/PRODUCT_SELECTOR_BSMALL_NEW.ASP' then '랭킹형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/BOARD/FREE_SAMPLE.ASP' then '랭킹형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/BOARD/PBHANDS_RANKING.ASP' then '랭킹형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BSMALL_PRODUCT_SELECTOR.ASP' then '랭킹형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BSMALL_PRODUCT_SELECTOR_V2.ASP' then '랭킹형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BSMALL_BANNER_IMAGE_NEW.ASP' then '배너형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BSMALL_BRAND.ASP' then '상품목록형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BSMALL_BRAND_RECOMM.ASP' then '상품목록형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BHANDS_BRAND_RECOMM.ASP' then '상품목록형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/EVENTMANAGEMENTLIST.ASPX' then '이벤트형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BHANDS_BENEFIT_BANNER.ASP' then '배너형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BSMALL_MAIN_VIEW.ASP' then '카테고리관리-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = 'BANNER_MST' then '배너형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = '/MD/BESTBANNER.ASP' then '배너형(베스트)-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = 'THECARD PRODUCT CLASSIFICATION REGISTRATION' then '랭킹형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
					when upper(link_url) = 'PRODUCT_DETAIL_BANNER' then '배너형-['+convert(varchar,m.company_seq)+'] '+md_text+' ('+convert(varchar,m.md_seq)+')'
				end as type_desc,
				case 
					when lower(link_url) = '/MD/PRODUCTS.ASP' then 'P'
					when upper(link_url) = '/MD/BANNER_IMAGE.ASP' then 'B'
					when upper(link_url) = '/MD/MBHANDS_EVENT_BANNER.ASP' then 'B'
					when upper(link_url) = '/MD/MPREMIERPAPER_EVENT_BANNER.ASP' then 'B'
					when upper(link_url) = '/MD/BANNER_IMAGE_NEW.ASP' then 'B'
					when upper(link_url) = '/MD/MAIN_EVT_LIST.ASP' then 'E'
					when upper(link_url) = '/MD/PRODUCT_SELECTOR.ASP' then 'R'
					when upper(link_url) = '/MD/PRODUCT_SELECTOR_BHANDS_NEW.ASP' then 'R'
					when upper(link_url) = '/MD/PRODUCT_SELECTOR_BSMALL_NEW.ASP' then 'R'
					when upper(link_url) = '/BOARD/FREE_SAMPLE.ASP' then 'R'
					when upper(link_url) = '/BOARD/PBHANDS_RANKING.ASP' then 'R'
					when upper(link_url) = '/MD/BSMALL_PRODUCT_SELECTOR.ASP' then 'R'
					when upper(link_url) = '/MD/BSMALL_PRODUCT_SELECTOR_V2.ASP' then 'R'
					when upper(link_url) = '/MD/BSMALL_BANNER_IMAGE_NEW.ASP' then 'B'
					when upper(link_url) = '/MD/BSMALL_BRAND.ASP' then 'P'
					when upper(link_url) = '/MD/BSMALL_BRAND_RECOMM.ASP' then 'P'
					when upper(link_url) = '/MD/BHANDS_BRAND_RECOMM.ASP' then 'P'
					when upper(link_url) = '/MD/EVENTMANAGEMENTLIST.ASPX' then 'E'
					when upper(link_url) = '/MD/BHANDS_BENEFIT_BANNER.ASP' then 'B'
					when upper(link_url) = '/MD/BSMALL_MAIN_VIEW.ASP' then 'BM'
					when upper(link_url) = 'BANNER_MST' then 'B'
					when upper(link_url) = '/MD/BESTBANNER.ASP' then 'B'
					when upper(link_url) = 'THECARD PRODUCT CLASSIFICATION REGISTRATION' then 'R'
					when upper(link_url) = 'PRODUCT_DETAIL_BANNER' then 'B'
				end as type_code,
				case 
					when upper(link_url) = '/MD/PRODUCTS.ASP' then 'products.jpg'
					when upper(link_url) = '/MD/BANNER_IMAGE.ASP' then 'banner_image.jpg'
					when upper(link_url) = '/MD/MBHANDS_EVENT_BANNER.ASP' then 'mbhands_event_banner.jpg'
					when upper(link_url) = '/MD/MPREMIERPAPER_EVENT_BANNER.ASP' then 'mpremierpaper_event_banner.jpg'
					when upper(link_url) = '/MD/BANNER_IMAGE_NEW.ASP' then 'banner_image_new.jpg'
					when upper(link_url) = '/MD/MAIN_EVT_LIST.ASP' then 'main_evt_list.jpg'
					when upper(link_url) = '/MD/PRODUCT_SELECTOR.ASP' then ''
					when upper(link_url) = '/MD/PRODUCT_SELECTOR_BHANDS_NEW.ASP' then ''
					when upper(link_url) = '/MD/PRODUCT_SELECTOR_BSMALL_NEW.ASP' then ''
					when upper(link_url) = '/BOARD/FREE_SAMPLE.ASP' then ''
					when upper(link_url) = '/BOARD/PBHANDS_RANKING.ASP' then ''
					when upper(link_url) = '/MD/BSMALL_PRODUCT_SELECTOR.ASP' then ''
					when upper(link_url) = '/MD/BSMALL_PRODUCT_SELECTOR_V2.ASP' then ''
					when upper(link_url) = '/MD/BSMALL_BANNER_IMAGE_NEW.ASP' then 'bsmall_banner_image_new.jpg'
					when upper(link_url) = '/MD/BSMALL_BRAND.ASP' then 'bsmall_brand.jpg'
					when upper(link_url) = '/MD/BSMALL_BRAND_RECOMM.ASP' then 'bsmall_brand_recomm.jpg'
					when upper(link_url) = '/MD/BHANDS_BRAND_RECOMM.ASP' then ''
					when upper(link_url) = '/MD/EVENTMANAGEMENTLIST.ASPX' then 'eventmanagementlist.jpg'
					when upper(link_url) = '/MD/BHANDS_BENEFIT_BANNER.ASP' then 'bhands_benefit_banner.jpg'
					when upper(link_url) = '/MD/BSMALL_MAIN_VIEW.ASP' then 'bsmall_main_view.jpg'
					when upper(link_url) = 'BANNER_MST' then 'banner_mst.jpg'
					when upper(link_url) = '/MD/BESTBANNER.ASP' then 'bestbanner.jpg'
					when upper(link_url) = 'THECARD PRODUCT CLASSIFICATION REGISTRATION' then ''
					when upper(link_url) = 'PRODUCT_DETAIL_BANNER' then ''
				end as type_image,
				UPPER(m.link_url) as link_url,
				m.md_seq,
				m.company_seq
			from S4_MD_Choice_Str AS m
				inner join (
					select max(mc.md_seq) md_seq 
					from S4_MD_Choice_Str AS mc
						inner join S4_MD_Choice_Str_UsedYN AS mcyn
							on mc.md_seq = mcyn.md_seq
								and mcyn.used_yn = 'Y'
								and mc.company_seq = @CompanySeq
					group by mc.link_url
				) as a
					on m.md_seq = a.md_seq
			where m.md_seq not in (286, 295, 468, 347, 680, 622, 683, 36)
				and m.link_url is not null
				and m.link_url != ''
		) AS a
	where type_code <> 'R'
	order by type_desc asc

END
GO
