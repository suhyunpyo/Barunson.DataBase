IF OBJECT_ID (N'dbo.proc_CloseCopy', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_CloseCopy
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     Procedure [dbo].[proc_CloseCopy]
@order_seq int
as
begin
	DECLARE @i int,@del_id int,@del_method varchar(1),@zipcode char(6),@addr varchar(100),@del_code varchar(12)
	Declare @id as bigint,@rslt as tinyint
	set @rslt = 1

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




	DECLARE item_cursor CURSOR FOR 
	select A.id,A.delivery_method,A.addr,B.ZIP_NO AS ZIPCODE from delivery_info A left outer join CJ_ZIPCODE B on A.zip = B.ZIP_NO where order_seq = @order_seq and (delivery_code_num is null or delivery_code_num='')
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @del_id,@del_method,@addr,@zipcode
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if @del_method = '1'
		begin
			--우편번호가 잘못되었는지 확인한다.
			begin
					
				--새로운 송장코드 하나 가져와서 배송정보에 셋팅한다.
				select top 1 @id = codeseq,@del_code = code from CJ_DELCODE where isUse='0' order by codeseq
				update CJ_DELCODE set isUse='1' where codeseq = @id
				update delivery_info set delivery_com = @DELIVERY_COMPANY_SHORT_NAME, delivery_code_num = @del_code where ID=@del_id
				insert into DELIVERY_INFO_DELCODE(order_seq,delivery_id,delivery_code_num,delivery_com) values(@order_seq,@del_id,@del_code, @DELIVERY_COMPANY_SHORT_NAME)
			end
		end
		else if @del_method <> '4'
		begin
			update DELIVERY_INFO set DELIVERY_COM='00',DELIVERY_CODE_NUM='' where ID=@del_id
		end
		FETCH NEXT FROM item_cursor  INTO @del_id,@del_method,@addr,@zipcode

	END			-- end of while

	CLOSE item_cursor
	DEALLOCATE item_cursor
	
	--마감시간 반영
	if @rslt = 1
	update custom_order set src_CloseCopy_date=GETDATE() where order_seq=@order_seq
	
	select @rslt
END
GO
