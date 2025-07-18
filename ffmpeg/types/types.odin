/*FFMPEG
	Odin bindings for FFmpeg.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package types

import "base:runtime"
import "core:c"

FFmpeg_Error :: enum i32 {}

Error :: union {
	runtime.Allocator_Error,
	FFmpeg_Error,
}


/* error handling */

//ERRORS are 4 bytes packed into an int in reverse order.
//e.g. BSF_NOT_FOUND takes the 32 bytes {0xF8, 'B', 'S','F'}, puts them in reverse order
//(sort of "big endian"), and negates the result.
//see av_error(int) in helpers.odin for the actual decoding.
//see below for C macros defining error handling from errors.h

/*#if EDOM > 0
#define AVERROR(e) (-(e))   ///< Returns a negative error code from a POSIX error code, to return from library functions.
#define AVUNERROR(e) (-(e)) ///< Returns a POSIX error code from a library function error return value.
#else
/* Some platforms have E* and errno already negated. */
#define AVERROR(e) (e)
#define AVUNERROR(e) (e)
#endif

#define FFERRTAG(a, b, c, d) (-(int)MKTAG(a, b, c, d))
*/
AVError_Int :: distinct i32
//Fix these:
AVError :: enum i32 {
	BSF_NOT_FOUND, ///< Bitstream filter not found
	BUG, ///< Internal bug, also see AVERROR_BUG2
	BUFFER_TOO_SMALL, ///< Buffer too small
	DECODER_NOT_FOUND, ///< Decoder not found
	DEMUXER_NOT_FOUND, ///< Demuxer not found
	ENCODER_NOT_FOUND, ///< Encoder not found
	EOF, ///< End of file
	EXIT, ///< Immediate exit was requested; the called function should not be restarted
	EXTERNAL, ///< Generic error in an external library
	FILTER_NOT_FOUND, ///< Filter not found
	INVALIDDATA, ///< Invalid data found when processing input
	MUXER_NOT_FOUND, ///< Muxer not found
	OPTION_NOT_FOUND, ///< Option not found
	PATCHWELCOME, ///< Not yet implemented in FFmpeg, patches welcome
	PROTOCOL_NOT_FOUND, ///< Protocol not found
	STREAM_NOT_FOUND, ///< Stream not found
	/**
	* This is semantically identical to AVERROR_BUG
	* it has been introduced in Libav after our AVERROR_BUG and with a modified value.
	*/
	BUG2,
	UNKNOWN, ///< Unknown error, typically from an external library
	EXPERIMENTAL, //< Requested feature is flagged experimental. Set strict_std_compliance if you really want to use it.
	INPUT_CHANGED, ///< Input changed between calls. Reconfiguration is required. (can be OR-ed with AVERROR_OUTPUT_CHANGED)
	OUTPUT_CHANGED, ///< Output changed between calls. Reconfiguration is required. (can be OR-ed with AVERROR_INPUT_CHANGED)
	/* HTTP & RTSP errors */
	HTTP_BAD_REQUEST,
	HTTP_UNAUTHORIZED,
	HTTP_FORBIDDEN,
	HTTP_NOT_FOUND,
	HTTP_OTHER_4XX,
	HTTP_SERVER_ERROR,

	//FFMPEG errors not in AVERROR defines:
	EAGAIN,
	ENOMEM,
	EINVAL,
}

AV_ERROR_MAX_STRING_SIZE :: 64
/*
	Buffer padding in bytes for decoder to allow larger reads.
*/
INPUT_BUFFER_PADDING_SIZE :: 64

/*
	Minimum encoding buffer size.
*/
INPUT_BUFFER_MIN_SIZE :: 16384

/* ==============================================================================================
	   CODECS - CODECS - CODECS - CODECS - CODECS - CODECS - CODECS - CODECS - CODECS - CODECS
   ============================================================================================== */

Get_Codecs_Type :: enum i32 {
	Decoder = 0,
	Encoder = 1,
	Both    = 2,
}

Discard :: enum i32 {
	None          = -16,
	Default       = 0,
	Non_Reference = 8,
	Bidrectional  = 16,
	Non_Intra     = 24,
	Non_Key       = 32,
	All           = 48,
}

Audio_Service_Type :: enum i32 {
	Main = 0,
	Effects = 1,
	Visually_Impaired = 2,
	Hearing_Impaired = 3,
	Dialogue = 4,
	Commentary = 5,
	Emergency = 6,
	Voice_Over = 7,
	Karaoke = 8,
	Not_Part_of_ABI,
}

RC_Override :: struct {
	start_frame:    i32,
	end_frame:      i32,
	qscale:         i32,
	quality_factor: f32,
}

/*
	`AV_Codec_Flags` can be passed into `AV_Codec_Context.flags` before initialization.
*/
Codec_Flag :: enum i32 {
	/*
		FLAG_*
	*/
	Unaligned                    = 0,
	Q_Scale                      = 1,
	Four_MV                      = 2,
	Output_Corrupt               = 3,
	Quarter_Pel                  = 4,
	//Drop_Changed                 =  5, //Deprecated
	Recon_Frame                  = 6,
	Copy_Opaque                  = 7,
	Frame_Duration               = 8,
	Pass_1                       = 9,
	Pass_2                       = 10,
	Loop_Filter                  = 11,
	Grayscale_Decode             = 13,
	Report_PSNR                  = 15,
	Interlaced_DCT               = 18,
	Low_Delay                    = 19,
	Global_Header                = 22,
	Bit_Exact                    = 23,
	AC_Prediction                = 24,
	Interlaced_Motion_Estimation = 29,
	Closed_GOP                   = 31,
}
Codec_Flags :: bit_set[Codec_Flag;i32]

Codec_Flag_2 :: enum i32 {
	/*
		FLAG2_*
	*/
	Fast                   = 0,
	Non_Compliant_Speedups = 0, //not present in avcodec.h??
	No_Output              = 2,
	Local_Header           = 3,
	Chunks                 = 15,
	Ignore_Crop            = 16,
	Show_All_Frames        = 22,
	Export_Motion_Vectors  = 28,
	Skip_Manual            = 29,
	No_Flush_Loop          = 30,
	ICC_Profiles           = 31,
}
Codec_Flags_2 :: bit_set[Codec_Flag_2;i32]

/*
	`Codec_Export_Data_Flags` can be passed into `Codec_Context.export_side_data` before initialization.
*/
Codec_Export_Data_Flag :: enum i32 {
	Motion_Vectors            = 0,
	Producer_Reference_Time   = 1,
	Video_Encoding_Parameters = 2,
	Film_Grain                = 3,
}
Codec_Export_Data_Flags :: bit_set[Codec_Export_Data_Flag;i32]

Subtitle_Type :: enum i32 {
	NONE = 0,
	Bitmap, ///< A bitmap, pict will be set
	/**
	 * Plain text, the text field must be set by the decoder and is
	 * authoritative. ass and pict fields may contain approximations.
	 */
	Text,

	/**
	 * Formatted text, the ass field must be set by the decoder and is
	 * authoritative. pict and text fields may contain approximations.
	 */
	ASS,
}

Picture_Structure :: enum i32 {
	UNKNOWN = 0, //< unknown
	Top_Field, //< coded as top field
	Bottom_Field, //< coded as bottom field
	Frame, //< coded as frame
}

/*
	Pan/Scan area to display
*/
Vec2_u16 :: [2]u16

Pan_Scan :: struct {
	id:       i32,
	width:    i32, // Width and Height in 1/16th of a pixel.
	height:   i32,
	position: [3]Vec2_u16, // Top left in 1/16th of a pixel for up to 3 frames.
}

/*
	Stream bitrate properties.
*/
Codec_Bitrate_Properties :: struct {
	max_bitrate: i64,
	min_bitrate: i64,
	avg_bitrate: i64,
	buffer_size: i64,
	vbv_delay:   u64,
}

/*
	Producer Reference Time (prft), per ISO/IEC 14496-12.
*/
Producer_Reference_Time :: struct {
	wall_clock: i64, // UTC timestamp in microseconds, e.g. `avcodec.get_time`.
	flags:      i32,
}

FourCC :: distinct [4]u8

/*
	AV Codec Tag
*/
Codec_Tag :: struct {
	id:  Codec_ID,
	tag: FourCC,
}

Codec_Mime :: struct {
	str: [32]u8,
	id:  Codec_ID,
}

Get_Buffer_Flag_Ref :: 1 << 0
Get_Encode_Buffer_Flag_Ref :: 1 << 0

Codec_Capability :: enum i32 {
	Draw_Horizontal_Band        = 0,
	DR1                         = 1,
	Delay                       = 5,
	Small_Last_Frame            = 6,
	Experimental                = 9,
	Channel_Configuration       = 10,
	Frame_Threads               = 12,
	Slice_Threads               = 13,
	Parameter_Change            = 14,
	Other_Threads               = 15,
	Variable_Frame_Size         = 16,
	Avoid_Probing               = 17,
	Hardware                    = 18,
	Hybrid                      = 19, // Potentially backed by hardware encoder, but can fall back to software.
	Encoder_Reordered_Opaque    = 20,
	Encoder_Flush               = 21,
	Encoder_Reconstructed_Frame = 22,
}
Codec_Capabilities :: bit_set[Codec_Capability;i32]

Profile :: struct {
	id:   i32,
	name: cstring,
}

Codec_HW_Config_Internal :: struct {
}

Codec :: struct {
	name:                  cstring,
	long_name:             cstring,
	type:                  Media_Type,
	id:                    Codec_ID,
	capabilities:          Codec_Capabilities,
	max_lowres:            u8,
	supported_framerates:  [^]Rational, // Array of supported framerates,        or NULL if any framerate. Terminated by {0, 0}
	pixel_formats:         [^]Pixel_Format, // Array of supported pixel formats,     or NULL if unknown.       Terminated by -1
	supported_samplerates: [^]i32, // Array of supported audio samplerates, or NULL if unknown.       Terminated by 0
	sample_formats:        [^]Sample_Format, // Array of supported sample formats,    or NULL if unknown.       Terminated by -1
	priv_class:            ^Class,
	profiles:              [^]Profile, // Array of recognized profiles,         or NULL if unknown.        Terminated by .Profile_Unknown
	wrapper_name:          cstring,
	ch_layouts:            [^]Channel_Layout,
}

Codec_Default :: struct {
}

/*
	main external API structure.

	New fields can be added to the end with minor version bumps.
	Removal, reordering and changes to existing fields require a major version bump.
	You can use Options (av_opt* / av_set/get*()) to access these fields from user applications.
	The name string for Options options matches the associated command line
	parameter name and can be found in libavcodec/options_table.h
	The Option/command line parameter names differ in some cases from the C
	structure field names for historic reasons or brevity.
	`size_of(Codec_Context)` must not be used outside libav*.
*/

COMPRESSION_DEFAULT :: -1


DCT :: struct {
	class:                Class,

	//void (*idct)(int16_t *block /* align 16 */);
	idct:                 proc(block: ^i16),
	/**
     * IDCT input permutation.
     * Several optimized IDCTs need a permutated input (relative to the
     * normal order of the reference IDCT).
     * This permutation must be performed before the idct_put/add.
     * Note, normally this can be merged with the zigzag/alternate scan<br>
     * An example to avoid confusion:
     * - (->decode coeffs -> zigzag reorder -> dequant -> reference IDCT -> ...)
     * - (x -> reference DCT -> reference IDCT -> x)
     * - (x -> reference DCT -> simple_mmx_perm = idct_permutation
     *    -> simple_idct_mmx -> x)
     * - (-> decode coeffs -> zigzag reorder -> simple_mmx_perm -> dequant
     *    -> simple_idct_mmx -> ...)
     */
	idct_permutation:     [64]u8,
	fdct:                 proc(block: ^i16),

	/**
     * DCT algorithm.
     * must use AVOptions to set this field.
     */
	dct_algo:             DCT_Algorithm,

	/**
     * IDCT algorithm.
     * must use AVOptions to set this field.
     */
	idct_algo:            IDCT_Algorithm,
	get_pixels:           proc(
		block: ^i16,
		/* align 16 */
		pixels: ^u8,
		/* align 8 */
		line_size: uintptr,
	), //ptrdiff_t. Is this a uintptr?
	bits_per_sample:      i32,
	get_pixels_unaligned: proc(
		block: ^i16,
		/* align 16 */
		pixels: ^u8,
		/* align 8 */
		line_size: uintptr,
	), //ptrdiff_t. Is this a uintptr?
}

Interlaced_DCT_Comparison :: enum i32 {
	SAD        = 0,
	SSE        = 1,
	SATD       = 2,
	DCT        = 3,
	PSNR       = 4,
	BIT        = 5,
	RD         = 6,
	ZERO       = 7,
	VSAD       = 8,
	VSSE       = 9,
	NSSE       = 10,
	W53        = 11,
	W97        = 12,
	DCTMAX     = 13,
	DCT264     = 14,
	MEDIAN_SAD = 15,
	CHROMA     = 256,
}

Slice_Flag :: enum i32 {
	Coded_Order = 1, ///< draw_horiz_band() is called in coded order instead of display
	Allow_Field = 2, ///< allow draw_horiz_band() with field slices (MPEG-2 field pics)
	Allow_Plane = 4, ///< allow draw_horiz_band() with 1 component at a time (SVQ1)
}
Slice_Flags :: bit_set[Slice_Flag;i32]

Macroblock_Decision_Mode :: enum i32 {
	Simple          = 0, ///< uses mb_cmp
	Bits            = 1, ///< chooses the one which needs the fewest bits
	Rate_Distortion = 2, ///< rate distortion
}

Work_Around_Bug :: enum i32 {
	Autodetect       = 0, //< autodetection
	XViD_Interlace   = 2,
	UMP4             = 3,
	No_Padding       = 4,
	AMV              = 5,
	QPEL_Chroma      = 6,
	Std_qPel         = 7,
	qPel_Chroma2     = 8,
	Direct_Blocksize = 9,
	Edge             = 10,
	hPel_Chroma      = 11,
	DC_Clip          = 12,
	MS               = 13, ///< Work around various bugs in Microsoft's broken decoders.
	Truncated        = 14,
	I_Edge           = 15,
}
Work_Around_Bugs :: bit_set[Work_Around_Bug;i32]

Strict_Standard_Compliance :: enum i32 {
	Very_Strict  = 2, ///< Strictly conform to an older more strict version of the spec or reference software.
	Strict       = 1, ///< Strictly conform to all the things in the spec no matter what consequences.
	Normal       = 0,
	Unofficial   = -1, ///< Allow unofficial extensions
	Experimental = -2, ///< Allow nonstandardized experimental things.
}

Error_Concealment_Flag :: enum i32 {
	GUESS_MVS   = 0,
	DEBLOCK     = 1,
	FAVOR_INTER = 8,
}
Error_Concealment_Flags :: bit_set[Error_Concealment_Flag;i32]

Codec_Context_Debug_Flag :: enum i32 {
	Pict_Info  = 0,
	RC         = 1,
	Bitstream  = 2,
	MB_Type    = 3,
	QP         = 4,
	DCT_Coeff  = 6,
	Skip       = 7,
	Start_Code = 8,
	ER         = 10,
	MMCO       = 11,
	Bufs       = 12,
	Buffers    = 15,
	Threads    = 16,
	Green_MD   = 23,
	NOMC       = 24,
}
Codec_Context_Debug_Flags :: bit_set[Codec_Context_Debug_Flag;i32]

Error_Recognition_Flag :: enum i32 {
	/**
 * Verify checksums embedded in the bitstream (could be of either encoded or
 * decoded data, depending on the codec) and print an error message on mismatch.
 * If AV_EF_EXPLODE is also set, a mismatching checksum will result in the
 * decoder returning an error.
 */
	CRC_Check    = 0,
	Bitstream    = 1, ///< detect bitstream specification deviations
	Buffer       = 2, ///< detect improper bitstream length
	Explode      = 3, ///< abort decoding on minor error detection
	Ignore_Error = 15, ///< ignore errors and continue
	Careful      = 16, ///< consider things that violate the spec, are fast to calculate and have not been seen in the wild as errors
	Compliant    = 17, ///< consider all spec non compliances as errors
	Aggressive   = 18, ///< consider things that a sane encoder should not do as an error
}
Error_Recognition_Flags :: bit_set[Error_Recognition_Flag;i32]

DCT_Algorithm :: enum i32 {
	Auto         = 0,
	Fast_Integer = 1,
	Integer      = 2,
	MMX          = 3,
	AltiVEC      = 5,
	FAAN         = 6,
}

IDCT_Algorithm :: enum i32 {
	Auto            = 0,
	Integer         = 1,
	Simple          = 2,
	Simple_MMX      = 3,
	ARM             = 7,
	AltiVEC         = 8,
	Simple_ARM      = 10,
	XViD            = 14,
	Simple_ARM_V5TE = 16,
	Simple_ARM_V6   = 17,
	FAAN            = 20,
	Simple_NEON     = 22,
	//None            = 24, // formerly used by xvmc
	Simple_Auto     = 128,
}

Thread_Type :: enum i32 {
	Frame = 1, ///< Decode more than one frame at once
	Slice = 2, ///< Decode more than one part of a single frame at once
}

//now in defs.h
Codec_Profile :: enum i32 {
	UNKNOWN                               = -99,
	RESERVED                              = -100,
	AAC_MAIN                              = 0,
	AAC_LOW                               = 1,
	AAC_SSR                               = 2,
	AAC_LTP                               = 3,
	AAC_HE                                = 4,
	AAC_HE_V2                             = 28,
	AAC_LD                                = 22,
	AAC_ELD                               = 38,
	MPEG2_AAC_LOW                         = 128,
	MPEG2_AAC_HE                          = 131,
	DNXHD                                 = 0,
	DNXHR_LB                              = 1,
	DNXHR_SQ                              = 2,
	DNXHR_HQ                              = 3,
	DNXHR_HQX                             = 4,
	DNXHR_444                             = 5,
	DTS                                   = 20,
	DTS_ES                                = 30,
	DTS_96_24                             = 40,
	DTS_HD_HRA                            = 50,
	DTS_HD_MA                             = 60,
	DTS_HD_MA_X                           = 61,
	DTS_HDA_MA_X_IMAX                     = 62,
	DTS_EXPRESS                           = 70,
	EAC3_DDP_ATMOS                        = 30,
	TRUEHD_ATMOS                          = 30,
	MPEG2_422                             = 0,
	MPEG2_HIGH                            = 1,
	MPEG2_SS                              = 2,
	MPEG2_SNR_SCALABLE                    = 3,
	MPEG2_MAIN                            = 4,
	MPEG2_SIMPLE                          = 5,
	H264_CONSTRAINED                      = 1 << 9, // 8+1 constraint_set1_flag
	H264_INTRA                            = 1 << 11, // 8+3 constraint_set3_flag
	H264_BASELINE                         = 66,
	H264_CONSTRAINED_BASELINE             = 66 | H264_CONSTRAINED,
	H264_MAIN                             = 77,
	H264_EXTENDED                         = 88,
	H264_HIGH                             = 100,
	H264_HIGH_10                          = 110,
	H264_HIGH_10_INTRA                    = 110 | H264_INTRA,
	H264_MULTIVIEW_HIGH                   = 118,
	H264_HIGH_422                         = 122,
	H264_HIGH_422_INTRA                   = 122 | H264_INTRA,
	H264_STEREO_HIGH                      = 128,
	H264_HIGH_444                         = 144,
	H264_HIGH_444_PREDICTIVE              = 244,
	H264_HIGH_444_INTRA                   = 244 | H264_INTRA,
	H264_CAVLC_444                        = 44,
	VC1_SIMPLE                            = 0,
	VC1_MAIN                              = 1,
	VC1_COMPLEX                           = 2,
	VC1_ADVANCED                          = 3,
	MPEG4_SIMPLE                          = 0,
	MPEG4_SIMPLE_SCALABLE                 = 1,
	MPEG4_CORE                            = 2,
	MPEG4_MAIN                            = 3,
	MPEG4_N_BIT                           = 4,
	MPEG4_SCALABLE_TEXTURE                = 5,
	MPEG4_SIMPLE_FACE_ANIMATION           = 6,
	MPEG4_BASIC_ANIMATED_TEXTURE          = 7,
	MPEG4_HYBRID                          = 8,
	MPEG4_ADVANCED_REAL_TIME              = 9,
	MPEG4_CORE_SCALABLE                   = 10,
	MPEG4_ADVANCED_CODING                 = 11,
	MPEG4_ADVANCED_CORE                   = 12,
	MPEG4_ADVANCED_SCALABLE_TEXTURE       = 13,
	MPEG4_SIMPLE_STUDIO                   = 14,
	MPEG4_ADVANCED_SIMPLE                 = 15,
	JPEG2000_CSTREAM_RESTRICTION_0        = 1,
	JPEG2000_CSTREAM_RESTRICTION_1        = 2,
	JPEG2000_CSTREAM_NO_RESTRICTION       = 32768,
	JPEG2000_DCINEMA_2K                   = 3,
	JPEG2000_DCINEMA_4K                   = 4,
	VP9_0                                 = 0,
	VP9_1                                 = 1,
	VP9_2                                 = 2,
	VP9_3                                 = 3,
	HEVC_MAIN                             = 1,
	HEVC_MAIN_10                          = 2,
	HEVC_MAIN_STILL_PICTURE               = 3,
	HEVC_REXT                             = 4,
	HEVC_SCC                              = 9,
	VVC_MAIN_10                           = 1,
	VVC_MAIN_10_444                       = 33,
	AV1_MAIN                              = 0,
	AV1_HIGH                              = 1,
	AV1_PROFESSIONAL                      = 2,
	MJPEG_HUFFMAN_BASELINE_DCT            = 0xc0,
	MJPEG_HUFFMAN_EXTENDED_SEQUENTIAL_DCT = 0xc1,
	MJPEG_HUFFMAN_PROGRESSIVE_DCT         = 0xc2,
	MJPEG_HUFFMAN_LOSSLESS                = 0xc3,
	MJPEG_JPEG_LS                         = 0xf7,
	SBC_MSBC                              = 1,
	PRORES_PROXY                          = 0,
	PRORES_LT                             = 1,
	PRORES_STANDARD                       = 2,
	PRORES_HQ                             = 3,
	PRORES_4444                           = 4,
	PRORES_XQ                             = 5,
	ARIB_PROFILE_A                        = 0,
	ARIB_PROFILE_C                        = 1,
	KLVA_SYNC                             = 0,
	KLVA_ASYNC                            = 1,
	EVC_BASELINE                          = 0,
	EVC_MAIN                              = 1,
}

LEVEL_UNKNOWN :: -99

Subtitle_Character_Mode :: enum i32 {
	Do_Nothing  = -1, ///< do nothing (demuxer outputs a stream supposed to be already in UTF-8, or the codec is bitmap for instance)
	Automatic   = 0, ///< libavcodec will select the mode itself
	Pre_Decoder = 1, ///< the AVPacket data needs to be recoded to UTF-8 before being fed to the decoder, requires iconv
	Ignore      = 2, ///< neither convert the subtitles, nor check them for valid UTF-8
}

Stream_Property_Flag :: enum i32 {
	LOSSLESS        = 0,
	CLOSED_CAPTIONS = 1,
	FILM_GRAIN      = 2,
}
Stream_Property_Flags :: bit_set[Stream_Property_Flag;i32]

Hardware_Accelerator_Flag :: enum i32 {
	/**
	 * Hardware acceleration should be used for decoding even if the codec level
	 * used is unknown or higher than the maximum supported level reported by the
	 * hardware driver.
	 *
	 * It's generally a good idea to pass this flag unless you have a specific
	 * reason not to, as hardware tends to under-report supported levels.
	 */
	Ignore_Level           = 0,

	/**
	 * Hardware acceleration can output YUV pixel formats with a different chroma
	 * sampling than 4:2:0 and/or other than 8 bits per component.
	 */
	Allow_High_Depth       = 1,

	/**
	 * Hardware acceleration should still be attempted for decoding when the
	 * codec profile does not match the reported capabilities of the hardware.
	 *
	 * For example, this can be used to try to decode baseline profile H.264
	 * streams in hardware - it will often succeed, because many streams marked
	 * as baseline profile actually conform to constrained baseline profile.
	 *
	 * @warning If the stream is actually not supported then the behaviour is
	 *          undefined, and may include returning entirely incorrect output
	 *          while indicating success.
	 */
	Allow_Profile_Mismatch = 2,
	/**
	* Some hardware decoders (namely nvdec) can either output direct decoder
	* surfaces, or make an on-device copy and return said copy.
	* There is a hard limit on how many decoder surfaces there can be, and it
	* cannot be accurately guessed ahead of time.
	* For some processing chains, this can be okay, but others will run into the
	* limit and in turn produce very confusing errors that require fine tuning of
	* more or less obscure options by the user, or in extreme cases cannot be
	* resolved at all without inserting an avfilter that forces a copy.
	*
	* Thus, the hwaccel will by default make a copy for safety and resilience.
	* If a users really wants to minimize the amount of copies, they can set this
	* flag and ensure their processing chain does not exhaust the surface pool.
	*/
	Unsafe_Output          = 3,
}
Hardware_Accelerator_Flags :: bit_set[Hardware_Accelerator_Flag;i32]

Codec_Internal :: struct {
}

