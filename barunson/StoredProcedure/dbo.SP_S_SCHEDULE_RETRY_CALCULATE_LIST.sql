IF OBJECT_ID (N'dbo.SP_S_SCHEDULE_RETRY_CALCULATE_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_SCHEDULE_RETRY_CALCULATE_LIST
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
CREATE PROCEDURE [dbo].[SP_S_SCHEDULE_RETRY_CALCULATE_LIST]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		A.Remit_ID,
		A.Account_ID,
		ISNULL(B.FailCount, 0) FailCount,
		A.Total_Price,
		A.Remitter_Name,
		A.Transaction_ID,
		A.Tax,
		Account.Kakao_Bank_Code,
		Account.Kakao_Account_Number,
		A.Bank_Code,
		A.Account_Number,
		A.Depositor_Name
	FROM (
			SELECT Remit.Remit_ID,
				Account.Account_ID,
				Remit.Total_Price,
				Remit.Remitter_Name,
				Remit.Transaction_ID,
				Tax.Tax,
				Account.Bank_Code,
				Account.Account_Number,
				Account.Depositor_Name
			FROM TB_Remit AS Remit
				LEFT JOIN TB_Calculate AS Calculate
					ON Remit.Remit_ID = Calculate.Remit_ID
						AND Calculate.Status_Code in ('100','200')
						AND Calculate.Calculate_Type_Code = 'CTC02'
				INNER JOIN TB_Invitation_Tax AS InvitationTax
					ON Remit.Invitation_ID = InvitationTax.Invitation_ID
				INNER JOIN TB_Tax AS Tax
					ON InvitationTax.Tax_ID = Tax.Tax_ID
				INNER JOIN TB_Account AS Account
					ON Remit.Account_ID = Account.Account_ID
			WHERE Remit.Result_Code = 'RC005'
				AND Calculate.Remit_ID IS NULL
				AND Complete_DateTime > DATEADD(DAY, -40, GETDATE())
		) AS A
		LEFT JOIN (
			SELECT
				Remit_ID,
				COUNT(1) FailCount
			FROM TB_Calculate
			WHERE Remit_ID IN (
					SELECT Remit.Remit_ID
					FROM TB_Remit AS Remit
						LEFT JOIN TB_Calculate AS Calculate
							ON Remit.Remit_ID = Calculate.Remit_ID
								AND Calculate.Status_Code in ('100','200')
								AND Calculate.Calculate_Type_Code = 'CTC02'
						INNER JOIN TB_Invitation_Tax AS InvitationTax
							ON Remit.Invitation_ID = InvitationTax.Invitation_ID
						INNER JOIN TB_Tax AS Tax
							ON InvitationTax.Tax_ID = Tax.Tax_ID
						INNER JOIN TB_Account AS Account
							ON Remit.Account_ID = Account.Account_ID
					WHERE Remit.Result_Code = 'RC005'
						AND Calculate.Remit_ID IS NULL
						AND Complete_DateTime > DATEADD(DAY, -40, GETDATE())
				)
			GROUP BY Remit_ID		
		) AS B
			ON A.Remit_ID = B.Remit_ID
		JOIN (
			SELECT TOP 1 
				Barunn_Bank_Code,
				Barunn_Account_Number,
				Kakao_Bank_Code,
				Kakao_Account_Number
				FROM TB_Account_Setting
			ORDER BY Account_Setting_ID DESC	
		) AS Account
			ON 1=1
	WHERE ISNULL(B.FailCount, 0) <= 20 /* 실패시 5회까지만 시도 */
END
GO
