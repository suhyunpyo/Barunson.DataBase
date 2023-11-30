IF OBJECT_ID (N'dbo.proc_AddPList_Digital', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_AddPList_Digital
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : proc_AddPList_Digital
-- Author        : 박혜림
-- Create date   : 2022-08-10
-- Description   : 디지털카드 인쇄판 추가주문
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[proc_AddPList_Digital]
      @TYPE         CHAR(1)		-- 구분(I:등록, D:삭제)
	, @PID          BIGINT
	, @ORDER_SEQ    INT
	, @PCOUNT       INT
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
DECLARE @TITLE VARCHAR(50)
      , @TITLE_FRONT VARCHAR(50)
	  , @PRE_ORDER_SEQ INT

SET @TITLE = ''
SET @TITLE_FRONT = ''
SET @PRE_ORDER_SEQ = 0

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			SELECT @PRE_ORDER_SEQ = order_seq
			     , @TITLE = title
			  FROM bar_shop1.dbo.custom_order_plist
			 WHERE id = @PID


			IF @TITLE = '카드기본인쇄'
				SET @TITLE_FRONT = @TITLE + ' 겉면'
			ELSE IF @TITLE = '카드내지인쇄'
				SET @TITLE_FRONT = @TITLE + ' 뒷면'
			ELSE
				SET @TITLE_FRONT = @TITLE + ' 겉면'

			IF @TYPE = 'I'
				IF EXISTS(SELECT id FROM bar_shop1.dbo.custom_order_plist WHERE order_seq = @ORDER_SEQ AND up_id = @PID)
				BEGIN

					UPDATE bar_shop1.dbo.custom_order_plist
					   SET print_count = @PCOUNT
					 WHERE order_seq = @ORDER_SEQ
					   AND up_id = @PID

					-- 겉면 업데이트
					UPDATE bar_shop1.dbo.custom_order_plist
					   SET print_count = @PCOUNT
					 WHERE order_seq = @ORDER_SEQ
					   AND title = @TITLE_FRONT
					   AND up_id IS NOT NULL
					   AND up_id <> 0

				END
				ELSE
				BEGIN
					INSERT INTO bar_shop1.dbo.custom_order_plist
							( order_seq
							, isFPrint
							, print_type
							, card_seq
							, title
							, print_count
							, etc_comment
							, isNotSet
							, isNotPrint
							, env_zip
							, env_addr
							, env_addr_detail
							, env_phone
							, env_hphone
							, env_person1_header
							, env_person2_header
							, env_person1
							, env_person2
							, env_person_tail
							, isEnv_person_tail
							, env_person1_tail
							, env_person2_tail
							, isZipBox
							, recv_tail
							, isPostMark
							, postname
							, imgFolder
							, imgName
							, pstatus
							, up_id
							, EnvSpecialType
							)
					SELECT @ORDER_SEQ
							, isFPrint
							, print_type
							, card_seq
							, title
							, @PCOUNT
							, etc_comment
							, '0'
							, CASE WHEN isNotPrint IS NULL OR isNotPrint = '' THEN '0' ELSE isNotPrint END
							, env_zip
							, CASE WHEN env_addr IS NULL THEN '' ELSE env_addr END
							, CASE WHEN env_addr_detail IS NULL THEN '' ELSE env_addr_detail END
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, ''
							, imgFolder
							, imgName
							, 1
							, id
							, ''
						FROM bar_shop1.dbo.custom_order_plist
						WHERE id = @PID

					-- 겉면 등록
					IF EXISTS(SELECT id FROM bar_shop1.dbo.custom_order_plist WHERE order_seq = @PRE_ORDER_SEQ AND title = @TITLE_FRONT)
					BEGIN

						INSERT INTO bar_shop1.dbo.custom_order_plist
							 ( order_seq
							 , isFPrint
							 , print_type
							 , card_seq
							 , title
							 , print_count
							 , etc_comment
							 , isNotSet
							 , isNotPrint
							 , env_zip
							 , env_addr
							 , env_addr_detail
							 , env_phone
							 , env_hphone
							 , env_person1_header
							 , env_person2_header
							 , env_person1
							 , env_person2
							 , env_person_tail
							 , isEnv_person_tail
							 , env_person1_tail
							 , env_person2_tail
							 , isZipBox
							 , recv_tail
							 , isPostMark
							 , postname
							 , imgFolder
							 , imgName
							 , pstatus
							 , up_id
							 , EnvSpecialType
							 )
					    SELECT @ORDER_SEQ
						     , isFPrint
							 , print_type
							 , card_seq
							 , title
							 , @PCOUNT
							 , etc_comment
							 , '0'
							 , CASE WHEN isNotPrint IS NULL OR isNotPrint = '' THEN '0' ELSE isNotPrint END
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , ''
							 , imgFolder
							 , imgName
							 , 1
							 , id
							 , ''
						  FROM bar_shop1.dbo.custom_order_plist
						 WHERE order_seq = @PRE_ORDER_SEQ
						   AND title = @TITLE_FRONT

					END
				END

			ELSE	-- 인쇄판 삭제
			BEGIN

				DELETE FROM bar_shop1.dbo.custom_order_plist
				 WHERE order_seq = @ORDER_SEQ
				   AND up_id = @PID 

				DELETE FROM bar_shop1.dbo.custom_order_plist
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

EXEC bar_shop1.dbo.proc_AddPList_Digital
       'I'
	 , 11982079
	 , 4172896
	 , 100
	 , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
