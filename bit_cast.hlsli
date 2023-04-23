/**
 * bit_cast<T> HLSL - version 0.01
 *
 * Copyright (C) 2022-2023, by Pavel Martishevsky
 * Report bugs and download new versions at https://github.com/pm4rtx/bit_cast_hlsl
 *
 * This header is distributed under the MIT License. See notice at the end of this file.
 */

#ifndef BITCAST_HLSLI
#define BITCAST_HLSLI

#ifndef BITCAST_16BIT_SUPPORTED
#define BITCAST_16BIT_SUPPORTED 0
#endif

#ifndef BITCAST_AUX_BASE_TYPE
#define BITCAST_AUX_BASE_TYPE 1
#endif

template<typename TDst, typename TSrc>
struct TBitCastTypeIsSame { static const bool Result = false; };

template<typename T>
struct TBitCastTypeIsSame<T, T> { static const bool Result = true; };

template<typename T>
struct TBitCastBaseTypeIs16Bit
{ 
#if BITCAST_16BIT_SUPPORTED
    static const bool Result = TBitCastTypeIsSame<T, float16_t>::Result
                            || TBitCastTypeIsSame<T,  uint16_t>::Result
                            || TBitCastTypeIsSame<T,   int16_t>::Result;
#else
    static const bool Result = false;
#endif
};

template<typename T, int S>
struct TBitCastBaseTypeIs16Bit<vector<T, S> >
{ 
#if BITCAST_16BIT_SUPPORTED
    static const bool Result = TBitCastTypeIsSame<T, float16_t>::Result
                            || TBitCastTypeIsSame<T,  uint16_t>::Result
                            || TBitCastTypeIsSame<T,   int16_t>::Result;
#else
    static const bool Result = false;
#endif
};

/**
 *  @brief  The primary purpose of this template is to define via template
 *          specialisation supported casts available as built-in HLSL intrinsics
 */
template<typename TDst, typename TSrc>
struct TBitCastIfSupported;

/** 
 *  @brief  Helper macro to define supported casts via partial template
 *          specialisations which call built-in HLSL intrinsics 
 */
#define BITCAST_SUPPORTED(TDst, TSrc, Intrinsic)                                    \
    template<int S> struct TBitCastIfSupported<vector<TDst, S>, vector<TSrc, S> >   \
    {                                                                               \
        static vector<TDst, S> bit_cast(vector<TSrc, S> x) { return Intrinsic(x); } \
    }

    /** @brief  Define all partial specialization for casts supported via built-in intrinsics */
    BITCAST_SUPPORTED(float,  uint, asfloat);
    BITCAST_SUPPORTED(float,   int, asfloat);
    BITCAST_SUPPORTED( uint, float,  asuint);
    BITCAST_SUPPORTED( uint,   int,  asuint);
    BITCAST_SUPPORTED(  int, float,   asint);
    BITCAST_SUPPORTED(  int,  uint,   asint);

    #if BITCAST_16BIT_SUPPORTED
        BITCAST_SUPPORTED(float16_t,  uint16_t, asfloat16);
        BITCAST_SUPPORTED(float16_t,   int16_t, asfloat16);
        BITCAST_SUPPORTED( uint16_t, float16_t,  asuint16);
        BITCAST_SUPPORTED( uint16_t,   int16_t,  asuint16);
        BITCAST_SUPPORTED(  int16_t, float16_t,   asint16);
        BITCAST_SUPPORTED(  int16_t,  uint16_t,   asint16);
    #endif

#undef BITCAST_SUPPORTED

