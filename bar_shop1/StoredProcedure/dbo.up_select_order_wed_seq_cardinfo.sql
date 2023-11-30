IF OBJECT_ID (N'dbo.up_select_order_wed_seq_cardinfo', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_order_wed_seq_cardinfo
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  김덕중        
-- Create date: 2014-04-29        
-- Description: 청첩장 오더1 프로세스1        
--up_select_order_wed_seq_cardinfo '5007','33527'        
-- =============================================        
CREATE PROCEDURE [dbo].[up_select_order_wed_seq_cardinfo]        
 -- Add the parameters for the stored procedure here        
 @company_seq AS int,        
 @card_seq   AS int        
AS        
BEGIN        
 -- SET NOCOUNT ON added to prevent extra result sets from        
 -- interfering with SELECT statements.        
    SET NOCOUNT ON;        
    SELECT      CARD_CODE    
        ,       CARD_NAME    
        ,       CARD_IMAGE    
        ,       CARDSET_PRICE    
        ,       ISJUMUN    
        ,       ENV_SEQ    
        ,       ENV_GROUPSEQ    
        ,       ACC1_SEQ    
        ,       ACC1_GROUPSEQ    
        ,       LINING_SEQ,LINING_GROUPSEQ    
        ,       UNIT_COUNT    
        ,       MINIMUM_COUNT    
        ,       ISNULL(ISDIGITALCOLOR,'0') AS ISDIGITALCOLOR    
        ,       DIGITALCOLOR    
        ,       D.ISENVSPECIAL    
        ,       ISEMBO AS CARD_EMBO    
        ,       ISEMBOCOLOR AS CARD_EMBOCOLOR    
        ,       ISUSRIMG1    
        ,       ISUSRIMG2    
        ,       ISUSRIMG3    
        ,       ISUSRCOMMENT    
        ,       D.ISCUSTOMDCOLOR    
        ,       D.ISINTERNALDIGITAL    
        ,       ISLINITIAL    
        ,       ISOUTSIDEINITIAL    
        ,       D.ISSELFEDITOR    
        ,       D.ISDIGITALCOLOR    
        ,       D.DIGITALCOLOR    
        ,       D.ISENVSPECIAL    
        ,       D.PRINTMETHOD    
        ,       ISNULL(OPTION_IMG1,'') AS OPTION_IMG1    
        ,       ISNULL(OPTION_IMG2,'') AS OPTION_IMG2    
        ,       D.ISCOLORINPAPER    
        ,       D.ISFCHOICE    
        ,       D.ISADD    
        ,       ISUSRIMG_INFO    
        ,       ISNULL(D.ISFONTTYPE,'A,B,C') ISFONTTYPE    
        ,       ISUSRIMG4    
        ,       ISLANGUAGE    
        ,       ISLASER    
        ,       ISNULL(D.ISJIGUNAMU, '0') AS ISJIGUNAMU    
        ,       ISNULL(D.ISWONGOYN, '0') AS ISWONGOYN    
        ,       ISNULL(D.ISGROOMBRIDEYN, '0') AS ISGROOMBRIDEYN    
        ,       ISNULL(D.ISENGWEDDING, '0') AS ISENGWEDDING    
        ,       ISNULL(D.ISHONEYMOON, '0') AS ISHONEYMOON    
        ,       ISNULL(D.isEnvSpecialPrint, '0') AS isEnvSpecialPrint   /* 디자인봉투 */    
        ,       ISNULL(D.isEnvDesignType, '') AS isEnvDesignType        /* 디자인봉투 */    
        ,       ISNULL(D.isGreeting, '') AS isGreeting        /* 식순지 인사말 */    
        ,       ISNULL(D.isPhrase, '') AS isPhrase        /* 식순지 인사말 */    
        , 		isnull(A.sealingsticker_seq, 0) sealingsticker_seq	/* 실링스티커 기본번호 */
        , 		isnull(A.sealingsticker_groupseq, 0) sealingsticker_groupseq	/* 실링스티커 그룹번호*/
    FROM        S2_CARDSALESSITE A WITH(NOLOCK)        
    INNER JOIN  S2_CARD B  WITH(NOLOCK) ON A.CARD_SEQ = B.CARD_SEQ         
    INNER JOIN  S2_CARDDETAIL C  WITH(NOLOCK) ON A.CARD_SEQ = C.CARD_SEQ        
    INNER JOIN  S2_CARDOPTION D  WITH(NOLOCK) ON A.CARD_SEQ = D.CARD_SEQ        
    WHERE       A.CARD_SEQ = @CARD_SEQ     
    AND         A.COMPANY_SEQ=@COMPANY_SEQ         
    
END
GO
