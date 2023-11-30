IF OBJECT_ID (N'dbo.sp_mmt_tran_rslt_update', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_mmt_tran_rslt_update
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_mmt_tran_rslt_update]
    @p_mt_report_code_ib        char(4)
  , @p_mt_report_code_ibtype    char(1)
  , @p_rs_id                    varchar(20)
  , @p_client_msg_key           int
  , @p_recipient_order          int
  , @p_carrier                  int
  , @p_date_rslt                datetime
  , @p_mt_res_cnt               int
AS

    UPDATE ata_mmt_tran
    SET    msg_status              = '3'
         , date_rslt               = @p_date_rslt
         , date_mt_report          = getdate()
         , report_code             = @p_mt_report_code_ib
         , rs_id                   = @p_rs_id
    WHERE mt_pr = @p_client_msg_key

RETURN
GO
