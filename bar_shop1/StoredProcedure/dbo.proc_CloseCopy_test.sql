IF OBJECT_ID (N'dbo.proc_CloseCopy_test', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_CloseCopy_test
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     Procedure [dbo].[proc_CloseCopy_test]
@order_seq int
as
begin
	DECLARE @i int,@del_id int,@del_method varchar(1),@zipcode char(6),@addr varchar(100),@del_code varchar(12)
	Declare @id as bigint,@rslt as tinyint
	set @rslt = 1

	DECLARE item_cursor CURSOR FOR 
	select A.id,A.delivery_method,A.addr,B.zipcode from delivery_info A left outer join hanjin_zipcode B on A.zip = B.zipcode where order_seq = @order_seq and (delivery_code_num is null or delivery_code_num='')
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @del_id,@del_method,@addr,@zipcode
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if @del_method = '1'
		begin
			--우편번호가 잘못되었는지 확인한다.
			if @zipcode is null
			begin
				set @rslt = 0
				break				
			end
			else if @addr='' 
			begin
				set @rslt = 0
				break				
			end
			else
			begin
					
				--새로운 송장코드 하나 가져와서 배송정보에 셋팅한다.
				select top 1 @id = codeseq,@del_code = code from CJ_DELCODE where isUse='0' order by codeseq
				update delivery_info set delivery_com='HJ',delivery_code_num = @del_code where ID=@del_id

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
	--if @rslt = 1
	--begin
	--update custom_order set src_CloseCopy_date=GETDATE() where order_seq=@order_seq
	--end
	
	select @rslt
	
END
GO
