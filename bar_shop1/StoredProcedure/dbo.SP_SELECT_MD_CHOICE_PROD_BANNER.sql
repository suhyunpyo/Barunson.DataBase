IF OBJECT_ID (N'dbo.SP_SELECT_MD_CHOICE_PROD_BANNER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_MD_CHOICE_PROD_BANNER
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
CREATE PROCEDURE [dbo].[SP_SELECT_MD_CHOICE_PROD_BANNER]
	@P_MD_SEQ AS int,
	@P_COMPANY_SEQ AS int,
	@P_PAGE AS int = 1,
	@P_PAGE_SCALE AS int = 50,
	@P_TYPE AS NVARCHAR(10) = N'list'

AS
BEGIN

	SET @P_TYPE = UPPER(@P_TYPE);
	
	IF (@P_TYPE = 'LIST')
		BEGIN

			SELECT 
				[seq] as Seq
				,[md_seq] as MdSeq
				,[company_seq] as CompanySeq
				,[banner_title] as BannerTitle
				,[target_type] as TargetType
				,[item_type1_yorn] as ItemType1YorN
				,[item_type2_yorn] as ItemType2YorN
				,[card_code] as CardCode
				,[pc_show_yorn] as PcShowYorN
				,[pc_banner_image] as PcBannerImage
				,[pc_move_url] as PcMoveUrl
				,[pc_click_count] as PcClickCount
				,[pc_new_win_yorn] as PcNewWinYorN
				,[mo_show_yorn] as MoShowYorN
				,[mo_banner_image] as MoBannerImage
				,[mo_move_url] as MoMoveUrl
				,[mo_click_count] as MoClickCount
				,[mo_new_win_yorn] as MoNewWinYorN
				,[start_date] as StartDate
				,[end_date] as EndDate
				,[reg_date] as RegDate
				,[reg_admin_id] as RegAdminId
				,[mod_date] as ModDate
				,[mod_admin_id] as ModAdminId
				,banner_status as BannerStatus
				,sort
				,[pc_title] as PcTitle
				,[pc_content] as PcContent
				,[mo_title] as MoTitle
				,[mo_content] as MoContent
			FROM (
					SELECT ROW_NUMBER() OVER (ORDER BY seq DESC) AS Row, 
						[seq]
						,[md_seq]
						,[company_seq]
						,[banner_title]
						,[target_type]
						,[item_type1_yorn]
						,[item_type2_yorn]
						,[card_code]
						,[pc_show_yorn]
						,[pc_banner_image]
						,[pc_move_url]
						,[pc_click_count]
						,[pc_new_win_yorn]
						,[mo_show_yorn]
						,[mo_banner_image]
						,[mo_move_url]
						,[mo_click_count]
						,[mo_new_win_yorn]
						,[start_date]
						,[end_date]
						,[reg_date]
						,[reg_admin_id]
						,[mod_date]
						,[mod_admin_id]
						,case 
							when [start_date] < getdate() and [end_date] < getdate() then 'E'
							when [start_date] < getdate() and [end_date] > getdate() then 'S'
							when [start_date] > getdate() and [end_date] > getdate() then 'R'
							else 'X'
						end as banner_status
						,sort
						,[pc_title]
						,[pc_content]
						,[mo_title]
						,[mo_content]
					FROM [S4_MD_Choice_ProdBanner]
					WHERE md_seq = @P_MD_SEQ
						AND company_seq = @P_COMPANY_SEQ
						AND use_yorn = 'Y'
				) as a
			WHERE Row between 
			(@P_PAGE - 1) * @P_PAGE_SCALE + 1 and @P_PAGE * @P_PAGE_SCALE

		END
	ELSE IF (@P_TYPE = 'COUNT')
		BEGIN
			SELECT 
				COUNT(1) AS TotalCount,
				CASE 
					WHEN COUNT(1) > 0 AND COUNT(1) % @P_PAGE_SCALE > 0 THEN (COUNT(1) / @P_PAGE_SCALE) + 1
					WHEN COUNT(1) > 0 AND COUNT(1) % @P_PAGE_SCALE = 0 THEN COUNT(1) / @P_PAGE_SCALE
					ELSE 1
				END TotalPage
			FROM [S4_MD_Choice_ProdBanner]
			WHERE md_seq = @P_MD_SEQ
				AND company_seq = @P_COMPANY_SEQ
				AND use_yorn = 'Y'
		END

END
GO
