IF OBJECT_ID (N'dbo.Usp_InsertUpdateDelete_BarunnIP', N'P') IS NOT NULL DROP PROCEDURE dbo.Usp_InsertUpdateDelete_BarunnIP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Usp_InsertUpdateDelete_BarunnIP]
	@IP_ID BIGINT = 0
	,@IP_NO NVARCHAR(15) = NULL
	,@UserName NVARCHAR(100) = NULL
	,@Descr NVARCHAR(200) = NULL
	,@Gubun NVARCHAR(10) 

AS
BEGIN


	IF (@Gubun = 'INSERT')
	BEGIN
		INSERT INTO BarunnIP( IP_NO, UserName, Descr, ActionDate )
		VALUES ( @IP_NO, @UserName, @Descr, GETDATE() )
 
		IF (@@ROWCOUNT > 0)
			SELECT 'INSERT'

	END
 


	IF (@Gubun = 'UPDATE')
	BEGIN
		UPDATE BarunnIP
		SET IP_NO = @IP_NO
			, UserName = @UserName
			, Descr = @Descr
			, ActionDate = GETDATE()
		WHERE IP_ID = @IP_ID
 
		SELECT 'UPDATE'
	END



	IF (@Gubun = 'DELETE')
	BEGIN
		DELETE FROM BarunnIP
		WHERE IP_ID = @IP_ID
 
		SELECT 'DELETE'
	END

 
	IF (@Gubun = 'SELECT')
	BEGIN
		SELECT IP_ID, IP_NO, LTRIM(RTRIM(UserName)) AS UserName, LTRIM(RTRIM(Descr)) AS Descr, ActionDate
		FROM BarunnIP
		ORDER BY IP_ID
	END


 
	IF (@Gubun = 'ID_SELECT')
	BEGIN
		SELECT IP_ID, IP_NO, LTRIM(RTRIM(UserName)) AS UserName, LTRIM(RTRIM(Descr)) AS Descr, ActionDate
		FROM BarunnIP
		WHERE IP_ID = @IP_ID
	END


END
GO
