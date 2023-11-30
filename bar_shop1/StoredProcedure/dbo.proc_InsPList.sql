IF OBJECT_ID (N'dbo.proc_InsPList', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_InsPList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     Procedure [dbo].[proc_InsPList]	
	@order_seq int,	
	@title varchar(50),	
	@card_seq int,	
	@ptype char(1),	
	@isBasic char(1),	
	@pcount int,	
	@isFPrint char(1),	
	@isNotPrint char(1),	
	@cont_diff	varchar(6),
	@etc_comment1	varchar(200),
	@etc_comment2	varchar(200),
	@etc_comment3	varchar(500),
	@etc_file	varchar(100),
	@pid int output	
	as	
	begin	
		
		insert into custom_order_plist(order_seq,title,card_seq,print_type,print_count,isFPrint,isNotPrint,env_zip,env_addr,env_addr_detail,etc_comment,order_filename,isBasic) 
		values(@order_seq,@title,@card_seq,@ptype,@pcount,@isFPrint,@isNotPrint,@cont_diff,@etc_comment1,@etc_comment2,@etc_comment3,@etc_file,@isBasic)
		set @pid = @@identity
	END	
GO
