IF OBJECT_ID (N'dbo.SP_S_USER_CALCULATE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_USER_CALCULATE
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
CREATE PROCEDURE [dbo].[SP_S_USER_CALCULATE]
	@UserId Varchar(50),
	@AccountTypeCode Varchar(10) = '',
	@InvitationId int,
	@Page int = 1,
	@PageSize int = 10,
	@Type varchar(50) = 'paging',
	@Total int = 0 output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	
insert test (Order_Code, resultMSG, reg_date)
values(@UserId, '', getdate())


	SET NOCOUNT ON;


		SELECT 
			@Total = count(1)
		FROM (
				SELECT 
					'A' as A
				FROM TB_Remit AS Remit
					INNER JOIN TB_Account AS Account
						ON Remit.Account_ID = Account.Account_ID
				WHERE Remit.Result_Code = 'RC005'
					AND Account.User_ID = @UserId
					And Account.Invitation_ID = @InvitationId
			) AS A

	if @Type = 'paging' BEGIN

		SELECT 
			convert(varchar, Remit.Complete_DateTime, 120) Complete_DateTime,
			Account.Depositor_Name,
			Remit.Remitter_Name,
			Remit.Total_Price AS Total_Amount,
			SUM(ISNULL(Tax.Tax, 0)) AS Tax,
			SUM(ISNULL(Calculate2.Remit_Price, 0)) AS Amount,
			Remit.Total_Price - SUM(ISNULL(Tax.Tax, 0)) - SUM(ISNULL(Calculate2.Remit_Price,0)) AS Left_Amount,
			CONVERT(varchar, MAX(Calculate2.Calculate_DateTime), 120) Calculate_DateTime
		FROM TB_Remit AS Remit
			INNER JOIN TB_Account AS Account
				ON Remit.Account_ID = Account.Account_ID
			INNER JOIN (
				SELECT
					Invitation.Invitation_ID,
					Tax.Tax
				FROM TB_Invitation AS Invitation
					INNER JOIN TB_Invitation_Tax AS InvitationTax
						ON Invitation.Invitation_ID = InvitationTax.Invitation_ID
					INNER JOIN TB_Tax AS Tax
						ON InvitationTax.Tax_ID = Tax.Tax_ID
			) AS Tax
				ON Remit.Invitation_ID = Tax.Invitation_ID
			LEFT JOIN (
				SELECT 
					Remit_ID,
					Calculate_Type_Code,
					sum(Remit_Price) remit_price,
					Remit_Bank_Code,
					Remit_Account_Number,
					Remit_Content,
					Status_Code,
					max(Calculate_DateTime) Calculate_DateTime
				FROM TB_Calculate
				WHERE Calculate_Type_Code = 'CTC02'
					AND Status_Code = '200'
				GROUP BY Remit_ID,
					Calculate_Type_Code,
					Remit_Bank_Code,
					Remit_Account_Number,
					Remit_Content,
					Status_Code			
			) AS Calculate2
				ON Remit.Remit_ID = Calculate2.Remit_ID
					AND Calculate2.Calculate_Type_Code = 'CTC02'
					AND Calculate2.Status_Code = '200'
		WHERE Remit.Result_Code = 'RC005'
			AND Account.User_ID = @UserId
			And (@AccountTypeCode = '' or @AccountTypeCode is null or Account.Account_Type_Code = @AccountTypeCode)
			And Account.Invitation_ID = @InvitationId
		group by Remit.Complete_DateTime,
			Account.Depositor_Name,
			Remit.Remitter_Name,
			Remit.Total_Price
		order by Remit.Complete_DateTime DESC
		OFFSET (@Page - 1) * @PageSize ROW
		FETCH NEXT @PageSize ROW ONLY

	END ELSE BEGIN
		SELECT 
			convert(varchar, Remit.Complete_DateTime, 120) Complete_DateTime,
			Account.Depositor_Name,
			Remit.Remitter_Name,
			Remit.Total_Price AS Total_Amount,
			SUM(ISNULL(Tax.Tax, 0)) AS Tax,
			SUM(ISNULL(Calculate2.Remit_Price, 0)) AS Amount,
			Remit.Total_Price - SUM(ISNULL(Tax.Tax, 0)) - SUM(ISNULL(Calculate2.Remit_Price,0)) AS Left_Amount,
			CONVERT(varchar, MAX(Calculate2.Calculate_DateTime), 120) Calculate_DateTime
		FROM TB_Remit AS Remit
			INNER JOIN TB_Account AS Account
				ON Remit.Account_ID = Account.Account_ID
			INNER JOIN (
				SELECT
					Invitation.Invitation_ID,
					Tax.Tax
				FROM TB_Invitation AS Invitation
					INNER JOIN TB_Invitation_Tax AS InvitationTax
						ON Invitation.Invitation_ID = InvitationTax.Invitation_ID
					INNER JOIN TB_Tax AS Tax
						ON InvitationTax.Tax_ID = Tax.Tax_ID
			) AS Tax
				ON Remit.Invitation_ID = Tax.Invitation_ID
			LEFT JOIN (
				SELECT 
					Remit_ID,
					Calculate_Type_Code,
					sum(Remit_Price) remit_price,
					Remit_Bank_Code,
					Remit_Account_Number,
					Remit_Content,
					Status_Code,
					max(Calculate_DateTime) Calculate_DateTime
				FROM TB_Calculate
				WHERE Calculate_Type_Code = 'CTC02'
					AND Status_Code = '200'
				GROUP BY Remit_ID,
					Calculate_Type_Code,
					Remit_Bank_Code,
					Remit_Account_Number,
					Remit_Content,
					Status_Code			
			) AS Calculate2
				ON Remit.Remit_ID = Calculate2.Remit_ID
					AND Calculate2.Calculate_Type_Code = 'CTC02'
					AND Calculate2.Status_Code = '200'
		WHERE Remit.Result_Code = 'RC005'
			AND Account.User_ID = @UserId
			And (@AccountTypeCode = '' or @AccountTypeCode is null or Account.Account_Type_Code = @AccountTypeCode)
			And Account.Invitation_ID = @InvitationId
		group by Remit.Complete_DateTime,
			Account.Depositor_Name,
			Remit.Remitter_Name,
			Remit.Total_Price
		order by Remit.Complete_DateTime DESC

	END


END




--select * from test
--order by reg_date desc

GO