Codec_Context :: struct {
	av_class:                     ^Class,
	log_level_offset:             i32,
	codec_type:                   Media_Type,
	codec:                        ^Codec,
	codec_id:                     Codec_ID,
	codec_tag:                    FourCC,
	priv_data:                    rawptr,

	/**
	 * Private context used for internal data.
	 *
	 * Unlike priv_data, this is not codec-specific. It is used in general
	 * libavcodec functions.
	 */
	internal:                     ^Codec_Internal,

	/**
	 * Private data of the user, can be used to carry app specific stuff.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	_opaque:                      rawptr,

	/**
	 * the average bitrate
	 * - encoding: Set by user unused for constant quantizer encoding.
	 * - decoding: Set by user, may be overwritten by libavcodec
	 *             if this info is available in the stream
	 */
	bit_rate:                     i64,

	/**
	 * AV_CODEC_FLAG_*.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	flags:                        Codec_Flags,

	/**
	 * AV_CODEC_FLAG2_*
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	flags2:                       Codec_Flags_2,

	/**
	 * some codecs need / can use extradata like Huffman tables.
	 * MJPEG: Huffman tables
	 * rv10: additional flags
	 * MPEG-4: global headers (they can be in the bitstream or here)
	 * The allocated memory should be AV_INPUT_BUFFER_PADDING_SIZE bytes larger
	 * than extradata_size to avoid problems if it is read with the bitstream reader.
	 * The bytewise contents of extradata must not depend on the architecture or CPU endianness.
	 * Must be allocated with the av_malloc() family of functions.
	 * - encoding: Set/allocated/freed by libavcodec.
	 * - decoding: Set/allocated/freed by user.
	 */
	extradata:                    [^]u8,
	extradata_size:               i32,

	/**
	 * This is the fundamental unit of time (in seconds) in terms
	 * of which frame timestamps are represented. For fixed-fps content,
	 * timebase should be 1/framerate and timestamp increments should be
	 * identically 1.
	 * This often, but not always is the inverse of the frame rate or field rate
	 * for video. 1/time_base is not the average frame rate if the frame rate is not
	 * constant.
	 *
	 * Like containers, elementary streams also can store timestamps, 1/time_base
	 * is the unit in which these timestamps are specified.
	 * As example of such codec time base see ISO/IEC 14496-2:2001(E)
	 * vop_time_increment_resolution and fixed_vop_rate
	 * (fixed_vop_rate == 0 implies that it is different from the framerate)
	 *
	 * - encoding: MUST be set by user.
	 * - decoding: the use of this field for decoding is deprecated.
	 *             Use framerate instead.
	 */
	time_base:                    Rational,
	pkt_timebase:                 Rational,
	framerate:                    Rational,
	ticks_per_frame:              i32,


	/**
	 * Codec delay.
	 *
	 * Encoding: Number of frames delay there will be from the encoder input to
	 *           the decoder output. (we assume the decoder matches the spec)
	 * Decoding: Number of frames delay in addition to what a standard decoder
	 *           as specified in the spec would produce.
	 *
	 * Video:
	 *   Number of frames the decoded output will be delayed relative to the
	 *   encoded input.
	 *
	 * Audio:
	 *   For encoding, this field is unused (see initial_padding).
	 *
	 *   For decoding, this is the number of samples the decoder needs to
	 *   output before the decoder's output is valid. When seeking, you should
	 *   start decoding this many samples prior to your desired seek point.
	 *
	 * - encoding: Set by libavcodec.
	 * - decoding: Set by libavcodec.
	 */
	delay:                        i32,

	/* video only */
	/**
	 * picture width / height.
	 *
	 * @note Those fields may not match the values of the last
	 * AVFrame output by avcodec_decode_video2 due frame
	 * reordering.
	 *
	 * - encoding: MUST be set by user.
	 * - decoding: May be set by the user before opening the decoder if known e.g.
	 *             from the container. Some decoders will require the dimensions
	 *             to be set by the caller. During decoding, the decoder may
	 *             overwrite those values as required while parsing the data.
	 */
	width:                        i32,
	height:                       i32,

	/**
	 * Bitstream width / height, may be different from width/height e.g. when
	 * the decoded frame is cropped before being output or lowres is enabled.
	 *
	 * @note Those field may not match the value of the last
	 * AVFrame output by avcodec_receive_frame() due frame
	 * reordering.
	 *
	 * - encoding: unused
	 * - decoding: May be set by the user before opening the decoder if known
	 *             e.g. from the container. During decoding, the decoder may
	 *             overwrite those values as required while parsing the data.
	 */
	coded_width:                  i32,
	coded_height:                 i32,
	sample_aspect_ratio:          Rational,

	/**
	 * Pixel format, see xxx.
	 * May be set by the demuxer if known from headers.
	 * May be overridden by the decoder if it knows better.
	 *
	 * @note This field may not match the value of the last
	 * AVFrame output by avcodec_receive_frame() due frame
	 * reordering.
	 *
	 * - encoding: Set by user.
	 * - decoding: Set by user if known, overridden by libavcodec while
	 *             parsing the data.
	 */
	pix_fmt:                      Pixel_Format,
	sw_pix_fmt:                   Pixel_Format,

	// Extra stuff from ffmpeg 7.1
	color_primaries:              Color_Primaries,
	color_trc:                    Color_Transfer_Characteristic,
	colorspace:                   Color_Space,
	color_range:                  Color_Range,
	chroma_sample_location:       Chroma_Location,
	refs:                         i32,
	has_b_frames:                 i32,
	slice_flags:                  Slice_Flags,

	/**
	 * If non NULL, 'draw_horiz_band' is called by the libavcodec
	 * decoder to draw a horizontal band. It improves cache usage. Not
	 * all codecs can do that. You must check the codec capabilities
	 * beforehand.
	 * When multithreading is used, it may be called from multiple threads
	 * at the same time threads might draw different parts of the same Frame,
	 * or multiple Frames, and there is no guarantee that slices will be drawn
	 * in order.
	 * The function is also used by hardware acceleration APIs.
	 * It is called at least once during frame decoding to pass
	 * the data needed for hardware render.
	 * In that mode instead of pixel data, AVFrame points to
	 * a structure specific to the acceleration API. The application
	 * reads the structure and can change some fields to indicate progress
	 * or mark state.
	 * - encoding: unused
	 * - decoding: Set by user.
	 * @param height the height of the slice
	 * @param y the y position of the slice
	 * @param type 1->top field, 2->bottom field, 3->frame
	 * @param offset offset into the AVFrame.data from which the slice should be read
	 */
	draw_horiz_band:              #type proc(
		ctx: ^Codec_Context,
		src: ^Frame,
		offset: [NUM_DATA_POINTERS]i32,
		y: i32,
		type: i32,
		height: i32,
	),

	/**
	 * callback to negotiate the Pixel_Format
	 * @param fmt is the list of formats which are supported by the codec,
	 * it is terminated by -1 as 0 is a valid format, the formats are ordered by quality.
	 * The first is always the native one.
	 * @note The callback may be called again immediately if initialization for
	 * the selected (hardware-accelerated) pixel format failed.
	 * @warning Behavior is undefined if the callback returns a value not
	 * in the fmt list of formats.
	 * @return the chosen format
	 * - encoding: unused
	 * - decoding: Set by user, if not set the native format will be chosen.
	 */
	get_format:                   #type proc(
		ctx: ^Codec_Context,
		fmt: ^Pixel_Format,
	) -> Pixel_Format,

	/**
	 * maximum number of B-frames between non-B-frames
	 * Note: The output will be delayed by max_b_frames+1 relative to the input.
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	max_b_frames:                 i32,

	/**
	 * qscale factor between IP and B-frames
	 * If > 0 then the last P-frame quantizer will be used (q= lastp_q*factor+offset).
	 * If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	b_quant_factor:               f32,

	/**
	 * qscale offset between IP and B-frames
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	b_quant_offset:               f32,

	/**
	 * qscale factor between P- and I-frames
	 * If > 0 then the last P-frame quantizer will be used (q = lastp_q * factor + offset).
	 * If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	i_quant_factor:               f32,

	/**
	 * qscale offset between P and I-frames
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	i_quant_offset:               f32,

	/**
	 * luminance masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	lumi_masking:                 f32,

	/**
	 * temporary complexity masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	temporal_cplx_masking:        f32,

	/**
	 * spatial complexity masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	spatial_cplx_masking:         f32,

	/**
	 * p block masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	p_masking:                    f32,

	/**
	 * darkness masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	dark_masking:                 f32,
	nsse_weight:                  i32,

	/**
	 * motion estimation comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	me_cmp:                       i32,

	/**
	 * subpixel motion estimation comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	me_sub_cmp:                   i32,

	/**
	 * macroblock comparison function (not supported yet)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	mb_cmp:                       i32,

	/**
	 * interlaced DCT comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	ildct_cmp:                    Interlaced_DCT_Comparison,

	/**
	 * ME diamond size & shape
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	dia_size:                     i32,

	/**
	 * amount of previous MV predictors (2a+1 x 2a+1 square)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	last_predictor_count:         i32,

	/**
	 * motion estimation prepass comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	me_pre_cmp:                   i32,

	/**
	 * ME prepass diamond size & shape
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	pre_dia_size:                 i32,

	/**
	 * subpel ME quality
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	me_subpel_quality:            i32,

	/**
	 * maximum motion estimation search range in subpel units
	 * If 0 then no limit.
	 *
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	me_range:                     i32,

	/**
	 * macroblock decision mode
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	mb_decision:                  Macroblock_Decision_Mode,

	/**
	 * custom intra quantization matrix
	 * Must be allocated with the av_malloc() family of functions, and will be freed in
	 * avcodec_free_context().
	 * - encoding: Set/allocated by user, freed by libavcodec. Can be NULL.
	 * - decoding: Set/allocated/freed by libavcodec.
	 */
	intra_matrix:                 [^]u16,

	/**
	 * custom inter quantization matrix
	 * Must be allocated with the av_malloc() family of functions, and will be freed in
	 * avcodec_free_context().
	 * - encoding: Set/allocated by user, freed by libavcodec. Can be NULL.
	 * - decoding: Set/allocated/freed by libavcodec.
	 */
	inter_matrix:                 [^]u16,
	chroma_intra_matrix:          [^]u16,

	/**
	 * precision of the intra DC coefficient - 8
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec
	 */
	intra_dc_precision:           i32,

	/**
	 * minimum MB Lagrange multiplier
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	mb_lmin:                      i32,

	/**
	 * maximum MB Lagrange multiplier
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	mb_lmax:                      i32,

	/**
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	bidir_refine:                 i32,

	/**
	 * minimum GOP size
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	keyint_min:                   i32,
	gop_size:                     i32,

	/**
	 * Note: Value depends upon the compare function used for fullpel ME.
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	mv0_threshold:                i32,

	/**
	 * Number of slices.
	 * Indicates number of picture subdivisions. Used for parallelized
	 * decoding.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	slices:                       i32,

	/* audio only */
	sample_rate:                  i32, ///< samples per second

	/**
	 * audio sample format
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec.
	 */
	sample_fmt:                   Sample_Format, ///< sample format
	ch_layout:                    Channel_Layout,

	/* The following data should not be initialized. */
	/**
	 * Number of samples per channel in an audio frame.
	 *
	 * - encoding: set by libavcodec in avcodec_open2(). Each submitted frame
	 *   except the last must contain exactly frame_size samples per channel.
	 *   May be 0 when the codec has AV_CODEC_CAP_VARIABLE_FRAME_SIZE set, then the
	 *   frame size is not restricted.
	 * - decoding: may be set by some decoders to indicate constant frame size
	 */
	frame_size:                   i32,
	/**
	 * number of bytes per packet if constant and known or 0
	 * Used by some WAV based audio codecs.
	 */
	block_align:                  i32,

	/**
	 * Audio cutoff bandwidth (0 means "automatic")
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	cutoff:                       i32,
	audio_service_type:           Audio_Service_Type,

	/**
	 * desired sample format
	 * - encoding: Not used.
	 * - decoding: Set by user.
	 * Decoder will decode to this format if it can.
	 */
	request_sample_fmt:           Sample_Format,
	initial_padding:              i32,
	trailing_padding:             i32,
	seek_preroll:                 i32,
	/**
	 * This callback is called at the beginning of each frame to get data
	 * buffer(s) for it. There may be one contiguous buffer for all the data or
	 * there may be a buffer per each data plane or anything in between. What
	 * this means is, you may set however many entries in buf[] you feel necessary.
	 * Each buffer must be reference-counted using the AVBuffer API (see description
	 * of buf[] below).
	 *
	 * The following fields will be set in the frame before this callback is
	 * called:
	 * - format
	 * - width, height (video only)
	 * - sample_rate, channel_layout, nb_samples (audio only)
	 * Their values may differ from the corresponding values in
	 * AVCodec_Context. This callback must use the frame values, not the codec
	 * context values, to calculate the required buffer size.
	 *
	 * This callback must fill the following fields in the frame:
	 * - data[]
	 * - linesize[]
	 * - extended_data:
	 *   * if the data is planar audio with more than 8 channels, then this
	 *     callback must allocate and fill extended_data to contain all pointers
	 *     to all data planes. data[] must hold as many pointers as it can.
	 *     extended_data must be allocated with av_malloc() and will be freed in
	 *     av_frame_unref().
	 *   * otherwise extended_data must point to data
	 * - buf[] must contain one or more pointers to AVBufferRef structures. Each of
	 *   the frame's data and extended_data pointers must be contained in these. That
	 *   is, one AVBufferRef for each allocated chunk of memory, not necessarily one
	 *   AVBufferRef per data[] entry. See: av_buffer_create(), av_buffer_alloc(),
	 *   and av_buffer_ref().
	 * - extended_buf and nb_extended_buf must be allocated with av_malloc() by
	 *   this callback and filled with the extra buffers if there are more
	 *   buffers than buf[] can hold. extended_buf will be freed in
	 *   av_frame_unref().
	 *
	 * If AV_CODEC_CAP_DR1 is not set then get_buffer2() must call
	 * avcodec_default_get_buffer2() instead of providing buffers allocated by
	 * some other means.
	 *
	 * Each data plane must be aligned to the maximum required by the target
	 * CPU.
	 *
	 * @see avcodec_default_get_buffer2()
	 *
	 * Video:
	 *
	 * If AV_GET_BUFFER_FLAG_REF is set in flags then the frame may be reused
	 * (read and/or written to if it is writable) later by libavcodec.
	 *
	 * avcodec_align_dimensions2() should be used to find the required width and
	 * height, as they normally need to be rounded up to the next multiple of 16.
	 *
	 * Some decoders do not support linesizes changing between frames.
	 *
	 * If frame multithreading is used, this callback may be called from a
	 * different thread, but not from more than one at once. Does not need to be
	 * reentrant.
	 *
	 * @see avcodec_align_dimensions2()
	 *
	 * Audio:
	 *
	 * Decoders request a buffer of a particular size by setting
	 * AVFrame.nb_samples prior to calling get_buffer2(). The decoder may,
	 * however, utilize only part of the buffer by setting AVFrame.nb_samples
	 * to a smaller value in the output frame.
	 *
	 * As a convenience, av_samples_get_buffer_size() and
	 * av_samples_fill_arrays() in libavutil may be used by custom get_buffer2()
	 * functions to find the required data size and to fill data pointers and
	 * linesize. In AVFrame.linesize, only linesize[0] may be set for audio
	 * since all planes must be the same size.
	 *
	 * @see av_samples_get_buffer_size(), av_samples_fill_arrays()
	 *
	 * - encoding: unused
	 * - decoding: Set by libavcodec, user can override.
	 */
	get_buffer2:                  #type proc(
		ctx: ^Codec_Context,
		frame: ^Frame,
		flags: i32,
	) -> i32,
	bit_rate_tolerance:           i32,
	global_quality:               i32,
	compression_level:            i32,

	/* - encoding parameters */
	qcompress:                    f32, ///< amount of qscale change between easy & hard scenes (0.0-1.0)
	qblur:                        f32, ///< amount of qscale smoothing over time (0.0-1.0)

	/**
	 * minimum quantizer
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	qmin:                         i32,

	/**
	 * maximum quantizer
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	qmax:                         i32,

	/**
	 * maximum quantizer difference between frames
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	max_qdiff:                    i32,

	/**
	 * decoder bitstream buffer size
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	rc_buffer_size:               i32,

	/**
	 * ratecontrol override, see RcOverride
	 * - encoding: Allocated/set/freed by user.
	 * - decoding: unused
	 */
	rc_override_count:            i32,
	rc_override:                  [^]RC_Override,

	/**
	 * maximum bitrate
	 * - encoding: Set by user.
	 * - decoding: Set by user, may be overwritten by libavcodec.
	 */
	rc_max_rate:                  i64,

	/**
	 * minimum bitrate
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	rc_min_rate:                  i64,

	/**
	 * Ratecontrol attempt to use, at maximum, <value> of what can be used without an underflow.
	 * - encoding: Set by user.
	 * - decoding: unused.
	 */
	rc_max_available_vbv_use:     f32,

	/**
	 * Ratecontrol attempt to use, at least, <value> times the amount needed to prevent a vbv overflow.
	 * - encoding: Set by user.
	 * - decoding: unused.
	 */
	rc_min_vbv_overflow_use:      f32,

	/**
	 * Number of bits which should be loaded into the rc buffer before decoding starts.
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	rc_initial_buffer_occupancy:  i32,

	/**
	 * trellis RD quantization
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	trellis:                      i32,

	/**
	 * pass1 encoding statistics output buffer
	 * - encoding: Set by libavcodec.
	 * - decoding: unused
	 */
	stats_out:                    cstring,

	/**
	 * pass2 encoding statistics input buffer
	 * Concatenated stuff from stats_out of pass1 should be placed here.
	 * - encoding: Allocated/set/freed by user.
	 * - decoding: unused
	 */
	stats_in:                     cstring,

	/**
	 * Work around bugs in encoders which sometimes cannot be detected automatically.
	 * - encoding: Set by user
	 * - decoding: Set by user
	 */
	workaround_bugs:              Work_Around_Bugs,

	/**
	 * strictly follow the standard (MPEG-4, ...).
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 * Setting this to STRICT or higher means the encoder and decoder will
	 * generally do stupid things, whereas setting it to unofficial or lower
	 * will mean the encoder might produce output that is not supported by all
	 * spec-compliant decoders. Decoders don't differentiate between normal,
	 * unofficial and experimental (that is, they always try to decode things
	 * when they can) unless they are explicitly asked to behave stupidly
	 * (=strictly conform to the specs)
	 */
	strict_std_compliance:        Strict_Standard_Compliance,

	/**
	 * error concealment flags
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	error_concealment:            Error_Concealment_Flags,

	/**
	 * debug
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	debug:                        Codec_Context_Debug_Flags,

	/**
	 * Error recognition may misdetect some more or less valid parts as errors.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	error_recognition:            Error_Recognition_Flags,

	/**
	 * Hardware accelerator in use
	 * - encoding: unused.
	 * - decoding: Set by libavcodec
	 */
	hardware_accelerator:         ^Hardware_Accelerator,

	/**
     * Legacy hardware accelerator context.
     *
     * For some hardware acceleration methods, the caller may use this field to
     * signal hwaccel-specific data to the codec. The struct pointed to by this
     * pointer is hwaccel-dependent and defined in the respective header. Please
     * refer to the FFmpeg HW accelerator documentation to know how to fill
     * this.
     *
     * In most cases this field is optional - the necessary information may also
     * be provided to libavcodec through @ref hw_frames_ctx or @ref
     * hw_device_ctx (see avcodec_get_hw_config()). However, in some cases it
     * may be the only method of signalling some (optional) information.
     *
     * The struct and its contents are owned by the caller.
     *
     * - encoding: May be set by the caller before avcodec_open2(). Must remain
     *             valid until avcodec_free_context().
     * - decoding: May be set by the caller in the get_format() callback.
     *             Must remain valid until the next get_format() call,
     *             or avcodec_free_context() (whichever comes first).
     */
	hardware_accelerator_context: rawptr,
	hw_frames_ctx:                ^Buffer_Ref,
	hw_device_ctx:                ^Buffer_Ref,
	hwaccel_flags:                Hardware_Accelerator_Flags,
	extra_hw_frames:              i32,
	error:                        [NUM_DATA_POINTERS]u64,

	/**
	 * DCT algorithm, see FF_DCT_* below
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	dct_algo:                     DCT_Algorithm,

	/**
	 * IDCT algorithm, see FF_IDCT_* below.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	idct_algo:                    IDCT_Algorithm,

	/**
	 * bits per sample/pixel from the demuxer (needed for huffyuv).
	 * - encoding: Set by libavcodec.
	 * - decoding: Set by user.
	 */
	bits_per_coded_sample:        i32,

	/**
	 * Bits per sample/pixel of internal libavcodec pixel/sample format.
	 * - encoding: set by user.
	 * - decoding: set by libavcodec.
	 */
	bits_per_raw_sample:          i32,

	/**
	 * thread count
	 * is used to decide how many independent tasks should be passed to execute()
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	thread_count:                 i32,

	/**
	 * Which multithreading methods to use.
	 * Use of FF_THREAD_FRAME will increase decoding delay by one frame per thread,
	 * so clients which cannot provide future frames should not use it.
	 *
	 * - encoding: Set by user, otherwise the default is used.
	 * - decoding: Set by user, otherwise the default is used.
	 */
	thread_type:                  Thread_Type,

	/**
	 * Which multithreading methods are in use by the codec.
	 * - encoding: Set by libavcodec.
	 * - decoding: Set by libavcodec.
	 */
	active_thread_type:           i32,


	/**
	 * The codec may call this to execute several independent things.
	 * It will return only after finishing all tasks.
	 * The user may replace this with some multithreaded implementation,
	 * the default implementation will execute the parts serially.
	 * @param count the number of things to execute
	 * - encoding: Set by libavcodec, user can override.
	 * - decoding: Set by libavcodec, user can override.
	 */
	execute:                      #type proc(
		ctx: ^Codec_Context,
		func: #type proc(ctx: ^Codec_Context, arg: rawptr) -> i32,
		arg: rawptr,
		ret: ^i32,
		count: i32,
		size: i32,
	) -> i32,

	/**
	 * The codec may call this to execute several independent things.
	 * It will return only after finishing all tasks.
	 * The user may replace this with some multithreaded implementation,
	 * the default implementation will execute the parts serially.
	 * Also see avcodec_thread_init and e.g. the --enable-pthread configure option.
	 * @param c context passed also to func
	 * @param count the number of things to execute
	 * @param arg2 argument passed unchanged to func
	 * @param ret return values of executed functions, must have space for "count" values. May be NULL.
	 * @param func function that will be called count times, with jobnr from 0 to count-1.
	 *             threadnr will be in the range 0 to c->thread_count-1 < MAX_THREADS and so that no
	 *             two instances of func executing at the same time will have the same threadnr.
	 * @return always 0 currently, but code should handle a future improvement where when any call to func
	 *         returns < 0 no further calls to func may be done and < 0 is returned.
	 * - encoding: Set by libavcodec, user can override.
	 * - decoding: Set by libavcodec, user can override.
	 */
	execute2:                     #type proc(
		ctx: ^Codec_Context,
		func: #type proc(ctx: ^Codec_Context, arg: rawptr, jobnr: i32, threadnr: i32) -> i32,
		arg: rawptr,
		ret: ^i32,
		count: i32,
	) -> i32,

	/**
	 * profile
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec.
	 */
	profile:                      Codec_Profile,

	/**
	 * level
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec.
	 */
	level:                        i32,
	properties:                   u32,


	/**
	 * Skip loop filtering for selected frames.
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	skip_loop_filter:             Discard,

	/**
	 * Skip IDCT/dequantization for selected frames.
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	skip_idct:                    Discard,

	/**
	 * Skip decoding for selected frames.
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	skip_frame:                   Discard,
	skip_alpha:                   i32,
	skip_top:                     i32,
	skip_bottom:                  i32,
	lowres:                       i32,
	codec_desciptor:              ^Codec_Descriptor,
	sub_charenc:                  [^]c.char,
	sub_charenc_mode:             Subtitle_Character_Mode,

	/**
	 * Header containing style information for text subtitles.
	 * For SUBTITLE_ASS subtitle type, it should contain the whole ASS
	 * [Script Info] and [V4+ Styles] section, plus the [Events] line and
	 * the Format line following. It shouldn't include any Dialogue line.
	 * - encoding: Set/allocated/freed by user (before avcodec_open2())
	 * - decoding: Set/allocated/freed by libavcodec (by avcodec_open2())
	 */
	subtitle_header_size:         i32,
	subtitle_header:              [^]u8,

	/**
	 * dump format separator.
	 * can be ", " or "\n      " or anything else
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	dump_separator:               cstring,

	/**
	 * ',' separated list of allowed decoders.
	 * If NULL then all are allowed
	 * - encoding: unused
	 * - decoding: set by user
	 */
	codec_whitelist:              cstring,

	/**
	 * Additional data associated with the entire coded stream.
	 *
	 * - decoding: unused
	 * - encoding: may be set by libavcodec after avcodec_open2().
	 */
	coded_side_data:              [^]Packet_Side_Data,
	nb_coded_side_data:           i32,
	export_side_data:             i32,

	/**
	 * The number of pixels per image to maximally accept.
	 *
	 * - decoding: set by user
	 * - encoding: set by user
	 */
	max_pixels:                   i64,

	/**
	 * Video decoding only. Certain video codecs support cropping, meaning that
	 * only a sub-rectangle of the decoded frame is intended for display.  This
	 * option controls how cropping is handled by libavcodec.
	 *
	 * When set to 1 (the default), libavcodec will apply cropping internally.
	 * I.e. it will modify the output frame width/height fields and offset the
	 * data pointers (only by as much as possible while preserving alignment, or
	 * by the full amount if the AV_CODEC_FLAG_UNALIGNED flag is set) so that
	 * the frames output by the decoder refer only to the cropped area. The
	 * crop_* fields of the output frames will be zero.
	 *
	 * When set to 0, the width/height fields of the output frames will be set
	 * to the coded dimensions and the crop_* fields will describe the cropping
	 * rectangle. Applying the cropping is left to the caller.
	 *
	 * @warning When hardware acceleration with opaque output frames is used,
	 * libavcodec is unable to apply cropping from the top/left border.
	 *
	 * @note when this option is set to zero, the width/height fields of the
	 * AVCodec_Context and output AVFrames have different meanings. The codec
	 * context fields store display dimensions (with the coded dimensions in
	 * coded_width/height), while the frame fields store the coded dimensions
	 * (with the display dimensions being determined by the crop_* fields).
	 */
	apply_cropping:               i32,


	/**
	 * The percentage of damaged samples to discard a frame.
	 *
	 * - decoding: set by user
	 * - encoding: unused
	 */
	discard_damaged_percentage:   i32,

	/**
	 * The number of samples per frame to maximally accept.
	 *
	 * - decoding: set by user
	 * - encoding: set by user
	 */
	max_samples:                  i64,

	/**
	 * This callback is called at the beginning of each packet to get a data
	 * buffer for it.
	 *
	 * The following field will be set in the packet before this callback is
	 * called:
	 * - size
	 * This callback must use the above value to calculate the required buffer size,
	 * which must padded by at least AV_INPUT_BUFFER_PADDING_SIZE bytes.
	 *
	 * This callback must fill the following fields in the packet:
	 * - data: alignment requirements for AVPacket apply, if any. Some architectures and
	 *   encoders may benefit from having aligned data.
	 * - buf: must contain a pointer to an AVBufferRef structure. The packet's
	 *   data pointer must be contained in it. See: av_buffer_create(), av_buffer_alloc(),
	 *   and av_buffer_ref().
	 *
	 * If AV_CODEC_CAP_DR1 is not set then get_encode_buffer() must call
	 * avcodec_default_get_encode_buffer() instead of providing a buffer allocated by
	 * some other means.
	 *
	 * The flags field may contain a combination of AV_GET_ENCODE_BUFFER_FLAG_ flags.
	 * They may be used for example to hint what use the buffer may get after being
	 * created.
	 * Implementations of this callback may ignore flags they don't understand.
	 * If AV_GET_ENCODE_BUFFER_FLAG_REF is set in flags then the packet may be reused
	 * (read and/or written to if it is writable) later by libavcodec.
	 *
	 * This callback must be thread-safe, as when frame threading is used, it may
	 * be called from multiple threads simultaneously.
	 *
	 * @see avcodec_default_get_encode_buffer()
	 *
	 * - encoding: Set by libavcodec, user can override.
	 * - decoding: unused
	 */
	get_encode_buffer:            #type proc(ctx: ^Codec_Context, pkt: ^Packet, flags: i32) -> i32,

	/**
     * Frame counter, set by libavcodec.
     *
     * - decoding: total number of frames returned from the decoder so far.
     * - encoding: total number of frames passed to the encoder so far.
     *
     *   @note the counter is not incremented if encoding/decoding resulted in
     *   an error.
     */
	frame_num:                    i64,
	side_data_prefer_packet:      [^]i32,
	nb_side_data_prefer_packet:   u32,
	decoded_side_data:            [^][^]Frame_Side_Data,
	nb_decoded_side_data:         i32,
} // Codec_Context

/**
 * @defgroup lavc_hwaccel AVHWAccel
 *
 * @note  Nothing in this structure should be accessed by the user.  At some
 *        point in future it will not be externally visible at all.
 *
 * @{
 */
Hardware_Accelerator :: struct {
	name:         cstring,
	type:         Media_Type,
	id:           Codec_ID,
	pixel_format: Pixel_Format,
	capabilities: Hardware_Accelerator_Codec_Capabilities_Flag,
}

Hardware_Accelerator_Codec_Capabilities_Flag :: enum i32 {
	Experimental = 1 << 9,
}

Subtitle_Flag_Forced :: 0x00000001

Subtitle_Rect :: struct {
	x:         i32, ///< top left corner  of pict, undefined when pict is not set
	y:         i32, ///< top left corner  of pict, undefined when pict is not set
	w:         i32, ///< width            of pict, undefined when pict is not set
	h:         i32, ///< height           of pict, undefined when pict is not set
	nb_colors: i32, ///< number of colors in pict, undefined when pict is not set

	/**
	 * data+linesize for the bitmap of this subtitle.
	 * Can be set for text/ass as well once they are rendered.
	 */
	data:      [4][^]u8,
	linesize:  [4]i32,
	type:      Subtitle_Type,
	text:      cstring, ///< 0 terminated plain UTF-8 text

	/**
	 * 0 terminated ASS/SSA compatible event line.
	 * The presentation of this is unaffected by the other values in this
	 * struct.
	 */
	ass:       cstring,
	flags:     i32,
}

Subtitle :: struct {
	format:             u16, /* 0 = graphics */
	start_display_time: u32, /* relative to packet pts, in ms */
	end_display_time:   u32, /* relative to packet pts, in ms */
	num_rects:          u32,
	rects:              ^[^]Subtitle_Rect,
	pts:                i64, ///< Same as packet pts, in AV_TIME_BASE
}

PARSER_PTS_NB :: 4

Parser_Context_Flag :: enum i32 {
	Complete_Frames = 0,
	Once            = 1,
	/// Set if the parser has a valid file offset
	Fetched_Offset  = 2,
	Use_Codec_TS    = 12,
}
Parser_Context_Flags :: bit_set[Parser_Context_Flag;i32]

Codec_Parser_Context :: struct {
	priv_data:             rawptr,
	parser:                ^Codec_Parser,
	frame_offset:          i64, /* offset of the current frame */
	cur_offset:            i64, /* current offset (incremented by each av_parser_parse()) */
	next_frame_offset:     i64, /* offset of the next frame */
	/* video info */
	pict_type:             i64, /* XXX: Put it back in Codec_Context. */
	/**
	 * This field is used for proper frame duration computation in lavf.
	 * It signals, how much longer the frame duration of the current frame
	 * is compared to normal frame duration.
	 *
	 * frame_duration = (1 + repeat_pict) * time_base
	 *
	 * It is used by codecs like H.264 to display telecined material.
	 */
	repeat_pict:           i32, /* XXX: Put it back in Codec_Context. */
	pts:                   i64, /* pts of the current frame */
	dts:                   i64, /* dts of the current frame */

	/* private data */
	last_pts:              i64,
	last_dts:              i64,
	fetch_timestamp:       i32,
	cur_frame_start_index: i32,
	cur_frame_offset:      [PARSER_PTS_NB]i64,
	cur_frame_pts:         [PARSER_PTS_NB]i64,
	cur_frame_dts:         [PARSER_PTS_NB]i64,
	flags:                 Parser_Context_Flags,
	offset:                i64, ///< byte offset from starting packet start
	cur_frame_end:         [PARSER_PTS_NB]i64,

	/**
	 * Set by parser to 1 for key frames and 0 for non-key frames.
	 * It is initialized to -1, so if the parser doesn't set this flag,
	 * old-style fallback using AV_PICTURE_TYPE_I picture type as key frames
	 * will be used.
	 */
	key_frame:             i32,

	// Timestamp generation support:
	/**
	 * Synchronization point for start of timestamp generation.
	 *
	 * Set to >0 for sync point, 0 for no sync point and <0 for undefined
	 * (default).
	 *
	 * For example, this corresponds to presence of H.264 buffering period
	 * SEI message.
	 */
	dts_sync_point:        i32,

	/**
	 * Offset of the current timestamp against last timestamp sync point in
	 * units of AVCodec_Context.time_base.
	 *
	 * Set to INT_MIN when dts_sync_point unused. Otherwise, it must
	 * contain a valid timestamp offset.
	 *
	 * Note that the timestamp of sync point has usually a nonzero
	 * dts_ref_dts_delta, which refers to the previous sync point. Offset of
	 * the next frame after timestamp sync point will be usually 1.
	 *
	 * For example, this corresponds to H.264 cpb_removal_delay.
	 */
	dts_ref_dts_delta:     i32,

	/**
	 * Presentation delay of current frame in units of AVCodec_Context.time_base.
	 *
	 * Set to INT_MIN when dts_sync_point unused. Otherwise, it must
	 * contain valid non-negative timestamp delta (presentation time of a frame
	 * must not lie in the past).
	 *
	 * This delay represents the difference between decoding and presentation
	 * time of the frame.
	 *
	 * For example, this corresponds to H.264 dpb_output_delay.
	 */
	pts_dts_delta:         i32,

	/**
	 * Position of the packet in file.
	 *
	 * Analogous to cur_frame_pts/dts
	 */
	cur_frame_pos:         [PARSER_PTS_NB]i64,

	/**
	 * Byte position of currently parsed frame in stream.
	 */
	pos:                   i64,

	/**
	 * Previous frame byte position.
	 */
	last_pos:              i64,

	/**
	 * Duration of the current frame.
	 * For audio, this is in units of 1 / AVCodec_Context.sample_rate.
	 * For all other types, this is in units of AVCodec_Context.time_base.
	 */
	duration:              i32,
	field_order:           Field_Order,

	/**
	 * Indicate whether a picture is coded as a frame, top field or bottom field.
	 *
	 * For example, H.264 field_pic_flag equal to 0 corresponds to
	 * AV_PICTURE_STRUCTURE_FRAME. An H.264 picture with field_pic_flag
	 * equal to 1 and bottom_field_flag equal to 0 corresponds to
	 * AV_PICTURE_STRUCTURE_TOP_FIELD.
	 */
	picture_structure:     Picture_Structure,

	/**
	 * Picture number incremented in presentation or output order.
	 * This field may be reinitialized at the first picture of a new sequence.
	 *
	 * For example, this corresponds to H.264 PicOrderCnt.
	 */
	output_picture_number: i32,

	/**
	 * Dimensions of the decoded video intended for presentation.
	 */
	width:                 i32,
	height:                i32,

	/**
	 * Dimensions of the coded video.
	 */
	coded_width:           i32,
	coded_height:          i32,

	/**
	 * The format of the coded data, corresponds to enum AVPixel_Format for video
	 * and for enum AVSampleFormat for audio.
	 *
	 * Note that a decoder can have considerable freedom in how exactly it
	 * decodes the data, so the format reported here might be different from the
	 * one returned by a decoder.
	 */
	format:                struct #raw_union {
		video: Pixel_Format,
		audio: Sample_Format,
	},
}

CODEC_PARSER_NUM_IDS :: 7

Codec_Parser :: struct {
	codec_ids:      [CODEC_PARSER_NUM_IDS]i32, /* several codec IDs are permitted */
	priv_data_size: i32,
	parser_init:    #type proc(ctx: ^Codec_Parser_Context) -> i32,

	/* This callback never returns an error, a negative value means that
	 * the frame start was in a previous packet. */
	parser_parse:   #type proc(
		ctx: ^Codec_Parser_Context,
		avctx: ^Codec_Context,
		poutbuf: ^[^]u8,
		poutbuf_size: ^i32,
		buf: [^]u8,
		buf_size: i32,
	) -> i32,
	parser_close:   #type proc(ctx: ^Codec_Parser_Context),
	split:          #type proc(ctx: ^Codec_Context, buf: [^]u8, buf_size: i32) -> i32,
}


/**
 * The bitstream filter state.
 *
 * This struct must be allocated with av_bsf_alloc() and freed with
 * av_bsf_free().
 *
 * The fields in the struct will only be changed (by the caller or by the
 * filter) as described in their documentation, and are to be considered
 * immutable otherwise.
 */
BSF_Context :: struct {
	/**
	 * A class for logging and AVOptions
	 */
	class:         ^Class,

	/**
	 * The bitstream filter this context is an instance of.
	 */
	filter:        ^Bit_Stream_Filter,

	/**
	 * Opaque filter-specific private data. If filter->priv_class is non-NULL,
	 * this is an AVOptions-enabled struct.
	 */
	priv_data:     rawptr,

	/**
	 * Parameters of the input stream. This field is allocated in
	 * av_bsf_alloc(), it needs to be filled by the caller before
	 * av_bsf_init().
	 */
	par_in:        ^Codec_Parameters,

	/**
	 * Parameters of the output stream. This field is allocated in
	 * av_bsf_alloc(), it is set by the filter in av_bsf_init().
	 */
	par_out:       ^Codec_Parameters,

	/**
	 * The timebase used for the timestamps of the input packets. Set by the
	 * caller before av_bsf_init().
	 */
	time_base_in:  Rational,

	/**
	 * The timebase used for the timestamps of the output packets. Set by the
	 * filter in av_bsf_init().
	 */
	time_base_out: Rational,
}

Bit_Stream_Filter :: struct {
	name:       cstring,

	/**
	 * A list of codec ids supported by the filter, terminated by
	 * NONE.
	 * May be NULL, in that case the bitstream filter works with any codec id.
	 */
	codec_ids:  [^]Codec_ID,

	/**
	 * A class for the private data, used to declare bitstream filter private
	 * AVOptions. This field is NULL for bitstream filters that do not declare
	 * any options.
	 *
	 * If this field is non-NULL, the first member of the filter private data
	 * must be a pointer to AVClass, which will be set by libavcodec generic
	 * code to this class.
	 */
	priv_class: ^Class,
}


Bit_Stream_Filter_Context :: struct {
	priv_data: rawptr,
	filter:    ^Bit_Stream_Filter,
	parser:    ^Codec_Parser_Context,
	next:      ^Bit_Stream_Filter_Context,
	/**
	 * Internal default arguments, used if NULL is passed to av_bitstream_filter_filter().
	 * Not for access by library users.
	 */
	args:      cstring,
}

Lock_Operation :: enum i32 {
	Create, ///< Create a mutex
	Obtain, ///< Lock the mutex
	Release, ///< Unlock the mutex
	Destroy, ///< Free mutex resources
}

//===codec_desc.h
Codec_Descriptor_Property :: enum i32 {
	/**
	 * Codec uses only intra compression.
	 * Video and audio codecs only.
	 */
	Intra_Only = 0,
	/**
	 * Codec supports lossy compression. Audio and video codecs only.
	 * @note a codec may support both lossy and lossless
	 * compression modes
	 */
	Lossy      = 1,
	/**
	 * Codec supports lossless compression. Audio and video codecs only.
	 */
	Lossless   = 2,
	/**
	 * Codec supports frame reordering. That is, the coded order (the order in which
	 * the encoded packets are output by the encoders / stored / input to the
	 * decoders) may be different from the presentation order of the corresponding
	 * frames.
	 *
	 * For codecs that do not have this property set, PTS and DTS should always be
	 * equal.
	 */
	Reorder    = 3,
	/**
	 * Video codec supports separate coding of fields in interlaced frames.
 	*/
	Fields     = 4,
	/**
	 * Subtitle codec is bitmap based
	 * Decoded AVSubtitle data can be read from the AVSubtitleRect->pict field.
	 */
	Bitmap_Sub = 16,
	/**
	 * Subtitle codec is text based.
	 * Decoded AVSubtitle data can be read from the AVSubtitleRect->ass field.
	 */
	Text_Sub   = 17,
}
Codec_Descriptor_Properties :: bit_set[Codec_Descriptor_Property;i32]

Codec_Descriptor :: struct {
	id:         Codec_ID,
	type:       Media_Type,

	/**
	 * Name of the codec described by this descriptor. It is non-empty and
	 * unique for each codec descriptor. It should contain alphanumeric
	 * characters and '_' only.
	 */
	name:       cstring,
	/**
	 * A more descriptive name for this codec. May be NULL.
	 */
	long_name:  cstring,
	/**
	 * Codec properties, a combination of AV_CODEC_PROP_* flags.
	 */
	props:      Codec_Descriptor_Properties,
	/**
	 * MIME type(s) associated with the codec.
	 * May be NULL if not, a NULL-terminated array of MIME types.
	 * The first item is always non-NULL and is the preferred MIME type.
	 */
	mime_types: [^]cstring,
	/**
	 * If non-NULL, an array of profiles recognized for this codec.
	 * Terminated with FF_PROFILE_UNKNOWN.
	 */
	profiles:   [^]Profile,
}

