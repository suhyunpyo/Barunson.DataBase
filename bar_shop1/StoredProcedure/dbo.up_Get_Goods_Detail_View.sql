IF OBJECT_ID (N'dbo.up_Get_Goods_Detail_View', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Get_Goods_Detail_View
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
-- =============================================    
-- Author:  조창연    
-- Create date: 2014-11-10    
-- Description: 비핸즈 제품 상세 정보    
    
-- =============================================    
CREATE PROCEDURE [dbo].[up_Get_Goods_Detail_View]    
 -- Add the parameters for the stored procedure here    
    
 -- 제품 상세 정보 --    
    
 @card_seq INT, --= 33499    
 @company_seq INT --= 5007     
    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
     
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
     
 SET NOCOUNT ON;    
     
  
 SELECT     
 A.carddiscount_seq --0    
 ,A.isdisplay  --1     
 ,A.isjumun   --2     
 ,A.isnew   --3    
 ,A.isbest   --4    
 ,A.isextra   --5    
 ,A.isextra2   --6    
 ,B.cardbrand  --7    
 ,B.card_code  --8    
 ,B.card_name  --9    
 ,B.cardset_price --10     
 ,B.card_price  --11    
 ,F.cardkind_seq  --12    
 ,C.env_seq   --13    
 ,C.inpaper_seq  --14    
 ,C.acc1_seq   --15    
 ,C.acc2_seq   --16    
 ,C.mapcard_seq  --17    
 ,C.greetingcard_seq --18    
 ,C.lining_seq  --19    
 ,C.env_groupseq  --20    
 ,C.inpaper_groupseq --21    
 ,C.acc1_groupseq --22     
 ,C.acc2_groupseq --23     
 ,C.mapcard_groupseq --24    
 ,C.greetingcard_groupseq --25    
 ,C.lining_groupseq --26    
 ,ISNULL(C.card_text, '') AS card_text  --27    
 ,ISNULL(C.card_content, '' ) AS card_content  --28    
 ,C.card_keyword  --29    
 ,C.minimum_count --30     
 ,C.unit_count  --31    
 ,D.isquick   --32    
 ,D.issample   --33    
 ,D.isUsrImg1  --34    
 ,D.isOutSideInitial --35    
 ,D.isdigitalcolor --36    
 ,D.isCustomDColor --37    
 ,ISNULL(D.digitalcolor, '') AS digitalcolor --38    
 ,D.isEnvSpecial  --39    
 ,D.IsInPaper   --40    
 ,D.IsHandmade   --41    
 ,D.IsJaebon   --42    
 ,D.IsEmbo    --43    
 ,D.IsEnvInsert  --44     
 ,D.isDesigner  --45    
 ,D.isLanguage  --46    
 ,D.isLaser   --47    
 ,ISNULL(D.isNewEvent, '0') AS isNewEvent --48    
 ,ISNULL(D.isRepinart, '0') AS isRepinart  --49    
 ,ISNULL(D.isHappyPrice, '0') AS isHappyPrice --50    
 ,ISNULL(D.isSpringYN, '0') AS isSpringYN --51    
 ,ISNULL(D.isNewGubun, '0') AS isNewGubun --52    
 , ISNULL((select CardImage_FileName from s2_cardimage where card_seq = @card_seq AND Company_Seq = 5007 and UPPER(CardImage_FileName) = UPPER(b.Card_Code+'_img.jpg') ), '') AS CardImage_FileName --53  
 ,d.isEnvSpecialPrint -- 53
 ,isnull(a.SealingSticker_seq,0) SealingS_seq  --54 실링스터커 카드코드 
 ,isnull(a.SealingSticker_GroupSeq,0) SealingS_GroupSeq  --55 실링스티커그룹코드
 FROM s2_cardsalessite A     
 INNER JOIN s2_card B ON A.card_seq = B.card_seq     
 INNER JOIN s2_carddetail C ON A.card_seq = C.card_seq     
 INNER JOIN s2_cardoption D ON A.card_seq = D.card_seq     
 INNER JOIN S2_CardKind F ON A.card_seq = F.card_seq     
 WHERE A.card_seq = @card_seq     
 AND A.company_seq = @company_seq    
  
    
END 
GO
