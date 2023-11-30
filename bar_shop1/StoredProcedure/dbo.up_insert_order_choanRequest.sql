IF OBJECT_ID (N'dbo.up_insert_order_choanRequest', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_order_choanRequest
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2015-04-22
-- Description:	초안수정요청 등록
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_order_choanRequest]
	-- Add the parameters for the stored procedure here
	@order_seq				INT,
	@preview_seq_list		VARCHAR(200),
	@content_list			VARCHAR(8000),
	@upfile_list			VARCHAR(4000),
	@notify_email_yesorno	CHAR(1),
	@email					VARCHAR(128),
	@writer					VARCHAR(128),
	@writer_ip				VARCHAR(128),
	@result_code	int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	
	DECLARE @tbltmp1 TABLE(f_ord INT IDENTITY(1,1), f_seq INT);
	DECLARE @tbltmp2 TABLE(f_ord INT IDENTITY(1,1), f_content VARCHAR(1000));
	DECLARE @tbltmp3 TABLE(f_ord INT IDENTITY(1,1), f_upfile VARCHAR(250));

	DECLARE @xmlString1 xml;
	DECLARE @xmlString2 xml;
	DECLARE @xmlString3 xml;

	SET @xmlString1 = CAST('<X>'+REPLACE(@preview_seq_list, '/*ROW*/', '</X><X>')+'</X>' AS xml);
	SET @xmlString2 = CAST('<X>'+REPLACE(@content_list, '/*ROW*/', '</X><X>')+'</X>' AS xml);
	SET @xmlString3 = CAST('<X>'+REPLACE(@upfile_list, '/*ROW*/', '</X><X>')+'</X>' AS xml);
	
	insert @tbltmp1(f_seq) SELECT N.value('.', 'INT') FROM @xmlString1.nodes('X') AS T(N)
	insert @tbltmp2(f_content) SELECT N.value('.', 'VARCHAR(1000)') FROM @xmlString2.nodes('X') AS T(N)
	insert @tbltmp3(f_upfile) SELECT N.value('.', 'VARCHAR(250)') FROM @xmlString3.nodes('X') AS T(N)

	BEGIN TRAN

	-- 수정요청사항 등록
	INSERT INTO preview_opinion(order_seq,preview_seq,writer,writer_ip,email,notify_email_yesorno,title,content,file_path)
		SELECT @order_seq, A.f_seq, @writer, @writer_ip, @email, @notify_email_yesorno, D.title, B.f_content, C.f_upfile
		FROM 
			@tbltmp1 A INNER JOIN @tbltmp2 B ON A.f_ord=B.f_ord INNER JOIN @tbltmp3 C ON A.f_ord = C.f_ord
			INNER JOIN custom_order_plist D ON A.f_seq = D.id

	
	-- 판정보 수정요청 상태로 변경
	UPDATE custom_order_plist SET pstatus=2 WHERE id in (SELECT f_seq FROM @tbltmp1)


	-- 주문상태 변경
	UPDATE custom_order SET src_modRequest_date = GETDATE(), status_seq=6 WHERE order_seq = @order_seq


	
	SET @result_code = @@Error		--에러발생 cnt
	IF (@result_code <> 0) 
		BEGIN
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			COMMIT TRAN
		END 

	RETURN @result_code
END
GO
