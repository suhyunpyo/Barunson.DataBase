IF OBJECT_ID (N'dbo.proc_InsPList_Digital', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_InsPList_Digital
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : proc_InsPList_Digital
-- Author        : 박혜림
-- Create date   : 2022-07-27
-- Description   : 디지털카드 인쇄판 정보 저장
-- Update History:
-- Comment       : 원주문, 추가주문
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[proc_InsPList_Digital]
      @TYPE         CHAR(1)		-- 구분(I:등록, M:수정)
	, @PID          BIGINT
	, @ORDER_SEQ    INT
	, @TITLE        VARCHAR(50)	-- 인쇄판명
	, @CARD_SEQ     INT
	, @PTYPE        CHAR(1)
	, @ISBASIC      CHAR(1)
	, @PCOUNT       INT
	, @ISNOTPRINT   CHAR(1)
	, @CONT_DIFF    VARCHAR(6)
	, @ETC_COMMENT1	VARCHAR(200)
	, @ETC_COMMENT2	VARCHAR(200)
	, @ETC_COMMENT3	VARCHAR(500)
	, @ETC_FILE     VARCHAR(100)
	, @ISFPRINT_YN  CHAR(1)		-- 겉면 유무
-----------------------------------------------------------------------------------------------------------------------      
    , @ErrNum   INT           OUTPUT
    , @ErrSev   INT           OUTPUT
    , @ErrState INT           OUTPUT
    , @ErrProc  VARCHAR(50)   OUTPUT
    , @ErrLine  INT           OUTPUT
    , @ErrMsg   VARCHAR(2000) OUTPUT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

-----------------------------------------------------------------------------------------------------------------------
-- Declare Block
-----------------------------------------------------------------------------------------------------------------------
DECLARE @TITLE_FRONT VARCHAR(50)

SET @TITLE_FRONT = ''

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			--IF @TITLE = '카드기본인쇄'
			--	SET @TITLE_FRONT = @TITLE + ' 겉면'
			--ELSE IF @TITLE = '카드내지인쇄'
			--	SET @TITLE_FRONT = @TITLE + ' 뒷면'
			--ELSE
				SET @TITLE_FRONT = @TITLE + ' 겉면'
			

			IF @TYPE = 'I' AND @PID = 0
			BEGIN
				INSERT INTO bar_shop1.dbo.custom_order_plist
			            ( order_seq
						, title
						, card_seq
						, print_type
						, print_count
						, isFPrint
						, isNotPrint
						, env_zip
						, env_addr
						, env_addr_detail
						, etc_comment
						, order_filename
						, isBasic
						)
				 VALUES ( @ORDER_SEQ
				        , @TITLE
						, @CARD_SEQ
						, @PTYPE
						, @PCOUNT
						, '0'
						, @ISNOTPRINT
						, @CONT_DIFF
						, @ETC_COMMENT1
						, @ETC_COMMENT2
						, @ETC_COMMENT3
						, @ETC_FILE
						, @ISBASIC
					)
		
				-----------------------------------------------------
				-- PID 조회
				-----------------------------------------------------
				SET @PID = @@identity

				SELECT @PID


				IF @ISFPRINT_YN = 'Y'
				BEGIN

					INSERT INTO bar_shop1.dbo.custom_order_plist
							( order_seq
							, title
							, card_seq
							, print_type
							, print_count
							, isFPrint
							, isNotPrint
							, env_zip
							, env_addr
							, env_addr_detail
							, etc_comment
							, order_filename
							, isBasic
							)
					 VALUES ( @ORDER_SEQ
							, @TITLE_FRONT
							, @CARD_SEQ
							, @PTYPE
							, @PCOUNT
							, '1'
							, @ISNOTPRINT
							, ''
							, ''
							, ''
							, ''
							, ''
							, '0'
						)
				END
			END
			ELSE
			BEGIN

				-----------------------------------------------------
				-- PID 조회
				-----------------------------------------------------
				SELECT @PID

				UPDATE bar_shop1.dbo.custom_order_plist
				   SET print_count     = @PCOUNT
				     , isNotPrint      = @ISNOTPRINT
				     , env_zip         = @CONT_DIFF
					 , env_addr        = @ETC_COMMENT1
					 , env_addr_detail = @ETC_COMMENT2
					 , etc_comment     = @ETC_COMMENT3
					 , order_filename  = @ETC_FILE
				WHERE order_seq = @ORDER_SEQ
				  AND id = @PID

				UPDATE bar_shop1.dbo.custom_order_plist
				   SET print_count = @PCOUNT
					 , isNotPrint  = @ISNOTPRINT
				 WHERE order_seq = @ORDER_SEQ
				   AND title = @TITLE_FRONT

			END
			
		COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		 BEGIN
		     ROLLBACK TRAN
        END	

		SELECT  @ErrNum   = ERROR_NUMBER()
			  , @ErrSev   = ERROR_SEVERITY()
			  , @ErrState = ERROR_STATE()
			  , @ErrProc  = ERROR_PROCEDURE()
			  , @ErrLine  = ERROR_LINE()
			  , @ErrMsg   = ERROR_MESSAGE();

	END CATCH

END

-- Execute Sample
/*

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)

EXEC bar_shop1.dbo.proc_InsPList_Digital
       'I'
	 , 0
     , 4188152
	 , '카드기본인쇄'				
	 , 0
	 , ''
	 , ''
	 , 0
	 , ''
	 , ''
	 , ''
	 , ''
	 , ''
	 , ''
	 , ''
	 , 'N'
	 , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
