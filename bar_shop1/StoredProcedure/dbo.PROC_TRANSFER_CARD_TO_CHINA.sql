IF OBJECT_ID (N'dbo.PROC_TRANSFER_CARD_TO_CHINA', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_TRANSFER_CARD_TO_CHINA
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 카드 등록 */
CREATE PROCEDURE [dbo].[PROC_TRANSFER_CARD_TO_CHINA] 
	@P_ORG_CARD_SEQ INT,
	@P_TGT_CARD_CODE VARCHAR(20),
	@P_TGT_ERP_CODE VARCHAR(20),
	@P_ADMIN_ID VARCHAR(20)

AS
BEGIN

declare 
	@T_TGT_CARD_SEQ INT,
	@T_RESULT INT = 1,
	@T_RESULT_MSG VARCHAR(100) = ''


BEGIN TRAN


/* 카드 등록 */
insert into S2_Card (
	CardBrand,
	Card_Code,
	Card_ERPCode,
	Card_Div,
	Card_Name,
	Card_Image,
	CardSet_Price,
	Card_Price,
	RegDate,
	Card_WSize,
	Card_HSize,
	Old_Code,
	t_env_code,
	t_inpaper_code,
	admin_id,
	new_code,
	CARD_GROUP,
	CardFactory_Price,
	REGIST_DATES,
	DISPLAY_YORN,
	DISPLAY_UPDATE_DATE,
	DISPLAY_UPDATE_UID,
	FPRINT_YORN,
	View_Discount_Percent,
	Cost_Price
)
SELECT 
	CardBrand,
	@P_TGT_CARD_CODE Card_Code,
	@P_TGT_ERP_CODE Card_ERPCode,
	Card_Div,
	Card_Name,
	@P_TGT_CARD_CODE+'_130.jpg' Card_Image,
	CardSet_Price,
	Card_Price,
	getdate() RegDate,
	Card_WSize,
	Card_HSize,
	@P_TGT_ERP_CODE Old_Code,
	t_env_code,
	t_inpaper_code,
	@P_ADMIN_ID admin_id,
	@P_TGT_CARD_CODE new_code,
	CARD_GROUP,
	CardFactory_Price,
	getdate() REGIST_DATES,
	DISPLAY_YORN,
	GETDATE() DISPLAY_UPDATE_DATE,
	@P_ADMIN_ID DISPLAY_UPDATE_UID,
	FPRINT_YORN,
	View_Discount_Percent,
	Cost_Price
from S2_Card
where CARD_SEQ = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(1)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0

SET @T_TGT_CARD_SEQ = (SELECT @@IDENTITY AS 'Identity')

/* 카드 상세 */
INSERT INTO S2_CardDetail (
	CARD_SEQ,
	ENV_SEQ,
	Env_GroupSeq,
	Inpaper_Seq,
	Inpaper_GroupSeq,
	Acc1_Seq,
	Acc1_GroupSeq,
	Acc2_Seq,
	Acc2_GroupSeq,
	MapCard_Seq,
	MapCard_GroupSeq,
	GreetingCard_Seq,
	GreetingCard_GroupSeq,
	Lining_Seq,
	Lining_GroupSeq,
	Card_Text,
	Card_Content,
	Card_Keyword,
	Card_Shape,
	Card_Folding,
	Card_PrintMethod,
	Card_Material,
	Card_PrintOffice,
	Minimum_Count,
	AddMinimum_count,
	Unit_Count,
	env_code,
	inpaper_code,
	ColorInpaper_seq,
	Acc_Type,
	Card_Text_Premier,
	seal_seq, 
	Sticker_seq,
	Sticker_GroupSeq,
	CuttingLineType,
	EnvCharge,
	Flower_seq,
	Flower_GroupSeq,
	SealingSticker_seq,
	SealingSticker_GroupSeq,
	EnvPrintMethod1,
	EnvPrintMethod2
)
SELECT 
	@T_TGT_CARD_SEQ CARD_SEQ,
	ENV_SEQ,
	Env_GroupSeq,
	Inpaper_Seq,
	Inpaper_GroupSeq,
	Acc1_Seq,
	Acc1_GroupSeq,
	Acc2_Seq,
	Acc2_GroupSeq,
	MapCard_Seq,
	MapCard_GroupSeq,
	GreetingCard_Seq,
	GreetingCard_GroupSeq,
	Lining_Seq,
	Lining_GroupSeq,
	Card_Text,
	Card_Content,
	Card_Keyword,
	Card_Shape,
	Card_Folding,
	Card_PrintMethod,
	Card_Material,
	Card_PrintOffice,
	Minimum_Count,
	AddMinimum_count,
	Unit_Count,
	env_code,
	inpaper_code,
	ColorInpaper_seq,
	Acc_Type,
	Card_Text_Premier,
	seal_seq, 
	Sticker_seq,
	Sticker_GroupSeq,
	CuttingLineType,
	EnvCharge,
	Flower_seq,
	Flower_GroupSeq,
	SealingSticker_seq,
	SealingSticker_GroupSeq,
	EnvPrintMethod1,
	EnvPrintMethod2
FROM S2_CardDetail
WHERE Card_Seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(2)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0

/* 카드 스타일 */
insert into S2_CardStyle (
	CardStyle_Seq,
	Card_Seq
)
select 
	CardStyle_Seq,
	@T_TGT_CARD_SEQ Card_Seq
from S2_CardStyle
where card_seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(3)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0


/* 카드 설정정보 */
insert into S2_CardOption (
Card_Seq,
    IsEmbo,
    IsEmboColor,
    embo_print,
    IsQuick,
    IsColorPrint,
    IsHandmade,
    IsHanji,
    IsInPaper,
    IsJaebon,
    IsLiningJaebon,
    IsEnvInsert,
    IsSample,
    IsOutsideInitial,
    PrintMethod,
    IsAdd,
    IsUsrImg1,
    IsUsrImg2,
    IsUsrImg3,
    IsUsrComment,
    IsSticker,
    IsSensInpaper,
    outsourcing_print,
    isSelfEditor,
    isDigitalColor,
    DigitalColor,
    isEnvSpecial,
    isDesigner,
    isTechnic,
    isLInitial,
    option_img1,
    option_img2,
    IsColorInpaper,
    IsFChoice,
    isCustomDColor,
    Master_2Color,
    isFonttype,
    isUsrImg_info,
    IsUsrImg4,
    isMoneyEnv,
    isLanguage,
    isLaser,
    isFSC,
    isJigunamu,
    isNewEvent,
    isRepinart,
    isHappyPrice,
    isWongoYN,
    isSpringYN,
    isStarcard,
    isLetterPress,
    isNewGubun,
    isGroomBrideYN,
    isMasterDigital,
    isInternalDigital,
    isLaserCard,
    isstickerspecial,
    isPutGiveCard,
    isEngWedding,
    isHoneyMoon,
    isCardOptionColor,
    isEnvSpecialPrint,
    isEnvDesignType,
    isColorOptionCards,
    isColorMaster,
    isMasterPrintColor,
    isGreeting,
    isPhrase,
    SpecialAccYN,
    IsSampleEnd,
    isMiniCard,
    IsHandmade2,
    isEnvPremium
)
select 
	@T_TGT_CARD_SEQ Card_Seq,
    IsEmbo,
    IsEmboColor,
    embo_print,
    IsQuick,
    IsColorPrint,
    IsHandmade,
    IsHanji,
    IsInPaper,
    IsJaebon,
    IsLiningJaebon,
    IsEnvInsert,
    IsSample,
    IsOutsideInitial,
    PrintMethod,
    IsAdd,
    IsUsrImg1,
    IsUsrImg2,
    IsUsrImg3,
    IsUsrComment,
    IsSticker,
    IsSensInpaper,
    outsourcing_print,
    isSelfEditor,
    isDigitalColor,
    DigitalColor,
    isEnvSpecial,
    isDesigner,
    isTechnic,
    isLInitial,
    option_img1,
    option_img2,
    IsColorInpaper,
    IsFChoice,
    isCustomDColor,
    Master_2Color,
    isFonttype,
    isUsrImg_info,
    IsUsrImg4,
    isMoneyEnv,
    isLanguage,
    isLaser,
    isFSC,
    isJigunamu,
    isNewEvent,
    isRepinart,
    isHappyPrice,
    isWongoYN,
    isSpringYN,
    isStarcard,
    isLetterPress,
    isNewGubun,
    isGroomBrideYN,
    isMasterDigital,
    isInternalDigital,
    isLaserCard,
    isstickerspecial,
    isPutGiveCard,
    isEngWedding,
    isHoneyMoon,
    isCardOptionColor,
    isEnvSpecialPrint,
    isEnvDesignType,
    isColorOptionCards,
    isColorMaster,
    isMasterPrintColor,
    isGreeting,
    isPhrase,
    SpecialAccYN,
    IsSampleEnd,
    isMiniCard,
    IsHandmade2,
    isEnvPremium
from S2_CardOption
WHERE Card_Seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(4)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0


/* 카드 인쇄 유형 */
insert into S2_CardKind (
	Card_Seq,
	CardKind_Seq
)
select 
	@T_TGT_CARD_SEQ Card_Seq,
	CardKind_Seq
from S2_CardKind
where Card_Seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(5)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0


/* 카드 전시 */
insert into S2_CardSalesSite (
    card_seq,
    Company_Seq,
    CardDiscount_Seq,
    IsDisplay,
    IsJumun,
    IsNew,
    IsBest,
    IsExtra,
    IsJehyu,
    Ranking,
    Ranking_w,
    Ranking_m,
    input_date,
    IsSale,
    SampRankNo,
    PostRankNo,
    ZzimRankNo,
    AppSample,
    isNotCoupon,
    IsExtra2,
    isRecommend,
    isSSPre,
    isSummary,
    isBgcolor,
    isDigitalCard,
    Display_Date,
    IsInProduct,
    MovieURL,
    DisplayLabel,
    Tip,
    sealingsticker_seq,
    sealingsticker_groupseq,
    ribbon_seq,
    ribbon_groupseq,
    papercover_seq,
    papercover_groupseq,
    Flower_seq,
    Flower_GroupSeq,
    pocket_seq,
    pocket_groupseq
)
select 
    @T_TGT_CARD_SEQ card_seq,
    Company_Seq,
    CardDiscount_Seq,
    0 IsDisplay,
    IsJumun,
    IsNew,
    IsBest,
    IsExtra,
    IsJehyu,
    Ranking,
    Ranking_w,
    Ranking_m,
    CONVERT(CHAR(10), getdate(), 23) input_date,
    IsSale,
    SampRankNo,
    PostRankNo,
    ZzimRankNo,
    AppSample,
    isNotCoupon,
    IsExtra2,
    isRecommend,
    isSSPre,
    isSummary,
    isBgcolor,
    isDigitalCard,
    Display_Date,
    IsInProduct,
    MovieURL,
    DisplayLabel,
    Tip,
    sealingsticker_seq,
    sealingsticker_groupseq,
    ribbon_seq,
    ribbon_groupseq,
    papercover_seq,
    papercover_groupseq,
    Flower_seq,
    Flower_GroupSeq,
    pocket_seq,
    pocket_groupseq
from S2_CardSalesSite
where card_seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(6)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0


/* 카드 이미지 */
insert into S2_CardImage (
    Card_Seq,
    CardImage_WSize,
    CardImage_HSize,
    CardImage_FileName,
    CardImage_Div,
    Company_Seq
)
select 
    @T_TGT_CARD_SEQ Card_Seq,
    CardImage_WSize,
    CardImage_HSize,
    CardImage_FileName,
    CardImage_Div,
    Company_Seq
from S2_CardImage
where card_seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(7)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0


insert into S2_UserCardView (
    session_id,
    card_seq,
    company_seq,
    cardkind_seq,
    site_div,
    reg_date
)
SELECT 
      session_id,
      @T_TGT_CARD_SEQ card_seq,
      company_seq,
      cardkind_seq,
      site_div,
      reg_date
FROM S2_UserCardView
where card_seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(8)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0

insert into S2_UserComment (
	sales_gubun,
    company_seq,
    card_seq,
    card_code,
    order_seq,
    uid,
    uname,
    title,
    comment,
    score,
    sym_cnt,
    isBest,
    isDP,
    best_year,
    best_month,
    best_week,
    reg_date,
    resch_color,
    resch_bright,
    upimg,
    comm_div,
    b_url,
    edit_date,
    EVENT_STATUS_CODE,
    device_type,
    resch_price
)
SELECT sales_gubun,
    company_seq,
    @T_TGT_CARD_SEQ card_seq,
    card_code,
    order_seq,
    uid,
    uname,
    title,
    comment,
    score,
    sym_cnt,
    isBest,
    isDP,
    best_year,
    best_month,
    best_week,
    reg_date,
    resch_color,
    resch_bright,
    upimg,
    comm_div,
    b_url,
    edit_date,
    EVENT_STATUS_CODE,
    device_type,
    resch_price
FROM S2_UserComment
where card_seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(9)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0

insert into S4_Event_Review (
	ER_Company_Seq,
    ER_Order_Seq,
    ER_Type,
    ER_Card_Seq,
    ER_Card_Code,
    ER_UserId,
    ER_Regdate,
    ER_Recom_Cnt,
    ER_Review_Title,
    ER_Review_Url,
    ER_Review_Url2,
    ER_Review_Content,
    ER_Review_Star,
    ER_Review_Price,
    ER_Review_Design,
    ER_Review_Quality,
    ER_Review_Satisfaction,
    ER_Status,
    ER_View,
    ER_UserName,
    ER_Review_Url_a,
    ER_Review_Url_b,
    ER_isBest,
    ER_isPhoto,
    ER_Gift_Code,
    ER_Review_Reply,
    ER_Review_Url3,
    inflow_route,
    ER_Comm_Div,
    device_type,
    ER_Comment
)
SELECT 
	ER_Company_Seq,
    ER_Order_Seq,
    ER_Type,
    @T_TGT_CARD_SEQ ER_Card_Seq,
    @P_TGT_CARD_CODE ER_Card_Code,
    ER_UserId,
    ER_Regdate,
    ER_Recom_Cnt,
    ER_Review_Title,
    ER_Review_Url,
    ER_Review_Url2,
    ER_Review_Content,
    ER_Review_Star,
    ER_Review_Price,
    ER_Review_Design,
    ER_Review_Quality,
    ER_Review_Satisfaction,
    ER_Status,
    ER_View,
    ER_UserName,
    ER_Review_Url_a,
    ER_Review_Url_b,
    ER_isBest,
    ER_isPhoto,
    ER_Gift_Code,
    ER_Review_Reply,
    ER_Review_Url3,
    inflow_route,
    ER_Comm_Div,
    device_type,
    ER_Comment
FROM S4_Event_Review
where ER_card_seq = @P_ORG_CARD_SEQ

IF @@ERROR <> 0
BEGIN
	ROLLBACK
	SET @T_RESULT = 0
	SET @T_RESULT_MSG = '등록중 오류 발생(10)'
	GOTO PROC_EXIT
END -- IF @@ERROR <> 0
COMMIT

SELECT 1 RESULT, '정상 등록 되었습니다.' MSG,  @T_TGT_CARD_SEQ SEQ

PROC_EXIT: 
SELECT @T_RESULT RESULT, @T_RESULT_MSG  MSG, 0 SEQ


END
GO
