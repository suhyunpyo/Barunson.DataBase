IF OBJECT_ID (N'dbo.SP_BENEFIT_BANNER_MANAGER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BENEFIT_BANNER_MANAGER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================================================================
-- Author:		<엄예지>
-- Create date: <2016.09.29>
-- Description:	MANAGER : MD관리> [메인]2016메인리뉴얼  >  [메인] 혜택배너 (417)  - 진행 또는 대기상태 리스트만 기간이 지나면 종료처리 한다.
--              대체배너는 상시임. 따라서 종료대상이 아니다.
--              현재 비핸즈 메인만 해당된다. (COMPANY_SEQ로 확장 가능)
-- =======================================================================================================================================
CREATE PROCEDURE [dbo].[SP_BENEFIT_BANNER_MANAGER]

AS
BEGIN

	DECLARE @CNT AS INT; 

	SET NOCOUNT ON;


	SELECT @CNT = COUNT(*)
	FROM BENEFIT_BANNER
	WHERE DISPLAY_YN = 'Y'
	AND END_YN = 'N'
	AND B_TYPE_NO IN (1,2)
	AND  EVENT_E_DT < CONVERT(CHAR(10), GETDATE(), 23)


	IF @CNT > 0 
	BEGIN
		UPDATE A 
		SET END_YN = 'Y',
			DISPLAY_YN = 'N',
			UPDATED_DATE = GETDATE(),
			UPDATED_UID = 'BATCH'
		FROM BENEFIT_BANNER A
		WHERE A.SEQ IN (
							SELECT SEQ
							FROM BENEFIT_BANNER
							WHERE DISPLAY_YN = 'Y'
							AND END_YN = 'N'
							AND B_TYPE_NO IN (1,2)
							AND  EVENT_E_DT < CONVERT(CHAR(10), GETDATE(), 23)
		               )

	END

	SET NOCOUNT OFF;

END
GO
