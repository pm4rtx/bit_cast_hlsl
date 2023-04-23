# bit_cast\<T\> HLSL ![MIT](https://img.shields.io/badge/license-MIT-blue.svg) [![GitHub](https://img.shields.io/badge/repo-github-green.svg)](https://github.com/zeux/meshoptimizer)

## Purpose

When writing shaders in HLSL, it is often necessary to `reinterpret_cast` variables of built-in types. The language offers built-in intrinsics such as `asfloat`, `asuint`, `asint` to achieve this goal. The list of supported built-in types has grown with addition of 16-bit types in [HLSL 2018](https://github.com/microsoft/DirectXShaderCompiler/wiki/16-Bit-Scalar-Types) and similarly the list of supported intrinsics was extended by the addition of `asfloat16`, `asuint16`, `asint16`. However, casting between 32-bit and 16-bit types remained problematic and still requires manual packing or unpacking. This often leads to chaining mentioned intrinsics. Similarly, increasing the number of component while padding with zeros or reducing the number of components by dropping trailing components could be useful.

The header file `bit_cast.hlsli` provides a proof of concept implementation of `bit_cast<T>` using templates in [HLSL 2021](https://github.com/microsoft/DirectXShaderCompiler/wiki/HLSL-2021) which covers arbitrary casts between scalar and vector  16-bit and 32-bit types allowing padding to zero and trimming input types, so the following examples are valid:

```hlsl
uint3 i = uint3(1, 2, 3);
half2 a = bit_cast<half2>(i.x); //< reinterpret as half2
 uint b = bit_cast<uint>(i);    //< drop .yz component
uint4 c = bit_cast<uint4>(i);   //< pad with zeros
half3 d = bit_cast<half3>(i);   //< reinterpret first uint as half2 (x <- lower 16-bit) and 
                                //< lower 16-bit of the second uint as half
```

The header can be compiled with [DX Compiler release for December 2022](https://github.com/microsoft/DirectXShaderCompiler/releases/tag/v1.7.2212).

## License

This header is available to anybody free of charge, under the terms of MIT License (see LICENSE.md).