HANDLE :: distinct rawptr

//??? what to do here?
//these structs are all windows d3d11 structs.
//left as dummy structs here, but maybe merge with
//existing d3d libs?
//TODO: ensure that putting these here to force a typecheck isn't a horrible idea.
ID3D11_Video_Decoder :: struct {
}
ID3D11_Video_Context :: struct {
}
D3D11_Video_Decoder_Config :: struct {
}
ID3D11_Video_Decoder_Output_View :: struct {
}

D3D11VA_Context :: struct {
	decoder:       ^ID3D11_Video_Decoder,
	video_context: ^ID3D11_Video_Context,
	cfg:           ^D3D11_Video_Decoder_Config,
	surface_count: u32,
	surface:       ^[^]ID3D11_Video_Decoder_Output_View,
	workaround:    u64,
	report_id:     u32,
	context_mutex: HANDLE,
}


//===dxva2.h===
//mystery structs defined in d3d9.h and dxva2api.h
IDirectX_Video_Decoder :: struct {
}
DXVA2_Config_Picture_Decode :: struct {
}
LP_DIRECT_3D_SURFACE_9 :: struct {
}

DXVA_Context :: struct {
	decoder:       ^IDirectX_Video_Decoder,
	cfg:           ^DXVA2_Config_Picture_Decode,
	surface_count: u32,
	surface:       ^LP_DIRECT_3D_SURFACE_9,
	workaround:    u64,
	report_id:     u32,
}


/* ==============================================================================================
   CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS
   ============================================================================================== */

Codec_ID :: enum u32 {
	NONE,

	/* video codecs */
	MPEG1VIDEO,
	MPEG2VIDEO, ///< preferred ID for MPEG-1/2 video decoding
	H261,
	H263,
	RV10,
	RV20,
	MJPEG,
	MJPEGB,
	LJPEG,
	SP5X,
	JPEGLS,
	MPEG4,
	RAWVIDEO,
	MSMPEG4V1,
	MSMPEG4V2,
	MSMPEG4V3,
	WMV1,
	WMV2,
	H263P,
	H263I,
	FLV1,
	SVQ1,
	SVQ3,
	DVVIDEO,
	HUFFYUV,
	CYUV,
	H264,
	INDEO3,
	VP3,
	THEORA,
	ASV1,
	ASV2,
	FFV1,
	_4XM,
	VCR1,
	CLJR,
	MDEC,
	ROQ,
	INTERPLAY_VIDEO,
	XAN_WC3,
	XAN_WC4,
	RPZA,
	CINEPAK,
	WS_VQA,
	MSRLE,
	MSVIDEO1,
	IDCIN,
	_8BPS,
	SMC,
	FLIC,
	TRUEMOTION1,
	VMDVIDEO,
	MSZH,
	ZLIB,
	QTRLE,
	TSCC,
	ULTI,
	QDRAW,
	VIXL,
	QPEG,
	PNG,
	PPM,
	PBM,
	PGM,
	PGMYUV,
	PAM,
	FFVHUFF,
	RV30,
	RV40,
	VC1,
	WMV3,
	LOCO,
	WNV1,
	AASC,
	INDEO2,
	FRAPS,
	TRUEMOTION2,
	BMP,
	CSCD,
	MMVIDEO,
	ZMBV,
	AVS,
	SMACKVIDEO,
	NUV,
	KMVC,
	FLASHSV,
	CAVS,
	JPEG2000,
	VMNC,
	VP5,
	VP6,
	VP6F,
	TARGA,
	DSICINVIDEO,
	TIERTEXSEQVIDEO,
	TIFF,
	GIF,
	DXA,
	DNXHD,
	THP,
	SGI,
	C93,
	BETHSOFTVID,
	PTX,
	TXD,
	VP6A,
	AMV,
	VB,
	PCX,
	SUNRAST,
	INDEO4,
	INDEO5,
	MIMIC,
	RL2,
	ESCAPE124,
	DIRAC,
	BFI,
	CMV,
	MOTIONPIXELS,
	TGV,
	TGQ,
	TQI,
	AURA,
	AURA2,
	V210X,
	TMV,
	V210,
	DPX,
	MAD,
	FRWU,
	FLASHSV2,
	CDGRAPHICS,
	R210,
	ANM,
	BINKVIDEO,
	IFF_ILBM,
	IFF_BYTERUN1 = IFF_ILBM,
	KGV1,
	YOP,
	VP8,
	PICTOR,
	ANSI,
	A64_MULTI,
	A64_MULTI5,
	R10K,
	MXPEG,
	LAGARITH,
	PRORES,
	JV,
	DFA,
	WMV3IMAGE,
	VC1IMAGE,
	UTVIDEO,
	BMV_VIDEO,
	VBLE,
	DXTORY,
	V410,
	XWD,
	CDXL,
	XBM,
	ZEROCODEC,
	MSS1,
	MSA1,
	TSCC2,
	MTS2,
	CLLC,
	MSS2,
	VP9,
	AIC,
	ESCAPE130,
	G2M,
	WEBP,
	HNM4_VIDEO,
	HEVC,
	H265 = HEVC,
	FIC,
	ALIAS_PIX,
	BRENDER_PIX,
	PAF_VIDEO,
	EXR,
	VP7,
	SANM,
	SGIRLE,
	MVC1,
	MVC2,
	HQX,
	TDSC,
	HQ_HQA,
	HAP,
	DDS,
	DXV,
	SCREENPRESSO,
	RSCC,
	AVS2,
	PGX,
	AVS3,
	MSP2,
	VVC,
	H266 = VVC,
	Y41P,
	AVRP,
	_012V,
	AVUI,
	TARGA_Y216,
	V308,
	V408,
	YUV4,
	AVRN,
	CPIA,
	XFACE,
	SNOW,
	SMVJPEG,
	APNG,
	DAALA,
	CFHD,
	TRUEMOTION2RT,
	M101,
	MAGICYUV,
	SHEERVIDEO,
	YLC,
	PSD,
	PIXLET,
	SPEEDHQ,
	FMVC,
	SCPR,
	CLEARVIDEO,
	XPM,
	AV1,
	BITPACKED,
	MSCC,
	SRGC,
	SVG,
	GDV,
	FITS,
	IMM4,
	PROSUMER,
	MWSC,
	WCMV,
	RASC,
	HYMT,
	ARBC,
	AGM,
	LSCR,
	VP4,
	IMM5,
	MVDV,
	MVHA,
	CDTOONS,
	MV30,
	NOTCHLC,
	PFM,
	MOBICLIP,
	PHOTOCD,
	IPU,
	ARGO,
	CRI,
	SIMBIOSIS_IMX,
	SGA_VIDEO,
	GEM,
	VBN,
	JPEGXL,
	QOI,
	PHM,
	RADIANCE_HDR,
	WBMP,
	MEDIA100,
	VQC,
	PDV,
	EVC,
	RTV1,
	VMIX,
	LEAD,

	/* various PCM "codecs" */
	FIRST_AUDIO = 0x10000, ///< A dummy id pointing at the start of audio codecs
	PCM_S16LE = 0x10000,
	PCM_S16BE,
	PCM_U16LE,
	PCM_U16BE,
	PCM_S8,
	PCM_U8,
	PCM_MULAW,
	PCM_ALAW,
	PCM_S32LE,
	PCM_S32BE,
	PCM_U32LE,
	PCM_U32BE,
	PCM_S24LE,
	PCM_S24BE,
	PCM_U24LE,
	PCM_U24BE,
	PCM_S24DAUD,
	PCM_ZORK,
	PCM_S16LE_PLANAR,
	PCM_DVD,
	PCM_F32BE,
	PCM_F32LE,
	PCM_F64BE,
	PCM_F64LE,
	PCM_BLURAY,
	PCM_LXF,
	S302M,
	PCM_S8_PLANAR,
	PCM_S24LE_PLANAR,
	PCM_S32LE_PLANAR,
	PCM_S16BE_PLANAR,
	PCM_S64LE,
	PCM_S64BE,
	PCM_F16LE,
	PCM_F24LE,
	PCM_VIDC,
	PCM_SGA,

	/* various ADPCM codecs */
	ADPCM_IMA_QT = 0x11000,
	ADPCM_IMA_WAV,
	ADPCM_IMA_DK3,
	ADPCM_IMA_DK4,
	ADPCM_IMA_WS,
	ADPCM_IMA_SMJPEG,
	ADPCM_MS,
	ADPCM_4XM,
	ADPCM_XA,
	ADPCM_ADX,
	ADPCM_EA,
	ADPCM_G726,
	ADPCM_CT,
	ADPCM_SWF,
	ADPCM_YAMAHA,
	ADPCM_SBPRO_4,
	ADPCM_SBPRO_3,
	ADPCM_SBPRO_2,
	ADPCM_THP,
	ADPCM_IMA_AMV,
	ADPCM_EA_R1,
	ADPCM_EA_R3,
	ADPCM_EA_R2,
	ADPCM_IMA_EA_SEAD,
	ADPCM_IMA_EA_EACS,
	ADPCM_EA_XAS,
	ADPCM_EA_MAXIS_XA,
	ADPCM_IMA_ISS,
	ADPCM_G722,
	ADPCM_IMA_APC,
	ADPCM_VIMA,
	ADPCM_AFC,
	ADPCM_IMA_OKI,
	ADPCM_DTK,
	ADPCM_IMA_RAD,
	ADPCM_G726LE,
	ADPCM_THP_LE,
	ADPCM_PSX,
	ADPCM_AICA,
	ADPCM_IMA_DAT4,
	ADPCM_MTAF,
	ADPCM_AGM,
	ADPCM_ARGO,
	ADPCM_IMA_SSI,
	ADPCM_ZORK,
	ADPCM_IMA_APM,
	ADPCM_IMA_ALP,
	ADPCM_IMA_MTF,
	ADPCM_IMA_CUNNING,
	ADPCM_IMA_MOFLEX,
	ADPCM_IMA_ACORN,
	ADPCM_XMD,

	/* AMR */
	AMR_NB = 0x12000,
	AMR_WB,

	/* RealAudio codecs*/
	RA_144 = 0x13000,
	RA_288,

	/* various DPCM codecs */
	ROQ_DPCM = 0x14000,
	INTERPLAY_DPCM,
	XAN_DPCM,
	SOL_DPCM,
	SDX2_DPCM,
	GREMLIN_DPCM,
	DERF_DPCM,
	WADY_DPCM,
	CBD2_DPCM,

	/* audio codecs */
	MP2 = 0x15000,
	MP3, ///< preferred ID for decoding MPEG audio layer 1, 2 or 3
	AAC,
	AC3,
	DTS,
	VORBIS,
	DVAUDIO,
	WMAV1,
	WMAV2,
	MACE3,
	MACE6,
	VMDAUDIO,
	FLAC,
	MP3ADU,
	MP3ON4,
	SHORTEN,
	ALAC,
	WESTWOOD_SND1,
	GSM, ///< as in Berlin toast format
	QDM2,
	COOK,
	TRUESPEECH,
	TTA,
	SMACKAUDIO,
	QCELP,
	WAVPACK,
	DSICINAUDIO,
	IMC,
	MUSEPACK7,
	MLP,
	GSM_MS, /* as found in WAV */
	ATRAC3,
	APE,
	NELLYMOSER,
	MUSEPACK8,
	SPEEX,
	WMAVOICE,
	WMAPRO,
	WMALOSSLESS,
	ATRAC3P,
	EAC3,
	SIPR,
	MP1,
	TWINVQ,
	TRUEHD,
	MP4ALS,
	ATRAC1,
	BINKAUDIO_RDFT,
	BINKAUDIO_DCT,
	AAC_LATM,
	QDMC,
	CELT,
	G723_1,
	G729,
	_8SVX_EXP,
	_8SVX_FIB,
	BMV_AUDIO,
	RALF,
	IAC,
	ILBC,
	OPUS,
	COMFORT_NOISE,
	TAK,
	METASOUND,
	PAF_AUDIO,
	ON2AVC,
	DSS_SP,
	CODEC2,
	FFWAVESYNTH,
	SONIC,
	SONIC_LS,
	EVRC,
	SMV,
	DSD_LSBF,
	DSD_MSBF,
	DSD_LSBF_PLANAR,
	DSD_MSBF_PLANAR,
	_4GV,
	INTERPLAY_ACM,
	XMA1,
	XMA2,
	DST,
	ATRAC3AL,
	ATRAC3PAL,
	DOLBY_E,
	APTX,
	APTX_HD,
	SBC,
	ATRAC9,
	HCOM,
	ACELP_KELVIN,
	MPEGH_3D_AUDIO,
	SIREN,
	HCA,
	FASTAUDIO,
	MSNSIREN,
	DFPWM,
	BONK,
	MISC4,
	APAC,
	FTR,
	WAVARC,
	RKA,
	AC4,
	OSQ,

	/* subtitle codecs */
	FIRST_SUBTITLE = 0x17000, ///< A dummy ID pointing at the start of subtitle codecs.
	DVD_SUBTITLE = 0x17000,
	DVB_SUBTITLE,
	TEXT, ///< raw UTF-8 text
	XSUB,
	SSA,
	MOV_TEXT,
	HDMV_PGS_SUBTITLE,
	DVB_TELETEXT,
	SRT,
	MICRODVD,
	EIA_608,
	JACOSUB,
	SAMI,
	REALTEXT,
	STL,
	SUBVIEWER1,
	SUBVIEWER,
	SUBRIP,
	WEBVTT,
	MPL2,
	VPLAYER,
	PJS,
	ASS,
	HDMV_TEXT_SUBTITLE,
	TTML,
	ARIB_CAPTION,

	/* other specific kind of codecs (generally used for attachments) */
	FIRST_UNKNOWN = 0x18000, ///< A dummy ID pointing at the start of various fake codecs.
	TTF = 0x18000,
	SCTE_35, ///< Contain timestamp estimated through PCR of program stream.
	EPG,
	BINTEXT,
	XBIN,
	IDF,
	OTF,
	SMPTE_KLV,
	DVD_NAV,
	TIMED_ID3,
	BIN_DATA,
	SMPTE_2038,
	PROBE = 0x19000, ///< codec_id is not known (like NONE) but lavf should attempt to identify it
	MPEG2TS = 0x20000, /**< _FAKE_ codec to indicate a raw MPEG-2 TS
                                * stream (only used by libavformat) */
	MPEG4SYSTEMS = 0x20001, /**< _FAKE_ codec to indicate a MPEG-4 Systems
                                * stream (only used by libavformat) */
	FFMETADATA = 0x21000, ///< Dummy codec for streams containing only metadata information.
	WRAPPED_AVFRAME = 0x21001, ///< Passthrough codec, AVFrames wrapped in AVPacket
	/**
     * Dummy null video codec, useful mainly for development and debugging.
     * Null encoder/decoder discard all input and never return any output.
     */
	VNULL,
	/**
     * Dummy null audio codec, useful mainly for development and debugging.
     * Null encoder/decoder discard all input and never return any output.
     */
	ANULL,
}

///////******** MY STUFF
//===dirac.h===
Dirac_Parse_Codes :: enum i32 {
	SEQ_HEADER      = 0x00,
	END_SEQ         = 0x10,
	AUX             = 0x20,
	PAD             = 0x30,
	PICTURE_CODED   = 0x08,
	PICTURE_RAW     = 0x48,
	PICTURE_LOW_DEL = 0xC8,
	PICTURE_HQ      = 0xE8,
	INTER_NOREF_CO1 = 0x0A,
	INTER_NOREF_CO2 = 0x09,
	INTER_REF_CO1   = 0x0D,
	INTER_REF_CO2   = 0x0E,
	INTRA_REF_CO    = 0x0C,
	INTRA_REF_RAW   = 0x4C,
	INTRA_REF_PICT  = 0xCC,
	MAGIC           = 0x42424344,
}

Dirac_Version_Info :: struct {
	major, minor: i32,
}

Dirac_Sequence_Header :: struct {
	width:               u32,
	height:              u32,
	chroma_format:       u8, ///< 0: 444  1: 422  2: 420
	interlaced:          u8,
	top_field_first:     u8,
	frame_rate_index:    u8, ///< index into dirac_frame_rate[]
	aspect_ratio_index:  u8, ///< index into dirac_aspect_ratio[]
	clean_width:         u16,
	clean_height:        u16,
	clean_left_offset:   u16,
	clean_right_offset:  u16,
	pixel_range_index:   u8, ///< index into dirac_pixel_range_presets[]
	color_spec_index:    u8, ///< index into dirac_color_spec_presets[]
	profile:             i32,
	level:               i32,
	framerate:           Rational,
	sample_aspect_ratio: Rational,
	pix_fmt:             Pixel_Format,
	color_range:         Color_Range,
	color_primaries:     Color_Primaries,
	color_trc:           Color_Transfer_Characteristic,
	colorspace:          Color_Space,
	version:             Dirac_Version_Info,
	bit_depth:           i32,
}

//===mediacodec.h===
Media_Codec_Context :: struct {
	// android/view/Surface object reference.
	surface: rawptr,
}

Media_Codec_Buffer :: struct {
}


FFT_Complex :: struct {
	re, im: FFT_Sample,
}

FFT_Context :: struct {
}
FFT_Sample :: f32

/* Real Discrete Fourier Transform */

RDFT_Transform_Type :: enum i32 {
	DFT_R2C,
	IDFT_C2R,
	IDFT_R2C,
	DFT_C2R,
}
RDFT_Context :: struct {
}

DCT_Transform_Type :: enum i32 {
	DCT_II = 0,
	DCT_III,
	DCT_I,
	DST_I,
}
DCT_Context :: struct {
}

BSF_List :: struct {
}


//===qsv.h===
/*
mfxSession :: struct{}
mfxExtBuffer :: struct{}

//These struct fields are not just opaque pointers.
//without knowing what mfxSession is I can't create the struct.
QSV_Context :: struct {
    session:mfxSession, //libavcodec will try to create session if null.
    iopattern:i32, 
    ext_buffers:^[^]mfxExtBuffer,
    nb_ext_buffers:i32,

	opaque_alloc:i32,
    nb_opaque_surfaces:i32,
    opaque_surfaces:^Buffer_Ref,
    opaque_alloc_type:i32,
}

//===vdpau.h===
VDPAU_Context {
	decoder: VdpDecoder,
	render:^VdpDecoderRender,
}
*/
/*
Video_Toolbox_Context :: struct {
    /**
     * Videotoolbox decompression session object.
     * Created and freed the caller.
     */
    VTDecompressionSessionRef session;

    /**
     * CVPixelBuffer Format Type that Videotoolbox will use for decoded frames.
     * set by the caller. If this is set to 0, then no specific format is
     * requested from the decoder, and its native format is output.
     */
    OSType cv_pix_fmt_type;

    /**
     * CoreMedia Format Description that Videotoolbox will use to create the decompression session.
     * Set by the caller.
     */
    CMVideoFormatDescriptionRef cm_fmt_desc;

    /**
     * CoreMedia codec type that Videotoolbox will use to create the decompression session.
     * Set by the caller.
     */
    cm_codec_type:i32,
} 
*/

Vorbis_Parse_Context :: struct {
}

Vorbis_Flag :: enum i32 {
	Header  = 0,
	Comment = 1,
	Setup   = 2,
}
Vorbis_Flags :: bit_set[Vorbis_Flag;i32]

//from avformat/avio
/* Avoid a warning. The header can not be included because it breaks c++. */


Escape_Mode :: enum i32 {
	Auto, ///< Use auto-selected escaping mode.
	Backslash, ///< Use backslash escaping.
	Quote, ///< Use single-quote escaping.
	XML, ///< Use XML non-markup character data escaping.
}

Escape_Flag :: enum i32 {
	Whitepspace       = (1 << 0),
	Strict            = (1 << 1),
	XML_Single_Quotes = (1 << 2),
	XML_Double_Quotes = (1 << 3),
}

Escape_Flags :: bit_set[Escape_Flag;i32]

UTF8_Flag :: enum u32 {
	Accept_Invalid_Big_Codes          = 1 << 0, // accept codepoints over 0x10FFFF
	Accept_Non_Characters             = 1 << 1, // accept non-characters - 0xFFFE and 0xFFFF
	Accept_Surrogates                 = 1 << 2, // accept UTF-16 surrogates codes
	Exclude_XML_Invalid_Control_Codes = 1 << 3, // exclude control codes not accepted by XML
}
UTF8_Flags :: bit_set[UTF8_Flag;u32]


//TODO: Big task: sometimes unclear whether a **
//is ^[^] or [^]^. This matters for correct access of later elements.
//second seems more common? Need to determine this for each case.


//MYSTUFF OVER


/* ==============================================================================================
	  DEVICES - DEVICES - DEVICES - DEVICES - DEVICES - DEVICES - DEVICES - DEVICES - DEVICES
   ============================================================================================== */

//===avdevice.h===
Device_Rect :: struct {
	x, y:          i32,
	width, height: i32,
}


App_To_Dev_Message_Type :: enum i32 {
	None           = 'E' | 'N' << 8 | 'O' << 16 | 'N' << 24,
	Window_Size    = 'M' | 'O' << 8 | 'E' << 16 | 'G' << 24,
	Window_Repaint = 'A' | 'P' << 8 | 'E' << 16 | 'R' << 24,
	Pause          = ' ' | 'U' << 8 | 'A' << 16 | 'P' << 24,
	Play           = 'Y' | 'A' << 8 | 'L' << 16 | 'P' << 24,
	Toggle_Pause   = 'T' | 'U' << 8 | 'A' << 16 | 'P' << 24,
	Set_Volume     = 'L' | 'O' << 8 | 'V' << 16 | 'S' << 24,
	Mute           = 'T' | 'U' << 8 | 'M' << 16 | ' ' << 24,
	Unmute         = 'T' | 'U' << 8 | 'M' << 16 | 'U' << 24,
	Toggle_Mute    = 'T' | 'U' << 8 | 'M' << 16 | 'T' << 24,
	Get_Volume     = 'L' | 'O' << 8 | 'V' << 16 | 'G' << 24,
	Get_Mute       = 'T' | 'U' << 8 | 'M' << 16 | 'G' << 24,
}

Dev_To_App_Message_Type :: enum i32 {
	None                  = 'E' | 'N' << 8 | 'O' << 16 | 'N' << 24,
	Create_Window_Buffer  = 'E' | 'R' << 8 | 'C' << 16 | 'B' << 24,
	Prepare_Window_Buffer = 'E' | 'R' << 8 | 'P' << 16 | 'B' << 24,
	Display_Window_Buffer = 'S' | 'I' << 8 | 'D' << 16 | 'B' << 24,
	Destroy_Window_Buffer = 'S' | 'E' << 8 | 'D' << 16 | 'B' << 24,
	Buffer_Overflow       = 'L' | 'F' << 8 | 'O' << 16 | 'B' << 24,
	Buffer_Underflow      = 'L' | 'F' << 8 | 'U' << 16 | 'B' << 24,
	Buffer_Readable       = ' ' | 'D' << 8 | 'R' << 16 | 'B' << 24,
	Buffer_Writable       = ' ' | 'R' << 8 | 'W' << 16 | 'B' << 24,
	Mute_State_Changed    = 'T' | 'U' << 8 | 'M' << 16 | 'C' << 24,
	Volume_Level_Changed  = 'L' | 'O' << 8 | 'V' << 16 | 'C' << 24,
}

Device_Info :: struct {
	device_name:        cstring,
	device_description: cstring,
	media_types:        [^]Media_Type,
	nb_media_types:     i32,
}

Device_Info_List :: struct {
	devices:        ^[^]Device_Info,
	nb_devices:     i32,
	default_device: i32,
}


//====//


Codec_Hardware_Config :: struct {
	pix_fmt:     Pixel_Format,
	methods:     Codec_HW_Config_Methods,
	device_type: Hardware_Device_Type,
}

Codec_HW_Config_Method :: enum i32 {
	HW_Device_Context = 1,
	HW_Frame_Context  = 2,
	Internal          = 4,
	AdHoc             = 8,
}
Codec_HW_Config_Methods :: bit_set[Codec_HW_Config_Method;i32]
/**
 * Following API allows user to probe device capabilities (supported codecs,
 * pixel formats, sample formats, resolutions, channel counts, etc).
 * It is build on top op AVOption API.
 * Queried capabilities make it possible to set up converters of video or audio
 * parameters that fit to the device.
 *
 * List of capabilities that can be queried:
 *  - Capabilities valid for both audio and video devices:
 *    - codec:          supported audio/video codecs.
 *                      type: AV_OPT_TYPE_INT (AVCodecID value)
 *  - Capabilities valid for audio devices:
 *    - sample_format:  supported sample formats.
 *                      type: AV_OPT_TYPE_INT (AVSampleFormat value)
 *    - sample_rate:    supported sample rates.
 *                      type: AV_OPT_TYPE_INT
 *    - channels:       supported number of channels.
 *                      type: AV_OPT_TYPE_INT
 *    - channel_layout: supported channel layouts.
 *                      type: AV_OPT_TYPE_INT64
 *  - Capabilities valid for video devices:
 *    - pixel_format:   supported pixel formats.
 *                      type: AV_OPT_TYPE_INT (AVPixel_Format value)
 *    - window_size:    supported window sizes (describes size of the window size presented to the user).
 *                      type: AV_OPT_TYPE_IMAGE_SIZE
 *    - frame_size:     supported frame sizes (describes size of provided video frames).
 *                      type: AV_OPT_TYPE_IMAGE_SIZE
 *    - fps:            supported fps values
 *                      type: AV_OPT_TYPE_RATIONAL
 *
 * Value of the capability may be set by user using av_opt_set() function
 * and AVDeviceCapabilitiesQuery object. Following queries will
 * limit results to the values matching already set capabilities.
 * For example, setting a codec may impact number of formats or fps values
 * returned during next query. Setting invalid value may limit results to zero.
*/
Device_Capabilities_Query :: struct {
	class:          ^Class,
	device_context: ^Format_Context,
	codec:          Codec_ID,
	sample_format:  Sample_Format,
	pixel_format:   Pixel_Format,
	sample_rate:    i32,
	channels:       i32,
	channel_layout: Channel_Layout,
	window_width:   i32,
	window_height:  i32,
	frame_width:    i32,
	frame_height:   i32,
	fps:            Rational,
}

/* ==============================================================================================
	  FILTERS - FILTERS - FILTERS - FILTERS - FILTERS - FILTERS - FILTERS - FILTERS - FILTERS 
   ============================================================================================== */
//===avfilter.h===
Filter_Flag :: enum i32 {
	Dynamic_Inputs            = 0,
	Dynamic_Outputs           = 1,
	Slice_Threads             = 2,
	Metadata_Only             = 3,
	Hardware_Device           = 4,
	Support_Timeline_Generic  = 16,
	Support_Timeline_Internal = 17,
}
//Support_Timeline is 1<<16 | 1<<17. How can I do this?
Filter_Flags :: bit_set[Filter_Flag;i32]

Buffer_Src_Flag :: enum i32 {
	No_Check_Format = 0,
	Push            = 2,
	Keep_Ref        = 3,
}
Buffer_Src_Flags :: bit_set[Buffer_Src_Flag;i32]

Filter_Buffer_Src_Parameters :: struct {
	format:              i32,
	time_base:           Rational,
	width, height:       i32,
	sample_aspect_ratio: Rational,
	frame_rate:          Rational,
	hw_frames_ctx:       ^Buffer_Ref,
	sample_rate:         i32,
	ch_layout:           Channel_Layout,
}


Buffer_Sink_Flag :: enum i32 {
	Peek       = 0,
	No_Request = 1,
}
Buffer_Sink_Flags :: bit_set[Buffer_Sink_Flag;i32]

Filter_Cmd_Flag :: enum i32 {
	One  = 0,
	Fast = 1,
}
Filter_Cmd_Flags :: bit_set[Filter_Cmd_Flag;i32]


Filter_Link_Init :: enum i32 {
	Uninit = 0,
	Startinit,
	Init,
}

Filter_Auto_Convert :: enum i32 {
	All  = 0,
	None = -1,
}

Filter_Context :: struct {
	av_class:        ^Class,
	filter:          ^Filter,
	name:            cstring,
	input_pads:      [^]Filter_Pad,
	inputs:          ^[^]Filter_Link,
	nb_inputs:       u32,
	output_pads:     [^]Filter_Pad,
	outputs:         ^[^]Filter_Link,
	nb_outputs:      u32,
	priv:            rawptr,
	graph:           ^Filter_Graph,
	thread_type:     i32,
	internal:        ^Filter_Internal,
	command_queue:   ^Filter_Command,
	enable_str:      cstring,
	enable:          rawptr,
	var_values:      ^f64,
	is_disabled:     i32,
	hw_device_ctx:   ^Buffer_Ref,
	nb_threads:      i32,
	ready:           u32,
	extra_hw_frames: i32,
}

Filter_Link :: struct {
	src:                 ^Filter_Context,
	srcpad:              ^Filter_Pad,
	dst:                 ^Filter_Context,
	dstpad:              ^Filter_Pad,
	type:                Media_Type,
	w:                   i32,
	h:                   i32,
	sample_aspect_ratio: Rational,
	sample_rate:         i32,
	format:              i32,
	time_base:           Rational,
	ch_layout:           Channel_Layout,
	incfg:               Filter_Formats_Config,
	outcfg:              Filter_Formats_Config,
	init_state:          Filter_Link_Init,
	graph:               ^Filter_Graph,
	current_pts:         i64,
	current_pts_us:      i64,
	age_index:           i32,
	frame_rate:          Rational,
	min_samples:         i32,
	max_samples:         i32,
	channels:            i32,
	frame_count_in:      i64,
	frame_count_out:     i64,
	sample_count_in:     i64,
	sample_count_out:    i64,
	frame_pool:          rawptr,
	frame_wanted_out:    i32,
	hw_frames_ctx:       ^Buffer_Ref,
	reserved:            [0xF000]u8,
}
Filter :: struct {
	name:            cstring,
	description:     cstring,
	inputs:          [^]Filter_Pad,
	outputs:         [^]Filter_Pad,
	priv_class:      ^Class,
	flags:           Filter_Flags,
	nb_inputs:       u8,
	nb_outputs:      u8,
	formats_state:   u8,
	preinit:         #type proc(ctx: ^Filter_Context) -> i32,
	init:            #type proc(ctx: ^Filter_Context) -> i32,
	init_dict:       #type proc(ctx: ^Filter_Context, options: ^[^]Dictionary) -> i32,
	uninit:          #type proc(ctx: ^Filter_Context),
	formats:         struct #raw_union {
		query_func:   proc(ctx: ^Filter_Context) -> i32,
		pixels_list:  [^]Pixel_Format,
		samples_list: [^]Sample_Format,
		pix_fmt:      Pixel_Format,
		sample_fmt:   Sample_Format,
	},
	priv_size:       i32,
	flags_internal:  i32,
	process_command: proc(
		ctx: ^Filter_Context,
		cmd: cstring,
		arg: cstring,
		res: cstring,
		res_len: i32,
		flags: i32,
	) -> i32,
	activate:        proc(ctx: ^Filter_Context) -> i32,
}

Filter_Graph_Action_Callback :: #type proc(
	ctx: Filter_Context,
	arg: rawptr,
	jobnr: i32,
	nb_jobs: i32,
) -> i32
Filter_Graph_Execute_Callback :: #type proc(
	ctx: Filter_Context,
	func: Filter_Graph_Action_Callback,
	arg: rawptr,
	ret: ^i32,
	nb_jobs: i32,
) -> i32


Filter_Graph :: struct {
	av_class:             ^Class,
	filters:              ^[^]Filter_Context,
	nb_filters:           u32,
	scale_sws_opts:       cstring,
	thread_type:          i32,
	nb_threads:           i32,
	internal:             ^Filter_Graph_Internal,
	_opaque:              rawptr,
	execute:              Filter_Graph_Execute_Callback,
	aresample_swr_opts:   cstring,
	sink_links:           ^[^]Filter_Link,
	sink_links_count:     i32,
	disable_auto_convert: u32,
}

Filter_Formats_Config :: struct {
	formats:         ^Filter_Formats,
	samplerates:     ^Filter_Formats,
	channel_layouts: ^Filter_Channel_Layouts,
}

Filter_In_Out :: struct {
	name:       cstring,
	filter_ctx: ^Filter_Context,
	pad_idx:    i32,
	next:       ^Filter_In_Out,
}

Filter_Pad_Params :: struct {
	label: cstring,
}

Filter_Params :: struct {
	filter:        ^Filter_Context,
	filter_name:   cstring,
	instance_name: cstring,
	opts:          ^Dictionary,
	inputs:        ^[^]Filter_Pad_Params,
	nb_inputs:     u32,
	outputs:       ^[^]Filter_Pad_Params,
	nb_outputs:    u32,
}

Filter_Chain :: struct {
	filters:    ^[^]Filter_Params,
	nb_filters: uintptr,
}

Filter_Graph_Segment :: struct {
	graph:          ^Filter_Graph,
	chains:         ^[^]Filter_Chain,
	nb_chains:      uintptr,
	scale_sws_opts: cstring,
}

Filter_Command :: struct {
}
Filter_Pad :: struct {
}
Filter_Formats :: struct {
}
Filter_Channel_Layouts :: struct {
}
Filter_Internal :: struct {
}
Filter_Graph_Internal :: struct {
}

/* ==============================================================================================
	  FORMATS - FORMATS - FORMATS - FORMATS - FORMATS - FORMATS - FORMATS - FORMATS - FORMATS
   ============================================================================================== */

