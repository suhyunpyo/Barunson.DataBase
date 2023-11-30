IF OBJECT_ID (N'dbo.SA_FIND_PROCEDURE', N'P') IS NOT NULL DROP PROCEDURE dbo.SA_FIND_PROCEDURE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
 작	성 일 : 2020-12-01
 작	성 자 : 박혜림
 SP	   명 : SA_FIND_PROCEDURE
 SP	기 능 : 지정된 문자열이 포함된 SP 검색
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SA_FIND_PROCEDURE]

	@SearchString VARCHAR (255)

AS

SET NOCOUNT ON

DECLARE @Name VARCHAR(255)
      , @Text NVARCHAR(4000)
	  ,	@strLog_Yn VARCHAR(1)					--Log기록여부(Y,N)

SET @strLog_Yn = 'N'

BEGIN
	BEGIN TRY

		CREATE TABLE #Objs ( ObjName VARCHAR (255))

		DECLARE Obj CURSOR

		FOR

			SELECT [NAME]
				 , [TEXT]
			  FROM sysobjects so
				 , syscomments sc
			 WHERE ( so.xtype = 'P' )
			   AND so.id = sc.id

		OPEN Obj

		FETCH Next FROM Obj INTO @Name, @Text

		WHILE @@FETCH_STATUS=0

			BEGIN

				IF PATINDEX(@SearchString, @Text) <> 0

				INSERT INTO #Objs VALUES (@Name)

		FETCH Next FROM Obj INTO @Name,@Text

		END

		CLOSE Obj

		DEALLOCATE Obj

		SELECT objname
		  FROM #Objs
		 GROUP BY objname

		DROP TABLE #Objs

	END TRY
	BEGIN CATCH	
		GOTO ERR_HANDLER		
	END CATCH


ERR_HANDLER:
	IF CURSOR_STATUS ('global', 'Obj') >= 0 
	BEGIN
		CLOSE Obj
		DEALLOCATE Obj
	END	

END
GO
