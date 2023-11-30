IF OBJECT_ID (N'dbo.SP_S_ADMIN_INVITATION_REMIT_USER_DETAIL_DATA', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_INVITATION_REMIT_USER_DETAIL_DATA
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
CREATE PROCEDURE [dbo].[SP_S_ADMIN_INVITATION_REMIT_USER_DETAIL_DATA]
	@InvitationID Integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		(SELECT Code_Name FROM TB_Common_Code WHERE Code_Group = 'Account_Type_Code' AND Code = Account.Account_Type_Code) AS Account_Type,
		Account.Depositor_Name,
		(SELECT Code_Name FROM TB_Common_Code WHERE Code_Group = 'Bank_Code' AND Code = Account.Bank_Code) AS Bank_Name,
		Account.Account_Number,
		Remit.Remitter_Name,
		Remit.Total_Price,
		Tax.Tax Remit_Tax,
		ISNULL(Calculate.Remit_Price, 0) Remit_Price,
		Remit.Total_Price - Tax.Tax - ISNULL(Calculate.Remit_Price, 0) AS Remain_Price,
		convert(varchar, Remit.Complete_DateTime, 120) AS Complete_Date,
		isnull(convert(varchar, Calculate.Calculate_DateTime, 120),'') AS Calculate_Date,
		Remit.Remit_Id
	FROM TB_Remit AS Remit
		INNER JOIN TB_Invitation AS Invitation
			ON Remit.Invitation_ID = Invitation.Invitation_ID
		INNER JOIN TB_Invitation_Tax As InvitationTax
			ON Invitation.Invitation_ID = InvitationTax.Invitation_ID
		INNER JOIN TB_Tax AS Tax
			ON InvitationTax.Tax_ID = Tax.Tax_ID
		INNER JOIN TB_Account AS Account
			ON Remit.Account_ID = Account.Account_ID
		LEFT JOIN TB_Calculate AS Calculate
			ON Remit.Remit_ID = Calculate.Remit_ID
				AND Calculate.Calculate_Type_Code = 'CTC02'
				AND Calculate.Status_Code = '200'
		/*
		INNER JOIN TB_Invitation_Detail AS Detail
			ON Invitation.Invitation_ID = Detail.Invitation_ID
		*/
	WHERE Remit.Result_Code = 'RC005'
		AND Invitation.Invitation_ID = @InvitationID
	ORDER BY Remit.Complete_DateTime DESC

END
GO
