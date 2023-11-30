IF OBJECT_ID (N'dbo.sp_mmt_tran_select', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_mmt_tran_select
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_mmt_tran_select]
    @p_priority char(2)
  , @p_ttl int
  , @p_ata_id char(2)
  , @p_bancheck_yn char(1)
AS

    /** update ata_id */
    IF @p_ata_id <> ' '
    BEGIN
    
    SET NOCOUNT ON

    BEGIN TRAN

    UPDATE ata_mmt_tran 
    SET    ata_id = @p_ata_id
    WHERE  mt_pr in ( SELECT TOP 300
                             mt_pr 
                      FROM   ata_mmt_tran
                      WHERE  priority = @p_priority
                      AND    msg_status = '1' 
                      AND   date_client_req BETWEEN ( getdate() -  ( @p_ttl/24/60 ) ) AND getdate() 
                      AND   ata_id = ' ' ) AND   ata_id = ' '

    if @@error != 0
    begin
        rollback tran
        return
    end

    COMMIT TRAN

    END
    
    /** real select */
    SELECT TOP 300
           A.mt_pr                 AS mt_pr
         , A.mt_refkey             AS mt_refkey
         , A.subject               AS subject
         , 0                       AS content_type
         , A.content               AS content
         , A.priority              AS priority
         , 'N'                     AS broadcast_yn
         , A.callback              AS callback
         , A.recipient_num         AS recipient_num
         , NULL                    AS recipient_net
         , NULL                    AS recipient_npsend
         , A.country_code          AS country_code
         , A.date_client_req       AS date_client_req
         , NULL                    AS charset
         , '1'                     AS msg_class
         , NULL                    AS attach_file_group_key
         , A.msg_type              AS msg_type
         , A.crypto_yn             AS crypto_yn
         , '3'                     AS service_type
         , NULL                    AS ttl
         , A.sender_key            AS sender_key
         , A.template_code         AS template_code
         , A.response_method       AS response_method
         , B.ban_type              AS ban_type
         , B.send_yn               AS send_yn
         , A.kko_btn_info          AS kko_btn_info
		 , A.kko_btn_type          AS kko_btn_type
		 , A.ad_flag               AS ad_flag
		 , A.img_url               AS img_url
         , A.img_link              AS img_link
    FROM   ata_mmt_tran A 
    LEFT OUTER JOIN ata_banlist B 
    ON     A.recipient_num = B.content
    AND    '3' = B.service_type
    AND    B.ban_type = 'R'
    AND    B.ban_status_yn = 'Y'
    WHERE  A.ata_id = @p_ata_id
    AND    A.priority = @p_priority
    AND    A.msg_status = '1' 
    AND    A.date_client_req BETWEEN (dateadd(n, (-1) * @p_ttl, getdate())) AND getdate()

RETURN
GO
