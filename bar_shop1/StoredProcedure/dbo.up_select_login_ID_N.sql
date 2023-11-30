IF OBJECT_ID (N'dbo.up_select_login_ID_N', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_login_ID_N
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-05-09
-- Description:	회원로그인 체크
-- =============================================
CREATE PROCEDURE [dbo].[up_select_login_ID_N]
	-- Add the parameters for the stored procedure here
	@sales_gubun AS nvarchar(10),
	@company_seq AS int,
	@uid	AS nvarchar(50),
	@pwd	AS nvarchar(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if (@sales_gubun = 'SB' or @sales_gubun='SS' or @sales_gubun='H' )	--바른손, 프리머어비핸즈, 프리미어페이퍼 제휴
		
		begin
			if (@sales_gubun = 'SB' or @sales_gubun='SS')
				begin
					Select pwd, PWDCOMPARE(@pwd, CONVERT(VARBINARY(200), pwd, 1)) AS PWD_COMPARE_YORN, uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender From 
					S2_UserInfo with(nolock)  Where company_seq is null and uid=@uid 
				end
			else
				begin
					Select pwd, PWDCOMPARE(@pwd, CONVERT(VARBINARY(200), pwd, 1)) AS PWD_COMPARE_YORN, uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender From 
					S2_UserInfo with(nolock)  Where company_seq=@company_seq and uid=@uid 
				end
		end
		
		
	if (@sales_gubun = 'SA' or @sales_gubun='B' or @sales_gubun='C'  )	--비핸즈, 비핸즈 제휴
		begin
			if @sales_gubun ='SA'
				begin
					Select pwd, PWDCOMPARE(@pwd, CONVERT(VARBINARY(200), pwd, 1)) AS PWD_COMPARE_YORN, uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender From 
					S2_UserInfo_BHands with(nolock)  Where company_seq is null and uid=@uid
				end
			else
				begin
					Select pwd, PWDCOMPARE(@pwd, CONVERT(VARBINARY(200), pwd, 1)) AS PWD_COMPARE_YORN, uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender From 
					S2_UserInfo_BHands with(nolock)  Where company_seq=@company_seq and uid=@uid	
				end
				
				
		end
	if (@sales_gubun = 'ST' or @sales_gubun = 'SN')		--더카드
		begin
		
			if (@sales_gubun = 'ST' or @sales_gubun='SN')
				begin
					Select pwd, PWDCOMPARE(@pwd, CONVERT(VARBINARY(200), pwd, 1)) AS PWD_COMPARE_YORN, uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender, convert(varchar(4),phone1)+'-'+convert(varchar(4),phone2)+'-'+convert(varchar(4),phone3) as uphone, convert(varchar(4),hand_phone1)+'-'+convert(varchar(4),hand_phone2)+'-'+convert(varchar(4),hand_phone3) as uhphone, chk_DormancyAccount
					, (select count(sp_idx) from S5_Supporters_User where SP_UserID=@uid and SP_Status=1 and SP_SeasonNo = 1) as supporter 
					, (select count(sp_idx) from S5_Supporters_User where SP_UserID=@uid and SP_Status=1 and SP_SeasonNo = 2) as supporter2
					, (select count(sp_idx) from S5_Supporters_User where SP_UserID=@uid and SP_Status=1 and SP_SeasonNo = 3) as supporter3
					From S2_UserInfo_TheCard with(nolock)  Where  company_seq is null  and uid=@uid
				end
			else
				begin
					Select pwd, PWDCOMPARE(@pwd, CONVERT(VARBINARY(200), pwd, 1)) AS PWD_COMPARE_YORN, uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender, convert(varchar(4),phone1)+'-'+convert(varchar(4),phone2)+'-'+convert(varchar(4),phone3) as uphone, convert(varchar(4),hand_phone1)+'-'+convert(varchar(4),hand_phone2)+'-'+convert(varchar(4),hand_phone3) as uhphone, chk_DormancyAccount
					, (select count(sp_idx) from S5_Supporters_User where SP_UserID=@uid and SP_Status=1 and SP_SeasonNo = 1) as supporter 
					, (select count(sp_idx) from S5_Supporters_User where SP_UserID=@uid and SP_Status=1 and SP_SeasonNo = 2) as supporter2
					, (select count(sp_idx) from S5_Supporters_User where SP_UserID=@uid and SP_Status=1 and SP_SeasonNo = 3) as supporter3
					From S2_UserInfo_TheCard with(nolock)  Where company_seq=@company_seq and uid=@uid	
				end
		end
END
GO
