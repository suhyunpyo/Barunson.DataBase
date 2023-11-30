IF OBJECT_ID (N'dbo.proc_CloseSample', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_CloseSample
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE        Procedure [dbo].[proc_CloseSample]
@order_seq int
as
begin

	DECLARE @del_code varchar(12),@id bigint
	--새로운 송장코드 하나 가져와서 배송정보에 셋팅한다.

    DECLARE @DELIVERY_COMPANY_SHORT_NAME AS VARCHAR(10)
    SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'

    /* 2015-08-03 이후 CJ택배로 변경 */
    IF GETDATE() >= '2015-08-03 00:00:00'
        BEGIN
            
            SET @DELIVERY_COMPANY_SHORT_NAME = 'CJ'

        END
    ELSE
        BEGIN
            
            SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'

        END

	
	update CJ_DELCODE
	   set isUse='1' 
		 , @id = A.codeseq
		 , @del_code = A.code
	 from CJ_DELCODE A
	WHERE codeseq IN ( select top 1 codeseq from CJ_DELCODE  where isUse='0' order by codeseq )
	
	update custom_sample_order set delivery_com=@DELIVERY_COMPANY_SHORT_NAME,delivery_code_num = @del_code,STATUS_SEQ=10,PREPARE_DATE=GETDATE() where sample_order_seq = @order_seq

end
GO
