set ROOT=%~dp0

:: Prior DX Compiler aren't supported
::%ROOT%\..\dxc_2021_12_08\bin\x64\dxc.exe -E main -T cs_6_2 -HV 2021 bit_cast_test.hlsl
::%ROOT%\..\dxc_2022_07_18\bin\x64\dxc.exe -E main -T cs_6_2 -HV 2021 bit_cast_test.hlsl

%ROOT%\..\dxc_2022_12_16\bin\x64\dxc.exe -E main -T cs_6_2 -HV 2021 bit_cast_test.hlsl
%ROOT%\..\dxc_2022_12_16\bin\x64\dxc.exe -E main -T cs_6_2 -HV 2021 -enable-16bit-types -DBITCAST_16BIT_SUPPORTED=1 bit_cast_test.hlsl
