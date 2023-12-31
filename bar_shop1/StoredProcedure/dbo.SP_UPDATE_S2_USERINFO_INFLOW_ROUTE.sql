IF OBJECT_ID (N'dbo.SP_UPDATE_S2_USERINFO_INFLOW_ROUTE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_S2_USERINFO_INFLOW_ROUTE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM S2_USERINFO WHERE UID = 's4guest'
SELECT * FROM S2_USERINFO_SIGNUP_DEVICE WHERE DUPINFO = 'asd'

*/

CREATE PROCEDURE [dbo].[SP_UPDATE_S2_USERINFO_INFLOW_ROUTE]
	@P_DUPINFO						AS VARCHAR(100)
,   @P_INFLOW_ROUTE					AS VARCHAR(100)
,	@P_USER_AGENT					AS VARCHAR(1000)
	

AS
BEGIN
	
	SET @P_INFLOW_ROUTE = CASE WHEN @P_INFLOW_ROUTE NOT IN ('PC', 'MOBILE') THEN 'MOBILE' ELSE @P_INFLOW_ROUTE END

	UPDATE	S2_USERINFO
	SET		INFLOW_ROUTE = @P_INFLOW_ROUTE
	WHERE	DUPINFO = @P_DUPINFO

	UPDATE	S2_USERINFO_THECARD
	SET		INFLOW_ROUTE = @P_INFLOW_ROUTE
	WHERE	DUPINFO = @P_DUPINFO

	UPDATE	S2_USERINFO_BHANDS
	SET		INFLOW_ROUTE = @P_INFLOW_ROUTE
	WHERE	DUPINFO = @P_DUPINFO



	DECLARE @UID AS VARCHAR(50)
	SET @UID = ISNULL((SELECT TOP 1 UID FROM S2_USERINFO WHERE DUPINFO = @P_DUPINFO AND SITE_DIV = 'SB'), '')

	IF NOT EXISTS(SELECT * FROM S2_USERINFO_SIGNUP_DEVICE WHERE DUPINFO = @P_DUPINFO AND UID = @UID)
		BEGIN
			
			INSERT INTO S2_USERINFO_SIGNUP_DEVICE (DUPINFO, UID, USER_AGENT, DEVICE_TYPE)

			SELECT	TOP 1
					DUPINFO
				,	UID
				,	@P_USER_AGENT
				,	@P_INFLOW_ROUTE
			FROM	S2_USERINFO
			WHERE	1 = 1
			AND		SITE_DIV = 'SB'
			AND		DUPINFO = @P_DUPINFO
			AND		UID = @UID

		END

END
GO
