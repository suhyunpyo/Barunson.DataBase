IF OBJECT_ID (N'dbo.sp_mmt_create', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_mmt_create
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_mmt_create]
AS

    IF NOT EXISTS (
        SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ata_mmt_tran'
    )
    BEGIN
        CREATE TABLE ata_mmt_tran
        ( mt_pr                 int identity(1,1)                          NOT NULL 
        , mt_refkey             varchar(20)   COLLATE Korean_Wansung_CS_AS
        , priority              char(2)       COLLATE Korean_Wansung_CS_AS NOT NULL default 'S'
        , date_client_req       datetime                                   NOT NULL default '1970-01-01 00:00:00'
        , subject               varchar(40)   COLLATE Korean_Wansung_CS_AS NOT NULL default ' '
        , content               varchar(4000) COLLATE Korean_Wansung_CS_AS NOT NULL
        , callback              varchar(25)   COLLATE Korean_Wansung_CS_AS NOT NULL
        , msg_status            char(1)       COLLATE Korean_Wansung_CS_AS NOT NULL default '1'
        , recipient_num         varchar(25)   COLLATE Korean_Wansung_CS_AS
        , date_mt_sent          datetime
        , date_rslt             datetime
        , date_mt_report        datetime
        , report_code           char(4)       COLLATE Korean_Wansung_CS_AS
        , rs_id                 varchar(20)   COLLATE Korean_Wansung_CS_AS
        , country_code          varchar(8)    COLLATE Korean_Wansung_CS_AS NOT NULL default '82'
        , msg_type              int                                        NOT NULL default '1008'
        , crypto_yn             char(1)       COLLATE Korean_Wansung_CS_AS          default 'Y'
        , ata_id                char(2)       COLLATE Korean_Wansung_CS_AS          default ' '
        , reg_date              datetime                                            default getdate()
        , sender_key            varchar(40)   COLLATE Korean_Wansung_CS_AS NOT NULL
        , template_code         varchar(30)   COLLATE Korean_Wansung_CS_AS
        , response_method       varchar(20)   COLLATE Korean_Wansung_CS_AS NOT NULL default 'push'
        , ad_flag               char(1)       COLLATE Korean_Wansung_CS_AS NOT NULL default 'N'
		, kko_btn_type          char(1)       COLLATE Korean_Wansung_CS_AS
		, kko_btn_info          varchar(4000) COLLATE Korean_Wansung_CS_AS
		, img_url               varchar(200)  COLLATE Korean_Wansung_CS_AS
        , img_link              varchar(100)  COLLATE Korean_Wansung_CS_AS
        , etc_text_1            varchar(100)  COLLATE Korean_Wansung_CS_AS
        , etc_text_2            varchar(100)  COLLATE Korean_Wansung_CS_AS
        , etc_text_3            varchar(100)  COLLATE Korean_Wansung_CS_AS
        , etc_num_1             int
        , etc_num_2             int
        , etc_num_3             int
        , etc_date_1            datetime
        )
        
        ALTER TABLE ata_mmt_tran  ADD PRIMARY KEY ( mt_pr )
        
        CREATE INDEX idx_ata_mmt_tran_1 ON ata_mmt_tran (msg_status, date_client_req)
        CREATE INDEX idx_ata_mmt_tran_2 ON ata_mmt_tran (recipient_num)
        CREATE INDEX idx_ata_mmt_tran_3 ON ata_mmt_tran (ata_id)
        CREATE INDEX idx_ata_mmt_tran_4 ON ata_mmt_tran (sender_key, template_code)

    END

RETURN
GO
