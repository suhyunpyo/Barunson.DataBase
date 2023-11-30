IF OBJECT_ID (N'dbo.SP_MCARD_INVITATION_FLOW', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_MCARD_INVITATION_FLOW
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
CREATE PROCEDURE [dbo].[SP_MCARD_INVITATION_FLOW]
	@UID                  AS VARCHAR(16),
	@PCM                  AS VARCHAR(2),
	@STEP0                AS INT,
	@STEP1                AS INT,
	@STEP2                AS INT,
	@STEP3                AS INT,
	@STEP4                AS INT

AS
BEGIN
	
	SET NOCOUNT ON;


		MERGE INTO MCARD_INVITATION_FLOW SDM
			USING (SELECT @UID UID
						, (SELECT PCM
						   FROM MCARD_INVITATION_FLOW
						   WHERE UID = @UID
						   AND PCM = @PCM)PCM
				) A
			ON (SDM.UID = A.UID
				and SDM.PCM = A.PCM)       
		WHEN MATCHED THEN
			UPDATE
				SET SDM.STEP0 = STEP0 + @STEP0,
					SDM.STEP1 = STEP1 + @STEP1,
					SDM.STEP2 = STEP2 + @STEP2,
					SDM.STEP3 = STEP3 + @STEP3,
					SDM.STEP4 = STEP4 + @STEP4,
					SDM.UPDATE_DATE = GETDATE()
		WHEN NOT MATCHED THEN
			INSERT (PCM, UID, STEP0 , STEP1 , STEP2 , STEP3 , STEP4 , MEM_GB , CREATE_DATE)
			VALUES(@PCM ,@UID , @STEP0 ,@STEP1 ,@STEP2 ,@STEP3 ,@STEP4 ,'Y' ,GETDATE());


	SET NOCOUNT OFF;

END
GO
