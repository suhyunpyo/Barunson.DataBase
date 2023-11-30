IF OBJECT_ID (N'dbo.BCryptHash', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BCryptHash', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BCryptHash', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BCryptHash', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BCryptHash', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.BCryptHash
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[BCryptHash](@password [nvarchar](4000), @rounds [int])
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [BCrypt].[BCryptPackage.UserDefinedFunctions].[BCrypt]
GO
EXEC sys.sp_addextendedproperty @name=N'AutoDeployed', @value=N'yes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'BCryptHash'
GO
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFile', @value=N'BCryptAssembly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'BCryptHash'
GO
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFileLine', @value=813 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'BCryptHash'
GO