Probe_Data :: struct {
	filename:  cstring,
	buf:       [^]u8,
	buf_size:  i32,
	mime_type: cstring,
}

PROBE_SCORE_EXTENSION :: 50
PROBE_SCORE_MIME :: 75
PROBE_SCORE_MAX :: 100
PROBE_SCORE_RETRY :: PROBE_SCORE_MAX / 4
PROBE_SCORE_STREAM_RETRY :: (PROBE_SCORE_MAX / 4 - 1)
PROBE_PADDING_SIZE :: 32

/*
	Demuxer uses `avio_open`. No file handle should be provided.
*/
Format_Flag :: enum i32 {
	No_File           = 0,
	Need_Number       = 1,
	Experimental      = 2,
	Show_IDs          = 3,
	Global_Header     = 6,
	No_Timestamps     = 7,
	Generic_Index     = 8,
	TS_Discontinuous  = 9,
	Variable_FPS      = 10,
	No_Dimensions     = 11,
	No_Streams        = 12,
	No_Binary_Search  = 13,
	No_Generic_Search = 14,
	No_Byte_Seek      = 15,
	//Allow_Flush       = 16,
	TS_Non_Strict     = 17,
	TS_Negative       = 18,
	Seek_to_PTS       = 26,
}
Format_Flags :: bit_set[Format_Flag;i32]

Format_Seek_Flag :: enum i32 {
	Backward = 0,
	Byte     = 1,
	Any      = 2,
	Frame    = 3,
}
Format_Seek_Flags :: bit_set[Format_Seek_Flag;i32]

/*
	Muxers
*/
Output_Format :: struct {
	name:           cstring,
	long_name:      cstring,
	mime_type:      cstring,
	extensions:     cstring,

	/*
		Output support.
	*/
	audio_codec:    Codec_ID, // Default Audio    Codec
	video_codec:    Codec_ID, // Default Video    Codec
	subtitle_codec: Codec_ID, // Default Subtitle Codec
	flags:          Format_Flags,

	/*
		List of supported codec_id-codec_tag pairs, ordered by "better
		choice first". The arrays are all terminated by .None
	*/
	codec_tags:     ^[^]Codec_Tag,
	priv_class:     ^Class,
}

/*
	Demuxers
*/
Input_Format :: struct {
	name:            cstring,
	long_name:       cstring,
	flags:           Format_Flags,
	extensions:      cstring,
	codec_tags:      ^[^]Codec_Tag,
	priv_class:      ^Class,
	mime_type:       cstring,

	// The rest of the fields are not part of the public API.
	rawcodec_id:     i32,
	priv_data_size:  i32,
	flags_internal:  i32,
	read_probe:      #type proc(probe: ^Probe_Data) -> i32,
	read_header:     #type proc(ctx: ^Format_Context) -> i32,
	read_packet:     #type proc(ctx: ^Format_Context, pkt: ^Packet) -> i32,
	readclose:       #type proc(ctx: ^Format_Context) -> i32,
	read_seek:       #type proc(
		ctx: ^Format_Context,
		stream_index: i32,
		timestamp: i64,
		flags: i32,
	) -> i32,
	read_timestamp:  #type proc(
		ctx: ^Format_Context,
		stream_index: i32,
		pos: ^i64,
		pos_limit: i64,
	) -> i64,
	read_play:       #type proc(ctx: ^Format_Context) -> i32,
	read_pause:      #type proc(ctx: ^Format_Context) -> i32,
	read_seek2:      #type proc(
		ctx: ^Format_Context,
		stream_index: i32,
		min_ts: i64,
		ts: i64,
		max_ts: i64,
		flags: i32,
	) -> i32,
	get_device_list: #type proc(ctx: ^Format_Context, device_list: ^Device_Info_List) -> i32,
}

IO_Dir_Entry_Type :: enum i32 {
	Unknown,
	Block_Device,
	Character_Device,
	Directory,
	Named_Pipe,
	Symbolic_Link,
	Socket,
	File,
	Server,
	Share,
	Workgroup,
}

IO_Dir_Entry :: struct {
	name:                   cstring,
	type:                   i32,
	utf8:                   i32,
	size:                   i64,
	modification_timestamp: i64,
	access_timestamp:       i64,
	statuschange_timestamp: i64,
	user_id:                i64,
	group_id:               i64,
	filemode:               i64,
}

IO_Data_Marker_Type :: enum i32 {
	Header,
	Sync_Point,
	Boundary_Point,
	Unknown,
	Trailer,
	Flush_Point,
}

/*
	Bytestream IO Context.

	New public fields can be added with minor version bumps.
	Removal, reordering and changes to existing public fields require a major version bump.
	size_of(IO_Context) must not be used outside libav*.

	Note: None of the function pointers in AVIOContext should be called directly,
	they should only be set by the client application when implementing custom I/O.
	Normally these are set to the function pointers specified in avio_alloc_context()
*/
IO_Context :: struct {
	class:                 ^Class,
	buffer:                [^]u8,
	buffer_size:           i32,
	buf_ptr:               ^u8,
	buf_end:               ^u8,
	_opaque:               rawptr,
	read_packet:           #type proc(_opaque: rawptr, buf: [^]u8, buf_size: i32) -> i32,
	write_packet:          #type proc(_opaque: rawptr, buf: [^]u8, buf_size: i32) -> i32,
	seek:                  #type proc(_opaque: rawptr, offset: i64, whence: i32) -> i64,
	pos:                   i64,
	eof_reached:           i32,
	error:                 i32,
	write_flag:            i32,
	max_packet_size:       i32,
	min_packet_size:       i32,
	checksum:              c.ulong,
	checksum_ptr:          ^u8,
	updatechecksum:        #type proc(checksum: c.ulong, buf: [^]u8, size: u32) -> c.ulong,
	read_pause:            #type proc(_opaque: rawptr, pause: i32) -> i32,
	read_seek:             #type proc(
		_opaque: rawptr,
		stream_index: i32,
		timestamp: i64,
		flags: i32,
	) -> i64,
	seekable:              i32,
	direct:                i32,
	protocol_whitelist:    cstring,
	protocol_blacklist:    cstring,
	write_data_type:       #type proc(
		_opaque: rawptr,
		buf: [^]u8,
		buf_size: i32,
		type: IO_Data_Marker_Type,
		time: i64,
	) -> i32,
	ignore_boundary_point: i32,
	buf_ptr_max:           ^u8,
	bytes_read:            i64,
	bytes_written:         i64,
}

IO_Interrupt_CB :: struct {
	callback: #type proc() -> i32,
	opaque:   rawptr,
}

IO_Flag :: enum i32 {
	Read     = 0,
	Write    = 1,
	Nonblock = 3,
	Direct   = 11,
}
IO_Flags :: bit_set[IO_Flag;i32]

Open_Callback :: #type proc(
	ctx: ^Format_Context,
	pb: ^[^]IO_Context,
	url: cstring,
	flags: i32,
	intcb: ^IO_Interrupt_CB,
	options: ^[^]Dictionary,
) -> i32


URL_Context :: struct {
	class:              ^Class, // information for av_log().
	protocol:           ^URL_Protocol,
	priv_data:          rawptr,
	filename:           cstring, // specified URL
	flags:              i32,
	max_packet_size:    i32, // if non zero, the stream is packetized with this max packet size
	is_streamed:        b32, // true if streamed (no seek possible), default = false
	is_connected:       b32,
	interrupt_callback: IO_Interrupt_CB,
	rw_timeout:         i64, // maximum time to wait for (network) read/write operation completion, in mcs.
	protocol_whitelist: cstring,
	protocol_blacklist: cstring,
	min_packet_size:    i32, // if non zero, the stream is packetized with this min packet size.
}

URL_Protocol :: struct {
	name:                      cstring,
	url_open:                  #type proc(h: ^URL_Context, url: cstring, flags: i32) -> i32,
	/**
	 * This callback is to be used by protocols which open further nested
	 * protocols. options are then to be passed to ffurl_open_whitelist()
	 * or ffurl_connect() for those nested protocols.
	 */
	url_open2:                 #type proc(
		h: ^URL_Context,
		url: cstring,
		flags: i32,
		options: ^[^]Dictionary,
	) -> i32,
	url_accept:                #type proc(h: ^URL_Context, c: ^[^]URL_Context) -> i32,
	url_handshake:             #type proc(c: ^URL_Context) -> i32,

	/**
	 * Read data from the protocol.
	 * If data is immediately available (even less than size), EOF is
	 * reached or an error occurs (including EINTR), return immediately.
	 * Otherwise:
	 * In non-blocking mode, return AVERROR(EAGAIN) immediately.
	 * In blocking mode, wait for data/EOF/error with a short timeout (0.1s),
	 * and return AVERROR(EAGAIN) on timeout.
	 * Checking interrupt_callback, looping on EINTR and EAGAIN and until
	 * enough data has been read is left to the calling function see
	 * retry_transfer_wrapper in avio.c.
	 */
	url_read:                  #type proc(h: ^URL_Context, buf: [^]u8, size: i32) -> i32,
	url_write:                 #type proc(h: ^URL_Context, buf: [^]u8, size: i32) -> i32,
	url_seek:                  #type proc(h: ^URL_Context, pos: i64, whence: i32) -> i64,
	url_close:                 #type proc(h: ^URL_Context) -> i32,
	url_read_pause:            #type proc(h: ^URL_Context, pause: i32) -> i32,
	url_read_seek:             #type proc(
		h: ^URL_Context,
		stream_index: i32,
		timestamp: i64,
		flags: i32,
	) -> i64,
	url_get_file_handle:       #type proc(h: ^URL_Context) -> i32,
	url_get_multi_file_handle: #type proc(
		h: ^URL_Context,
		handles: ^[^]i32,
		num_handles: ^i32,
	) -> i32,
	url_get_short_seek:        #type proc(h: ^URL_Context) -> i32,
	url_shutdown:              #type proc(h: ^URL_Context, flags: i32) -> i32,
	priv_data_class:           ^Class,
	priv_data_size:            i32,
	flags:                     i32,
	url_check:                 #type proc(h: ^URL_Context, mask: i32) -> i32,
	url_open_dir:              #type proc(h: ^URL_Context) -> i32,
	url_read_dir:              #type proc(h: ^URL_Context, next: ^^IO_Dir_Entry) -> i32,
	url_close_dir:             #type proc(h: ^URL_Context) -> i32,
	url_delete:                #type proc(h: ^URL_Context) -> i32,
	url_move:                  #type proc(src: ^URL_Context, dst: ^URL_Context) -> i32,
	default_whitelist:         cstring,
}

IO_Dir_Context :: struct {
	url_context: ^URL_Context,
}

/**
 * The duration of a video can be estimated through various ways, and this enum can be used
 * to know how the duration was estimated.
 */
Duration_Estimation_Method :: enum i32 {
	From_PTS, ///< Duration accurately estimated from PTSes
	From_Stream, ///< Duration estimated from a stream with a known duration
	From_Bitrate, ///< Duration estimated from bitrate (less accurate)
}


/**
 * Flags modifying the (de)muxer behaviour. A combination of AVFMT_FLAG_*.
 * Set by the user before avformat_open_input() / avformat_write_header().
 */
Format_Context_Flag :: enum i32 {
	GenPTS          = 0, ///< Generate missing pts even if it requires parsing future frames.
	Ignore_Index    = 1, ///< Ignore index.
	Non_Blocking    = 2, ///< Do not block when reading packets from input.
	Ignore_DTS      = 3, ///< Ignore DTS on frames that contain both DTS & PTS
	No_Fill_In      = 4, ///< Do not infer any values from other values, just return what is stored in the container
	No_Parse        = 5, ///< Do not use AVParsers, you also must set AVFMT_FLAG_NOFILLIN as the fillin code works on frames and no parsing -> no frames. Also seeking to frames can not work if parsing to find frame boundaries has been disabled
	No_Buffer       = 6, ///< Do not buffer frames when possible
	Custom_IO       = 7, ///< The caller has supplied a custom AVIOContext, don't avio_close() it.
	Discard_Corrupt = 8, ///< Discard frames marked corrupted
	Flush_Packets   = 9, ///< Flush the IO_Context every packet.

	/**
	 * When muxing, try to avoid writing any random/volatile data to the output.
	 * This includes any random IDs, real-time timestamps/dates, muxer version, etc.
	 *
	 * This flag is mainly intended for testing.
	 */
	Bit_Exact       = 10,
	Sort_DTS        = 16, ///< try to interleave outputted packets by dts (using this flag can slow demuxing down)
	Fast_Seek       = 19, ///< Enable fast, but inaccurate seeks for some formats
	Shortest        = 20, ///< Stop muxing when the shortest stream stops.
	Auto_BSF        = 21, //< Add bitstream filters as requested by the muxer
}
Format_Context_Flags :: bit_set[Format_Context_Flag;i32]

Format_Context_Debug :: enum i32 {
	TS = 1,
}

Format_Context_Event_Flag :: enum i32 {
	/**
	 * - demuxing: the demuxer read new metadata from the file and updated
	 *   AVFormatContext.metadata accordingly
	 * - muxing: the user updated AVFormatContext.metadata and wishes the muxer to
	 *   write it into the file
	 */
	Metadata_Updated = 0,
}
Format_Context_Event_Flags :: bit_set[Format_Context_Event_Flag;i32]

Avoid_Negative_TS_Flag :: enum i32 {
	Auto               = -1, ///< Enabled when required by target format
	Make_None_Negative = 1, ///< Shift timestamps so they are non negative
	Make_Zero          = 2, ///< Shift timestamps so that they start at 0	
}

Format_Control_Message :: #type proc(
	ctx: Format_Context,
	type: i32,
	data: [^]u8,
	data_size: i64,
) -> i32

Frame_Filename_Flag :: enum i32 {
	Multiple = 0,
}
Frame_Filename_Flags :: bit_set[Frame_Filename_Flag;i32]

/**
 * Format I/O context.
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * size_of(Format_Context) must not be used outside libav*, use
 * avformat.alloc_context() to create a `Format_Context`.
 *
 * Fields can be accessed through Options (av_opt*),
 * the name string used matches the associated command line parameter name and
 * can be found in libavformat/options_table.h.
 * The Option/command line parameter names differ in some cases from the C
 * structure field names for historic reasons or brevity.
 */

Format_Internal :: struct {
}

Format_Context :: struct {
	/**
	 * A class for logging and @ref avoptions. Set by avformat.alloc_context().
	 * Exports (de)muxer private options if they exist.
	 */
	class:                           ^Class,

	/**
	 * The input container format.
	 *
	 * Demuxing only, set by avformat.open_input().
	 */
	input_format:                    ^Input_Format,

	/**
	 * The output container format.
	 *
	 * Muxing only, must be set by the caller before avformat_write_header().
	 */
	output_format:                   ^Output_Format,

	/**
	 * Format private data. This is an Options-enabled struct
	 * if and only if iformat/oformat.priv_class is not NULL.
	 *
	 * - muxing:   set by avformat.write_header()
	 * - demuxing: set by avformat.open_input()
	 */
	priv_data:                       rawptr,

	/**
	 * I/O context.
	 *
	 * - demuxing: either set by the user before avformat.open_input() (then
	 *             the user must close it manually) or set by avformat.open_input().
	 * - muxing: set by the user before avformat.write_header(). The caller must
	 *           take care of closing / freeing the IO context.
	 *
	 * Do NOT set this field if AVFMT_NOFILE flag is set in iformat/oformat.flags. In such a case, the (de)muxer will handle
	 * I/O in some other way and this field will be NULL.
	 */
	pb:                              ^IO_Context,

	/**
	 * Flags signalling stream properties. A combination of AVFMTCTX_*.
	 * Set by libavformat.
	 */
	ctx_flags:                       i32,

	/**
	 * Number of elements in AVFormatContext.streams.
	 *
	 * Set by avformat_new_stream(), must not be modified by any other code.
	 */
	nb_streams:                      u32,

	/**
	 * A list of all streams in the file. New streams are created with
	 * avformat.new_stream().
	 *
	 * - demuxing: streams are created by libavformat in avformat.open_input().
	 *             If AVFMTCTX_NOHEADER is set in ctx_flags, then new streams may also
	 *             appear in read_frame().
	 * - muxing: streams are created by the user before avformat.write_header().
	 *
	 * Freed by libavformat in avformat.free_context().
	 */
	streams:                         [^]^Stream,

	/**
	 * input or output URL. Unlike the old filename field, this field has no
	 * length restriction.
	 *
	 * - demuxing: set by avformat.open_input(), initialized to an empty
	 *             string if url parameter was NULL in avformat.open_input().
	 * - muxing: may be set by the caller before calling avformat.write_header()
	 *           (or avformat.init_output() if that is called first) to a string
	 *           which is freeable by av_free(). Set to an empty string if it
	 *           was NULL in avformat.init_output().
	 *
	 * Freed by libavformat in avformat.free_context().
	 */
	url:                             cstring,

	/**
	 * Position of the first frame of the component, in
	 * AV_TIME_BASE fractional seconds. NEVER set this value directly:
	 * It is deduced from the AVStream values.
	 *
	 * Demuxing only, set by libavformat.
	 */
	start_time:                      i64,

	/**
	 * Duration of the stream, in AV_TIME_BASE fractional
	 * seconds. Only set this value if you know none of the individual stream
	 * durations and also do not set any of them. This is deduced from the
	 * AVStream values if not set.
	 *
	 * Demuxing only, set by libavformat.
	 */
	duration:                        i64,

	/**
	 * Total stream bitrate in bit/s, 0 if not
	 * available. Never set it directly if the file_size and the
	 * duration are known as FFmpeg can compute it automatically.
	 */
	bit_rate:                        i64,
	packet_size:                     u32,
	max_delay:                       i32,
	flags:                           Format_Context_Flags,

	/**
	 * Maximum size of the data read from input for determining
	 * the input container format.
	 * Demuxing only, set by the caller before avformat_open_input().
	 */
	probesize:                       i64,

	/**
	 * Maximum duration (in AV_TIME_BASE units) of the data read
	 * from input in avformat_find_stream_info().
	 * Demuxing only, set by the caller before avformat_find_stream_info().
	 * Can be set to 0 to let avformat choose using a heuristic.
	 */
	max_analyze_duration:            i64,
	key:                             [^]u8,
	keylen:                          i32,
	nb_programs:                     u32,
	programs:                        ^[^]Program,

	/**
	 * Forced video codec_id.
	 * Demuxing: Set by user.
	 */
	video_codec_id:                  Codec_ID,

	/**
	 * Forced audio codec_id.
	 * Demuxing: Set by user.
	 */
	audio_codec_id:                  Codec_ID,

	/**
	 * Forced subtitle codec_id.
	 * Demuxing: Set by user.
	 */
	subtitle_codec_id:               Codec_ID,

	/**
	 * Maximum amount of memory in bytes to use for the index of each stream.
	 * If the index exceeds this size, entries will be discarded as
	 * needed to maintain a smaller size. This can lead to slower or less
	 * accurate seeking (depends on demuxer).
	 * Demuxers for which a full in-memory index is mandatory will ignore
	 * this.
	 * - muxing: unused
	 * - demuxing: set by user
	 */
	max_index_size:                  u32,

	/**
	 * Maximum amount of memory in bytes to use for buffering frames
	 * obtained from realtime capture devices.
	 */
	max_picture_buffer:              u32,

	/**
	 * Number of chapters in AVChapter array.
	 * When muxing, chapters are normally written in the file header,
	 * so nb_chapters should normally be initialized before write_header
	 * is called. Some muxers (e.g. mov and mkv) can also write chapters
	 * in the trailer.  To write chapters in the trailer, nb_chapters
	 * must be zero when write_header is called and non-zero when
	 * write_trailer is called.
	 * - muxing: set by user
	 * - demuxing: set by libavformat
	 */
	nb_chapters:                     u32,
	chapters:                        ^[^]Chapter,

	/**
	 * Metadata that applies to the whole file.
	 *
	 * - demuxing: set by libavformat in avformat_open_input()
	 * - muxing: may be set by the caller before avformat_write_header()
	 *
	 * Freed by libavformat in avformat_free_context().
	 */
	metadata:                        ^Dictionary,

	/**
	 * Start time of the stream in real world time, in microseconds
	 * since the Unix epoch (00:00 1st January 1970). That is, pts=0 in the
	 * stream was captured at this real world time.
	 * - muxing: Set by the caller before avformat_write_header(). If set to
	 *           either 0 or AV_NOPTS_VALUE, then the current wall-time will
	 *           be used.
	 * - demuxing: Set by libavformat. AV_NOPTS_VALUE if unknown. Note that
	 *             the value may become known after some number of frames
	 *             have been received.
	 */
	start_time_realtime:             i64,

	/**
	 * The number of frames used for determining the framerate in
	 * avformat_find_stream_info().
	 * Demuxing only, set by the caller before avformat_find_stream_info().
	 */
	fps_probe_size:                  i32,

	/**
	 * Error recognition higher values will detect more errors but may
	 * misdetect some more or less valid parts as errors.
	 * Demuxing only, set by the caller before avformat_open_input().
	 */
	error_recognition:               i32,

	/**
	 * Custom interrupt callbacks for the I/O layer.
	 *
	 * demuxing: set by the user before avformat_open_input().
	 * muxing: set by the user before avformat_write_header()
	 * (mainly useful for AVFMT_NOFILE formats). The callback
	 * should also be passed to avio_open2() if it's used to
	 * open the file.
	 */
	interrupt_callback:              IO_Interrupt_CB,

	/**
	 * Flags to enable debugging.
	 */
	debug:                           Format_Context_Debug,

	/**
	 * Maximum buffering duration for interleaving.
	 *
	 * To ensure all the streams are interleaved correctly,
	 * av_interleaved_write_frame() will wait until it has at least one packet
	 * for each stream before actually writing any packets to the output file.
	 * When some streams are "sparse" (i.e. there are large gaps between
	 * successive packets), this can result in excessive buffering.
	 *
	 * This field specifies the maximum difference between the timestamps of the
	 * first and the last packet in the muxing queue, above which libavformat
	 * will output a packet regardless of whether it has queued a packet for all
	 * the streams.
	 *
	 * Muxing only, set by the caller before avformat_write_header().
	 */
	max_interleave_delta:            i64,

	/**
	 * Allow non-standard and experimental extension
	 * @see AVCodec_Context.strict_std_compliance
	 */
	strict_std_compliance:           i32,

	/**
	 * Flags indicating events happening on the file, a combination of
	 * AVFMT_EVENT_FLAG_*.
	 *
	 * - demuxing: may be set by the demuxer in avformat_open_input(),
	 *   avformat_find_stream_info() and av_read_frame(). Flags must be cleared
	 *   by the user once the event has been handled.
	 * - muxing: may be set by the user after avformat_write_header() to
	 *   indicate a user-triggered event.  The muxer will clear the flags for
	 *   events it has handled in av_[interleaved]_write_frame().
	 */
	event_flags:                     Format_Context_Event_Flags,

	/**
	 * Maximum number of packets to read while waiting for the first timestamp.
	 * Decoding only.
	 */
	max_ts_probe:                    i32,

	/**
	 * Avoid negative timestamps during muxing.
	 * Any value of the AVFMT_AVOID_NEG_TS_* constants.
	 * Note, this only works when using av_interleaved_write_frame. (interleave_packet_per_dts is in use)
	 * - muxing: Set by user
	 * - demuxing: unused
	 */
	avoid_negative_ts:               Avoid_Negative_TS_Flag,

	/**
	 * Transport stream id.
	 * This will be moved into demuxer private options. Thus no API/ABI compatibility
	 */
	ts_id:                           i32,

	/**
	 * Audio preload in microseconds.
	 * Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	audio_preload:                   i32,

	/**
	 * Max chunk time in microseconds.
	 * Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	max_chunk_duration:              i32,

	/**
	 * Max chunk size in bytes
	 * Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	max_chunk_size:                  i32,

	/**
	 * forces the use of wallclock timestamps as pts/dts of packets
	 * This has undefined results in the presence of B frames.
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	use_wallclock_as_timestamps:     i32,

	/**
	 * avio flags, used to force AVIO_FLAG_DIRECT.
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	avio_flags:                      i32,

	/**
	 * The duration field can be estimated through various ways, and this field can be used
	 * to know how the duration was estimated.
	 * - encoding: unused
	 * - decoding: Read by user
	 */
	duration_estimation_method:      Duration_Estimation_Method,

	/**
	 * Skip initial bytes when opening stream
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	skip_initial_bytes:              i64,

	/**
	 * Correct single timestamp overflows
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	correct_ts_overflow:             u32,

	/**
	 * Force seeking to any (also non key) frames.
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	seek2any:                        i32,

	/**
	 * Flush the I/O context after each packet.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	flush_packets:                   i32,

	/**
	 * format probing score.
	 * The maximal score is AVPROBE_SCORE_MAX, its set when the demuxer probes
	 * the format.
	 * - encoding: unused
	 * - decoding: set by avformat, read by user
	 */
	probe_score:                     i32,

	/**
	 * number of bytes to read maximally to identify format.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	format_probesize:                i32,

	/**
	 * ',' separated list of allowed decoders.
	 * If NULL then all are allowed
	 * - encoding: unused
	 * - decoding: set by user
	 */
	codec_whitelist:                 cstring,

	/**
	 * ',' separated list of allowed demuxers.
	 * If NULL then all are allowed
	 * - encoding: unused
	 * - decoding: set by user
	 */
	format_whitelist:                cstring,

	/**
	 * IO repositioned flag.
	 * This is set by avformat when the underlaying IO context read pointer
	 * is repositioned, for example when doing byte based seeking.
	 * Demuxers can use the flag to detect such changes.
	 */
	io_repositioned:                 i32,

	/**
	 * Forced video codec.
	 * This allows forcing a specific decoder, even when there are multiple with
	 * the same codec_id.
	 * Demuxing: Set by user
	 */
	video_codec:                     ^Codec,

	/**
	 * Forced audio codec.
	 * This allows forcing a specific decoder, even when there are multiple with
	 * the same codec_id.
	 * Demuxing: Set by user
	 */
	audio_codec:                     ^Codec,

	/**
	 * Forced subtitle codec.
	 * This allows forcing a specific decoder, even when there are multiple with
	 * the same codec_id.
	 * Demuxing: Set by user
	 */
	subtitle_codec:                  ^Codec,

	/**
	 * Forced data codec.
	 * This allows forcing a specific decoder, even when there are multiple with
	 * the same codec_id.
	 * Demuxing: Set by user
	 */
	data_codec:                      ^Codec,

	/**
	 * Number of bytes to be written as padding in a metadata header.
	 * Demuxing: Unused.
	 * Muxing: Set by user via av_format_set_metadata_header_padding.
	 */
	metadata_header_padding:         i32,

	/**
	 * User data.
	 * This is a place for some private data of the user.
	 */
	opaque:                          rawptr,

	/**
	 * Callback used by devices to communicate with application.
	 */
	control_message_cb:              Format_Control_Message,

	/**
	 * Output timestamp offset, in microseconds.
	 * Muxing: set by user
	 */
	output_ts_offset:                i64,

	/**
	 * dump format separator.
	 * can be ", " or "\n      " or anything else
	 * - muxing: Set by user.
	 * - demuxing: Set by user.
	 */
	dump_separator:                  cstring,

	/**
	 * Forced Data codec_id.
	 * Demuxing: Set by user.
	 */
	data_codec_id:                   Codec_ID,

	/**
	 * ',' separated list of allowed protocols.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	protocol_whitelist:              cstring,

	/**
	 * A callback for opening new IO streams.
	 *
	 * Whenever a muxer or a demuxer needs to open an IO stream (typically from
	 * avformat_open_input() for demuxers, but for certain formats can happen at
	 * other times as well), it will call this callback to obtain an IO context.
	 *
	 * @param s the format context
	 * @param pb on success, the newly opened IO context should be returned here
	 * @param url the url to open
	 * @param flags a combination of AVIO_FLAG_*
	 * @param options a dictionary of additional options, with the same
	 *                semantics as in avio_open2()
	 * @return 0 on success, a negative AVERROR code on failure
	 *
	 * @note Certain muxers and demuxers do nesting, i.e. they open one or more
	 * additional internal format contexts. Thus the AVFormatContext pointer
	 * passed to this callback may be different from the one facing the caller.
	 * It will, however, have the same 'opaque' field.
	 */
	io_open:                         #type proc(
		ctx: ^Format_Context,
		pb: ^^IO_Context,
		url: cstring,
		IO_flags: i32,
		options: ^[^]Dictionary,
	) -> i32,
	io_close:                        #type proc(ctx: ^Format_Context, pb: ^IO_Context),

	/**
	 * ',' separated list of disallowed protocols.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	protocol_blacklist:              cstring,

	/**
	 * The maximum number of streams.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	max_streams:                     i32,

	/**
	 * Skip duration calcuation in estimate_timings_from_pts.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	skip_estimate_duration_from_pts: i32,

	/**
	 * Maximum number of packets that can be probed
	 * - encoding: unused
	 * - decoding: set by user
	 */
	max_probe_packets:               i32,
	/**
     * A callback for closing the streams opened with AVFormatContext.io_open().
     *
     * Using this is preferred over io_close, because this can return an error.
     * Therefore this callback is used instead of io_close by the generic
     * libavformat code if io_close is NULL or the default.
     *
     * @param s the format context
     * @param pb IO context to be closed and freed
     * @return 0 on success, a negative AVERROR code on failure
     */
	io_close2:                       #type proc(s: ^Format_Context, pb: ^IO_Context) -> i32,
}

Stream_Parse_Type :: enum i32 {
	None,
	Full, /**< full parsing and repack */
	Headers, /**< Only parse headers, do not repack. */
	Timestamps, /**< full parsing and interpolation of timestamps for frames not starting on a packet boundary */
	Full_Once, /**< full parsing and repack of the first frame only, only implemented for H.264 currently */
	Full_Raw, /**< full parsing and repack with timestamp and position generation by parser for raw
									this assumes that each packet in the file contains no demuxer level headers and
									just codec level data, otherwise position generation would fail */
}

Index_Flag :: enum i32 {
	Keyframe      = 1,
	Discard_Frame = 2,
}

Index_Entry :: struct {
	pos:          i64,
	timestamp:    i64, /**< Timestamp in Stream.time_base units, preferably the time from which on correctly decoded frames are available
					  *  when seeking to this entry. That means preferable PTS on keyframe based formats.
					  *  But demuxers can choose to store a different timestamp, if it is more convenient for the implementation or nothing better
					  *  is known
					  */
	flags:        Index_Flag,
	size:         i32,
	min_distance: i32, /**< Minimum distance between this and the previous keyframe, used to avoid unneeded searching. */
}

Disposition_Flag :: enum i32 {
	Default          = 0,
	Dub              = 1,
	Original         = 2,
	Comment          = 3,
	Lyrics           = 4,
	Karaoke          = 5,

	/**
	 * Track should be used during playback by default.
	 * Useful for subtitle track that should be displayed
	 * even when user did not explicitly ask for subtitles.
	 */
	Forced           = 6,
	Hearing_Impaired = 7, /**< stream for hearing impaired audiences */
	Visual_Impaired  = 8, /**< stream for visual impaired audiences */
	Clean_Effects    = 9, /**< stream without voice */

	/**
	 * The stream is stored in the file as an attached picture/"cover art" (e.g.
	 * APIC frame in ID3v2). The first (usually only) packet associated with it
	 * will be returned among the first few packets read from the file unless
	 * seeking takes place. It can also be accessed at any time in
	 * AVStream.attached_pic.
	 */
	Attached_Pic     = 10,

	/**
	 * The stream is sparse, and contains thumbnail images, often corresponding
	 * to chapter markers. Only ever used with AV_DISPOSITION_ATTACHED_PIC.
	 */
	Timed_Thumbnails = 11,
	/**
	* The stream is intended to be mixed with a spatial audio track. For example,
	* it could be used for narration or stereo music, and may remain unchanged by
	* listener head rotation.
	*/
	Non_Diegetic     = 12,

	/**
	 * To specify text track kind (different from subtitles default).
	 */
	Captions         = 16,
	Descriptions     = 17,
	Metadata         = 18,
	Dependent        = 19, ///< dependent audio stream (mix_type=0 in mpegts)
	Still_Image      = 20, ///< still images in video stream (still_picture_flag=1 in mpegts)
}
Disposition_Flags :: bit_set[Disposition_Flag;i32]

/*
	Options for behavior on timestamp wrap detection.
*/
Timestamp_Wrap :: enum i32 {
	Ignore     = 0, ///< ignore the wrap
	Add_offset = 1, ///< add the format specific offset on wrap detection
	Sub_offset = -1, ///< subtract the format specific offset on wrap detection
}

Event_Flag :: enum i32 {
	/**
	 * - demuxing: the demuxer read new metadata from the file and updated
	 *     AVStream.metadata accordingly
	 * - muxing: the user updated AVStream.metadata and wishes the muxer to write
	 *     it into the file
	 */
	Metadata_Updated = 0,
	/**
	 * - demuxing: new packets for this stream were read from the file. This
	 *   event is informational only and does not guarantee that new packets
	 *   for this stream will necessarily be returned from av_read_frame().
	 */
	New_Packets      = 1,
}
Event_Flags :: bit_set[Event_Flag;i32]
/**
 * Stream structure.
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * sizeof(AVStream) must not be used outside libav*.
 */
