IF OBJECT_ID (N'dbo.sp_lock3', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_lock3
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_lock3]


AS



SELECT
		[master].[dbo].[sysprocesses].spid AS spid,
		[master].[dbo].[sysprocesses].open_tran AS 차단하는중,
		[master].[dbo].[sysprocesses].ecid AS 차단주체,
		[master].[dbo].[sysprocesses].login_time AS 로그인시간,
		[master].[dbo].[sysprocesses].last_batch AS 마지막_일괄_처리,
	RTRIM([master].[dbo].[sysprocesses].loginame) AS 사용자,
	RTRIM([master].[dbo].[sysprocesses].hostname) AS 호스트,
	RTRIM([master].[dbo].[sysprocesses].program_name) AS 응용프로그램,
	RTRIM([master].[dbo].[sysprocesses].status) AS 상태,
	RTRIM([master].[dbo].[sysprocesses].cmd) AS 실행타입,
	RTRIM([master].[dbo].[sysprocesses].cpu) AS CPU사용량
INTO  #TMP
FROM           [master].[dbo].[sysprocesses]
WHERE        ([master].[dbo].[sysprocesses].open_tran <> 0)
ORDER BY    [master].[dbo].[sysprocesses].spid



CREATE TABLE #DBCC(
	ID     INT  IDENTITY
	, SPID    INT 
	, EVENTTYPE VARCHAR(255)
	, PARAMETERS INT
	, EVENTINFO  VARCHAR(255)
)

DECLARE C1 CURSOR READ_ONLY
FOR

	SELECT DISTINCT spid
	FROM #TMP


DECLARE @SPID INT
OPEN C1
FETCH NEXT FROM C1 INTO @SPID

WHILE (@@FETCH_STATUS = 0)
BEGIN
	
	INSERT #DBCC (EVENTTYPE, PARAMETERS, EVENTINFO)
	EXEC ('DBCC INPUTBUFFER(' + @SPID + ')')

	UPDATE #DBCC SET SPID = @SPID
	WHERE ID = @@IDENTITY



FETCH NEXT FROM C1 INTO @SPID

END
DEALLOCATE C1



SELECT A.*
	, B.EVENTINFO AS 실행쿼리
FROM #TMP A 
LEFT JOIN #DBCC B ON A.spid = B.spid




GO
