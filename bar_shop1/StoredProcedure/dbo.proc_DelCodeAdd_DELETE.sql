IF OBJECT_ID (N'dbo.proc_DelCodeAdd_DELETE', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_DelCodeAdd_DELETE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE           Procedure [dbo].[proc_DelCodeAdd_DELETE]
@order_seq int,
@del_id int,
@addnum int
--,@rslt tinyint output
as
begin
	DECLARE @i int,@del_code varchar(12),@id bigint

    DECLARE @DELIVERY_COMPANY_SHORT_NAME AS VARCHAR(10)

	DECLARE @returnValue INT	--0:성공


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


	set @i = 0
	while @i < @addnum
	begin
		-----------------------------------------------------------------------------------------------
		--select top 1 @id = codeseq,@del_code = code from CJ_DELCODE where isUse='0' order by codeseq


		--update	CJ_DELCODE 
		--set		isUse='1' 
		--	,	@id = codeseq
		--	,	@del_code = code
		--where	1 = 1
		--AND		codeseq IN (select top 1 codeseq from CJ_DELCODE where isUse='0' order by codeseq)
		
		--insert into DELIVERY_INFO_DELCODE (order_seq,delivery_id,delivery_code_num,delivery_com) 
		--values (@order_seq,@del_id,@del_code, @DELIVERY_COMPANY_SHORT_NAME)
		----update CJ_DELCODE set isUse='1' where codeseq = @id
		

			EXEC [dbo].[SP_CJ_DELEVERY] 'DELIVERY_INFO_DELCODE|', @order_seq, @del_id, @DELIVERY_COMPANY_SHORT_NAME, @DEL_CODE OUTPUT

		set @i = @i + 1
	END			-- end of while

END

GO