Stream :: struct {
	class:               ^Class,
	index:               i32, /**< stream index in `Format_Context` */
	/*
	 * Format-specific stream ID.
	 * decoding: set by libavformat
	 * encoding: set by the user, replaced by libavformat if left unset
	 */
	id:                  i32,
	codecpar:            ^Codec_Parameters,
	priv_data:           rawptr,

	/**
	 * This is the fundamental unit of time (in seconds) in terms
	 * of which frame timestamps are represented.
	 *
	 * decoding: set by libavformat
	 * encoding: May be set by the caller before avformat_write_header() to
	 *           provide a hint to the muxer about the desired timebase. In
	 *           avformat_write_header(), the muxer will overwrite this field
	 *           with the timebase that will actually be used for the timestamps
	 *           written into the file (which may or may not be related to the
	 *           user-provided one, depending on the format).
	 */
	time_base:           Rational,

	/**
	 * Decoding: pts of the first frame of the stream in presentation order, in stream time base.
	 * Only set this if you are absolutely 100% sure that the value you set
	 * it to really is the pts of the first frame.
	 * This may be undefined (AV_NOPTS_VALUE).
	 * @note The ASF header does NOT contain a correct start_time the ASF
	 * demuxer must NOT set this.
	 */
	start_time:          i64,

	/**
	 * Decoding: duration of the stream, in stream time base.
	 * If a source file does not specify a duration, but does specify
	 * a bitrate, this value will be estimated from bitrate and file size.
	 *
	 * Encoding: May be set by the caller before avformat_write_header() to
	 * provide a hint to the muxer about the estimated duration.
	 */
	duration:            i64,
	nb_frames:           i64, ///< number of frames in this stream if known or 0
	disposition:         Disposition_Flags, /**< AV_DISPOSITION_* bit field */
	discard:             Discard, ///< Selects which packets can be discarded at will and do not need to be demuxed.

	/**
	 * sample aspect ratio (0 if unknown)
	 * - encoding: Set by user.
	 * - decoding: Set by libavformat.
	 */
	sample_aspect_ratio: Rational,
	metadata:            ^Dictionary,

	/**
	 * Average framerate
	 *
	 * - demuxing: May be set by libavformat when creating the stream or in
	 *             avformat_find_stream_info().
	 * - muxing: May be set by the caller before avformat_write_header().
	 */
	avg_frame_rate:      Rational,

	/**
	 * For streams with AV_DISPOSITION_ATTACHED_PIC disposition, this packet
	 * will contain the attached picture.
	 *
	 * decoding: set by libavformat, must not be modified by the caller.
	 * encoding: unused
	 */
	attached_pic:        Packet,

	//deprecated! Still think I need to include this 
	// to pad out the struct correctly.
	side_data:           ^Packet_Side_Data,
	nb_side_data:        i32,


	/**
	 * Flags indicating events happening on the stream, a combination of
	 * AVSTREAM_EVENT_FLAG_*.
	 *
	 * - demuxing: may be set by the demuxer in avformat_open_input(),
	 *   avformat_find_stream_info() and av_read_frame(). Flags must be cleared
	 *   by the user once the event has been handled.
	 * - muxing: may be set by the user after avformat_write_header(). to
	 *   indicate a user-triggered event.  The muxer will clear the flags for
	 *   events it has handled in av_[interleaved]_write_frame().
	 */
	event_flags:         Event_Flags,

	/**
	 * Real base framerate of the stream.
	 * This is the lowest framerate with which all timestamps can be
	 * represented accurately (it is the least common multiple of all
	 * framerates in the stream). Note, this value is just a guess!
	 * For example, if the time base is 1/90000 and all frames have either
	 * approximately 3600 or 1800 timer ticks, then r_frame_rate will be 50/1.
	 */
	r_frame_rate:        Rational,
	pts_wrap_bits:       i32,
}

Packet_Flag :: enum i32 {
	Key        = 0, ///< The packet contains a keyframe
	Corrupt    = 1, ///< The packet content is corrupted
	/**
	 * Flag is used to discard packets which are required to maintain valid
	 * decoder state but are not required for output and should be dropped
	 * after decoding.
	 **/
	Discard    = 2,
	/**
	 * The packet comes from a trusted source.
	 *
	 * Otherwise-unsafe constructs such as arbitrary pointers to data
	 * outside the packet may be followed.
	 */
	Trusted    = 3,
	/**
	 * Flag is used to indicate packets that contain frames that can
	 * be discarded by the decoder.  I.e. Non-reference frames.
	 */
	Disposable = 4,
}
Packet_Flags :: bit_set[Packet_Flag;i32]

Packet :: struct {
	/**
	 * A reference to the reference-counted buffer where the packet data is
	 * stored.
	 * May be NULL, then the packet data is not reference-counted.
	 */
	buf:             ^Buffer_Ref,

	/**
	 * Presentation timestamp in AVStream->time_base units the time at which
	 * the decompressed packet will be presented to the user.
	 * Can be AV_NOPTS_VALUE if it is not stored in the file.
	 * pts MUST be larger or equal to dts as presentation cannot happen before
	 * decompression, unless one wants to view hex dumps. Some formats misuse
	 * the terms dts and pts/cts to mean something different. Such timestamps
	 * must be converted to true pts/dts before they are stored in AVPacket.
	 */
	pts:             i64,

	/**
	 * Decompression timestamp in AVStream->time_base units the time at which
	 * the packet is decompressed.
	 * Can be AV_NOPTS_VALUE if it is not stored in the file.
	 */
	dts:             i64,
	data:            [^]u8,
	size:            i32,
	stream_index:    i32,

	/**
	 * A combination of FLAG values
	 */
	flags:           Packet_Flags,
	/**
	 * Additional packet data that can be provided by the container.
	 * Packet can contain several types of side information.
	 */
	side_data:       [^]Packet_Side_Data,
	side_data_elems: i32,

	/**
	 * Duration of this packet in AVStream->time_base units, 0 if unknown.
	 * Equals next_pts - this_pts in presentation order.
	 */
	duration:        i64,
	pos:             i64, ///< byte position in stream, -1 if unknown
	_opaque:         rawptr,
	opaque_ref:      ^Buffer_Ref,
	time_base:       Rational,
}


Side_Data_Param_Change_Flags :: enum i32 {
	Sample_Rate = 0x0004,
	Dimensions  = 0x0008,
}

/**
 * @defgroup lavc_packet AVPacket
 *
 * Types and functions for working with AVPacket.
 * @{
 */
Packet_Side_Data_Type :: enum i32 {
	/**
	 * An PALETTE side data packet contains exactly AVPALETTE_SIZE
	 * bytes worth of palette. This side data signals that a new palette is
	 * present.
	 */
	Palette,

	/**
	 * The NEW_EXTRADATA is used to notify the codec or the format
	 * that the extradata buffer was changed and the receiving side should
	 * act upon it appropriately. The new extradata is embedded in the side
	 * data buffer and should be immediately used for processing the current
	 * frame or packet.
	 */
	New_ExtraData,

	/**
	 * An PARAM_CHANGE side data packet is laid out as follows:
	 * @code
	 * u32le param_flags
	 * if (param_flags & AV_SIDE_PARAM_CHANGE_CHANNEL_COUNT)
	 *     s32le channel_count
	 * if (param_flags & AV_SIDE_PARAM_CHANGE_CHANNEL_LAYOUT)
	 *     u64le channel_layout
	 * if (param_flags & AV_SIDE_PARAM_CHANGE_SAMPLE_RATE)
	 *     s32le sample_rate
	 * if (param_flags & AV_SIDE_PARAM_CHANGE_DIMENSIONS)
	 *     s32le width
	 *     s32le height
	 * @endcode
	 */
	Param_Change,

	/**
	 * An H263_MB_INFO side data packet contains a number of
	 * structures with info about macroblocks relevant to splitting the
	 * packet into smaller packets on macroblock edges (e.g. as for RFC 2190).
	 * That is, it does not necessarily contain info about all macroblocks,
	 * as long as the distance between macroblocks in the info is smaller
	 * than the target payload size.
	 * Each MB info structure is 12 bytes, and is laid out as follows:
	 * @code
	 * u32le bit offset from the start of the packet
	 * u8    current quantizer at the start of the macroblock
	 * u8    GOB number
	 * u16le macroblock address within the GOB
	 * u8    horizontal MV predictor
	 * u8    vertical MV predictor
	 * u8    horizontal MV predictor for block number 3
	 * u8    vertical MV predictor for block number 3
	 * @endcode
	 */
	H263_mb_info,

	/**
	 * This side data should be associated with an audio stream and contains
	 * ReplayGain information in form of the AVReplayGain struct.
	 */
	ReplayGain,

	/**
	 * This side data contains a 3x3 transformation matrix describing an affine
	 * transformation that needs to be applied to the decoded video frames for
	 * correct presentation.
	 *
	 * See libavutil/display.h for a detailed description of the data.
	 */
	Display_Matrix,

	/**
	 * This side data should be associated with a video stream and contains
	 * Stereoscopic 3D information in form of the AVStereo3D struct.
	 */
	Stereo3D,

	/**
	 * This side data should be associated with an audio stream and corresponds
	 * to enum AVAudioServiceType.
	 */
	Audio_Service_Type,

	/**
	 * This side data contains quality related information from the encoder.
	 * @code
	 * u32le quality factor of the compressed frame. Allowed range is between 1 (good) and FF_LAMBDA_MAX (bad).
	 * u8    picture type
	 * u8    error count
	 * u16   reserved
	 * u64le[error count] sum of squared differences between encoder in and output
	 * @endcode
	 */
	Quality_Stats,

	/**
	 * This side data contains an integer value representing the stream index
	 * of a "fallback" track.  A fallback track indicates an alternate
	 * track to use when the current track can not be decoded for some reason.
	 * e.g. no decoder available for codec.
	 */
	Fallback_Track,

	/**
	 * This side data corresponds to the AVCPBProperties struct.
	 */
	CPB_Properties,

	/**
	 * Recommmends skipping the specified number of samples
	 * @code
	 * u32le number of samples to skip from start of this packet
	 * u32le number of samples to skip from end of this packet
	 * u8    reason for start skip
	 * u8    reason for end   skip (0=padding silence, 1=convergence)
	 * @endcode
	 */
	Skip_Samples,

	/**
	 * An JP_DUALMONO side data packet indicates that
	 * the packet may contain "dual mono" audio specific to Japanese DTV
	 * and if it is true, recommends only the selected channel to be used.
	 * @code
	 * u8    selected channels (0=mail/left, 1=sub/right, 2=both)
	 * @endcode
	 */
	JP_DualMono,

	/**
	 * A list of zero terminated key/value strings. There is no end marker for
	 * the list, so it is required to rely on the side data size to stop.
	 */
	Strings_Metadata,

	/**
	 * Subtitle event position
	 * @code
	 * u32le x1
	 * u32le y1
	 * u32le x2
	 * u32le y2
	 * @endcode
	 */
	Subtitle_Position,

	/**
	 * Data found in BlockAdditional element of matroska container. There is
	 * no end marker for the data, so it is required to rely on the side data
	 * size to recognize the end. 8 byte id (as found in BlockAddId) followed
	 * by data.
	 */
	Matroska_Block_Additional,

	/**
	 * The optional first identifier line of a WebVTT cue.
	 */
	WebVTT_Identifier,

	/**
	 * The optional settings (rendering instructions) that immediately
	 * follow the timestamp specifier of a WebVTT cue.
	 */
	WebVTT_Settings,

	/**
	 * A list of zero terminated key/value strings. There is no end marker for
	 * the list, so it is required to rely on the side data size to stop. This
	 * side data includes updated metadata which appeared in the stream.
	 */
	Metadata_Update,

	/**
	 * MPEGTS stream ID as uint8_t, this is required to pass the stream ID
	 * information from the demuxer to the corresponding muxer.
	 */
	MPEGTS_Stream_ID,

	/**
	 * Mastering display metadata (based on SMPTE-2086:2014). This metadata
	 * should be associated with a video stream and contains data in the form
	 * of the AVMasteringDisplayMetadata struct.
	 */
	Mastering_Display_Metadata,

	/**
	 * This side data should be associated with a video stream and corresponds
	 * to the AVSphericalMapping structure.
	 */
	Spherical,

	/**
	 * Content light level (based on CTA-861.3). This metadata should be
	 * associated with a video stream and contains data in the form of the
	 * AVContentLightMetadata struct.
	 */
	Content_Light_Level,

	/**
	 * ATSC A53 Part 4 Closed Captions. This metadata should be associated with
	 * a video stream. A53 CC bitstream is stored as uint8_t in AVPacketSideData.data.
	 * The number of bytes of CC data is AVPacketSideData.size.
	 */
	A53_CC,

	/**
	 * This side data is encryption initialization data.
	 * The format is not part of ABI, use av_encryption_init_info_* methods to
	 * access.
	 */
	Encryption_Init_Info,

	/**
	 * This side data contains encryption info for how to decrypt the packet.
	 * The format is not part of ABI, use av_encryption_info_* methods to access.
	 */
	Encryption_Info,

	/**
	 * Active Format Description data consisting of a single byte as specified
	 * in ETSI TS 101 154 using AVActiveFormatDescription enum.
	 */
	Active_Format_Description,

	/**
	 * Producer Reference Time data corresponding to the AVProducerReferenceTime struct,
	 * usually exported by some encoders (on demand through the prft flag set in the
	 * AVCodec_Context export_side_data field).
	 */
	PRFT,

	/**
	 * ICC profile data consisting of an opaque octet buffer following the
	 * format described by ISO 15076-1.
	 */
	ICC_Profile,

	/**
	 * DOVI configuration
	 * ref:
	 * dolby-vision-bitstreams-within-the-iso-base-media-file-format-v2.1.2, section 2.2
	 * dolby-vision-bitstreams-in-mpeg-2-transport-stream-multiplex-v1.2, section 3.3
	 * Tags are stored in struct AVDOVIDecoderConfigurationRecord.
	 */
	DOVI_Conf,

	/**
	 * Timecode which conforms to SMPTE ST 12-1:2014. The data is an array of 4 uint32_t
	 * where the first uint32_t describes how many (1-3) of the other timecodes are used.
	 * The timecode format is described in the documentation of av_timecode_get_smpte_from_framenum()
	 * function in libavutil/timecode.h.
	 */
	S12m_TimeCode,
	Dynamic_HDR_10_Plus,
	/**
	 * The number of side data types.
	 * This is not part of the public API/ABI in the sense that it may
	 * change when new side data types are added.
	 * This must stay the last enum value.
	 * If its value becomes huge, some code using it
	 * needs to be updated as it assumes it to be smaller than other limits.
	 */
	Not_Part_of_ABI,
}

Packet_Side_Data :: struct {
	data: [^]u8,
	size: i32,
	type: Packet_Side_Data_Type,
}

PROGRAM_RUNNING :: 1

Field_Order :: enum i32 {
	Unknown,
	Progressive,
	TT, //< Top coded_first, top displayed first
	BB, //< Bottom coded first, bottom displayed first
	TB, //< Top coded first, bottom displayed first
	BT, //< Bottom coded first, top displayed first
}

/**
 * This struct describes the properties of an encoded stream.
 *
 * sizeof(AVCodecParameters) is not a part of the public ABI, this struct must
 * be allocated with avcodec_parameters_alloc() and freed with
 * avcodec_parameters_free().
 */
Codec_Parameters :: struct {
	/**
	 * General type of the encoded data.
	 */
	codec_type:            Media_Type,
	/**
	 * Specific type of the encoded data (the codec used).
	 */
	codec_id:              Codec_ID,
	/**
	 * Additional information about the codec (corresponds to the AVI FOURCC).
	 */
	codec_tag:             FourCC,

	/**
	 * Extra binary data needed for initializing the decoder, codec-dependent.
	 *
	 * Must be allocated with av_malloc() and will be freed by
	 * avcodec_parameters_free(). The allocated size of extradata must be at
	 * least extradata_size + AV_INPUT_BUFFER_PADDING_SIZE, with the padding
	 * bytes zeroed.
	 */
	extra_data:            [^]byte,
	/**
	 * Size of the extradata content in bytes.
	 */
	extra_data_size:       i32,

	/**
	 * - video: the  pixel format, the value corresponds to enum `Pixel_Format`.
	 * - audio: the sample format, the value corresponds to enum `Sample_Format`.
	 */
	format:                struct #raw_union {
		video: Pixel_Format,
		audio: Sample_Format,
	},

	/**
	 * The average bitrate of the encoded data (in bits per second).
	 */
	bit_rate:              i64,

	/**
	 * The number of bits per sample in the codedwords.
	 *
	 * This is basically the bitrate per sample. It is mandatory for a bunch of
	 * formats to actually decode them. It's the number of bits for one sample in
	 * the actual coded bitstream.
	 *
	 * This could be for example 4 for ADPCM
	 * For PCM formats this matches bits_per_raw_sample
	 * Can be 0
	 */
	bits_per_coded_sample: i32,

	/**
	 * This is the number of valid bits in each output sample. If the
	 * sample format has more bits, the least significant bits are additional
	 * padding bits, which are always 0. Use right shifts to reduce the sample
	 * to its actual size. For example, audio formats with 24 bit samples will
	 * have bits_per_raw_sample set to 24, and format set to AV_SAMPLE_FMT_S32.
	 * To get the original sample use "(int32_t)sample >> 8"."
	 *
	 * For ADPCM this might be 12 or 16 or similar
	 * Can be 0
	 */
	bits_per_raw_sample:   i32,

	/**
	 * Codec-specific bitstream restrictions that the stream conforms to.
	 */
	profile:               i32,
	level:                 i32,

	/**
	 * Video only. The dimensions of the video frame in pixels.
	 */
	width:                 i32,
	height:                i32,

	/**
	 * Video only. The aspect ratio (width / height) which a single pixel
	 * should have when displayed.
	 *
	 * When the aspect ratio is unknown / undefined, the numerator should be
	 * set to 0 (the denominator may have any value).
	 */
	sample_aspect_ratio:   Rational,

	/**
	 * Video only. The order of the fields in interlaced video.
	 */
	field_order:           Field_Order,

	/**
	 * Video only. Additional colorspace characteristics.
	 */
	color_range:           Color_Range,
	color_primaries:       Color_Primaries,
	color_trc:             Color_Transfer_Characteristic,
	color_space:           Color_Space,
	chroma_location:       Chroma_Location,

	/**
	 * Video only. Number of delayed frames.
	 */
	video_delay:           i32,

	// yep
	channel_layout:        u64,
	channels:              i32,

	/**
	 * Audio only. The number of audio samples per second.
	 */
	sample_rate:           i32,
	/**
	 * Audio only. The number of bytes per coded audio frame, required by some
	 * formats.
	 *
	 * Corresponds to nBlockAlign in WAVEFORMATEX.
	 */
	block_align:           i32,
	/**
	 * Audio only. Audio frame size, if known. Required by some formats to be static.
	 */
	frame_size:            i32,

	/**
	 * Audio only. The amount of padding (in samples) inserted by the encoder at
	 * the beginning of the audio. I.e. this number of leading decoded samples
	 * must be discarded by the caller to get the original audio without leading
	 * padding.
	 */
	initial_padding:       i32,
	/**
	 * Audio only. The amount of padding (in samples) appended by the encoder to
	 * the end of the audio. I.e. this number of decoded samples must be
	 * discarded by the caller from the end of the stream to get the original
	 * audio without any trailing padding.
	 */
	trailing_padding:      i32,
	/**
	 * Audio only. Number of samples to skip after a discontinuity.
	 */
	seek_preroll:          i32,
	/**
     * Audio only. The channel layout and number of channels.
     */
	ch_layout:             Channel_Layout,

	/**
	  * Video only. Number of frames per second, for streams with constant frame
	  * durations. Should be set to { 0, 1 } when some frames have differing
	  * durations or if the value is not known.
	  *
	  * @note This field correponds to values that are stored in codec-level
	  * headers and is typically overridden by container/transport-layer
	  * timestamps, when available. It should thus be used only as a last resort,
	  * when no higher-level timing information is available.
	  */
	framerate:             Rational,

	/**
	  * Additional data associated with the entire stream.
	  *
	  * Should be allocated with av_packet_side_data_new() or
	  * av_packet_side_data_add(), and will be freed by avcodec_parameters_free().
	  */
	coded_side_data:       ^Packet_Side_Data,

	/**
	  * Amount of entries in @ref coded_side_data.
	  */
	nb_coded_side_data:    i32,
}

/**
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * size_of(Program) must not be used outside libav*.
 */
Program :: struct {
	id:                 i32,
	flags:              i32,
	discard:            Discard,
	stream_index:       [^]u32,
	nb_stream_indexes:  u32,
	metadata:           ^Dictionary,
	program_num:        i32,
	pmt_pid:            i32,
	pcr_pid:            i32,
	pmt_version:        i32,

	/*****************************************************************
	 * All fields below this line are not part of the public API. They
	 * may not be used outside of libavformat and can be changed and
	 * removed at will.
	 * New public fields should be added right above.
	 *****************************************************************
	 */
	start_time:         i64,
	end_time:           i64,
	pts_wrap_reference: i64,
	pts_wrap_behavior:  i32,
}

FMT_CTX_NOHEADER :: 0x0001 /**< signal that no header is present
							   (streams are added dynamically) */
FMT_CTX_UNSEEKABLE :: 0x0002 /**< signal that the stream is definitely
							   not seekable, and attempts to call the
							   seek function will fail. For some
							   network protocols (e.g. HLS), this can
							   change dynamically at runtime. */

Chapter :: struct {
	id:        i64, ///< unique ID to identify the chapter
	time_base: Rational, ///< time base in which the start/end timestamps are specified
	start:     i64,
	end:       i64, ///< chapter start/end time in time_base units
	metadata:  ^Dictionary,
}

SEEK_FLAG_BACKWARD :: 1 ///< seek backward
SEEK_FLAG_BYTE :: 2 ///< seeking based on position in bytes
SEEK_FLAG_ANY :: 4 ///< seek to any frame, even non-keyframes
SEEK_FLAG_FRAME :: 8 ///< seeking based on frame number

STREAM_INIT_IN_WRITE_HEADER :: 0 ///< stream parameters initialized in avformat_write_header
STREAM_INIT_IN_INIT_OUTPUT :: 1 ///< stream parameters initialized in avformat_init_output
FRAME_FILENAME_FLAGS_MULTIPLE :: 1 ///< Allow multiple %d

Timebase_Source :: enum i32 {
	Auto = -1,
	Decoder,
	Demuxer,
	R_framerate,
}

/* ==============================================================================================
	  SWRESAMPLE - SWRESAMPLE - SWRESAMPLE - SWRESAMPLE - SWRESAMPLE - SWRESAMPLE - SWRESAMPLE 
   ============================================================================================== */

Software_Resample_Flag :: 1

Software_Resample_Dither_Flag :: enum i32 {
	None = 0,
	Rectangular,
	Triangular,
	Triangular_Highpass,
	Ns = 64,
	Ns_Lipshitz,
	NsF_Weighted,
	Ns_Modified_E_Weighted,
	Ns_Improved_E_Weighted,
	Ns_Shibata,
	Ns_Low_Shibata,
	Ns_High_Shibata,
	Not_Part_of_ABI,
}

Software_Resample_Engine :: enum i32 {
	Swr,
	Soxr,
	Not_Part_of_ABI,
}

Software_Resample_Filter_Type :: enum i32 {
	Cubic,
	Blackman_Nuttall,
	Kaiser,
}

Software_Resample_Context :: struct {
}

/* ==============================================================================================
	  SWSCALE - SWSCALE - SWSCALE - SWSCALE - SWSCALE - SWSCALE - SWSCALE - SWSCALE - SWSCALE
   ============================================================================================== */


Software_Scale_Method_Flag :: enum i32 {
	SWS_FAST_BILINEAR = 0,
	SWS_BILINEAR      = 1,
	SWS_BICUBIC       = 2,
	SWS_X             = 3,
	SWS_POINT         = 4,
	SWS_AREA          = 5,
	SWS_BICUBLIN      = 6,
	SWS_GAUSS         = 7,
	SWS_SINC          = 8,
	SWS_LANCZOS       = 9,
	SWS_SPLINE        = 10,
}
Software_Scale_Method_Flags :: bit_set[Software_Scale_Method_Flag;i32]

SWS_SRC_V_CHR_DROP_MASK :: 0x30000
SWS_SRC_V_CHR_DROP_SHIFT :: 16
SWS_PARAM_DEFAULT :: 123456
SWS_PRINT_INFO :: 0x1000
SWS_FULL_CHR_H_INT :: 0x2000
SWS_FULL_CHR_H_INP :: 0x4000
SWS_DIRECT_BGR :: 0x8000
SWS_ACCURATE_RND :: 0x40000
SWS_BITEXACT :: 0x80000
SWS_ERROR_DIFFUSION :: 0x800000

SWS_MAX_REDUCE_CUTOFF :: 0.002


Software_Scale_ColorSpace :: enum i32 {
	SWS_CS_ITU709    = 1,
	SWS_CS_FCC       = 4,
	SWS_CS_ITU601    = 5,
	SWS_CS_ITU624    = 5,
	SWS_CS_SMPTE170M = 5,
	SWS_CS_SMPTE240M = 7,
	SWS_CS_DEFAULT   = 5,
	SWS_CS_BT2020    = 9,
}

Software_Scale_Vector :: struct {
	coeff:  ^f64,
	length: i32,
}

Software_Scale_Filter :: struct {
	lumH: ^Software_Scale_Vector,
	lumV: ^Software_Scale_Vector,
	chrH: ^Software_Scale_Vector,
	chrV: ^Software_Scale_Vector,
}

Sws_Context :: struct {
}

/* ==============================================================================================
	  UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL
   ============================================================================================== */
//===adler32.h===
Adler :: distinct u32
//===aes_ctr.h===
AESCTR :: struct {
}
//===aes.h===
AES :: struct {
}

Ambient_Viewing_Environment :: struct {
	//Environmental illuminance of the ambient viewing environment in lux.
	ambient_illuminance: Rational,

	/**
     * Normalized x,y chromaticity coordinate of the environmental ambient light
     * in the nominal viewing environment according to the CIE 1931 definition
     * of x and y as specified in ISO/CIE 11664-1.
     */
	ambient_light_x:     Rational,
	ambient_light_y:     Rational,
}

//===audio_fifo.h===
Audio_Fifo :: struct {
}

//===blowfish.h===
BF_ROUNDS :: 16
Blowfish :: struct {
	p: [BF_ROUNDS + 2]u32,
	s: [4][256]u32,
}

//===bprint.h===
//defined as two parallel structs in a macro. Hoping I can ignore.
BPrint :: struct {
}
Tm :: struct {
}

//===buffer.h===
Buffer_Flag :: enum u32 {
	Read_Only = 0,
}
Buffer_Flags :: bit_set[Buffer_Flag;u32]

Buffer_Flag_Internal :: enum u32 {
	/**
	 * The buffer was av_realloc()ed, so it is reallocatable.
	 */
	Reallocatable = 0,
	/**
	 * The AVBuffer structure is part of a larger structure
	 * and should not be freed.
	 */
	No_Free       = 1,
}
Buffer_Flags_Internal :: bit_set[Buffer_Flag_Internal;u32]

/*
	Reference counted buffer. Meant to be used through a Buffer_Ref
*/
Buffer :: struct {
}

Buffer_Ref :: struct {
	buffer: ^Buffer,
	data:   [^]u8, // It is considered writable if and only if this is the only reference to the buffer,
	// in which case `buffer_is_writable()` returns 1.
	size:   uintptr,
}

Buffer_Pool_Entry :: struct {
}

/*
	This structure is opaque and not meant to be accessed directly.
	It is allocated with `buffer_pool_init` and freed with `av_buffer_pool_uninit`.
*/
Buffer_Pool :: struct {
}


//===camellia.h===
CAMELLIA :: struct {
}

//===cast5.h===
CAST5 :: struct {
}


//===channel_layout.h===
Channel :: enum i32 {
	None                  = -1,
	Front_Left            = 0,
	Front_Right           = 1,
	Front_Center          = 2,
	Low_Frequency         = 3,
	Back_Left             = 4,
	Back_Right            = 5,
	Front_Left_of_Center  = 6,
	Front_Right_of_Center = 7,
	Back_Center           = 8,
	Side_Left             = 9,
	Side_Right            = 10,
	Top_Center            = 11,
	Top_Front_Left        = 12,
	Top_Front_Center      = 13,
	Top_Front_Right       = 14,
	Top_Back_Left         = 15,
	Top_Back_Center       = 16,
	Top_Back_Right        = 17,
	Stereo_Left           = 29, ///< Stereo downmix.
	Stereo_Right          = 30, ///< See STEREO_LEFT.
	Wide_Left             = 31,
	Wide_Right            = 32,
	Surround_Direct_Left  = 33,
	Surround_Direct_Right = 34,
	Low_Frequency_2       = 35,
	Top_Side_Left         = 36,
	Top_Side_Right        = 37,
	Bottom_Front_Center   = 38,
	Bottom_Front_Left     = 39,
	Bottom_Front_Right    = 40,
	Unused                = 0x200,
	Unknown               = 0x300,
	Ambisonic_Base        = 0x400,
	Ambisonic_End         = 0x7ff,
}
//reduced set of Channel entries, used to define
//Channel_Layout as a u64.
Channel__internal__ :: enum u64 {
	Front_Left            = 0,
	Front_Right           = 1,
	Front_Center          = 2,
	Low_Frequency         = 3,
	Back_Left             = 4,
	Back_Right            = 5,
	Front_Left_of_Center  = 6,
	Front_Right_of_Center = 7,
	Back_Center           = 8,
	Side_Left             = 9,
	Side_Right            = 10,
	Top_Center            = 11,
	Top_Front_Left        = 12,
	Top_Front_Center      = 13,
	Top_Front_Right       = 14,
	Top_Back_Left         = 15,
	Top_Back_Center       = 16,
	Top_Back_Right        = 17,
	Stereo_Left           = 29, ///< Stereo downmix.
	Stereo_Right          = 30, ///< See STEREO_LEFT.
	Wide_Left             = 31,
	Wide_Right            = 32,
	Surround_Direct_Left  = 33,
	Surround_Direct_Right = 34,
	Low_Frequency_2       = 35,
	Top_Side_Left         = 36,
	Top_Side_Right        = 37,
	Bottom_Front_Center   = 38,
	Bottom_Front_Left     = 39,
	Bottom_Front_Right    = 40,
}
Channel_BitSet :: bit_set[Channel__internal__;u64]

Channel_Order :: enum i32 {
	Unspec,
	Native,
	Custom,
	Ambisonic,
}

Layout_Mono :: Channel_BitSet{.Front_Center}
Layout_Stereo :: Channel_BitSet{.Front_Left, .Front_Right}
Layout_2point1 :: Layout_Stereo + Channel_BitSet{.Low_Frequency}
Layout_2_1 :: Layout_Stereo + Channel_BitSet{.Back_Center}
Layout_Surround :: Layout_Stereo + Channel_BitSet{.Front_Center}
Layout_3point1 :: Layout_Surround + Channel_BitSet{.Low_Frequency}
Layout_4point0 :: Layout_Surround + Channel_BitSet{.Back_Center}
Layout_4point1 :: Layout_4point0 + Channel_BitSet{.Low_Frequency}
Layout_2_2 :: Layout_Stereo + Channel_BitSet{.Side_Left, .Side_Right}
Layout_Quad :: Layout_Stereo + Channel_BitSet{.Back_Left, .Back_Right}
Layout_5point0 :: Layout_Surround + Channel_BitSet{.Side_Left, .Side_Right}
Layout_5point1 :: Layout_5point0 + Channel_BitSet{.Low_Frequency}
Layout_5point0_Back :: Layout_Surround + Channel_BitSet{.Back_Left, .Back_Right}
Layout_5point1_Back :: Layout_5point0_Back + Channel_BitSet{.Low_Frequency}
Layout_6point0 :: Layout_5point0 + Channel_BitSet{.Back_Center}
Layout_6point0_Front :: Layout_2_2 + Channel_BitSet{.Front_Left_of_Center, .Front_Right_of_Center}
Layout_Hexagonal :: Layout_5point0_Back + Channel_BitSet{.Back_Center}
Layout_3point1point2 :: Layout_3point1 + Channel_BitSet{.Top_Front_Left, .Top_Front_Right}
Layout_6point1 :: Layout_5point1 + Channel_BitSet{.Back_Center}
Layout_6point1_Back :: Layout_5point1_Back + Channel_BitSet{.Back_Center}
Layout_6point1_Front :: Layout_6point0_Front + Channel_BitSet{.Low_Frequency}
Layout_7point0 :: Layout_5point0 + Channel_BitSet{.Back_Left, .Back_Right}
Layout_7point0_Front ::
	Layout_5point0 + Channel_BitSet{.Front_Left_of_Center, .Front_Right_of_Center}
Layout_7point1 :: Layout_5point1 + Channel_BitSet{.Back_Left, .Back_Right}
Layout_7point1_Wide ::
	Layout_5point1 + Channel_BitSet{.Front_Left_of_Center, .Front_Right_of_Center}
Layout_7point1_Wide_Back ::
	Layout_5point1_Back + Channel_BitSet{.Front_Left_of_Center, .Front_Right_of_Center}
Layout_5point1point2_Back ::
	Layout_5point1_Back + Channel_BitSet{.Top_Front_Left, .Top_Front_Right}
Layout_Octagonal :: Layout_5point0 + Channel_BitSet{.Back_Left, .Back_Center, .Back_Right}
Layout_Cube ::
	Layout_Quad +
	Channel_BitSet{.Top_Front_Left, .Top_Front_Right, .Top_Back_Left, .Top_Back_Right}
Layout_5point1point4_Back ::
	Layout_5point1point2_Back + Channel_BitSet{.Top_Back_Left, .Top_Back_Right}
