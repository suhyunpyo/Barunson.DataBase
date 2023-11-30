IF OBJECT_ID (N'dbo.sp_common_create', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_common_create
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_common_create]
AS

    IF NOT EXISTS (
        SELECT name
        FROM   sysobjects 
        WHERE  name = 'ata_banlist' 
        AND    type = 'U' )
    BEGIN
        CREATE TABLE ata_banlist
        ( service_type  char(2)     COLLATE Korean_Wansung_CS_AS NOT NULL
        , ban_seq       int                                      NOT NULL
        , ban_type      char(1)     COLLATE Korean_Wansung_CS_AS NOT NULL
        , content       varchar(45) COLLATE Korean_Wansung_CS_AS NOT NULL
        , send_yn       char(1)     COLLATE Korean_Wansung_CS_AS NOT NULL default 'N'
        , ban_status_yn char(1)     COLLATE Korean_Wansung_CS_AS NOT NULL default 'Y'
        , reg_date      datetime                                 NOT NULL default getdate()
        , reg_user      varchar(20) COLLATE Korean_Wansung_CS_AS
        , update_date   datetime                                 NOT NULL default '1970-01-01 00:00:00'
        , update_user   varchar(20) COLLATE Korean_Wansung_CS_AS
        )
        
        ALTER TABLE ata_banlist  ADD PRIMARY KEY(service_type, ban_seq)
        CREATE INDEX idx_ata_banlist_1 ON ata_banlist(ban_type, service_type, ban_status_yn)
        CREATE INDEX idx_ata_banlist_2 ON ata_banlist(content)

    END

RETURN
GO
