IF OBJECT_ID (N'dbo.proc_DelCodeAdd2', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_DelCodeAdd2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO







CREATE    Procedure [dbo].[proc_DelCodeAdd2]
@order_seq int,
@del_seq int,
@del_code varchar(15) output
as
begin
	DECLARE @i int,@del_id int,@id bigint,@ispacking char(1)

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


	-----------------------------------------------------------------------------------------------
	select @del_id = ID,@ispacking = case when packing_date is null then '0' else '1' end
	from DELIVERY_INFO
	where ORDER_SEQ=@order_seq 
	and DELIVERY_SEQ=@del_seq
	
	if @ispacking='1'
	begin	
		select top 1 @id = codeseq,@del_code = code from CJ_DELCODE where isUse='0' order by codeseq
		insert into DELIVERY_INFO_DELCODE(order_seq,delivery_id,delivery_code_num,delivery_com) values(@order_seq,@del_id,@del_code, @DELIVERY_COMPANY_SHORT_NAME)
		update CJ_DELCODE set isUse='1' where codeseq = @id
	end
	else
	begin
		set @del_code=''
		select @del_code
	end

END
GO