/** @brief  This section allows to enable 16-bit to 32-bit casts */
#if BITCAST_16BIT_SUPPORTED && BITCAST_AUX_BASE_TYPE

    #ifndef BITCAST_CUSTOM_U16x2_TO_U32
        uint asuint(uint16_t2 x) { return (uint(x.y) << 16u) | uint(x.x); }
    #else
        uint asuint(uint16_t2 x) { return BITCAST_CUSTOM_U16x2_TO_U32(x); }
    #endif
    
    #ifndef BITCAST_CUSTOM_I16x2_TO_U32
        uint asuint(int16_t2 x) { return asuint(asuint16(x)); }
    #else
        uint asuint(int16_t2 x) { return BITCAST_CUSTOM_I16x2_TO_U32(x); }
    #endif
    
    #ifndef BITCAST_CUSTOM_F16x2_TO_U32
        uint asuint(float16_t2 x) { return asuint(asuint16(x)); }
    #else
        uint asuint(float16_t2 x) { return BITCAST_CUSTOM_F16x2_TO_U32(x); }
    #endif

    #ifndef BITCAST_CUSTOM_U32_TO_U16x2
        uint16_t2 asuint16(uint x) { return uint16_t2(x & 0xffffu, x >> 16u); };
    #else
        uint16_t2 asuint16(uint x) { return BITCAST_CUSTOM_U32_TO_U16x2(x); };
    #endif

    #ifndef BITCAST_CUSTOM_U32_TO_I16x2
        int16_t2 asint16(uint x) { return asint16(asuint16(x)); };
    #else
        int16_t2 asint16(uint x) { return BITCAST_CUSTOM_U32_TO_I16x2(x); };
    #endif

    #ifndef BITCAST_CUSTOM_U32_TO_F16x2
        float16_t2 asfloat16(uint x) { return asfloat16(asuint16(x)); };
    #else
        float16_t2 asfloat16(uint x) { return BITCAST_CUSTOM_U32_TO_F16x2(x); };
    #endif

    #define BITCAST_SUPPORTED(TDst, TSrc, Intrinsic)                                        \
        template<> struct TBitCastIfSupported<vector<TDst, 2>, vector<TSrc, 4> >            \
        {                                                                                   \
            static vector<TDst, 2> bit_cast(vector<TSrc, 4> x)                              \
            {                                                                               \
                return vector<TDst, 2>(Intrinsic(asuint(x.xy)), Intrinsic(asuint(x.zw)));   \
            }                                                                               \
        }

        BITCAST_SUPPORTED(uint,  uint16_t, asuint);
        BITCAST_SUPPORTED(uint,   int16_t, asuint);
        BITCAST_SUPPORTED(uint, float16_t, asuint);

        BITCAST_SUPPORTED( int,  uint16_t, asint);
        BITCAST_SUPPORTED( int,   int16_t, asint);
        BITCAST_SUPPORTED( int, float16_t, asint);

        BITCAST_SUPPORTED(float,  uint16_t, asfloat);
        BITCAST_SUPPORTED(float,   int16_t, asfloat);
        BITCAST_SUPPORTED(float, float16_t, asfloat);

    #undef BITCAST_SUPPORTED

    #define BITCAST_SUPPORTED(TDst, TSrc, Intrinsic)                                    \
        template<> struct TBitCastIfSupported<vector<TDst, 4>, vector<TSrc, 2> >        \
        {                                                                               \
            static vector<TDst, 4> bit_cast(vector<TSrc, 2> x)                          \
            {                                                                           \
                return vector<TDst, 4>(Intrinsic(asuint(x.x)), Intrinsic(asuint(x.y))); \
            }                                                                           \
        }

        BITCAST_SUPPORTED(float16_t,  uint, asfloat16);
        BITCAST_SUPPORTED(float16_t,   int, asfloat16);
        BITCAST_SUPPORTED(float16_t, float, asfloat16);

        BITCAST_SUPPORTED(uint16_t,  uint, asuint16);
        BITCAST_SUPPORTED(uint16_t,   int, asuint16);
        BITCAST_SUPPORTED(uint16_t, float, asuint16);
    
        BITCAST_SUPPORTED(int16_t,  uint, asint16);
        BITCAST_SUPPORTED(int16_t,   int, asint16);
        BITCAST_SUPPORTED(int16_t, float, asint16);

    #undef BITCAST_SUPPORTED

#endif /** BITCAST_16BIT_SUPPORTED && BITCAST_AUX_BASE_TYPE */

/**
 *  @brief  The primary purpose of TBitCastWidenOrShrink is to make sure the source
 *          vector is transformed to a vector having the same type but the size
 *          matching the destination vector, so underlying templates need only to
 *          perform the actual cast.
 *
 *          The base template doesn't have implementation because the partial
 *          specialization handles all the cases since input and output arguments
 *          are both of vector<T, N> type (ensured by `TBitCastVectorize{Src, Dst}`)
 *
 *  @see    `TBitCastVectorizeSrc`, `TBitCastVectorizeDst`
 */
template<typename TDst, 
         typename TSrc, 
         bool IsDstBase16Bit = TBitCastBaseTypeIs16Bit<TDst>::Result, 
         bool IsSrcBase16Bit = TBitCastBaseTypeIs16Bit<TSrc>::Result >
struct TBitCastWidenOrShrink;

/** 
 *  @brief  The primary purpose of `TBitCastWidenOrShrinkIfSameBase` is to either
 *          widen or shrink an input vector to the size of an output vector if
 *          the base type is the same
 */
template<typename TDst, typename TSrc>
struct TBitCastWidenOrShrinkIfSameBase
{
    static TDst bit_cast(TSrc x) { return TBitCastWidenOrShrink<TDst, TSrc>::bit_cast(x); }
};

template<typename T, int SDst, int SSrc>
struct TBitCastWidenOrShrinkIfSameBase<vector<T, SDst>, vector<T, SSrc> >
{
    static vector<T, SDst> bit_cast(vector<T, SSrc> x)
    {
        vector<T, SDst> o;
        uint i;
        [unroll] for (i = 0; i < min(SDst, SSrc); ++i)
        {
            o[i] = x[i];
        }
        [unroll] for (i = min(SDst, SSrc) - 1; i < SDst; ++i)
        {
            o[i] = 0;
        }
        return o;
    }
};


/** 
 *  @brief  The primary purpose of `TBitCastIfNotSame` is to return early if casting between same types
 */