Layout_7point1point2 :: Layout_7point1 + Channel_BitSet{.Top_Front_Left, .Top_Front_Right}
Layout_7point1point4_Back :: Layout_7point1point2 + Channel_BitSet{.Top_Back_Left, .Top_Back_Right}
Layout_7point2point3 :: Layout_7point1point2 + Channel_BitSet{.Top_Back_Center, .Low_Frequency_2}
Layout_9point1point4_Back ::
	Layout_7point1point4_Back + Channel_BitSet{.Front_Left_of_Center, .Front_Right_of_Center}
Layout_Hexadecagonal ::
	Layout_Octagonal +
	Channel_BitSet {
			.Wide_Left,
			.Wide_Right,
			.Top_Back_Left,
			.Top_Back_Right,
			.Top_Back_Center,
			.Top_Front_Center,
			.Top_Front_Left,
			.Top_Front_Right,
		}
Layout_Stereo_Downmix :: Channel_BitSet{.Stereo_Left, .Stereo_Right}
Layout_22point2 ::
	Layout_7point1point4_Back +
	Channel_BitSet {
			.Front_Left_of_Center,
			.Front_Right_of_Center,
			.Back_Center,
			.Low_Frequency_2,
			.Top_Front_Center,
			.Top_Center,
			.Top_Side_Left,
			.Top_Side_Right,
			.Top_Back_Center,
			.Bottom_Front_Center,
			.Bottom_Front_Left,
			.Bottom_Front_Right,
		}

Layout_7point1_Top_Back :: Layout_5point1point2_Back


Matrix_Encoding :: enum i32 {
	NONE,
	DOLBY,
	DPLII,
	DPLIIX,
	DPLIIZ,
	DOLBYEX,
	DOLBYHEADPHONE,
	Not_Part_of_ABI,
}


Channel_Custom :: struct {
	id:     Channel,
	name:   [16]byte,
	opaque: rawptr,
}

Channel_Layout :: struct {
	order:       Channel_Order,
	nb_channels: i32,
	u:           struct #raw_union {
		mask:   u64,
		ch_map: ^Channel_Custom,
	},
	opaque:      rawptr,
}


//===cpu.h===
//TODO: Handle channel layouts in AV_CHANNEL_LAYOUT
// note: not (AV_CH_LAYOUT)


//How to handle overlapping flag names?

Cpu_Flag :: enum u32 {
	FORCE       = 31, /* force usage of selected flags (OR) */

	/* lower 16 bits - CPU features */
	MMX         = 0, ///< standard MMX
	MMXEXT      = 1, ///< SSE integer functions or AMD MMX ext
	MMX2        = 1, ///< SSE integer functions or AMD MMX ext
	_3DNOW      = 2, ///< AMD 3DNOW
	SSE         = 3, ///< SSE functions
	SSE2        = 4, ///< PIV SSE2 functions
	SSE2SLOW    = 30, ///< SSE2 supported, but usually not faster
	///< than regular MMX/SSE (e.g. Core1)
	_3DNOWEXT   = 5, ///< AMD 3DNowExt
	SSE3        = 6, ///< Prescott SSE3 functions
	SSE3SLOW    = 29, ///< SSE3 supported, but usually not faster
	///< than regular MMX/SSE (e.g. Core1)
	SSSE3       = 7, ///< Conroe SSSE3 functions
	SSSE3SLOW   = 26, ///< SSSE3 supported, but usually not faster
	ATOM        = 28, ///< Atom processor, some SSSE3 instructions are slower
	SSE4        = 8, ///< Penryn SSE4.1 functions
	SSE42       = 9, ///< Nehalem SSE4.2 functions
	AESNI       = 19, ///< Advanced Encryption Standard functions
	AVX         = 14, ///< AVX functions: requires OS support even if YMM registers aren't used
	AVXSLOW     = 27, ///< AVX supported, but slow when using YMM registers (e.g. Bulldozer)
	XOP         = 10, ///< Bulldozer XOP functions
	FMA4        = 11, ///< Bulldozer FMA4 functions
	CMOV        = 12, ///< supports cmov instruction
	AVX2        = 15, ///< AVX2 functions: requires OS support even if YMM registers aren't used
	FMA3        = 16, ///< Haswell FMA3 functions
	BMI1        = 17, ///< Bit Manipulation Instruction Set 1
	BMI2        = 18, ///< Bit Manipulation Instruction Set 2
	AVX512      = 20, ///< AVX-512 functions: requires OS support even if YMM/ZMM registers aren't used
	AVX512ICL   = 21,
	SLOW_GATHER = 25,
	ALTIVEC     = 0, ///< standard
	VSX         = 1, ///< ISA 2.06
	POWER8      = 2, ///< ISA 2.07
	ARMV5TE     = 0,
	ARMV6       = 1,
	ARMV6T2     = 2,
	VFP         = 3,
	VFPV3       = 4,
	NEON        = 5,
	ARMV8       = 6,
	VFP_VM      = 7, ///< VFPv2 vector mode, deprecated in ARMv7-A and unavailable in various CPUs implementations
	DOTPROD     = 8,
	I8MM        = 9,
	SETEND      = 16,
	MMI         = 0,
	MSA         = 1,
	LSX         = 0,
	LASX        = 1,
	RVI         = 0,
	RVF         = 1,
	RVD         = 2, ///< D (double precision FP)
	RVV_I32     = 3, ///< Vectors of 8/16/32-bit int's */
	RVV_F32     = 4, ///< Vectors of float's */
	RVV_I64     = 5, ///< Vectors of 64-bit int's */
	RVV_F64     = 6, ///< Vectors of double's
	RVB_BASIC   = 7, ///< Basic bit-manipulations
	RVB_ADDR    = 8, ///< Address bit-manipulations
}
Cpu_Flags :: bit_set[Cpu_Flag;u64]


//===crc.h===
CRC :: distinct u32

CRC_Id :: enum i32 {
	_8_ATM,
	_16_ANSI,
	_16_CCITT,
	_32_IEEE,
	_32_IEEE_LE, /*< reversed bitorder version of AV_CRC_32_IEEE */
	_16_ANSI_LE, /*< reversed bitorder version of AV_CRC_16_ANSI */
	_24_IEEE,
	_8_EBU,
	MAX, /*< Not part of public API! Do not use outside libavutil. */
}

//===csp.h===
Luma_Coefficients :: struct {
	cr, cg, cb: Rational,
}

CIE_xy :: struct {
	x, y: Rational,
}

Primary_Coefficients :: struct {
	r, g, b: CIE_xy,
}

Whitepoint_Coefficients :: distinct CIE_xy


Color_Primaries_Desc :: struct {
	wp:   Whitepoint_Coefficients,
	prim: Primary_Coefficients,
}

csp_trc_function :: #type proc(input: f64) -> f64

//===des.h===
DES :: struct {
	round_keys: [3][16]u64,
	triple_des: i32,
}

//===detection_bbox.h===
DETECTION_BBOX_LABEL_NAME_MAX_SIZE :: 64
NUM_DETECTION_BBOX_CLASSIFY :: 4
Detection_Bounding_Box :: struct {
	x, y, w, h:           i32,
	detect_label:         [DETECTION_BBOX_LABEL_NAME_MAX_SIZE]byte,
	detect_confidence:    Rational,
	classify_count:       u32,
	classify_labels:      [NUM_DETECTION_BBOX_CLASSIFY][DETECTION_BBOX_LABEL_NAME_MAX_SIZE]byte,
	classify_confidences: [NUM_DETECTION_BBOX_CLASSIFY]Rational,
}

Detection_Bounding_Box_Header :: struct {
	source:        [256]byte,
	nb_boxes:      u32,
	bboxes_offset: uintptr,
	bbox_size:     uintptr,
}

//===dict.h===

Dictionary_Flag :: enum i32 {
	Match_Case      = 0,
	Ignore_Suffix   = 1,
	Dont_Strdup_Key = 2,
	Dont_Strdup_Val = 3,
	Dont_Overwrite  = 4,
	Append          = 5,
	Multikey        = 6,
}
Dictionary_Flags :: bit_set[Dictionary_Flag;i32]

Dictionary_Entry :: struct {
	key:   cstring,
	value: cstring,
}
Dictionary :: struct {
}
/* Not present in dict.h??
Dictionary :: struct {
	count:    u32,
	elements: [^]Dictionary_Entry,
}*/

//===dovi_meta.h===	
DOVI_Decoder_Configuration_Record :: struct {
	dv_version_major:              u8,
	dv_version_minor:              u8,
	dv_profile:                    u8,
	dv_level:                      u8,
	rpu_present_flag:              u8,
	el_present_flag:               u8,
	bl_present_flag:               u8,
	dv_bl_signal_compatibility_id: u8,
}

DOVI_RPU_Data_Header :: struct {
	rpu_type:                               u8,
	rpu_format:                             u16,
	vdr_rpu_profile:                        u8,
	vdr_rpu_level:                          u8,
	chroma_resampling_explicit_filter_flag: u8,
	coef_data_type:                         u8, /* informative, lavc always converts to fixed */
	coef_log2_denom:                        u8,
	vdr_rpu_normalized_idc:                 u8,
	bl_video_full_range_flag:               u8,
	bl_bit_depth:                           u8, /* [8, 16] */
	el_bit_depth:                           u8, /* [8, 16] */
	vdr_bit_depth:                          u8, /* [8, 16] */
	spatial_resampling_filter_flag:         u8,
	el_spatial_resampling_filter_flag:      u8,
	disable_residual_flag:                  u8,
}

DOVI_Mapping_Method :: enum i32 {
	Polynomial = 0,
	MMR        = 1,
}

DOVI_MAX_PIECES :: 8
DOVI_Reshaping_Curve :: struct {
	num_pivots:   u8, /* [2, 9] */
	pivots:       [DOVI_MAX_PIECES + 1]u16, /* sorted ascending */
	mapping_idc:  [DOVI_MAX_PIECES]DOVI_Mapping_Method,
	/* AV_DOVI_MAPPING_POLYNOMIAL */
	poly_order:   [DOVI_MAX_PIECES]u8, /* [1, 2] */
	poly_coef:    [DOVI_MAX_PIECES][3]i64, /* x^0, x^1, x^2 */
	/* AV_DOVI_MAPPING_MMR */
	mmr_order:    [DOVI_MAX_PIECES]u8, /* [1, 3] */
	mmr_constant: [DOVI_MAX_PIECES]i64,
	mmr_coef:     [DOVI_MAX_PIECES][3] /* order - 1 */[7]i64,
}

DOVI_NLQ_Method :: enum i32 {
	None      = -1,
	Linear_DZ = 0,
}

DOVI_NLQ_Params :: struct {
	nlq_offset:                u16,
	vdr_in_max:                u64,
	linear_deadzone_slope:     u64,
	linear_deadzone_threshold: u64,
}

DOVI_Data_Mapping :: struct {
	vdr_rpu_id:                 u8,
	mapping_color_space:        u8,
	mapping_chdroma_Format_idc: u8,
	curves:                     [3]DOVI_Reshaping_Curve,
	nlq_method_idc:             DOVI_NLQ_Method,
	num_x_partitions:           u32,
	num_y_partitions:           u32,
	nlq:                        [3]DOVI_NLQ_Params,
}

DOVI_Color_Metadata :: struct {
	dm_metadata_id:         u8,
	scene_refresh_flag:     u8,
	ycc_to_rgb_matrix:      [9]Rational, /* before PQ linearization */
	ycc_to_rgb_offset:      [3]Rational, /* input offset of neutral value */
	rgb_to_lms_matrix:      [9]Rational, /* after PQ linearization */
	signal_eotf:            u16,
	signal_eotf_param0:     u16,
	signal_eotf_param1:     u16,
	signal_eotf_param2:     u32,
	signal_bit_depth:       u8,
	signal_color_space:     u8,
	signal_chroma_format:   u8,
	signal_full_range_flag: u8, /* [0, 3] */
	source_min_pq:          u16,
	source_max_pq:          u16,
	source_diagonal:        u16,
}

DOVI_Metadata :: struct {
	header_offset:  uintptr, /* AVDOVIRpuDataHeader */
	mapping_offset: uintptr, /* AVDOVIDataMapping */
	color_offset:   uintptr, /* AVDOVIColorMetadata */
}

//===downmix_info.h===

Downmix_Type :: enum i32 {
	UNKNOWN, /**< Not indicated. */
	LORO, /**< Lo/Ro 2-channel downmix (Stereo). */
	LTRT, /**< Lt/Rt 2-channel downmix, Dolby Surround compatible. */
	DPLII, /**< Lt/Rt 2-channel downmix, Dolby Pro Logic II compatible. */
	Not_Part_of_ABI, /**< Number of downmix types. Not part of ABI. */
}

Downmix_Info :: struct {
	preferred_downmix_type:  Downmix_Type,
	center_mix_level:        f64,
	center_mix_level_ltrt:   f64,
	surround_mix_level:      f64,
	surround_mix_level_ltrt: f64,
	lfe_mix_level:           f64,
}


//===encryption_info.h===

Subsample_Encryption_Info :: struct {
	bytes_of_clear_data:     u32,
	bytes_of_protected_data: u32,
}

/**
 * This describes encryption info for a packet.  This contains frame-specific
 * info for how to decrypt the packet before passing it to the decoder.
 *
 * The size of this struct is not part of the public ABI.
 */
Encryption_Info :: struct {
	/** The fourcc encryption scheme, in big-endian byte order. */
	scheme:           u32,

	/**
     * Only used for pattern encryption.  This is the number of 16-byte blocks
     * that are encrypted.
     */
	crypt_byte_block: u32,

	/**
     * Only used for pattern encryption.  This is the number of 16-byte blocks
     * that are clear.
     */
	skip_byte_block:  u32,

	/**
     * The ID of the key used to encrypt the packet.  This should always be
     * 16 bytes long, but may be changed in the future.
     */
	key_id:           [^]u8,
	key_id_size:      u32,

	/**
     * The initialization vector.  This may have been zero-filled to be the
     * correct block size.  This should always be 16 bytes long, but may be
     * changed in the future.
     */
	iv:               [^]u8,
	iv_size:          u32,

	/**
     * An array of subsample encryption info specifying how parts of the sample
     * are encrypted.  If there are no subsamples, then the whole sample is
     * encrypted.
     */
	subsamples:       [^]Subsample_Encryption_Info,
	subsample_count:  u32,
}

/**
 * This describes info used to initialize an encryption key system.
 *
 * The size of this struct is not part of the public ABI.
 */
Encryption_Init_Info :: struct {
	/**
     * A unique identifier for the key system this is for, can be NULL if it
     * is not known.  This should always be 16 bytes, but may change in the
     * future.
     */
	system_id:      [^]u8,
	system_id_size: u32,

	/**
     * An array of key IDs this initialization data is for.  All IDs are the
     * same length.  Can be NULL if there are no known key IDs.
     */
	key_ids:        ^[^]u8,
	/** The number of key IDs. */
	num_key_ids:    u32,
	/**
     * The number of bytes in each key ID.  This should always be 16, but may
     * change in the future.
     */
	key_id_size:    u32,

	/**
     * Key-system specific initialization data.  This data is copied directly
     * from the file and the format depends on the specific key system.  This
     * can be NULL if there is no initialization data; in that case, there
     * will be at least one key ID.
     */
	data:           [^]byte,
	data_size:      u32,

	/**
     * An optional pointer to the next initialization info in the list.
     */
	next:           ^Encryption_Init_Info,
}

//===executor.h===

Executor :: struct {
}

Task :: struct {
	next: ^Task,
}

Task_Callbacks :: struct {
	user_data:          rawptr,
	local_context_size: i32,
	priority_higher:    #type proc(a: ^Task, b: ^Task) -> i32,
	ready:              #type proc(t: ^Task, user_data: rawptr) -> i32,
	run:                #type proc(t: ^Task, local_context: rawptr, user_data: rawptr) -> i32,
}

//===fifo.h===

Fifo :: struct {
}

fifo_cb :: #type proc(opaque: rawptr, buf: rawptr, nb_elems: uintptr) -> i32

Fifo_Flag :: enum i32 {
	Auto_Grow = 0,
}
Fifo_Flags :: bit_set[Fifo_Flag;i32]


/* NOTE:
	original C code changes the meaning of va_list based on how ffmpeg is compiled.
	#ifndef _VA_LIST_DEFINED
    #define _VA_LIST_DEFINED
    #ifdef _M_CEE_PURE
        typedef System::ArgIterator va_list;
    #else
        typedef char* va_list;
    #endif
#endif
	It is assumed to be a char* (cstring) here.
	*/
va_list :: distinct cstring


//===film_grain_params.h===
Film_Grain_Params_Type :: enum i32 {
	NONE = 0,

	// The union is valid when interpreted as Film_Grain_AOM_Params (codec.aom)
	AV1,

	// The union is valid when interpreted as Film_Grain_H274_Params (codec.h274)
	H274,
}

// This structure describes how to handle film grain synthesis for AOM codecs.
//??? CHECK that multiple-arrays were flipped around properly.
Film_Grain_AOM_Params :: struct {
	num_y_points:             i32,
	y_points:                 [14][2]u8, // value, scaling
	chroma_scaling_from_luma: i32,
	num_uv_points:            [2]i32, // cb, cr
	uv_points:                [2] /*cb, cr*/[10][2] /*value, scaling*/u8,
	scaling_shift:            i32,

	// Specifies the auto-regression lag.
	ar_coeff_lag:             i32,
	ar_coeffs_y:              [24]i8,
	ar_coeffs_uv:             [2][25]i8, // cb, cr
	ar_coeff_shift:           i32,
	grain_scale_shift:        i32,
	uv_mult:                  [2]i32, // cb, cr
	uv_mult_luma:             [2]i32, // cb, cr
	uv_offset:                [2]i32, // cb, cr
	overlap_flag:             i32,
	limit_output_range:       i32,
}

Film_Grain_H274_Params :: struct {
	model_id:                       i32,
	bit_depth_luma:                 i32,
	bit_depth_chroma:               i32,
	color_range:                    Color_Range,
	color_primaries:                Color_Primaries,
	color_trc:                      Color_Transfer_Characteristic,
	color_space:                    Color_Space,
	blending_mode_id:               i32,
	log2_scale_factor:              i32,
	component_model_present:        [3]i32, // y, cb, cr
	num_intensity_intervals:        [3]u16, // y, cb, cr
	num_model_values:               [3]u8, // y, cb, cr
	intensity_interval_lower_bound: [3][256]u8, // y, cb, cr, intensity interval
	intensity_interval_upper_bound: [3][256]u8, // y, cb, cr, intensity interval
	comp_model_value:               [3][256][6]i16, // y, cb, cr, intensity interval, model value
}

Film_Grain_Params :: struct {
	type:  Film_Grain_Params_Type,
	seed:  u64,
	codec: struct #raw_union {
		aom:  Film_Grain_AOM_Params,
		h274: Film_Grain_H274_Params,
	},
}

//===frame.h===

Frame_Side_Data_Type :: enum i32 {
	Pan_Scan,
	A53Cc,
	Stereo_3D,
	Matrix_Encoding,
	Downmix_Info,
	Replay_Gain,
	Display_Matrix,
	Active_Format_Description,
	Motion_Vectors,
	Skip_Samples,
	Audio_Service_Type,
	Mastering_Display_Metadata,
	GOP_Timecode,
	Spherical,
	Content_Light_Level,
	ICC_Profile,
	S12M_Timecode,
	Dynamic_HDR_Plus,
	Regions_of_Interest,
	Video_Enc_Params,
	Sei_Unregistered,
	Film_Grain_Params,
	Detection_Bboxes,
	DOVI_RPU_Buffer,
	DOVI_Metadata,
	Dynamic_HDR_Vivid,
	Ambient_Viewing_Environment,
	Video_Hint,
}


Active_Format_Description :: enum i32 {
	Same            = 8,
	AR_4_3          = 9,
	AR_16_9         = 10,
	AR_14_9         = 11,
	AR_4_3_SP_14_9  = 13,
	AR_16_9_SP_14_9 = 14,
	AR_SP_4_3       = 15,
}

Frame_Side_Data :: struct {
	type:     Frame_Side_Data_Type,
	data:     [^]u8,
	size:     uint,
	metadata: ^Dictionary,
	buffer:   ^Buffer_Ref,
}


NUM_DATA_POINTERS :: 8

Frame_Flag :: enum i32 {
	Corrupt         = 0,
	Key             = 1,
	Discard         = 2,
	Interlaced      = 3,
	Top_Field_First = 4,
}
Frame_Flags :: bit_set[Frame_Flag;i32]


Region_of_Interest :: struct {
	/**
	 * Must be set to the size of this data structure (that is,
	 * size_of(Region_of_Interest)).
	 */
	self_size: u32,

	/**
	 * Distance in pixels from the top edge of the frame to the top and
	 * bottom edges and from the left edge of the frame to the left and
	 * right edges of the rectangle defining this region of interest. */
	top:       i32,
	bottom:    i32,
	left:      i32,
	right:     i32,

	/**
	  * Quantisation offset.
	  *	  */
	q_offet:   Rational,
}


Frame :: struct {
	/**
	 * pointer to the picture/channel planes.
	 * This might be different from the first allocated byte
	 *	 */
	data:                   [NUM_DATA_POINTERS][^]u8,

	/**
	 * For video, size in bytes of each picture line.
	 * For audio, size in bytes of each plane.
	 *	 */
	linesize:               [NUM_DATA_POINTERS]i32,

	/**
	 * pointers to the data planes/channels.
	 *	 */
	extended_data:          ^[^]u8,

	/**
	 * @name Video dimensions
	 * 	 */
	width:                  i32,
	height:                 i32,

	/**
	 * number of audio samples (per channel) described by this frame
	 */
	nb_samples:             i32,

	/**
	 * format of the frame, -1 if unknown or unset
	 * Values correspond to enum `Pixel_Format` for video frames, enum `Sample_Format` for audio)
	 */
	//TODO: How does this handle the -1 case?
	format:                 struct #raw_union {
		video: Pixel_Format,
		audio: Sample_Format,
	},
	key_frame:              i32,

	/**
	 * Picture type of the frame.
	 */
	pict_type:              Picture_Type,

	/**
	 * Sample aspect ratio for the video frame, 0/1 if unknown/unspecified.
	 */
	sample_aspect_ratio:    Rational,

	/**
	 * Presentation timestamp in time_base units (time when frame should be shown to user).
_Base	 */
	pts:                    i64,

	/**
	 * DTS copied from the AVPacket that triggered returning this frame. (if frame threading isn't used)
	 * This is also the Presentation time of this AVFrame calculated from
	 * only AVPacket.dts values without pts values.
	 */
	pkt_dts:                i64,

	/* Time base for the timestamps in this frame. */
	time_base:              Rational,
	oded_picture_number:    i32,
	/**
     * picture number in display order
     */
	display_picture_number: i32,
	/**
	 * quality (between 1 (good) and FF_LAMBDA_MAX (bad))
	 */
	quality:                i32,

	/**
	 * for some private data of the user
	 */
	opaque:                 rawptr,

	/**
	 * When decoding, this signals how much the picture must be delayed.
	 * extra_delay = repeat_pict / (2*fps)
	 */
	repeat_pict:            i32,
	interlaced_frame:       i32,
	top_field_first:        i32,
	palette_has_changed:    i32,
	reordered_opaque:       i64,
	/**
	 * Sample rate of the audio data.
	 */
	sample_rate:            i32,
	channel_layout:         u64,


	/**
	 * AVBuffer references backing the data for this frame. If all elements of
	 * this array are NULL, then this frame is not reference counted. This array
	 * must be filled contiguously -- if buf[i] is non-NULL then buf[j] must
	 * also be non-NULL for all j < i.	 */
	buf:                    [NUM_DATA_POINTERS]^Buffer_Ref,

	/**
	 * For planar audio which requires more than AV_NUM_DATA_POINTERS
	 * AVBufferRef pointers, this array will hold all the references which
	 * cannot fit into AVFrame.buf.
	 */
	extnded_buf:            ^[^]Buffer_Ref,

	/**
	 * Number of elements in extended_buf.
	 */
	nb_extended_buf:        i32,
	side_data:              ^[^]Frame_Side_Data,
	nb_side_data:           i32,

	/**
	 * Frame flags, a combination of @ref lavu_frame_flags
	 */
	flags:                  Frame_Flags,

	/**
	 * MPEG vs JPEG YUV range.
	 */
	color_range:            Color_Range,
	color_primaries:        Color_Primaries,
	color_trc:              Color_Transfer_Characteristic,

	/**
	 * YUV colorspace type.
	 */
	colorspace:             Color_Space,
	chroma_location:        Chroma_Location,

	/**
	 * frame timestamp estimated using various heuristics, in stream time base
	 */
	best_effort_timestamp:  i64,
	pkt_pos:                i64,
	pkt_duration:           i64,

	/**
	 * metadata.
	 */
	metadata:               ^Dictionary,

	/**
	 * decode error flags of the frame, set to a combination of
	 * FF_DECODE_ERROR_xxx flags if the decoder produced a frame, but there
	 * were errors during the decoding.
	 */
	decode_error_flags:     Decode_Error_Flags,
	channels:               i32,
	pkt_size:               i32,


	/**
	 * For hwaccel-format frames, this should be a reference to the
	 * AVHWFramesContext describing the frame.
	 */
	hw_frames_ctx:          ^Buffer_Ref,

	/**
	 * AVBufferRef for free use by the API user. FFmpeg will never check the
	 * contents of the buffer ref. 	 */
	opaque_ref:             ^Buffer_Ref,

	/**
	 * @name Cropping
	 * Video frames only. The number of pixels to discard from the the
	 * top/bottom/left/right border of the frame to obtain the sub-rectangle of
	 * the frame intended for presentation.
	 * @{
	 */
	//TODO: understand why this is a size_t in the original code.
	crop_top:               i64,
	crop_bottom:            i64,
	crop_left:              i64,
	crop_right:             i64,
	/**
	 * @}
	 */

	/**
	 * AVBufferRef for internal use by a single libav* library.
	 * Must not be used to transfer data between libraries.
	 */
	private_ref:            ^Buffer_Ref,
	ch_layout:              Channel_Layout,
	duration:               i64,
}

Frame_Crop_Flag :: enum i32 {
	Unaligned = 0,
}
Frame_Crop_Flags :: bit_set[Frame_Crop_Flag;i32]

//===hash.h===
Hash_Context :: struct {
}

//===hdr_dynamic_metadata.h===
HDR_Plus_Overlap_Process_Option :: enum i32 {
	HDR_PLUS_OVERLAP_PROCESS_WEIGHTED_AVERAGING = 0,
	HDR_PLUS_OVERLAP_PROCESS_LAYERING           = 1,
}

HDR_Plus_Percentile :: struct {
	percentage: u8,
	percentile: Rational,
}

HDR_Plus_Color_Transform_Params :: struct {
	window_upper_left_corner_x:          Rational,
	window_upper_left_corner_y:          Rational,
	window_lower_right_corner_x:         Rational,
	window_lower_right_corner_y:         Rational,
	center_of_ellipse_x:                 u16,
	center_of_ellipse_y:                 u16,
	rotation_angle:                      u8,
	semimajor_axis_internal_ellipse:     u16,
	semimajor_axis_external_ellipse:     u16,
	semiminor_axis_external_ellipse:     u16,
	overlap_process_option:              HDR_Plus_Overlap_Process_Option,
	maxscl:                              [3]Rational,
	average_maxrgb:                      Rational,
	num_distribution_maxrgb_percentiles: u8,
	distribution_maxrgb:                 [15]HDR_Plus_Percentile,
	fraction_bright_pixels:              Rational,
	tone_mapping_flag:                   u8,
	knee_point_x:                        Rational,
	knee_point_y:                        Rational,
	num_bezier_curve_anchors:            u8,
	bezier_curve_anchors:                [15]Rational,
	color_saturation_mapping_flag:       u8,
	color_saturation_weight:             Rational,
}

Dynamic_HDR_Plus :: struct {
	itu_t_t35_country_code:                                 u8,
	application_version:                                    u8,
	num_windows:                                            u8,
	params:                                                 [3]HDR_Plus_Color_Transform_Params,
	targeted_system_display_maximum_luminance:              Rational,
	targeted_system_display_actual_peak_luminance_flag:     u8,
	num_rows_targeted_system_display_actual_peak_luminance: u8,
	num_cols_targeted_system_display_actual_peak_luminance: u8,
	targeted_system_display_actual_peak_luminance:          [25][25]Rational,
	mastering_display_actual_peak_luminance_flag:           u8,
	num_rows_mastering_display_actual_peak_luminance:       u8,
	num_cols_mastering_display_actual_peak_luminance:       u8,
	mastering_display_actual_peak_luminance:                [25][25]Rational,
}


//===hdr_dynamic_vivid_metadata.h===
HDR_Vivid_3_Spline_Params :: struct {
	th_mode:         i32,
	th_enable_mb:    Rational,
	th_enable:       Rational,
	th_delta1:       Rational,
	th_delta2:       Rational,
	enable_strength: Rational,
}

HDR_Vivid_Color_ToneMapping_Params :: struct {
	targeted_system_display_maximum_luminance: Rational,
	base_enable_flag:                          i32,
	base_param_m_p:                            Rational,
	base_param_m_m:                            Rational,
	base_param_m_a:                            Rational,
	base_param_m_b:                            Rational,
	base_param_m_n:                            Rational,
	base_param_k1:                             i32,
	base_param_k2:                             i32,
	base_param_k3:                             i32,
	base_param_Delta_enable_mode:              i32,
	base_param_Delta:                          Rational,
	three_Spline_enable_flag:                  i32,
	three_Spline_num:                          i32,
	three_spline:                              [2]HDR_Vivid_3_Spline_Params,
}

HDR_Vivid_Color_Transform_Params :: struct {
	minimum_maxrgb:                Rational,
	average_maxrgb:                Rational,
	variance_maxrgb:               Rational,
	maximum_maxrgb:                Rational,
	tone_mapping_mode_flag:        i32,
	tone_mapping_param_num:        i32,
	tm_params:                     [2]HDR_Vivid_Color_ToneMapping_Params,
	color_saturation_mapping_flag: i32,
	color_saturation_num:          i32,
	color_saturation_gain:         [8]Rational,
}

Dynamic_HDR_Vivid :: struct {
	system_start_code: u8,
	num_windows:       u8,
	params:            [3]HDR_Vivid_Color_Transform_Params,
}

//===hmac.h===
HMAC_Type :: enum i32 {
	HMAC_MD5,
	HMAC_SHA1,
	HMAC_SHA224,
	HMAC_SHA256,
	HMAC_SHA384,
	HMAC_SHA512,
}

HMAC :: struct {
}


//===hwcontext.h===
HW_Device_Type :: enum i32 {
	NONE,
	VDPAU,
	CUDA,
	VAAPI,
	DXVA2,
	QSV,
	VIDEOTOOLBOX,
	D3D11VA,
	DRM,
	OPENCL,
	MEDIACODEC,
	VULKAN,
}

Hardware_Device_Internal :: struct {
}

Hardware_Device_Context :: struct {
	class:       ^Class,
	internal:    ^Hardware_Device_Internal,
	type:        Hardware_Device_Type,
	hwctx:       rawptr,
	free:        #type proc(ctx: ^Hardware_Device_Context),
	user_opaque: rawptr,
}

Hardware_Frames_Internal :: struct {
}

Hardware_Frames_Context :: struct {
	av_class:          ^Class,
	internal:          ^Hardware_Frames_Internal,
	device_ref:        ^Buffer_Ref,
	device_ctx:        ^Hardware_Device_Context,
	hwctx:             rawptr,
	free:              proc(ctx: ^Hardware_Frames_Context),
	user_opaque:       rawptr,
	pool:              ^Buffer_Pool,
	initial_pool_size: i32,
	format:            Pixel_Format,
	sw_format:         Pixel_Format,
	width:             i32,
	height:            i32,
}

Hardware_Frame_Transfer_Direction :: enum i32 {
	FROM,
	TO,
}

Hardware_Frames_Constraints :: struct {
	valid_hw_formats: ^Pixel_Format,
	valid_sw_formats: ^Pixel_Format,
	min_width:        i32,
	min_height:       i32,
	max_width:        i32,
	max_height:       i32,
}

Hardware_Frame_Map_Flag :: enum i32 {
	Read      = 0,
	Write     = 1,
	Overwrite = 2,
	Direct    = 3,
}
Hardware_Frame_Map_Flags :: bit_set[Hardware_Frame_Map_Flag;i32]

//===lfg.h===
LFG :: struct {
	state: [64]u32,
	index: i32,
}

//===log.h===

Class_Category :: enum i32 {
	NONE = 0,
	Input,
	Output,
	Muxer,
	Demuxer,
	Encoder,
	Decoder,
	Filter,
	Bitstream_Filter,
	Swscaler,
	Swresampler,
	Device_Video_Output = 40,
	Device_Video_Input,
	Device_Audio_Output,
	Device_Audio_Input,
	Device_Output,
	Device_Input,
	Not_Part_of_ABI,
}


Class :: struct {
	class_name:                cstring,
	item_name:                 #type proc(ctx: rawptr) -> cstring,
	option:                    ^Option,
	av_util_verion:            i32,
	log_level_offset_offset:   i32,
	parent_log_context_offset: i32,
	category:                  Class_Category,
	get_category:              #type proc(ctx: rawptr) -> (category: Class_Category),
	query_ranges:              #type proc(
		ranges: ^[^]Option_Ranges,
		obj: rawptr,
		key: cstring,
		flags: Option_Flags,
	) -> i32,
	child_next:                #type proc(obj: rawptr, prev: rawptr) -> rawptr,
	child_class_iterate:       #type proc(iter: ^rawptr) -> ^Class,
}


