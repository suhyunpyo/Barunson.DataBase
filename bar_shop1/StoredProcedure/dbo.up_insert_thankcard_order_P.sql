IF OBJECT_ID (N'dbo.up_insert_thankcard_order_P', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_thankcard_order_P
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-22
-- Description:	답례장 주문 1단계 정보 저장/수정 
-- up_insert_thankcard_order_P

-- =============================================
CREATE PROCEDURE [dbo].[up_insert_thankcard_order_P]
	
	@order_seq int,
	@print_type varchar(1),
	@card_seq int,
	@title varchar(50),
	@print_count int,
	@etc_comment varchar(1000),
	@order_filename varchar(100),
	@isNotPrint varchar(1),
	@isNotPrint_Addr varchar(1),
	@env_zip varchar(6),
	@env_addr varchar(300),
	@env_addr_detail varchar(200),
	@env_hphone varchar(30),
	@env_hphone2 varchar(30),
	@env_person1 varchar(50),
	@env_person2 varchar(50),
	@env_person_tail varchar(10),
	@env_person1_tail varchar(50),
	@env_person2_tail varchar(50),
	@isZipBox varchar(1),
	@recv_tail varchar(10),
	@isPostMark varchar(1),
	@postname varchar(50),
	@postname_tail varchar(15),
	@isBasic varchar(1),
	@save_type	varchar(1)
	
AS
BEGIN


	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	BEGIN TRAN
		
		/*
		IF @save_type = 'U' BEGIN
			DELETE FROM Custom_Order_Plist WHERE order_seq = @order_seq
		END
		*/
			
		INSERT INTO Custom_Order_Plist 
		(
			order_seq, isFPrint, print_type, card_seq, title, print_count, etc_comment, order_filename, isNotPrint, env_zip, env_addr, env_addr_detail, 
			env_hphone, env_hphone2, env_person1, env_person2, env_person_tail, env_person1_tail, env_person2_tail, isZipBox, recv_tail, 
			isPostMark, postname, postname_tail, isBasic, reg_date, isNotPrint_Addr 
		) 
		VALUES 
		(
			@order_seq, 0, @print_type, @card_seq, @title, @print_count, @etc_comment, @order_filename, @isNotPrint, @env_zip, @env_addr, @env_addr_detail,
			@env_hphone, @env_hphone2, @env_person1, @env_person2, @env_person_tail, @env_person1_tail, @env_person2_tail, @isZipBox, @recv_tail, 
			@isPostMark, @postname, @postname_tail, @isBasic, GETDATE(), @isNotPrint_Addr
		)
	
	--SET @result_cnt = @@ROWCOUNT	-- 변경된 rowcount
	--SET @result_code = @@Error	-- 에러발생 cnt
	
	IF (@@Error <> 0) GOTO PROBLEM
	COMMIT TRAN

	PROBLEM:
	IF (@@Error <> 0) BEGIN
		ROLLBACK TRAN
	END


END

/*
select * from Custom_Order_Plist
where  print_type = 'E'
and title = '백봉투'
order by 
*/
GO
