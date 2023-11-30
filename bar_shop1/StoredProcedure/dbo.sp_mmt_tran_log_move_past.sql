IF OBJECT_ID (N'dbo.sp_mmt_tran_log_move_past', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_mmt_tran_log_move_past
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_mmt_tran_log_move_past]
    @p_ata_id char(2)
AS

    SET NOCOUNT ON      
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED       

    DECLARE @dsql nvarchar(4000)
          , @v_date_client_req varchar(8)
          , @v_log_table varchar(6)

    -- set up cursor 
    DECLARE csr_obj cursor local for
        SELECT top 300
               convert(varchar, date_client_req, 112) AS date_client_req 
        FROM   ata_mmt_tran WITH(NOLOCK)
        WHERE  ata_id = @p_ata_id
        AND    date_client_req < getdate() - 3
        AND    msg_status <> '3'
        GROUP BY convert(varchar, date_client_req, 112)

    open csr_obj
    FETCH next FROM csr_obj into @v_date_client_req

    while (@@fetch_status = 0)
    begin
    SET @v_log_table = substring(@v_date_client_req, 1, 6)

    SELECT TOP 50000 
           mt_pr
         , mt_refkey
         , priority
         , date_client_req
         , subject
         , content
         , callback
         , msg_status
         , recipient_num
         , date_mt_sent
         , date_rslt
         , date_mt_report
         , report_code
         , rs_id
         , country_code
         , msg_type
         , crypto_yn
         , ata_id
         , reg_date
         , sender_key
         , template_code
         , response_method
         , ad_flag
         , kko_btn_type
         , kko_btn_info
		 , img_url
         , img_link
         , etc_text_1
         , etc_text_2
         , etc_text_3
         , etc_num_1
         , etc_num_2
         , etc_num_3
         , etc_date_1
    INTO   #ata_mmt_log_temp_past
    FROM   ata_mmt_tran WITH(NOLOCK) 
    WHERE  ata_id = @p_ata_id
    AND    convert(varchar, date_client_req, 112) = @v_date_client_req
    AND    msg_status <> '3'
    
    SELECT  @dsql = '
        INSERT ata_mmt_log_'+@v_log_table+' 
               SELECT temp.mt_pr
                    , temp.mt_refkey
                    , temp.priority
                    , temp.msg_class
                    , temp.date_client_req
                    , temp.subject
                    , temp.content
                    , temp.callback
                    , temp.msg_status
                    , temp.recipient_num
                    , temp.date_mt_sent
                    , temp.date_rslt
                    , temp.date_mt_report
                    , temp.report_code
                    , temp.rs_id
                    , temp.country_code
                    , temp.msg_type
                    , temp.crypto_yn
                    , temp.ata_id
                    , temp.reg_date
                    , getdate()
                    , temp.sender_key
                    , temp.template_code
                    , temp.response_method
                    , temp.ad_flag
                    , temp.kko_btn_type
                    , temp.kko_btn_info
					, temp.img_url
                    , temp.img_link
                    , temp.etc_text_1
                    , temp.etc_text_2
                    , temp.etc_text_3
                    , temp.etc_num_1
                    , temp.etc_num_2
                    , temp.etc_num_3
                    , temp.etc_date_1
               FROM   #ata_mmt_log_temp_past temp WITH(NOLOCK) 
               WHERE NOT EXISTS( SELECT A.mt_pr FROM ata_mmt_log_'+@v_log_table+'  A WHERE A.mt_pr = temp.mt_pr) '

    EXEC sp_mmt_log_create @v_log_table

    BEGIN TRAN

    EXEC sp_executesql @dsql

    if @@error != 0
    begin
        rollback tran
        close csr_obj
        deallocate csr_obj
        return
    end

    DELETE ata_mmt_tran FROM ata_mmt_tran A, #ata_mmt_log_temp_past B
    WHERE A.mt_pr = B.mt_pr

    if @@error != 0
    begin
        rollback tran
        close csr_obj
        deallocate csr_obj
        return
    end

    COMMIT TRAN

    DROP TABLE #ata_mmt_log_temp_past

        fetch next from csr_obj into @v_date_client_req

    end

    close csr_obj
    deallocate csr_obj

RETURN
GO
