IF OBJECT_ID (N'dbo.sp_common_checkprivilege', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_common_checkprivilege
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_common_checkprivilege]
AS

    IF NOT EXISTS (
        SELECT name
        FROM   sysobjects 
        WHERE  name = 'ata_temp' 
        AND type = 'U' )
    BEGIN
        CREATE TABLE ata_temp (a char(1))

    DROP TABLE ata_temp
    END

RETURN
GO
