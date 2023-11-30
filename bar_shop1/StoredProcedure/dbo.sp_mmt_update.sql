IF OBJECT_ID (N'dbo.sp_mmt_update', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_mmt_update
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_mmt_update]
    @p_table_divi             char(1)
  , @p_update_all_yn          char(1)
  , @p_mt_pr                  int
  , @p_mt_seq                 int
  , @p_msg_status             char(1)
  , @p_mt_report_code_ib      char(4)
  , @p_mt_report_code_ibtype  char(1)
AS

    DECLARE @dsql nvarchar(1000)
    DECLARE @v_params as nvarchar(200)

    SET @dsql = ' UPDATE ata_mmt_tran SET  '
 
    SET @dsql = @dsql + '
        msg_status            = @pp_msg_status,
        report_code     = @pp_mt_report_code_ib,
        date_mt_sent = getdate() '

    IF @p_msg_status = '3'
        SET @dsql = @dsql + ' , date_rslt  = getdate() '

    SET @dsql = @dsql + ' WHERE mt_pr  = @pp_mt_pr '

    
    SET @v_params = '@pp_msg_status char(1)
      , @pp_mt_report_code_ib char(4)
      , @pp_mt_pr int'

    EXECUTE sp_executesql @dsql, @v_params
                        , @pp_msg_status            = @p_msg_status
                        , @pp_mt_report_code_ib     = @p_mt_report_code_ib
                        , @pp_mt_pr                 = @p_mt_pr

RETURN
GO
