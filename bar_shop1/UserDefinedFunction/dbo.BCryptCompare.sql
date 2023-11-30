IF OBJECT_ID (N'dbo.BCryptCompare', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BCryptCompare', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BCryptCompare', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BCryptCompare', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BCryptCompare', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.BCryptCompare
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[BCryptCompare](@password [nvarchar](4000), @hashed [nvarchar](4000))
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [BCrypt].[BCryptPackage.UserDefinedFunctions].[CheckPassword]
GO
EXEC sys.sp_addextendedproperty @name=N'AutoDeployed', @value=N'yes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'BCryptCompare'
GO
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFile', @value=N'BCryptAssembly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'BCryptCompare'
GO
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFileLine', @value=820 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'BCryptCompare'
GO
