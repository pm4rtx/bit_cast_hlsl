#include "bit_cast.hlsli"

RWByteAddressBuffer o;
static uint GAddress;

template<typename T> void Append(T data)
{
    o.Store(GAddress, data);
    GAddress += sizeof(T) * 64;
}

[numthreads(64, 1, 1)]
void main()
{
    GAddress = 0;

    int xs = uint(1);
    int1 x1 = uint1(1);
    int2 x2 = uint2(1, 2);
    int3 x3 = uint3(1, 2, 3);
    int4 x4 = uint4(1, 2, 3, 4);

    int ys = int(-1);
    int1 y1 = int1(-1);
    int2 y2 = int2(-1, -2);
    int3 y3 = int3(-1, -2, -3);
    int4 y4 = int4(-1, -2, -3, -4);

    float zs = float(-0.1);
    float1 z1 = float1(-0.1);
    float2 z2 = float2(-0.1, -0.2);
    float3 z3 = float3(-0.1, -0.2, -0.3);
    float4 z4 = float4(-0.1, -0.2, -0.3, -0.4);

    #define TEST_BIT_CAST_TO_B32(x)         \
        {                                   \
            Append(bit_cast<int>(x));       \
            Append(bit_cast<int1>(x));      \
            Append(bit_cast<int2>(x));      \
            Append(bit_cast<int3>(x));      \
            Append(bit_cast<int4>(x));      \
            Append(bit_cast<uint>(x));      \
            Append(bit_cast<uint1>(x));     \
            Append(bit_cast<uint2>(x));     \
            Append(bit_cast<uint3>(x));     \
            Append(bit_cast<uint4>(x));     \
            Append(bit_cast<float>(x));     \
            Append(bit_cast<float1>(x));    \
            Append(bit_cast<float2>(x));    \
            Append(bit_cast<float3>(x));    \
            Append(bit_cast<float4>(x));    \
        }

    TEST_BIT_CAST_TO_B32(xs)
    TEST_BIT_CAST_TO_B32(x1)
    TEST_BIT_CAST_TO_B32(x2)
    TEST_BIT_CAST_TO_B32(x3)
    TEST_BIT_CAST_TO_B32(x4)
    TEST_BIT_CAST_TO_B32(ys)
    TEST_BIT_CAST_TO_B32(y1)
    TEST_BIT_CAST_TO_B32(y2)
    TEST_BIT_CAST_TO_B32(y3)
    TEST_BIT_CAST_TO_B32(y4)
    TEST_BIT_CAST_TO_B32(zs)
    TEST_BIT_CAST_TO_B32(z1)
    TEST_BIT_CAST_TO_B32(z2)
    TEST_BIT_CAST_TO_B32(z3)
    TEST_BIT_CAST_TO_B32(z4)

#if BITCAST_16BIT_SUPPORTED

    uint16_t  as = uint16_t(1);
    uint16_t1 a1 = uint16_t1(1);
    uint16_t2 a2 = uint16_t2(1, 2);
    uint16_t3 a3 = uint16_t3(1, 2, 3);
    uint16_t4 a4 = uint16_t4(1, 2, 3, 4);

    int16_t  bs = int16_t(-1);
    int16_t1 b1 = int16_t1(-1);
    int16_t2 b2 = int16_t2(-1, -2);
    int16_t3 b3 = int16_t3(-1, -2, -3);
    int16_t4 b4 = int16_t4(-1, -2, -3, -4);

    float16_t  cs = float16_t(-0.1);
    float16_t1 c1 = float16_t1(-0.1);
    float16_t2 c2 = float16_t2(-0.1, -0.2);
    float16_t3 c3 = float16_t3(-0.1, -0.2, -0.3);
    float16_t4 c4 = float16_t4(-0.1, -0.2, -0.3, -0.4);

    #define TEST_BIT_CAST_TO_B16(x)         \
        {                                   \
            Append(bit_cast<int16_t>(x));   \
            Append(bit_cast<int16_t1>(x));  \
            Append(bit_cast<int16_t2>(x));  \
            Append(bit_cast<int16_t3>(x));  \
            Append(bit_cast<int16_t4>(x));  \
            Append(bit_cast<uint16_t>(x));  \
            Append(bit_cast<uint16_t1>(x)); \
            Append(bit_cast<uint16_t2>(x)); \
            Append(bit_cast<uint16_t3>(x)); \
            Append(bit_cast<uint16_t4>(x)); \
            Append(bit_cast<float16_t>(x)); \
            Append(bit_cast<float16_t1>(x));\
            Append(bit_cast<float16_t2>(x));\
            Append(bit_cast<float16_t3>(x));\
            Append(bit_cast<float16_t4>(x));\
        }

    TEST_BIT_CAST_TO_B16(as)
    TEST_BIT_CAST_TO_B16(a1)
    TEST_BIT_CAST_TO_B16(a2)
    TEST_BIT_CAST_TO_B16(a3)
    TEST_BIT_CAST_TO_B16(a4)
    TEST_BIT_CAST_TO_B16(bs)
    TEST_BIT_CAST_TO_B16(b1)
    TEST_BIT_CAST_TO_B16(b2)
    TEST_BIT_CAST_TO_B16(b3)
    TEST_BIT_CAST_TO_B16(b4)
    TEST_BIT_CAST_TO_B16(cs)
    TEST_BIT_CAST_TO_B16(c1)
    TEST_BIT_CAST_TO_B16(c2)
    TEST_BIT_CAST_TO_B16(c3)
    TEST_BIT_CAST_TO_B16(c4)

    #if BITCAST_AUX_BASE_TYPE

        TEST_BIT_CAST_TO_B32(as)
        TEST_BIT_CAST_TO_B32(a1)
        TEST_BIT_CAST_TO_B32(a2)
        TEST_BIT_CAST_TO_B32(a3)
        TEST_BIT_CAST_TO_B32(a4)
        TEST_BIT_CAST_TO_B32(bs)
        TEST_BIT_CAST_TO_B32(b1)
        TEST_BIT_CAST_TO_B32(b2)
        TEST_BIT_CAST_TO_B32(b3)
        TEST_BIT_CAST_TO_B32(b4)
        TEST_BIT_CAST_TO_B32(cs)
        TEST_BIT_CAST_TO_B32(c1)
        TEST_BIT_CAST_TO_B32(c2)
        TEST_BIT_CAST_TO_B32(c3)
        TEST_BIT_CAST_TO_B32(c4)

        TEST_BIT_CAST_TO_B16(xs)
        TEST_BIT_CAST_TO_B16(x1)
        TEST_BIT_CAST_TO_B16(x2)
        TEST_BIT_CAST_TO_B16(x3)
        TEST_BIT_CAST_TO_B16(x4)
        TEST_BIT_CAST_TO_B16(ys)
        TEST_BIT_CAST_TO_B16(y1)
        TEST_BIT_CAST_TO_B16(y2)
        TEST_BIT_CAST_TO_B16(y3)
        TEST_BIT_CAST_TO_B16(y4)
        TEST_BIT_CAST_TO_B16(zs)
        TEST_BIT_CAST_TO_B16(z1)
        TEST_BIT_CAST_TO_B16(z2)
        TEST_BIT_CAST_TO_B16(z3)
        TEST_BIT_CAST_TO_B16(z4)

    #endif /** BITCAST_AUX_BASE_TYPE */

#endif /** BITCAST_16BIT_SUPPORTED */
}
