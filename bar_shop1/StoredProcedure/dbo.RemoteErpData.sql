IF OBJECT_ID (N'dbo.RemoteErpData', N'P') IS NOT NULL DROP PROCEDURE dbo.RemoteErpData
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoteErpData] 
	--<@param1, sysname, @p1> <datatype_for_param1, , int> = <default_value_for_param1, , 0>, 
AS
	--원격서버 연결
	EXEC sp_addlinkedserver    @server='erp', @srvproduct='',  @provider='SQLOLEDB', @datasrc='222.120.91.61'
	
	EXEC sp_addlinkedsrvlogin 'erp', false, null,'remoteUser','dnjsrurfhrmdlssa' 
	
	--select top 100 * from erp.xerp.dbo.glDocHeader
		
	--원격서버 연결 해제	
	EXEC sp_dropserver 'erp', 'droplogins'

GO
