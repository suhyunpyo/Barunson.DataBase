IF OBJECT_ID (N'dbo.BRANCH_INITIAL_CREATE_FAQ', N'P') IS NOT NULL DROP PROCEDURE dbo.BRANCH_INITIAL_CREATE_FAQ
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	작성정보   : [2005-09-26] 	
	내용	   : 대리점사이트 추가로 인한 초기작업 - FAQ 생성 - 최초한번!
	수정정보   : 
*/
CREATE PROCEDURE [dbo].[BRANCH_INITIAL_CREATE_FAQ]
	@company_seq	INT
AS
	DECLARE @seq INT
    DECLARE @display_order  smallint
    DECLARE @name varchar(50)
    DECLARE @title	varchar(100)
    DECLARE @contents varchar(2000) 
    DECLARE @div tinyint
    DECLARE @sales_gubun char(1)
    DECLARE @mdate smalldatetime

    DECLARE Cur_Product_Master CURSOR 
    FOR
        SELECT	[seq], [display_order], [name], [title], [contents], [div], [sales_gubun], [mdate]
        FROM		WEDD_FAQ    
        where company_seq = 200
    OPEN Cur_Product_Master

    FETCH NEXT FROM Cur_Product_Master INTO @seq, @display_order, @name, @title, @contents, @div, @sales_gubun, @mdate

    WHILE @@FETCH_STATUS = 0
    BEGIN       
        insert into WEDD_FAQ ([display_order], [name], [title], [contents], [div], [sales_gubun], [mdate], [COMPANY_SEQ])
        values (@display_order, @name, @title, @contents, @div, @sales_gubun, @mdate, @company_seq )

        FETCH NEXT FROM Cur_Product_Master INTO @seq, @display_order, @name, @title, @contents, @div, @sales_gubun, @mdate
    END

    CLOSE Cur_Product_Master
    DEALLOCATE Cur_Product_Master
GO