Log_Level :: enum i32 {
	QUIET      = -8,
	PANIC      = 0,
	FATAL      = 8,
	ERROR      = 16,
	WARNING    = 24,
	INFO       = 32,
	VERBOSE    = 40,
	DEBUG      = 48,
	TRACE      = 56,
	MAX_OFFSET = (TRACE - QUIET),
}

//===lzo.h===
LZO_Decode_Flag :: enum i32 {
	Input_Depleted  = 0,
	Output_Full     = 1,
	Invalid_Backptr = 2,
	Error           = 3,
}
LZO_Decode_Flags :: bit_set[LZO_Decode_Flag;i32]

//===mastering_display_metadata.h===
Mastering_Display_Metadata :: struct {
	display_primaries: [3][2]Rational,
	white_point:       [2]Rational,
	min_luminance:     Rational,
	max_luminance:     Rational,
	has_primaries:     i32,
	has_luminance:     i32,
}

Content_Light_Metadata :: struct {
	MaxCLL:  u32,
	MaxFALL: u32,
}

//===mathematics.h===
Rounding :: enum i32 {
	Zero          = 0,
	Infinity      = 1,
	Down          = 2,
	Up            = 3,
	Near_Infinity = 5,
	Pass_Min_Max  = 8192,
}


//===md5.h===
MD5 :: struct {
}

//===motion_vector.h===
Motion_Vector :: struct {
	source:             i32,
	w, h:               u8,
	src_x, src_y:       i16,
	dst_x, dst_y:       i16,
	flags:              u64,
	motion_x, motion_y: i32,
	motion_scale:       u16,
}

//===murmur3.h===

//defined in murmur3.c, not declared in murmur3.h. Hoping I can ignore that.
MurMur3 :: struct {
}

//===opt.h===

Option_Type :: enum i32 {
	Flags,
	Int,
	Int64,
	Double,
	Float,
	String,
	Rational,
	Binary,
	Dict,
	Uint64,
	Const,
	Image_Size,
	Pixel_Fmt,
	Sample_Fmt,
	Video_Rate,
	Duration,
	Color,
	Bool,
	ChLayout,
}

Option_Flag :: enum i32 {
	Encoding_Param  = 0,
	Decoding_Param  = 1,
	Audio_Param     = 3,
	Video_Param     = 4,
	Subtitle_Param  = 5,
	Export          = 6,
	Read_Only       = 7,
	BSF_Param       = 8,
	Runtime_Param   = 15,
	Filtering_Param = 16,
	Deprecated      = 17,
	Child_Constants = 18,
}
Option_Flags :: bit_set[Option_Flag;i32]

Option :: struct {
	name:          cstring,
	help:          cstring,
	option_offset: i32,
	type:          Option_Type,
	default_val:   struct #raw_union {
		int_64: i64,
		dbl:    f64,
		str:    cstring,
		q:      Rational,
	},
	min:           f64,
	max:           f64,
	flags:         Option_Flags,
	unit:          cstring,
}


Option_Range :: struct {
	str:           cstring,
	value_min:     f64,
	value_max:     f64,
	component_min: f64,
	component_max: f64,
	is_range:      i32,
}

Option_Ranges :: struct {
	range:         ^[^]Option_Range,
	nb_ranges:     i32,
	nb_components: i32,
}

//TODO: add in the smaller opt.h flag enums.

//===pixdesc.h===

Component_Descriptor :: struct {
	plane:  i32,
	step:   i32,
	offset: i32,
	shift:  i32,
	depth:  i32,
}

Pix_Fmt_Descriptor :: struct {
	name:          cstring,
	nb_components: u8,
	log2_chroma_w: u8,
	log2_chroma_h: u8,
	flags:         u64,
	comp:          [4]Component_Descriptor,
	alias:         ^u8,
}

Pixel_Format_Flag :: enum i32 {
	BE        = 0,
	Palette   = 1,
	Bitstream = 2,
	HW_Accel  = 3,
	Planar    = 4,
	RGB       = 5,
	Alpha     = 7,
	Bayer     = 8,
	Float     = 9,
	XYZ       = 10,
}
Pixel_Format_Flags :: bit_set[Pixel_Format_Flag;i32]

Conversion_Loss_Flag :: enum i32 {
	Resolution         = 0,
	Depth              = 1,
	Colorspace         = 2,
	Alpha              = 3,
	Color_Quantization = 4,
	Chroma             = 5,
	Excess_Resolution  = 6,
	Excess_Depth       = 7,
}
Conversion_Loss_Flags :: bit_set[Conversion_Loss_Flag;i32]


//===pixelutils.h===
av_pixelutils_sad_fn :: #type proc(
	src1: []u8,
	stride1: uintptr,
	src2: []u8,
	stride2: uintptr,
) -> int


//===pixfmt.h===

PALETTE_SIZE :: 1024
PALETTE_COUNT :: 256

/**
 * Pixel format.
 *
 * @note
 * RGB32 is handled in an endian-specific manner. An RGBA
 * color is put together as:
 *  (A << 24) | (R << 16) | (G << 8) | B
 * This is stored as BGRA on little-endian CPU architectures and ARGB on
 * big-endian CPUs.
 *
 * @note
 * If the resolution is not a multiple of the chroma subsampling factor
 * then the chroma plane resolution must be rounded up.
 *
 * @par
 * When the pixel format is palettized RGB32 (PAL8), the palettized
 * image data is stored in AVFrame.data[0]. The palette is transported in
 * AVFrame.data[1], is 1024 bytes long (256 4-byte entries) and is
 * formatted the same as in RGB32 described above (i.e., it is
 * also endian-specific). Note also that the individual RGB32 palette
 * components stored in AVFrame.data[1] should be in the range 0..255.
 * This is important as many custom PAL8 video codecs that were designed
 * to run on the IBM VGA graphics adapter use 6-bit palette components.
 *
 * @par
 * For all the 8 bits per pixel formats, an RGB32 palette is in data[1] like
 * for pal8. This palette is filled in automatically by the function
 * allocating the picture.
 */
//TODO: grab this from the new .h file correctly.

Pixel_Format :: enum i32 {
	NONE = -1,
	YUV420P, ///< planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
	YUYV422, ///< packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
	RGB24, ///< packed RGB 8:8:8, 24bpp, RGBRGB...
	BGR24, ///< packed RGB 8:8:8, 24bpp, BGRBGR...
	YUV422P, ///< planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
	YUV444P, ///< planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
	YUV410P, ///< planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
	YUV411P, ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
	GRAY8, ///<        Y        ,  8bpp
	MONOWHITE, ///<        Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
	MONOBLACK, ///<        Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
	PAL8, ///< 8 bits with RGB32 palette
	YUVJ420P, ///< planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of YUV420P and setting color_range
	YUVJ422P, ///< planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of YUV422P and setting color_range
	YUVJ444P, ///< planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of YUV444P and setting color_range
	UYVY422, ///< packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
	UYYVYY411, ///< packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
	BGR8, ///< packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
	BGR4, ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
	BGR4_BYTE, ///< packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
	RGB8, ///< packed RGB 3:3:2,  8bpp, (msb)2R 3G 3B(lsb)
	RGB4, ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
	RGB4_BYTE, ///< packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
	NV12, ///< planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
	NV21, ///< as above, but U and V bytes are swapped
	ARGB, ///< packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
	RGBA, ///< packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
	ABGR, ///< packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
	BGRA, ///< packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
	GRAY16BE, ///<        Y        , 16bpp, big-endian
	GRAY16LE, ///<        Y        , 16bpp, little-endian
	YUV440P, ///< planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
	YUVJ440P, ///< planar YUV 4:4:0 full scale (JPEG), deprecated in favor of YUV440P and setting color_range
	YUVA420P, ///< planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
	RGB48BE, ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
	RGB48LE, ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian
	RGB565BE, ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
	RGB565LE, ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
	RGB555BE, ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
	RGB555LE, ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined
	BGR565BE, ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
	BGR565LE, ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
	BGR555BE, ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
	BGR555LE, ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined

	/**
     *  Hardware acceleration through VA-API, data[3] contains a
     *  VASurfaceID.
     */
	VAAPI,
	YUV420P16LE, ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P16BE, ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV422P16LE, ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV422P16BE, ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV444P16LE, ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P16BE, ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	DXVA2_VLD, ///< HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer
	RGB444LE, ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
	RGB444BE, ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
	BGR444LE, ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
	BGR444BE, ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
	YA8, ///< 8 bits gray, 8 bits alpha
	Y400A = YA8, ///< alias for YA8
	GRAY8A = YA8, ///< alias for YA8
	BGR48BE, ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
	BGR48LE, ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian

	/**
     * The following 12 formats have the disadvantage of needing 1 format for each bit depth.
     * Notice that each 9/10 bits sample is stored in 16 bits with extra padding.
     * If you want to support multiple bit depths, then using YUV420P16* with the bpp stored separately is better.
     */
	YUV420P9BE, ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P9LE, ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P10BE, ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P10LE, ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV422P10BE, ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P10LE, ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV444P9BE, ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P9LE, ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P10BE, ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P10LE, ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV422P9BE, ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P9LE, ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	GBRP, ///< planar GBR 4:4:4 24bpp
	GBR24P = GBRP, // alias for #GBRP
	GBRP9BE, ///< planar GBR 4:4:4 27bpp, big-endian
	GBRP9LE, ///< planar GBR 4:4:4 27bpp, little-endian
	GBRP10BE, ///< planar GBR 4:4:4 30bpp, big-endian
	GBRP10LE, ///< planar GBR 4:4:4 30bpp, little-endian
	GBRP16BE, ///< planar GBR 4:4:4 48bpp, big-endian
	GBRP16LE, ///< planar GBR 4:4:4 48bpp, little-endian
	YUVA422P, ///< planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
	YUVA444P, ///< planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
	YUVA420P9BE, ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
	YUVA420P9LE, ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
	YUVA422P9BE, ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
	YUVA422P9LE, ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
	YUVA444P9BE, ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
	YUVA444P9LE, ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
	YUVA420P10BE, ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
	YUVA420P10LE, ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
	YUVA422P10BE, ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
	YUVA422P10LE, ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
	YUVA444P10BE, ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
	YUVA444P10LE, ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
	YUVA420P16BE, ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
	YUVA420P16LE, ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
	YUVA422P16BE, ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
	YUVA422P16LE, ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
	YUVA444P16BE, ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
	YUVA444P16LE, ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
	VDPAU, ///< HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface
	XYZ12LE, ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
	XYZ12BE, ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
	NV16, ///< interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
	NV20LE, ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	NV20BE, ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	RGBA64BE, ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
	RGBA64LE, ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
	BGRA64BE, ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
	BGRA64LE, ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
	YVYU422, ///< packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb
	YA16BE, ///< 16 bits gray, 16 bits alpha (big-endian)
	YA16LE, ///< 16 bits gray, 16 bits alpha (little-endian)
	GBRAP, ///< planar GBRA 4:4:4:4 32bpp
	GBRAP16BE, ///< planar GBRA 4:4:4:4 64bpp, big-endian
	GBRAP16LE, ///< planar GBRA 4:4:4:4 64bpp, little-endian
	/**
     * HW acceleration through QSV, data[3] contains a pointer to the
     * mfxFrameSurface1 structure.
     *
     * Before FFmpeg 5.0:
     * mfxFrameSurface1.Data.MemId contains a pointer when importing
     * the following frames as QSV frames:
     *
     * VAAPI:
     * mfxFrameSurface1.Data.MemId contains a pointer to VASurfaceID
     *
     * DXVA2:
     * mfxFrameSurface1.Data.MemId contains a pointer to IDirect3DSurface9
     *
     * FFmpeg 5.0 and above:
     * mfxFrameSurface1.Data.MemId contains a pointer to the mfxHDLPair
     * structure when importing the following frames as QSV frames:
     *
     * VAAPI:
     * mfxHDLPair.first contains a VASurfaceID pointer.
     * mfxHDLPair.second is always MFX_INFINITE.
     *
     * DXVA2:
     * mfxHDLPair.first contains IDirect3DSurface9 pointer.
     * mfxHDLPair.second is always MFX_INFINITE.
     *
     * D3D11:
     * mfxHDLPair.first contains a ID3D11Texture2D pointer.
     * mfxHDLPair.second contains the texture array index of the frame if the
     * ID3D11Texture2D is an array texture, or always MFX_INFINITE if it is a
     * normal texture.
     */
	QSV,
	/**
     * HW acceleration though MMAL, data[3] contains a pointer to the
     * MMAL_BUFFER_HEADER_T structure.
     */
	MMAL,
	D3D11VA_VLD, ///< HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer

	/**
     * HW acceleration through CUDA. data[i] contain CUdeviceptr pointers
     * exactly as for system memory frames.
     */
	CUDA,
	_0RGB, ///< packed RGB 8:8:8, 32bpp, XRGBXRGB...   X=unused/undefined
	RGB0, ///< packed RGB 8:8:8, 32bpp, RGBXRGBX...   X=unused/undefined
	_0BGR, ///< packed BGR 8:8:8, 32bpp, XBGRXBGR...   X=unused/undefined
	BGR0, ///< packed BGR 8:8:8, 32bpp, BGRXBGRX...   X=unused/undefined
	YUV420P12BE, ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P12LE, ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P14BE, ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P14LE, ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV422P12BE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P12LE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV422P14BE, ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P14LE, ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV444P12BE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P12LE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P14BE, ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P14LE, ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	GBRP12BE, ///< planar GBR 4:4:4 36bpp, big-endian
	GBRP12LE, ///< planar GBR 4:4:4 36bpp, little-endian
	GBRP14BE, ///< planar GBR 4:4:4 42bpp, big-endian
	GBRP14LE, ///< planar GBR 4:4:4 42bpp, little-endian
	YUVJ411P, ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of YUV411P and setting color_range
	BAYER_BGGR8, ///< bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples
	BAYER_RGGB8, ///< bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples
	BAYER_GBRG8, ///< bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples
	BAYER_GRBG8, ///< bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples
	BAYER_BGGR16LE, ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian
	BAYER_BGGR16BE, ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian
	BAYER_RGGB16LE, ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian
	BAYER_RGGB16BE, ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian
	BAYER_GBRG16LE, ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian
	BAYER_GBRG16BE, ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian
	BAYER_GRBG16LE, ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian
	BAYER_GRBG16BE, ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian
	YUV440P10LE, ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
	YUV440P10BE, ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
	YUV440P12LE, ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
	YUV440P12BE, ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
	AYUV64LE, ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
	AYUV64BE, ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
	VIDEOTOOLBOX, ///< hardware decoding through Videotoolbox
	P010LE, ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
	P010BE, ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian
	GBRAP12BE, ///< planar GBR 4:4:4:4 48bpp, big-endian
	GBRAP12LE, ///< planar GBR 4:4:4:4 48bpp, little-endian
	GBRAP10BE, ///< planar GBR 4:4:4:4 40bpp, big-endian
	GBRAP10LE, ///< planar GBR 4:4:4:4 40bpp, little-endian
	MEDIACODEC, ///< hardware decoding through MediaCodec
	GRAY12BE, ///<        Y        , 12bpp, big-endian
	GRAY12LE, ///<        Y        , 12bpp, little-endian
	GRAY10BE, ///<        Y        , 10bpp, big-endian
	GRAY10LE, ///<        Y        , 10bpp, little-endian
	P016LE, ///< like NV12, with 16bpp per component, little-endian
	P016BE, ///< like NV12, with 16bpp per component, big-endian

	/**
     * Hardware surfaces for Direct3D11.
     *
     * This is preferred over the legacy D3D11VA_VLD. The new D3D11
     * hwaccel API and filtering support D3D11 only.
     *
     * data[0] contains a ID3D11Texture2D pointer, and data[1] contains the
     * texture array index of the frame as intptr_t if the ID3D11Texture2D is
     * an array texture (or always 0 if it's a normal texture).
     */
	D3D11,
	GRAY9BE, ///<        Y        , 9bpp, big-endian
	GRAY9LE, ///<        Y        , 9bpp, little-endian
	GBRPF32BE, ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
	GBRPF32LE, ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
	GBRAPF32BE, ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
	GBRAPF32LE, ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian

	/**
     * DRM-managed buffers exposed through PRIME buffer sharing.
     *
     * data[0] points to an AVDRMFrameDescriptor.
     */
	DRM_PRIME,
	/**
     * Hardware surfaces for OpenCL.
     *
     * data[i] contain 2D image objects (typed in C as cl_mem, used
     * in OpenCL as image2d_t) for each plane of the surface.
     */
	OPENCL,
	GRAY14BE, ///<        Y        , 14bpp, big-endian
	GRAY14LE, ///<        Y        , 14bpp, little-endian
	GRAYF32BE, ///< IEEE-754 single precision Y, 32bpp, big-endian
	GRAYF32LE, ///< IEEE-754 single precision Y, 32bpp, little-endian
	YUVA422P12BE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
	YUVA422P12LE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
	YUVA444P12BE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
	YUVA444P12LE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian
	NV24, ///< planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
	NV42, ///< as above, but U and V bytes are swapped

	/**
     * Vulkan hardware images.
     *
     * data[0] points to an AVVkFrame
     */
	VULKAN,
	Y210BE, ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, big-endian
	Y210LE, ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, little-endian
	X2RGB10LE, ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), little-endian, X=unused/undefined
	X2RGB10BE, ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), big-endian, X=unused/undefined
	X2BGR10LE, ///< packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), little-endian, X=unused/undefined
	X2BGR10BE, ///< packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), big-endian, X=unused/undefined
	P210BE, ///< interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, big-endian
	P210LE, ///< interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, little-endian
	P410BE, ///< interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, big-endian
	P410LE, ///< interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, little-endian
	P216BE, ///< interleaved chroma YUV 4:2:2, 32bpp, big-endian
	P216LE, ///< interleaved chroma YUV 4:2:2, 32bpp, little-endian
	P416BE, ///< interleaved chroma YUV 4:4:4, 48bpp, big-endian
	P416LE, ///< interleaved chroma YUV 4:4:4, 48bpp, little-endian
	VUYA, ///< packed VUYA 4:4:4, 32bpp, VUYAVUYA...
	RGBAF16BE, ///< IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., big-endian
	RGBAF16LE, ///< IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., little-endian
	VUYX, ///< packed VUYX 4:4:4, 32bpp, Variant of VUYA where alpha channel is left undefined
	P012LE, ///< like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, little-endian
	P012BE, ///< like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, big-endian
	Y212BE, ///< packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, big-endian
	Y212LE, ///< packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, little-endian
	XV30BE, ///< packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), big-endian, variant of Y410 where alpha channel is left undefined
	XV30LE, ///< packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), little-endian, variant of Y410 where alpha channel is left undefined
	XV36BE, ///< packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, big-endian, variant of Y412 where alpha channel is left undefined
	XV36LE, ///< packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, little-endian, variant of Y412 where alpha channel is left undefined
	RGBF32BE, ///< IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., big-endian
	RGBF32LE, ///< IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., little-endian
	RGBAF32BE, ///< IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
	RGBAF32LE, ///< IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian
	P212BE, ///< interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, big-endian
	P212LE, ///< interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, little-endian
	P412BE, ///< interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, big-endian
	P412LE, ///< interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, little-endian
	GBRAP14BE, ///< planar GBR 4:4:4:4 56bpp, big-endian
	GBRAP14LE, ///< planar GBR 4:4:4:4 56bpp, little-endian
	Not_Part_of_ABI, ///< number of pixel formats, DO NOT USE THIS if you want to link with shared libav* because the number of formats might differ between versions
}

when ODIN_ENDIAN == .Little {
	RGB32 :: Pixel_Format.BGRA // Little Endian
	RGB32_1 :: Pixel_Format.ABGR // Little Endian
	BGR32 :: Pixel_Format.RGBA // Little Endian
	BGR32_1 :: Pixel_Format.ARGB // Little Endian
	_0RGB32 :: Pixel_Format.BGR0 // Little Endian
	_0BGR32 :: Pixel_Format.RGB0 // Little Endian
} else {
	RGB32 :: Pixel_Format.ARGB // Big Endian 
	RGB32_1 :: Pixel_Format.RGBA // Big Endian 
	BGR32 :: Pixel_Format.ABGR // Big Endian 
	BGR32_1 :: Pixel_Format.BGRA // Big Endian 
	_0RGB32 :: Pixel_Format._0RGB // Big Endian 
	_0BGR32 :: Pixel_Format._0BGR // Big Endian 
}

when ODIN_ENDIAN == .Little {
	GRAY9 :: Pixel_Format.GRAY9LE
	GRAY10 :: Pixel_Format.GRAY10LE
	GRAY12 :: Pixel_Format.GRAY12LE
	GRAY14 :: Pixel_Format.GRAY14LE
	GRAY16 :: Pixel_Format.GRAY16LE
	YA16 :: Pixel_Format.YA16LE
	RGB48 :: Pixel_Format.RGB48LE
	RGB565 :: Pixel_Format.RGB565LE
	RGB555 :: Pixel_Format.RGB555LE
	RGB444 :: Pixel_Format.RGB444LE
	RGBA64 :: Pixel_Format.RGBA64LE
	BGR48 :: Pixel_Format.BGR48LE
	BGR565 :: Pixel_Format.BGR565LE
	BGR555 :: Pixel_Format.BGR555LE
	BGR444 :: Pixel_Format.BGR444LE
	BGRA64 :: Pixel_Format.BGRA64LE

	YUV420P9 :: Pixel_Format.YUV420P9LE
	YUV422P9 :: Pixel_Format.YUV422P9LE
	YUV444P9 :: Pixel_Format.YUV444P9LE
	YUV420P10 :: Pixel_Format.YUV420P10LE
	YUV422P10 :: Pixel_Format.YUV422P10LE
	YUV440P10 :: Pixel_Format.YUV440P10LE
	YUV444P10 :: Pixel_Format.YUV444P10LE
	YUV420P12 :: Pixel_Format.YUV420P12LE
	YUV422P12 :: Pixel_Format.YUV422P12LE
	YUV440P12 :: Pixel_Format.YUV440P12LE
	YUV444P12 :: Pixel_Format.YUV444P12LE
	YUV420P14 :: Pixel_Format.YUV420P14LE
	YUV422P14 :: Pixel_Format.YUV422P14LE
	YUV444P14 :: Pixel_Format.YUV444P14LE
	YUV420P16 :: Pixel_Format.YUV420P16LE
	YUV422P16 :: Pixel_Format.YUV422P16LE
	YUV444P16 :: Pixel_Format.YUV444P16LE

	GBRP9 :: Pixel_Format.GBRP9LE
	GBRP10 :: Pixel_Format.GBRP10LE
	GBRP12 :: Pixel_Format.GBRP12LE
	GBRP14 :: Pixel_Format.GBRP14LE
	GBRP16 :: Pixel_Format.GBRP16LE
	GBRAP10 :: Pixel_Format.GBRAP10LE
	GBRAP12 :: Pixel_Format.GBRAP12LE
	GBRAP16 :: Pixel_Format.GBRAP16LE

	BAYER_BGGR16 :: Pixel_Format.BAYER_BGGR16LE
	BAYER_RGGB16 :: Pixel_Format.BAYER_RGGB16LE
	BAYER_GBRG16 :: Pixel_Format.BAYER_GBRG16LE
	BAYER_GRBG16 :: Pixel_Format.BAYER_GRBG16LE

	GBRPF32 :: Pixel_Format.GBRPF32LE
	GBRAPF32 :: Pixel_Format.GBRAPF32LE
	GRAYF32 :: Pixel_Format.GRAYF32LE

	YUVA420P9 :: Pixel_Format.YUVA420P9LE
	YUVA422P9 :: Pixel_Format.YUVA422P9LE
	YUVA444P9 :: Pixel_Format.YUVA444P9LE
	YUVA420P10 :: Pixel_Format.YUVA420P10LE
	YUVA422P10 :: Pixel_Format.YUVA422P10LE
	YUVA444P10 :: Pixel_Format.YUVA444P10LE
	YUVA422P12 :: Pixel_Format.YUVA422P12LE
	YUVA444P12 :: Pixel_Format.YUVA444P12LE
	YUVA420P16 :: Pixel_Format.YUVA420P16LE
	YUVA422P16 :: Pixel_Format.YUVA422P16LE
	YUVA444P16 :: Pixel_Format.YUVA444P16LE

	XYZ12 :: Pixel_Format.XYZ12LE
	NV20 :: Pixel_Format.NV20LE
	AYUV64 :: Pixel_Format.AYUV64LE
	P010 :: Pixel_Format.P010LE
	P016 :: Pixel_Format.P016LE
	Y210 :: Pixel_Format.Y210LE
	Y212 :: Pixel_Format.Y212LE
	XV30 :: Pixel_Format.XV30LE
	XV36 :: Pixel_Format.XV36LE
	X2RGB10 :: Pixel_Format.X2RGB10LE
	X2BGR10 :: Pixel_Format.X2BGR10LE

	P210 :: Pixel_Format.P210LE
	P410 :: Pixel_Format.P410LE
	P212 :: Pixel_Format.P212LE
	P412 :: Pixel_Format.P412LE
	P216 :: Pixel_Format.P216LE
	P416 :: Pixel_Format.P416LE

	RGBAF16 :: Pixel_Format.RGBAF16LE
	RGBF32 :: Pixel_Format.RGBF32LE
	RGBAF32 :: Pixel_Format.RGBAF32LE
} else {
	GRAY9 :: Pixel_Format.GRAY9BE
	GRAY10 :: Pixel_Format.GRAY10BE
	GRAY12 :: Pixel_Format.GRAY12BE
	GRAY14 :: Pixel_Format.GRAY14BE
	GRAY16 :: Pixel_Format.GRAY16BE
	YA16 :: Pixel_Format.YA16BE
	RGB48 :: Pixel_Format.RGB48BE
	RGB565 :: Pixel_Format.RGB565BE
	RGB555 :: Pixel_Format.RGB555BE
	RGB444 :: Pixel_Format.RGB444BE
	RGBA64 :: Pixel_Format.RGBA64BE
	BGR48 :: Pixel_Format.BGR48BE
	BGR565 :: Pixel_Format.BGR565BE
	BGR555 :: Pixel_Format.BGR555BE
	BGR444 :: Pixel_Format.BGR444BE
	BGRA64 :: Pixel_Format.BGRA64BE

	YUV420P9 :: Pixel_Format.YUV420P9BE
	YUV422P9 :: Pixel_Format.YUV422P9BE
	YUV444P9 :: Pixel_Format.YUV444P9BE
	YUV420P10 :: Pixel_Format.YUV420P10BE
	YUV422P10 :: Pixel_Format.YUV422P10BE
	YUV440P10 :: Pixel_Format.YUV440P10BE
	YUV444P10 :: Pixel_Format.YUV444P10BE
	YUV420P12 :: Pixel_Format.YUV420P12BE
	YUV422P12 :: Pixel_Format.YUV422P12BE
	YUV440P12 :: Pixel_Format.YUV440P12BE
	YUV444P12 :: Pixel_Format.YUV444P12BE
	YUV420P14 :: Pixel_Format.YUV420P14BE
	YUV422P14 :: Pixel_Format.YUV422P14BE
	YUV444P14 :: Pixel_Format.YUV444P14BE
	YUV420P16 :: Pixel_Format.YUV420P16BE
	YUV422P16 :: Pixel_Format.YUV422P16BE
	YUV444P16 :: Pixel_Format.YUV444P16BE

	GBRP9 :: Pixel_Format.GBRP9BE
	GBRP10 :: Pixel_Format.GBRP10BE
	GBRP12 :: Pixel_Format.GBRP12BE
	GBRP14 :: Pixel_Format.GBRP14BE
	GBRP16 :: Pixel_Format.GBRP16BE
	GBRAP10 :: Pixel_Format.GBRAP10BE
	GBRAP12 :: Pixel_Format.GBRAP12BE
	GBRAP16 :: Pixel_Format.GBRAP16BE

	BAYER_BGGR16 :: Pixel_Format.BAYER_BGGR16BE
	BAYER_RGGB16 :: Pixel_Format.BAYER_RGGB16BE
	BAYER_GBRG16 :: Pixel_Format.BAYER_GBRG16BE
	BAYER_GRBG16 :: Pixel_Format.BAYER_GRBG16BE

	GBRPF32 :: Pixel_Format.GBRPF32BE
	GBRAPF32 :: Pixel_Format.GBRAPF32BE
	GRAYF32 :: Pixel_Format.GRAYF32BE

	YUVA420P9 :: Pixel_Format.YUVA420P9BE
	YUVA422P9 :: Pixel_Format.YUVA422P9BE
	YUVA444P9 :: Pixel_Format.YUVA444P9BE
	YUVA420P10 :: Pixel_Format.YUVA420P10BE
	YUVA422P10 :: Pixel_Format.YUVA422P10BE
	YUVA444P10 :: Pixel_Format.YUVA444P10BE
	YUVA422P12 :: Pixel_Format.YUVA422P12BE
	YUVA444P12 :: Pixel_Format.YUVA444P12BE
	YUVA420P16 :: Pixel_Format.YUVA420P16BE
	YUVA422P16 :: Pixel_Format.YUVA422P16BE
	YUVA444P16 :: Pixel_Format.YUVA444P16BE

	XYZ12 :: Pixel_Format.XYZ12BE
	NV20 :: Pixel_Format.NV20BE
	AYUV64 :: Pixel_Format.AYUV64BE
	P010 :: Pixel_Format.P010BE
	P016 :: Pixel_Format.P016BE
	Y210 :: Pixel_Format.Y210BE
	Y212 :: Pixel_Format.Y212BE
	XV30 :: Pixel_Format.XV30BE
	XV36 :: Pixel_Format.XV36BE
	X2RGB10 :: Pixel_Format.X2RGB10BE
	X2BGR10 :: Pixel_Format.X2BGR10BE

	P210 :: Pixel_Format.P210BE
	P410 :: Pixel_Format.P410BE
	P212 :: Pixel_Format.P212BE
	P412 :: Pixel_Format.P412BE
	P216 :: Pixel_Format.P216BE
	P416 :: Pixel_Format.P416BE

	RGBAF16 :: Pixel_Format.RGBAF16BE
	RGBF32 :: Pixel_Format.RGBF32BE
	RGBAF32 :: Pixel_Format.RGBAF32BE
}

/**
  * Chromaticity coordinates of the source primaries.
  * These values match the ones defined by ISO/IEC 23001-8_2013 § 7.1.
  */
Color_Primaries :: enum i32 {
	RESERVED0 = 0,
	BT709 = 1, ///< also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP177 Annex B
	UNSPECIFIED = 2,
	RESERVED = 3,
	BT470M = 4, ///< also FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
	BT470BG = 5, ///< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
	SMPTE170M = 6, ///< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
	SMPTE240M = 7, ///< functionally identical to above
	FILM = 8, ///< colour filters using Illuminant C
	BT2020 = 9, ///< ITU-R BT2020
	SMPTE428 = 10, ///< SMPTE ST 428-1 (CIE 1931 XYZ)
	SMPTEST428_1 = SMPTE428,
	SMPTE431 = 11, ///< SMPTE ST 431-2 (2011) / DCI P3
	SMPTE432 = 12, ///< SMPTE ST 432-1 (2010) / P3 D65 / Display P3
	EBU3213 = 22, ///< EBU Tech. 3213-E / JEDEC P22 phosphors
	JEDEC_P22 = EBU3213,
	Not_Part_of_ABI, ///< Not part of ABI
}

/**
 * Color Transfer Characteristic.
 * These values match the ones defined by ISO/IEC 23001-8_2013 § 7.2.
 */
Color_Transfer_Characteristic :: enum i32 {
	RESERVED0 = 0,
	BT709 = 1, ///< also ITU-R BT1361
	UNSPECIFIED = 2,
	RESERVED = 3,
	GAMMA22 = 4, ///< also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
	GAMMA28 = 5, ///< also ITU-R BT470BG
	SMPTE170M = 6, ///< also ITU-R BT601-6 525 or 625 / ITU-R BT1358 525 or 625 / ITU-R BT1700 NTSC
	SMPTE240M = 7,
	LINEAR = 8, ///< "Linear transfer characteristics"
	LOG = 9, ///< "Logarithmic transfer characteristic (100:1 range)"
	LOG_SQRT = 10, ///< "Logarithmic transfer characteristic (100 * Sqrt(10) : 1 range)"
	IEC61966_2_4 = 11, ///< IEC 61966-2-4
	BT1361_ECG = 12, ///< ITU-R BT1361 Extended Colour Gamut
	IEC61966_2_1 = 13, ///< IEC 61966-2-1 (sRGB or sYCC)
	BT2020_10 = 14, ///< ITU-R BT2020 for 10-bit system
	BT2020_12 = 15, ///< ITU-R BT2020 for 12-bit system
	SMPTE2084 = 16, ///< SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems
	SMPTEST2084 = SMPTE2084,
	SMPTE428 = 17, ///< SMPTE ST 428-1
	SMPTEST428_1 = SMPTE428,
	ARIB_STD_B67 = 18, ///< ARIB STD-B67, known as "Hybrid log-gamma"
	Not_Part_of_ABI, ///< Not part of ABI
}

/**
 * YUV colorspace type.
 * These values match the ones defined by ISO/IEC 23001-8_2013 § 7.3.
 */
