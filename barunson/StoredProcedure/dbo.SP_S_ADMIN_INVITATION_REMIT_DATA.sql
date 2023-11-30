IF OBJECT_ID (N'dbo.SP_S_ADMIN_INVITATION_REMIT_DATA', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_INVITATION_REMIT_DATA
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
CREATE PROCEDURE [dbo].[SP_S_ADMIN_INVITATION_REMIT_DATA]
	@ProcType VARCHAR(50) = 'list',
	@SearchType VARCHAR(50) = 'id',
	@SearchKeyword VARCHAR(50) = '',
	@CalculateType VARCHAR(50) = 'all', 
	@DateType VARCHAR(50) = 'remit',
	@StartDate CHAR(10) = '2021-01-01', 
	@EndDate CHAR(10) = '2099-12-31'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	SET @ProcType = 'list';
	SET @SearchType = 'id';
	SET @Keyword = '시스템';
	SET @DateType = 'invitation'; /* invitation : M카드구매일, account : 계좌개설일, wedding : 예식일 */
	SET @StartDate = '2021-05-01';
	SET @EndDate = DATEADD(D, 1, CONVERT(DATE, '2021-05-03'));
	SET @CalculateType = 'all'; /* all : 전체, remit : 정산완료, remain : 미정산 */
	*/

	SET @EndDate = DATEADD(D, 1, CONVERT(DATE, @EndDate));

	IF @ProcType = 'list' BEGIN


		SELECT 
			isnull(U.NAME, '탈퇴회원') NAME,
			isnull(Invitation.User_ID, '-') User_ID,
			Ord.Order_Code,
			(SELECT Code_Name FROM TB_Common_Code WHERE Code_Group = 'Account_Type_Code' AND Code = Account.Account_Type_Code) AS Account_Type,
			Account.Depositor_Name,
			(SELECT Code_Name FROM TB_Common_Code WHERE Code_Group = 'Bank_Code' AND Code = Account.Bank_Code) AS Bank_Name,
			Account.Account_Number,
			Remit.Remitter_Name,
			Remit.Total_Price,
			Tax.Tax,
			ISNULL(Calculate.Remit_Price, 0) Remit_Price,
			Remit.Total_Price - Tax.Tax - ISNULL(Calculate.Remit_Price, 0) Remain_Price,
			Detail.WeddingDate,
			convert(varchar, Account.Regist_DateTime, 120) AS Account_Date,
			convert(varchar, Remit.Complete_DateTime, 120) AS Complete_Date,
			convert(varchar, Calculate.Calculate_DateTime, 120) AS Calculate_Date,
			Detail.Invitation_URL,
			Ord.Order_ID,
			Remit.Remit_ID
		FROM TB_Remit AS Remit
			INNER JOIN TB_Invitation AS Invitation
				ON Remit.Invitation_ID = Invitation.Invitation_ID
			INNER JOIN TB_Order AS Ord
				ON Invitation.Order_ID = Ord.Order_ID
			LEFT JOIN TB_Invitation_Detail AS Detail
				ON Invitation.Invitation_ID = Detail.Invitation_ID
			LEFT JOIN (
				SELECT 
					USER_ID AS User_ID , 
					NAME 
				FROM VW_User 
			) AS U
				ON Invitation.User_ID = U.USER_ID
			INNER JOIN TB_Account AS Account
				ON Remit.Account_ID = Account.Account_ID
			INNER JOIN TB_Invitation_Tax AS InvitationTax
				ON Invitation.Invitation_ID = InvitationTax.Invitation_ID
			INNER JOIN TB_Tax AS Tax 
				ON InvitationTax.Tax_ID = Tax.Tax_ID
			LEFT JOIN TB_Calculate AS Calculate
				ON Remit.Remit_ID = Calculate.Remit_ID
					AND Calculate.Calculate_Type_Code = 'CTC02'
					AND Calculate.Status_Code = '200'
		WHERE Remit.Result_Code = 'RC005'
			AND Remit.Status_Code = '200'
			AND (@SearchType <> 'order' OR Ord.Order_Code LIKE '%' + @SearchKeyword + '%')
			AND (@CalculateType <> 'all' OR Remit.Total_Price is not null)
			AND (@SearchType <> 'id' OR U.User_ID  LIKE '%' + @SearchKeyword + '%')
			AND (@SearchType <> 'name' OR U.NAME  LIKE '%' + @SearchKeyword + '%')
			AND (@SearchType <> 'sender' OR remit.Remitter_Name  LIKE '%' + @SearchKeyword + '%')
			--AND (@CalculateType <> 'remit' OR (Remit.Total_Price - Tax.Tax - ISNULL(Calculate.Remit_Price, 0)) = 0)
			--AND (@CalculateType <> 'remain' OR (Remit.Total_Price - Tax.Tax - ISNULL(Calculate.Remit_Price, 0)) > 0)
			AND (@CalculateType <> 'remit' OR Calculate.Remit_Price is not null)
			AND (@CalculateType <> 'remain' OR Calculate.Remit_Price is null)
			AND (@DateType <> 'invitation' OR (Invitation.Regist_DateTime> @StartDate AND Invitation.Regist_DateTime < @EndDate))
			AND (@DateType <> 'remit' OR (Remit.Complete_DateTime > @StartDate AND Remit.Complete_DateTime < @EndDate))
			AND (@DateType <> 'wedding' OR (Detail.WeddingDate > @StartDate AND Detail.WeddingDate < @EndDate))
		ORDER BY Remit.Complete_DateTime DESC

	END ELSE BEGIN
		SELECT
			0 User_Count,
			0 Account_Count,
			COUNT(1) Remit_Count,
			SUM(Total_Price) Total_Price
		FROM (
				SELECT 
					isnull(Invitation.User_ID, '-') User_ID,
					Remit.Total_Price,
					Tax.Tax,
					ISNULL(Calculate.Remit_Price, 0) Remit_Price,
					Remit.Total_Price - Tax.Tax - ISNULL(Calculate.Remit_Price, 0) Remain_Price
				FROM TB_Remit AS Remit
					INNER JOIN TB_Invitation AS Invitation
						ON Remit.Invitation_ID = Invitation.Invitation_ID
					INNER JOIN TB_Order AS Ord
						ON Invitation.Order_ID = Ord.Order_ID
					LEFT JOIN TB_Invitation_Detail AS Detail
						ON Invitation.Invitation_ID = Detail.Invitation_ID
					LEFT JOIN (
						SELECT 
							USER_ID AS User_ID , 
							NAME 
						FROM VW_User 
					) AS U
						ON Invitation.User_ID = U.USER_ID
					INNER JOIN TB_Account AS Account
						ON Remit.Account_ID = Account.Account_ID
					INNER JOIN TB_Invitation_Tax AS InvitationTax
						ON Invitation.Invitation_ID = InvitationTax.Invitation_ID
					INNER JOIN TB_Tax AS Tax 
						ON InvitationTax.Tax_ID = Tax.Tax_ID
					LEFT JOIN TB_Calculate AS Calculate
						ON Remit.Remit_ID = Calculate.Remit_ID
							AND Calculate.Calculate_Type_Code = 'CTC02'
							AND Calculate.Status_Code = '200'
				WHERE Remit.Result_Code = 'RC005'
					AND Remit.Status_Code = '200'
					AND (@SearchType <> 'order' OR Ord.Order_Code LIKE '%' + @SearchKeyword + '%')
					AND (@CalculateType <> 'all' OR Remit.Total_Price is not null)
					AND (@SearchType <> 'id' OR U.User_ID  LIKE '%' + @SearchKeyword + '%')
					AND (@SearchType <> 'name' OR U.NAME  LIKE '%' + @SearchKeyword + '%')
					AND (@SearchType <> 'sender' OR remit.Remitter_Name  LIKE '%' + @SearchKeyword + '%')
					--AND (@CalculateType <> 'remit' OR (Remit.Total_Price - Tax.Tax - ISNULL(Calculate.Remit_Price, 0)) = 0)
					--AND (@CalculateType <> 'remain' OR (Remit.Total_Price - Tax.Tax - ISNULL(Calculate.Remit_Price, 0)) > 0)
					AND (@CalculateType <> 'remit' OR Calculate.Remit_Price is not null)
					AND (@CalculateType <> 'remain' OR Calculate.Remit_Price is null)
					AND (@DateType <> 'invitation' OR (Invitation.Regist_DateTime> @StartDate AND Invitation.Regist_DateTime < @EndDate))
					AND (@DateType <> 'remit' OR (Remit.Complete_DateTime > @StartDate AND Remit.Complete_DateTime < @EndDate))
					AND (@DateType <> 'wedding' OR (Detail.WeddingDate > @StartDate AND Detail.WeddingDate < @EndDate))
		) AS A
	END

END
GO