template<typename TDst, typename TSrc>
struct TBitCastIfNotSame
{
    static TDst bit_cast(TSrc x) { return TBitCastWidenOrShrinkIfSameBase<TDst, TSrc>::bit_cast(x); }
};

template<typename T>
struct TBitCastIfNotSame<T, T>
{
    static T bit_cast(T x) { return x; }
};


template<typename TDst, typename TSrc, int SDst, int SSrc, bool IsBase16BitOr32Bit>
struct TBitCastWidenOrShrink<vector<TDst, SDst>, vector<TSrc, SSrc>, IsBase16BitOr32Bit, IsBase16BitOr32Bit>
{
    static vector<TDst, SDst> bit_cast(vector<TSrc, SSrc> x)
    {
        vector<TSrc, SDst> o;
        uint i;
        [unroll] for (i = 0; i < min(SDst, SSrc); ++i)
        {
            o[i] = x[i];
        }
        [unroll] for (i = min(SDst, SSrc) - 1; i < SDst; ++i)
        {
            o[i] = 0;
        }
        return TBitCastIfSupported< vector<TDst, SDst>, vector<TSrc, SDst> >::bit_cast(o);
    }
};

template<typename TDst, typename TSrc, int SDst, int SSrc>
struct TBitCastWidenOrShrink<vector<TDst, SDst>, vector<TSrc, SSrc>, true, false>
{
    static vector<TDst, SDst> bit_cast(vector<TSrc, SSrc> x)
    {
        /**
         *  NOTE: when the base type of the source is 32-bit, shrink to a vector
         *        containing two elements (which satisfied any cast to 16-bit)
         *        then do the cast to 4-component 16-bit vector and then shrink
         *        to 16-bit vector with actual number of components
         */
        vector<TSrc, 2> xaligned = TBitCastIfNotSame<vector<TSrc, 2>, vector<TSrc, SSrc> >::bit_cast(x);
        vector<TDst, 4> oaligned = TBitCastIfSupported<vector<TDst, 4> , vector<TSrc, 2> >::bit_cast(xaligned);
        return TBitCastIfNotSame<vector<TDst, SDst>, vector<TDst, 4> >::bit_cast(oaligned);
    }
};

template<typename TDst, typename TSrc, int SDst, int SSrc>
struct TBitCastWidenOrShrink<vector<TDst, SDst>, vector<TSrc, SSrc>, false, true>
{
    static vector<TDst, SDst> bit_cast(vector<TSrc, SSrc> x)
    {
        /**
         *  NOTE: when the base type of the source is 16-bit, widen to a vector
         *        containing four elements (which is maximal possible for built-in vector
         *        then do the cast to 2-component 32-bit vector and then widen or shrink 
         *        to a vector with actual number of 32-bit components
         */
        vector<TSrc, 4> xaligned = TBitCastIfNotSame<vector<TSrc, 4>, vector<TSrc, SSrc> >::bit_cast(x);
        vector<TDst, 2> oaligned = TBitCastIfSupported<vector<TDst, 2> , vector<TSrc, 4> >::bit_cast(xaligned);
        return TBitCastIfNotSame<vector<TDst, SDst>, vector<TDst, 2> >::bit_cast(oaligned);
    }
};


/**
 *  @brief  The primary purpose of TBitCastVectorize{Src, Dst} is to transform 
 *          input argument from scalar to vector<T, 1> in order to simplify
 *          underlying templates by making sure they need to handle only 
 *          vector<T1, N1> <- vector<T2, N2> casts
 */
template<typename TDst, typename TSrc> struct TBitCastVectorizeSrc
{
    static TDst bit_cast(TSrc x) { return TBitCastIfNotSame<TDst, vector<TSrc, 1> >::bit_cast(vector<TSrc, 1>(x)); }
};

template<typename TDst, typename TSrc, int SSrc> struct TBitCastVectorizeSrc<TDst, vector<TSrc, SSrc> >
{
    static TDst bit_cast(vector<TSrc, SSrc> x) { return TBitCastIfNotSame<TDst, vector<TSrc, SSrc> >::bit_cast(x); }
};


template<typename TDst, typename TSrc> struct TBitCastVectorizeDst
{
    /** NOTE: make use of implicit scalar <- vector<T, 1> cast */
    static TDst bit_cast(TSrc x) { return TBitCastVectorizeSrc<vector<TDst, 1>, TSrc>::bit_cast(x).x; }
};

template<typename TDst, typename TSrc, int SDst> struct TBitCastVectorizeDst<vector<TDst, SDst>, TSrc>
{
    static vector<TDst, SDst> bit_cast(TSrc x) { return TBitCastVectorizeSrc<vector<TDst, SDst>, TSrc>::bit_cast(x); }
};

/** @brief  Public `bit_cast` */
template<typename TDstType, typename TSrcType>
static TDstType bit_cast(TSrcType x)
{
    return TBitCastVectorizeDst<TDstType, TSrcType>::bit_cast(x);
}

#endif /** BITCAST_HLSLI */

/**
 * Copyright (c) 2022-2023 Pavel Martishevsky
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
 * copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
