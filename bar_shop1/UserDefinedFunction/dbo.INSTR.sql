IF OBJECT_ID (N'dbo.INSTR', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.INSTR', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.INSTR', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.INSTR', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.INSTR', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.INSTR
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
create function [dbo].[INSTR] (  
 @Start INTEGER = 1 --시작 
, @String1 nvarchar(600) --문자열1 
, @String2 nvarchar(600) --문자열2 
) 
RETURNS INTEGER 
AS 
BEGIN 
          WHILE LEN(@String1) - @Start > = 0 
          BEGIN  
                    IF SUBSTRING(@String1, @Start, LEN(@String2)) = @String2  
                              BREAK 
                              SET @Start = @Start + 1  
          END 
          IF @Start > LEN(@String1)  
          SELECT @Start = 0 
          RETURN @Start 
END 
GO
