IF OBJECT_ID (N'dbo.SP_INSERT_MD_CHOICE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MD_CHOICE
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
CREATE PROCEDURE [dbo].[SP_INSERT_MD_CHOICE]
	@P_MD_TEXT NVARCHAR(100),
	@P_UPPER_MD_SEQ INT,
	@P_COMPANY_SEQ INT,
	@P_REFER_MD_SEQ INT
AS
BEGIN
	
	DECLARE @LINK_URL NVARCHAR(255);

	SET @LINK_URL = (SELECT LINK_URL FROM S4_MD_Choice_Str WHERE MD_SEQ = @P_REFER_MD_SEQ)

	DECLARE @TMP_MG_SEQ INT;

	INSERT INTO S4_MD_Choice_Str (
		[md_text]
		,[md_upper_code]
		,[choice_div]
		,[link_url]
		,[link_target]
		,[company_seq]
		,[reg_date]
		,[sorting_num]
		,[cardtitle_yn]
		,[customimg_yn]
		,[md_sub_text]
		,[md_image]
		,[md_html]
	) 
	SELECT @P_MD_TEXT AS [md_text]
		,@P_UPPER_MD_SEQ AS [md_upper_code]
		,[choice_div]
		,[link_url]
		,[link_target]
		,@P_COMPANY_SEQ AS [company_seq]
		,GETDATE() AS [reg_date]
		,[sorting_num]
		,[cardtitle_yn]
		,[customimg_yn]
		,[md_sub_text]
		,[md_image]
		,[md_html]
	FROM [dbo].[S4_MD_Choice_Str]
	WHERE MD_SEQ = @P_REFER_MD_SEQ;

	SET @TMP_MG_SEQ = @@IDENTITY

	INSERT INTO S4_MD_Choice_Str_UsedYN values(@TMP_MG_SEQ, 'Y');
	
	IF (
		UPPER(@LINK_URL) = '/MD/PRODUCT_SELECTOR.ASP' 
		OR UPPER(@LINK_URL) = '/MD/PRODUCT_SELECTOR_BHANDS_NEW.ASP' 
		OR UPPER(@LINK_URL) = '/MD/PRODUCT_SELECTOR_BSMALL_NEW.ASP' 
		OR UPPER(@LINK_URL) = '/BOARD/FREE_SAMPLE.ASP' 
		OR UPPER(@LINK_URL) = '/BOARD/PBHANDS_RANKING.ASP' 
		OR UPPER(@LINK_URL) = '/MD/BSMALL_PRODUCT_SELECTOR.ASP' 
		OR UPPER(@LINK_URL) = '/MD/BSMALL_PRODUCT_SELECTOR_V2.ASP' 
		OR UPPER(@LINK_URL) = 'THECARD PRODUCT CLASSIFICATION REGISTRATION' 
	)
		BEGIN
			INSERT INTO S4_Ranking_Sort (ST_company_seq, ST_tabgubun, ST_brand, ST_CODE, ST_MD_SEQ) values (@P_COMPANY_SEQ, @TMP_MG_SEQ, 'all', cast(@TMP_MG_SEQ as char), @TMP_MG_SEQ);
		END
	
END
GO