Color_Space :: enum i32 {
	RGB = 0, ///< order of coefficients is actually GBR, also IEC 61966-2-1 (sRGB)
	BT709 = 1, ///< also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
	UNSPECIFIED = 2,
	RESERVED = 3,
	FCC = 4, ///< FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
	BT470BG = 5, ///< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
	SMPTE170M = 6, ///< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
	SMPTE240M = 7, ///< functionally identical to above
	YCGCO = 8, ///< Used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
	YCOCG = YCGCO,
	BT2020_NCL = 9, ///< ITU-R BT2020 non-constant luminance system
	BT2020_CL = 10, ///< ITU-R BT2020 constant luminance system
	SMPTE2085 = 11, ///< SMPTE 2085, Y'D'zD'x
	CHROMA_DERIVED_NCL = 12, ///< Chromaticity-derived non-constant luminance system
	CHROMA_DERIVED_CL = 13, ///< Chromaticity-derived constant luminance system
	ICTCP = 14, ///< ITU-R BT.2100-0, ICtCp
	Not_Part_of_ABI, ///< Not part of ABI
}

/**
 * Visual content value range.
 *
 * These values are based on definitions that can be found in multiple
 * specifications, such as ITU-T BT.709 (3.4 - Quantization of RGB, luminance
 * and colour-difference signals), ITU-T BT.2020 (Table 5 - Digital
 * Representation) as well as ITU-T BT.2100 (Table 9 - Digital 10- and 12-bit
 * integer representation). At the time of writing, the BT.2100 one is
 * recommended, as it also defines the full range representation.
 *
 * Common definitions:
 *   - For RGB and luminance planes such as Y in YCbCr and I in ICtCp,
 *     'E' is the original value in range of 0.0 to 1.0.
 *   - For chrominance planes such as Cb,Cr and Ct,Cp, 'E' is the original
 *     value in range of -0.5 to 0.5.
 *   - 'n' is the output bit depth.
 *   - For additional definitions such as rounding and clipping to valid n
 *     bit unsigned integer range, please refer to BT.2100 (Table 9).
 */
Color_Range :: enum i32 {
	Unspecified = 0,

	/**
	 * Narrow or limited range content.
	 *
	 * - For luminance planes:
	 *
	 *       (219 * E + 16) * 2^(n-8)
	 *
	 *   F.ex. the range of 16-235 for 8 bits
	 *
	 * - For chrominance planes:
	 *
	 *       (224 * E + 128) * 2^(n-8)
	 *
	 *   F.ex. the range of 16-240 for 8 bits
	 */
	MPEG = 1,

	/**
	 * Full range content.
	 *
	 * - For RGB and luminance planes:
	 *
	 *       (2^n - 1) * E
	 *
	 *   F.ex. the range of 0-255 for 8 bits
	 *
	 * - For chrominance planes:
	 *
	 *       (2^n - 1) * E + 2^(n - 1)
	 *
	 *   F.ex. the range of 1-255 for 8 bits
	 */
	JPEG = 2,
	Not_Part_of_ABI, ///< Not part of ABI
}

/**
 * Location of chroma samples.
 *
 * Illustration showing the location of the first (top left) chroma sample of the
 * image, the left shows only luma, the right
 * shows the location of the chroma sample, the 2 could be imagined to overlay
 * each other but are drawn separately due to limitations of ASCII
 *
 *                1st 2nd       1st 2nd horizontal luma sample positions
 *                 v   v         v   v
 *                 ______        ______
 *1st luma line > |X   X ...    |3 4 X ...     X are luma samples,
 *                |             |1 2           1-6 are possible chroma positions
 *2nd luma line > |X   X ...    |5 6 X ...     0 is undefined/unknown position
 */
Chroma_Location :: enum i32 {
	Unspecified = 0,
	Left = 1, ///< MPEG-2/4 4:2:0, H.264 default for 4:2:0
	Center = 2, ///< MPEG-1 4:2:0, JPEG 4:2:0, H.263 4:2:0
	Top_Left = 3, ///< ITU-R 601, SMPTE 274M 296M S314M(DV 4:1:1), mpeg2 4:2:2
	Top = 4,
	Bottom_Left = 5,
	Bottom = 6,
	Not_Part_of_ABI, ///< Not part of ABI
}


//===rational.h===
Rational :: struct {
	numerator:   i32,
	denominator: i32,
}

//===rc4.h===
RC4 :: struct {
	state: [256]u8,
	x, y:  i32,
}

//===replaygain.h===
Replay_Gain :: struct {
	track_gain: i32,
	track_peak: u32,
	album_gain: i32,
	album_peak: u32,
}

//===ripemd.h===
RIPEMD :: struct {
}


//===samplefmt.h===
Sample_Format :: enum i32 {
	NONE = -1,
	U8, ///< unsigned 8 bits
	S16, ///< signed 16 bits
	S32, ///< signed 32 bits
	FLT, ///< float
	DBL, ///< double
	U8P, ///< unsigned 8 bits, planar
	S16P, ///< signed 16 bits, planar
	S32P, ///< signed 32 bits, planar
	FLTP, ///< float, planar
	DBLP, ///< double, planar
	S64, ///< signed 64 bits
	S64P, ///< signed 64 bits, planar
	Not_Part_of_ABI, //< Number of sample formats. DO NOT USE if linking dynamically
}

//===sha.h===
// AVSHA struct
SHA :: struct {
}

//===sha512.h===
// AVSHA512 struct
SHA512 :: struct {
}

//===spherical.h===
// AVSphericalProjection enum
Spherical_Projection :: enum i32 {
	EQUIRECTANGULAR,
	CUBEMAP,
	EQUIRECTANGULAR_TILE,
}

// AVSphericalMapping struct
Spherical_Mapping :: struct {
	projection:                                       Spherical_Projection,
	yaw, pitch, roll:                                 i32,
	bound_left, bound_top, bound_right, bound_bottom: u32,
	padding:                                          u32,
}


//===stereo3d.h===
// AVStereo3DType enum
Stereo_3D_Type :: enum i32 {
	_2D,
	SIDEBYSIDE,
	TOPBOTTOM,
	FRAMESEQUENCE,
	CHECKERBOARD,
	SIDEBYSIDE_QUINCUNX,
	LINES,
	COLUMNS,
}

// AVStereo3DView enum
Stereo_3D_View :: enum i32 {
	VIEW_PACKED,
	VIEW_LEFT,
	VIEW_RIGHT,
}

STEREO3D_FLAG_INVERT :: 1 << 0

// AVStereo3D struct
Stereo_3D :: struct {
	type:  Stereo_3D_Type,
	flags: i32,
	view:  Stereo_3D_View,
}


//===tea.h===
TEA :: struct {
}

//===threadmessage.h===
Thread_Message_Queue :: struct {
}
THREAD_MESSAGE_NONBLOCK :: 1

//===timecode.h===
// AVTimecodeFlag enum
Timecode_Flag :: enum i32 {
	DROPFRAME     = 0, // timecode is drop frame
	_24HOURSMAX   = 1, // timecode wraps after 24 hours
	ALLOWNEGATIVE = 2, // negative time values are allowed
}
Timecode_Flags :: bit_set[Timecode_Flag;u32]

// AVTimecode struct
Timecode :: struct {
	start: i32, // timecode frame start (first base frame number)
	flags: Timecode_Flags, // flags such as drop frame, +24 hours support, ...
	rate:  Rational, // frame rate in rational form
	fps:   u32, // frame per second; must be consistent with the rate field
}

//===tree.h===
// AVTreeNode struct
Tree_Node :: struct {
}

//===twofish.h===
// AVTWOFISH struct
TWOFISH :: struct {
}

//===tx.h===
// AVTXContext struct
TX_Context :: struct {
}

Complex_Float :: struct {
	re, im: f32,
}

Complex_Double :: struct {
	re, im: f64,
}

Complex_Int32 :: struct {
	re, im: i32,
}

TX_Type :: enum i32 {
	FLOAT_FFT = 0,
	FLOAT_MDCT = 1,
	DOUBLE_FFT = 2,
	DOUBLE_MDCT = 3,
	INT32_FFT = 4,
	INT32_MDCT = 5,
	FLOAT_RDFT = 6,
	DOUBLE_RDFT = 7,
	INT32_RDFT = 8,
	FLOAT_DCT = 9,
	DOUBLE_DCT = 10,
	INT32_DCT = 11,
	FLOAT_DCT_I = 12,
	DOUBLE_DCT_I = 13,
	INT32_DCT_I = 14,
	FLOAT_DST_I = 15,
	DOUBLE_DST_I = 16,
	INT32_DST_I = 17,
	Not_Part_of_ABI,
}

// av_tx_fn function pointer
tx_fn :: #type proc(s: ^TX_Context, out: rawptr, ptr_in: rawptr, stride: int)

TX_Flag :: enum i32 {
	In_Place     = 0,
	Unaligned    = 1,
	Inverse_MDCT = 2,
	Real_To_Real = 3,
	Real_To_Imag = 4,
}
TX_Flags :: bit_set[TX_Flag;u64]

//===uuid.h===
UUID_LEN :: 16
UUID :: distinct [UUID_LEN]u8


//===video_enc_params.h===
Video_Enc_Params_Type :: enum i32 {
	NONE = -1,
	VP9,
	H264,
	MPEG2,
}

// AVVideoEncParams struct
Video_Enc_Params :: struct {
	nb_blocks:     u32, // Number of blocks in the array
	blocks_offset: uintptr, // Offset in bytes from the beginning of this structure at which the array of blocks starts
	block_size:    uintptr, // Size of each block in bytes. May not match sizeof(AVVideoBlockParams)
	type:          Video_Enc_Params_Type, // Type of the parameters (the codec they are used with)
	qp:            i32, // Base quantisation parameter for the frame. The final quantiser for a given block in a given plane is obtained from this value, possibly combined with delta_qp and the per-block delta in a manner documented for each type
	delta_qp:      [4][2]i32, // Quantisation parameter offset from the base (per-frame) qp for a given plane (first index) and AC/DC coefficients (second index)
}

// AVVideoBlockParams struct
Video_Block_Params :: struct {
	src_x, src_y: i32, // Distance in luma pixels from the top-left corner of the visible frame to the top-left corner of the block. Can be negative if top/right padding is present on the coded frame
	w, h:         i32, // Width and height of the block in luma pixels
	delta_qp:     i32, // Difference between this block's final quantization parameter and the corresponding per-frame value
}

//===video_hint.h===
Video_Hint :: struct {
	nb_rects:    uintptr,
	rect_offset: uintptr,
	rect_size:   uintptr,
}

//===xtea.h===
XTEA :: struct {
	key: [16]u32,
}


//Below structs are not put under their correct file.

Media_Type :: enum i32 {
	Unknown = -1,
	Video,
	Audio,
	Data,
	Subtitle,
	Attachment,
	Not_Part_of_ABI,
}


FF_LAMBDA_SHIFT :: 7
FF_LAMBDA_SCALE :: (1 << FF_LAMBDA_SHIFT)
FF_QP2LAMBDA :: 118
FF_LAMBDA_MAX :: (256 * 128 - 1)
FF_QUALITY_SCALE :: FF_LAMBDA_SCALE

NOPTS_VALUE :: 0x8000000000000000
TIME_BASE :: 1000000

TIME_BASE_Q :: Rational{1, TIME_BASE}

Picture_Type :: enum i32 {
	NONE = 0,
	I, // Intra
	P, // Predicted
	B, // Bidirectionally predicted
	S, // S(GMC)-VOP MPEG-4
	SI, // Switching Intra
	SP, // Switching Predicted
	BI, // Bidirectional
}

FOURCC_MAX_STRING_SIZE :: 32

Opt_Flag :: enum i32 {
	None                  = 0,
	Implicit_Key          = 1,
	Opt_Allow_Null        = 2,
	Multi_Component_Range = 12,
}
Opt_Flags :: bit_set[Opt_Flag;i32]

Opt_Search_Flag :: enum i32 {
	Children    = 0,
	Fake_Object = 1,
}
Opt_Search_Flags :: bit_set[Opt_Search_Flag;i32]

Opt_Serialize_Flag :: enum i32 {
	Skip_Defaults   = 0,
	Opt_Flags_Exact = 1,
}
Opt_Serialize_Flags :: bit_set[Opt_Serialize_Flag;i32]


DV_Profile :: struct {
	dsf:                i32, // value of the dsf in the DV header
	video_stype:        i32, // stype for VAUX source pack
	frame_size:         i32, // total size of one frame in bytes
	difseg_size:        i32, // number of DIF segments per DIF channel
	n_difchan:          i32, // number of DIF channels per frame
	time_base:          Rational, // 1/framerate
	ltc_divisor:        i32, // FPS from the LTS standpoint
	height:             i32, // picture height in pixels
	width:              i32, // picture width in pixels
	sar:                [2]Rational, // sample aspect ratios for 4:3 and 16:9
	pix_fmt:            Pixel_Format, // picture pixel format
	bpm:                i32, // blocks per macroblock
	block_sizes:        []u8, // AC block sizes, in bits
	audio_stride:       i32, // size of audio_shuffle table
	audio_min_samples:  [3]i32, // min amount of audio samples for 48kHz, 44.1kHz and 32kHz
	audio_samples_dist: [5]i32, // how many samples are supposed to be in each frame in a 5 frames window
	audio_shuffle:      ^^byte, // PCM shuffling table //TODO: This is a  const uint8_t  (*audio_shuffle)[9]; , put in properly.
}


MUTEX_SIZE :: #config(MUTEX_SIZE, 1)
Mutex :: distinct [MUTEX_SIZE]u8


/*
	Frame: https://ffmpeg.org/doxygen/trunk/structAVFrame.html

	This structure describes decoded (raw) audio or video data.
	Frame must be allocated using `frame_alloc`. Note that this only allocates the `Frame` itself,
	the buffers for the data must be managed through other means (see below). `Frame` must be freed with `frame_free`.

	`Frame` is typically allocated once and then reused multiple times to hold different data
	(e.g. a single `Frame` to hold frames received from a decoder). In such a case, `frame_unref` will free
	any references held by the frame and reset it to its original clean state before it is reused again.

	The data described by a `Frame` is usually reference counted through the `Buffer` API.
	The underlying buffer references are stored in `Frame.buf` / `Frame.extended_buf`.
	A `Frame` is considered to be reference counted if at least one reference is set, i.e. if `Frame.buf[0]` != nil.

	In such a case, every single data plane must be contained in one of the buffers in `Frame.buf` or `Frame.extended_buf`.
	There may be a single buffer for all the data, or one separate buffer for each plane, or anything in between.

	`size_of(Frame)` is not a part of the public ABI, so new fields may be added to the end with a minor bump.

	Fields can be accessed through `Options`, the name string used matches the C structure field name for fields accessible through `Options`.
	The `Class` for `Frame` can be obtained from `avcodec.get_frame_class`
*/


Decode_Error_Flag :: enum i32 {
	Invalid_Bitstream  = 0,
	Missing_Reference  = 1,
	Concealment_Active = 2,
	Decode_Slices      = 3,
}
Decode_Error_Flags :: bit_set[Decode_Error_Flag;i32]


/* deprecated
FIFO_Buffer :: struct {
	buffer:           [^]u8,
	read_ptr:         rawptr,
	write_ptr:        rawptr,
	end:              rawptr,
	rndx:             u32,
	wndx:             u32,
}*/

PThread_Condition :: distinct rawptr

PThread_Fast_Lock :: struct {
	status:   u64,
	spinlock: i32,
}

PThread_Descr :: rawptr

PThread_Mutex :: struct {
	reserved: i32,
	count:    i32,
	owner:    PThread_Descr,
	kind:     i32,
	lock:     PThread_Fast_Lock,
}

PThread :: distinct u64


/* ==============================================================================================
	   FFMPEG - FFMPEG - FFMPEG - FFMPEG - FFMPEG - FFMPEG - FFMPEG - FFMPEG - FFMPEG - FFMPEG
   ============================================================================================== */
//===ffmpeg.h===
VSync :: enum i32 {
	AUTO = -1,
	PASSTHROUGH,
	CFR,
	VFR,
	VSCFR,
	DROP,
}

MAX_STREAMS :: 1024 /* arbitrary sanity check value */

Encoder_Time_Base :: enum i32 {
	Demux  = -1,
	Filter = -2,
}

Hardware_Accelerator_ID :: enum i32 {
	None = 0,
	Auto,
	Generic,
}

//not in ffmpeg.h
Hardware_Device_Type :: enum i32 {
	None,
	VDPAU,
	CUDA,
	VAAPI,
	DXVA2,
	QSV,
	VideoToolbox,
	D3D11Va,
	DRM,
	OpenCL,
	Media_Codec,
	Vulkan,
}

//not in ffmpeg.h
Hardware_Device_Type_Frame_Mapping :: enum i32 {
	Read      = 1,
	Write     = 2,
	Overwrite = 4,
	Direct    = 8,
}


Hardware_Device :: struct {
	name:       cstring,
	type:       Hardware_Device_Type,
	device_ref: ^Buffer_Ref,
}


/* select an input stream for an output stream */
Stream_Map :: struct {
	disabled:     i32, /* 1 is this mapping is disabled by a negative map */
	file_index:   i32,
	stream_index: i32,
	link_label:   cstring, /* name of an output link, for mapping lavfi outputs */
}

Demux_Packet_Data :: struct {
	dts_est: i64,
}


Options_Context :: struct {
	g:                              ^Command_Option_Group,
	start_time:                     i64,
	start_time_eof:                 i64,
	seek_timestamp:                 i32,
	format:                         cstring,
	codec_names:                    [^]Specifier_Opt,
	nb_codec_names:                 i32,
	audio_ch_layouts:               [^]Specifier_Opt,
	nb_audio_ch_layouts:            i32,
	audio_channels:                 [^]Specifier_Opt,
	nb_audio_channels:              i32,
	audio_sample_rate:              [^]Specifier_Opt,
	nb_audio_sample_rate:           i32,
	frame_rates:                    [^]Specifier_Opt,
	nb_frame_rates:                 i32,
	max_frame_rates:                [^]Specifier_Opt,
	nb_max_frame_rates:             i32,
	frame_sizes:                    [^]Specifier_Opt,
	nb_frame_sizes:                 i32,
	frame_pix_fmts:                 [^]Specifier_Opt,
	nb_frame_pix_fmts:              i32,
	input_ts_offset:                i64,
	loop:                           i32,
	rate_emu:                       i32,
	readrate:                       f32,
	readrate_initial_burst:         f64,
	accurate_seek:                  i32,
	thread_queue_size:              i32,
	input_sync_ref:                 i32,
	find_stream_info:               i32,
	ts_scale:                       [^]Specifier_Opt,
	nb_ts_scale:                    i32,
	dump_attachment:                [^]Specifier_Opt,
	nb_dump_attachment:             i32,
	hwaccels:                       [^]Specifier_Opt,
	nb_hwaccels:                    i32,
	hwaccel_devices:                [^]Specifier_Opt,
	nb_hwaccel_devices:             i32,
	hwaccel_output_formats:         [^]Specifier_Opt,
	nb_hwaccel_output_formats:      i32,
	autorotate:                     [^]Specifier_Opt,
	nb_autorotate:                  i32,
	stream_maps:                    [^]Stream_Map,
	nb_stream_maps:                 i32,
	attachments:                    [^]cstring,
	nb_attachments:                 i32,
	chapters_input_file:            i32,
	recording_time:                 i64,
	stop_time:                      i64,
	limit_filesize:                 u64,
	mux_preload:                    f32,
	mux_max_delay:                  f32,
	shortest_buf_duration:          f32,
	shortest:                       i32,
	bitexact:                       i32,
	video_disable:                  i32,
	audio_disable:                  i32,
	subtitle_disable:               i32,
	data_disable:                   i32,
	streamid:                       ^Dictionary,
	metadata:                       [^]Specifier_Opt,
	nb_metadata:                    i32,
	max_frames:                     [^]Specifier_Opt,
	nb_max_frames:                  i32,
	bitstream_filters:              [^]Specifier_Opt,
	nb_bitstream_filters:           i32,
	codec_tags:                     [^]Specifier_Opt,
	nb_codec_tags:                  i32,
	sample_fmts:                    [^]Specifier_Opt,
	nb_sample_fmts:                 i32,
	qscale:                         [^]Specifier_Opt,
	nb_qscale:                      i32,
	forced_key_frames:              [^]Specifier_Opt,
	nb_forced_key_frames:           i32,
	fps_mode:                       [^]Specifier_Opt,
	nb_fps_mode:                    i32,
	force_fps:                      [^]Specifier_Opt,
	nb_force_fps:                   i32,
	display_rotations:              [^]Specifier_Opt,
	nb_display_rotations:           i32,
	frame_aspect_ratios:            [^]Specifier_Opt,
	nb_frame_aspect_ratios:         i32,
	display_hflips:                 [^]Specifier_Opt,
	nb_display_hflips:              i32,
	display_vflips:                 [^]Specifier_Opt,
	nb_display_vflips:              i32,
	rc_overrides:                   [^]Specifier_Opt,
	nb_rc_overrides:                i32,
	intra_matrices:                 [^]Specifier_Opt,
	nb_intra_matrices:              i32,
	inter_matrices:                 [^]Specifier_Opt,
	nb_inter_matrices:              i32,
	chroma_intra_matrices:          [^]Specifier_Opt,
	nb_chroma_intra_matrices:       i32,
	metadata_map:                   [^]Specifier_Opt,
	nb_metadata_map:                i32,
	presets:                        [^]Specifier_Opt,
	nb_presets:                     i32,
	copy_initial_nonkeyframes:      [^]Specifier_Opt,
	nb_copy_initial_nonkeyframes:   i32,
	copy_prior_start:               [^]Specifier_Opt,
	nb_copy_prior_start:            i32,
	filters:                        [^]Specifier_Opt,
	nb_filters:                     i32,
	filter_scripts:                 [^]Specifier_Opt,
	nb_filter_scripts:              i32,
	reinit_filters:                 [^]Specifier_Opt,
	nb_reinit_filters:              i32,
	fix_sub_duration:               [^]Specifier_Opt,
	nb_fix_sub_duration:            i32,
	fix_sub_duration_heartbeat:     [^]Specifier_Opt,
	nb_fix_sub_duration_heartbeat:  i32,
	canvas_sizes:                   [^]Specifier_Opt,
	nb_canvas_sizes:                i32,
	pass:                           [^]Specifier_Opt,
	nb_pass:                        i32,
	passlogfiles:                   [^]Specifier_Opt,
	nb_passlogfiles:                i32,
	max_muxing_queue_size:          [^]Specifier_Opt,
	nb_max_muxing_queue_size:       i32,
	muxing_queue_data_threshold:    [^]Specifier_Opt,
	nb_muxing_queue_data_threshold: i32,
	guess_layout_max:               [^]Specifier_Opt,
	nb_guess_layout_max:            i32,
	apad:                           [^]Specifier_Opt,
	nb_apad:                        i32,
	discard:                        [^]Specifier_Opt,
	nb_discard:                     i32,
	disposition:                    [^]Specifier_Opt,
	nb_disposition:                 i32,
	program:                        [^]Specifier_Opt,
	nb_program:                     i32,
	time_bases:                     [^]Specifier_Opt,
	nb_time_bases:                  i32,
	enc_time_bases:                 [^]Specifier_Opt,
	nb_enc_time_bases:              i32,
	autoscale:                      [^]Specifier_Opt,
	nb_autoscale:                   i32,
	bits_per_raw_sample:            [^]Specifier_Opt,
	nb_bits_per_raw_sample:         i32,
	enc_stats_pre:                  [^]Specifier_Opt,
	nb_enc_stats_pre:               i32,
	enc_stats_post:                 [^]Specifier_Opt,
	nb_enc_stats_post:              i32,
	mux_stats:                      [^]Specifier_Opt,
	nb_mux_stats:                   i32,
	enc_stats_pre_fmt:              [^]Specifier_Opt,
	nb_enc_stats_pre_fmt:           i32,
	enc_stats_post_fmt:             [^]Specifier_Opt,
	nb_enc_stats_post_fmt:          i32,
	mux_stats_fmt:                  [^]Specifier_Opt,
	nb_mux_stats_fmt:               i32,
}

Input_Filter :: struct {
	graph: ^Filter_Graph,
	name:  cstring,
}

Output_Filter :: struct {
	ost:            ^Output_Stream,
	graph:          ^Filter_Graph,
	name:           cstring,
	linkelabel:     cstring,
	type:           Media_Type,
	last_pts:       i64,
	nb_frames_dub:  u64,
	nb_frames_drop: u64,
}

FF_Filter_Graph :: struct {
	class:      ^Class,
	index:      i32,
	graph:      ^Filter_Graph,
	inputs:     ^[^]Input_Filter,
	nb_inputs:  i32,
	outputs:    ^[^]Output_Filter,
	nb_outputs: i32,
}

Decoder :: struct {
}


Input_Stream :: struct {
	// done!
	class:                 ^Class,
	file_index:            i32,
	index:                 i32,
	st:                    ^Stream,
	discard:               i32,
	user_set_discard:      i32,
	decoding_needed:       i32,
	par:                   ^Codec_Parameters,
	decoder:               Decoder,
	dec_ctx:               ^Codec_Context,
	dec:                   ^Codec,
	codec_desc:            ^Codec_Descriptor,
	framerate_guessed:     Rational,
	decoder_opts:          [^]Dictionary,
	framerate:             Rational,
	autorotate:            i32,
	fix_sub_duration:      i32,
	sub2video:             struct {
		w, h: i32,
	},
	filters:               ^[^]Input_Filter,
	nb_filters:            i32,
	outputs:               ^[^]Output_Stream,
	nb_outputs:            i32,
	reinit_filters:        i32,
	hwaccel_id:            Hardware_Accelerator_ID,
	hwaccel_device_type:   Hardware_Device_Type,
	hwaccel_device:        cstring,
	hwaccel_output_format: Pixel_Format,
	frames_decoded:        u64,
	samples_decoded:       u64,
	decode_errors:         u64,
}


Input_File :: struct {
	// done!
	class:                ^Class,
	index:                i32,
	format_nots:          i32,
	ctx:                  ^Format_Context,
	eof_reached:          b32,
	e_again:              b32,
	input_ts_offset:      i64,
	input_sync_ref:       i32,
	start_time_effective: i64,
	ts_offset:            i64,
	start_time:           i64,
	recording_time:       i64,
	streams:              ^[^]Input_Stream,
	nb_streams:           i32,
	readrate:             f32,
	accurate_seek:        i32,
	audio_ts_queue:       ^Thread_Message_Queue,
	audio_ts_queue_size:  i32,
}

Forced_Keyframes :: enum i32 {
	N,
	N_forced,
	PrevForcedN,
	fPrevForcedT,
	T,
	Not_Part_of_ABI,
}

Enc_Stats_Type :: enum i32 {
	LITERAL = 0,
	FILE_IDX,
	STREAM_IDX,
	FRAME_NUM,
	FRAME_NUM_IN,
	TIMEBASE,
	TIMEBASE_IN,
	PTS,
	PTS_TIME,
	PTS_IN,
	PTS_TIME_IN,
	DTS,
	DTS_TIME,
	SAMPLE_NUM,
	NB_SAMPLES,
	PKT_SIZE,
	BITRATE,
	AVG_BITRATE,
}


Enc_Stats_Component :: struct {
	type:    Enc_Stats_Type,
	str:     cstring,
	str_len: uintptr,
}


Enc_Stats :: struct {
	components:    [^]Enc_Stats_Component,
	nb_components: i32,
	io:            ^IO_Context,
}


OST_Finished :: enum i32 {
	Encoder_Finished = 1,
	Muxer_Finished   = 2,
}

FKF_NB :: 5
Keyframe_Force_Context :: struct {
	type:              i32,
	ref_pts:           i64,
	pts:               [^]i64,
	nb_pts:            i32,
	index:             i32,
	pexpr:             ^Expr,
	expr_const_values: [FKF_NB]f64,
	dropped_keyframe:  i32,
}

Encoder :: struct {
}


Output_Stream :: struct {
	class:                      ^Class,
	type:                       Media_Type,
	file_index:                 i32,
	index:                      i32,
	par_in:                     ^Codec_Parameters,
	ist:                        ^Input_Stream,
	st:                         ^Stream,
	last_mux_dts:               i64,
	enc_timebase:               Rational,
	enc:                        ^Encoder,
	enc_ctx:                    ^Codec_Context,
	frame_rate:                 Rational,
	max_frame_rate:             Rational,
	vsync_method:               VSync,
	is_cfr:                     i32,
	force_fps:                  i32,
	frame_aspect_ratio:         Rational,
	kf:                         Keyframe_Force_Context,
	logfile_prefix:             cstring,
	logfile:                    ^File,
	filter:                     ^Output_Filter,
	encoder_opts:               ^Dictionary,
	sws_dict:                   ^Dictionary,
	swr_opts:                   ^Dictionary,
	apad:                       cstring,
	finished:                   OST_Finished,
	unavailable:                i32,
	initialized:                i32,
	attachment_filename:        cstring,
	keep_pix_fmt:               i32,
	packets_written:            u64,
	frames_encoded:             u64,
	samples_encoded:            u64,
	quality:                    i32,
	sq_idx_encode:              i32,
	sq_idx_mux:                 i32,
	enc_stats_pre:              Enc_Stats,
	enc_stats_post:             Enc_Stats,
	fix_sub_duration_heartbeat: u32,
}


//this struct declared properly in sync_queue.h, not dealing with that whole thing.
Sync_Queue :: struct {
}

Output_File :: struct {
	class:          ^Class,
	index:          i32,
	format:         ^Output_Format,
	url:            cstring,
	streams:        ^[^]Output_Stream,
	nb_streams:     i32,
	sq_encode:      Sync_Queue,
	recording_time: i64,
	start_time:     i64,
	shortest:       i32,
	bit_exact:      i32,
}

Frame_Data :: struct {
	dec:                 struct {
		frame_num: u64,
		pts:       i64,
		tb:        Rational,
	},
	frame_rate_filter:   Rational,
	bits_per_raw_sample: i32,
}

/////done ffmpeg.h

File :: distinct u64

Expr_Type :: enum i32 {
	e_value,
	e_const,
	e_func0,
	e_func1,
	e_func2,
	e_squish,
	e_gauss,
	e_ld,
	e_isnan,
	e_isinf,
	e_mod,
	e_max,
	e_min,
	e_eq,
	e_gt,
	e_gte,
	e_lte,
	e_lt,
	e_pow,
	e_mul,
	e_div,
	e_add,
	e_last,
	e_st,
	e_while,
	e_taylor,
	e_root,
	e_floor,
	e_ceil,
	e_trunc,
	e_round,
	e_sqrt,
	e_not,
	e_random,
	e_hypot,
	e_gcd,
	e_if,
	e_ifnot,
	e_print,
	e_bitand,
	e_bitor,
	e_between,
	e_clip,
	e_atan2,
	e_lerp,
	e_sgn,
}

Expr :: struct {
	type:        Expr_Type,
	value:       f64, // is sign in other types
	const_index: i32,
	a:           struct #raw_union {
		func0: #type proc(v: f64) -> f64,
		func1: #type proc(p: rawptr, v: f64) -> f64,
		func2: #type proc(p: rawptr, v1: f64, v2: f64) -> f64,
	},
	param:       ^[3]Expr,
	var:         ^f64,
}

Command_Opt_Flag :: enum i32 {
	ARG      = 0,
	BOOL     = 1,
	EXPERT   = 2,
	STRING   = 3,
	VIDEO    = 4,
	AUDIO    = 5,
	INT      = 7,
	FLOAT    = 8,
	SUBTITLE = 9,
	INT64    = 10,
	EXIT     = 11,
	DATA     = 12,
	PERFILE  = 13,
	OFFSET   = 14,
	SPEC     = 15,
	TIME     = 16,
	DOUBLE   = 17,
	INPUT    = 18,
	OUTPUT   = 19,
}
Command_Opt_Flags :: bit_set[Command_Opt_Flag;i32]

Command_Opt_Type_Union :: struct #raw_union {
	str:  cstring,
	i:    i32,
	i_64: i64,
	ui64: u64,
	f:    f32,
	dbl:  f64,
}

Specifier_Opt :: struct {
	specifier: cstring,
	u:         Command_Opt_Type_Union,
}

Command_Option_Def :: struct {
	name:    cstring,
	flags:   i32,
	u:       Command_Value_Union,
	help:    cstring,
	argname: cstring,
}

Command_Option :: struct {
	opt: ^Command_Option_Def,
	key: cstring,
	val: cstring,
}

Command_Option_Group_Def :: struct {
	name:  cstring,
	sep:   cstring,
	flags: i32,
}

Command_Option_Group :: struct {
	group_def:   ^Command_Option_Group_Def,
	arg:         cstring,
	opts:        ^Option,
	nb_opts:     i32,
	codec_opts:  ^Dictionary,
	format_opts: ^Dictionary,
	sws_dict:    ^Dictionary,
	swr_opts:    ^Dictionary,
}

Command_Option_Group_List :: struct {
	group_def: ^Command_Option_Group_Def,
	groups:    ^Command_Option_Group,
	nb_groups: i32,
}

Command_Option_Parse_Context :: struct {
	global_opts: Command_Option_Group,
	groups:      ^Command_Option_Group_List,
	nb_groups:   i32,
	cur_group:   Command_Option_Group,
}

Command_Value_Union :: struct #raw_union {
	dst_ptr:  rawptr,
	func_arg: #type proc(ctx: rawptr, arg1: cstring, arg2: cstring) -> i32,
	off:      u64,
}
