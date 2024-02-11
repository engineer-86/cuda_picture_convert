//
// Created by Konrad Münch on 08.12.2023.
//

#ifndef CUDA_TEST_HOSTSYSTEM_CUH
#define CUDA_TEST_HOSTSYSTEM_CUH


__host__ void ConvertRGBtoHSV(uchar3 *input, float3 *output, int width, int height);
__host__ void AddBoxBlur(uchar3 *input, uchar3 *output, int width, int height);

#endif //CUDA_TEST_HOSTSYSTEM_CUH
