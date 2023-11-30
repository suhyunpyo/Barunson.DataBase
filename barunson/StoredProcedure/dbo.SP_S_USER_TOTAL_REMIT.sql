IF OBJECT_ID (N'dbo.SP_S_USER_TOTAL_REMIT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_USER_TOTAL_REMIT
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
CREATE PROCEDURE [dbo].[SP_S_USER_TOTAL_REMIT]
	@UserId VARCHAR(50),
	@InvitationId Int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	
	

	SET NOCOUNT ON;

	SELECT 
		isnull(SUM(Remit.Total_Price),0) Total_Price,
		isnull(SUM(Calculate.Remit_Price),0) Remit_Price,
		isnull(SUM(Tax.Tax),0) Tax,
		COUNT(1) RemitCount
	FROM TB_Remit AS Remit
		INNER JOIN TB_Invitation AS Invitation
			ON Remit.Invitation_ID = Invitation.Invitation_ID
		LEFT JOIN TB_Calculate AS Calculate
			ON Remit.Remit_ID = Calculate.Remit_ID
				AND Calculate.Calculate_Type_Code = 'CTC02'
				AND Calculate.Status_Code = '200'
		INNER JOIN TB_Invitation_Tax AS InvitationTax
			ON InvitationTax.Invitation_ID = Invitation.Invitation_ID
		INNER JOIN TB_Tax AS Tax
			ON Tax.Tax_ID = InvitationTax.Tax_ID
	WHERE Invitation.User_ID = @UserId
		AND Invitation.Invitation_ID = @InvitationId
		AND Remit.Result_Code = 'RC005'

END




GO
