IF OBJECT_ID (N'dbo.fn_datediff', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_datediff', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_datediff', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_datediff', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_datediff', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_datediff
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fn_datediff](@date1 datetime, @date2 datetime) 
returns bigint
as
BEGIN
	RETURN ABS(convert(bigint, CONVERT(VARCHAR(30), @date1, 112) + REPLACE(CONVERT(VARCHAR(30), @date1, 108), ':', '')) - convert(bigint, CONVERT(VARCHAR(30), @date2, 112) + REPLACE(CONVERT(VARCHAR(30), @date2, 108), ':', '')))
END
GO
