//
// Created by Konrad Münch on 05.12.2023.
//

#ifndef CUDA_TEST_DEVICEKERNEL_CUH
#define CUDA_TEST_DEVICEKERNEL_CUH


__global__ void ConvertRGBtoHSVKernel(uchar3 *input, float3 *output, int width, int height);
__global__ void AddBoxBlurKernel(uchar3 *input, uchar3 *output, int width, int height);

#endif //CUDA_TEST_DEVICEKERNEL_CUH
