USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[PROC_SELECT_HARDCODING_DIGITAL]    Script Date: 7/3/2023 1:37:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PROC_SELECT_HARDCODING_DIGITAL] 
	@P_HARD_ID VARCHAR(20) = 'DigitalCardCode',
	@P_CARD_CODE VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF ISNULL(@P_CARD_CODE, '') = ''
	BEGIN

	select 
		a.CardCode,
		Max(a.CardSeq) CardSeq,
		case when count(1) > 1 then Max(CardType) + '외 '+ convert(varchar,count(1) - 1) +'개 유형' else Max(CardType) end CardType,
		Max(IsDigit) IsDigit,
		Max(CardImage) CardImage
	from (
		select a.HardCode as CardCode,
			b.card_seq as CardSeq,
			b.Card_Div as CardDiv,
			m.code_value as CardType,
			b.card_image as CardImage,
			case k.CardKind_Seq when 14 then 'Y' else 'N' end IsDigit
		from HardCodingList as a with (nolock)
			left join (
				select 
					c.card_code,
					c.card_seq,
					c.Card_Div,
					c.card_image
				from s2_card c  with (nolock)
			) as b
				on a.HardCode = b.Card_Code
			left join manage_code m with (nolock)
				on b.Card_Div = m.code 
					and m.code_type = 'Card_Div'
			left join S2_CardKind k with (nolock)
				on b.Card_Seq = k.Card_Seq
					and k.CardKind_Seq = 14
		where HardID = @P_HARD_ID
		) a
	group by a.CardCode
	order by a.CardCode

	END
ELSE
	BEGIN
	
	SELECT
		Max(CardSeq) CardSeq,
		CardCode,
		Max(CardDiv) CardDiv,
		Max(CardType) CardType,
		Max(CardImage) CardImage,
		Max(HardCode) HardCode,
		Max(CardKind) CardKind
	FROM (
			SELECT 
				C.Card_Seq CardSeq,
				C.Card_Code CardCode, 
				C.Card_Div CardDiv,
				M.code_value CardType,
				C.Card_Image CardImage,
				H.HardCode HardCode,
				K.CardKind_Seq CardKind
			FROM S2_Card C with(nolock)
				left join HardCodingList H with(nolock)
					on C.Card_Code = H.HardID and H.HardID = @P_HARD_ID
				left join manage_code as M with(nolock)
					on C.Card_Div = M.code and M.code_type = 'Card_Div'
				left join S2_CardKind K with(nolock)
					on C.Card_Seq = K.Card_Seq And K.CardKind_Seq = 14
			WHERE C.Card_Code = @P_CARD_CODE
		) A
	GROUP BY CardCode

	END

END
GO


