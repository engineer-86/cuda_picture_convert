//
// Created by Konrad Münch on 05.12.2023.
//

#include <iostream>
#include "DeviceKernel.cuh"

// https://harmanani.github.io/classes/csc447/Notes/Lecture15.pdf

__global__ void ConvertRGBtoHSVKernel(uchar3 *input, float3 *output, int width, int height) {
    unsigned int x = threadIdx.x + blockIdx.x * blockDim.x;
    unsigned int y = threadIdx.y + blockIdx.y * blockDim.y;

    if (x < width && y < height) {
        unsigned int idx = y * width + x;
        uchar3 rgb = input[idx];

        float B = static_cast<float>(rgb.x) / 255.0f;
        float G = static_cast<float>(rgb.y) / 255.0f;
        float R = static_cast<float>(rgb.z) / 255.0f;

        float c_max = fmaxf(R, fmaxf(G, B));
        float c_min = fminf(R, fminf(G, B));
        float diff = c_max - c_min;

        float H = 0;
        if (diff != 0) {
            if (c_max == R) {
                H = fmodf((60 * ((G - B) / diff) + 360), 360);
            } else if (c_max == G) {
                H = fmodf((60 * ((B - R) / diff) + 120), 360);
            } else if (c_max == B) {
                H = fmodf((60 * ((R - G) / diff) + 240), 360);
            }
        }

        H = (H / 360) * 255;

        float S, V;
        if (c_max == 0) {
            S = 0;
        } else {
            S = diff / c_max * 255;
        }
        V = c_max * 255;

        output[idx] = make_float3(H, S, V);
    }
}

__global__ void AddBoxBlurKernel(uchar3 *input, uchar3 *output, int width, int height) {
    int blurRadius = 2;

    unsigned int x = threadIdx.x + blockIdx.x * blockDim.x;
    unsigned int y = threadIdx.y + blockIdx.y * blockDim.y;

    if (x < width && y < height) {
        unsigned int idx = y * width + x;

        float3 sum = make_float3(0, 0, 0);
        int count = 0;

        for (int i = -blurRadius; i <= blurRadius; i++) {
            for (int j = -blurRadius; j <= blurRadius; j++) {
                int x1 = x + i;
                int y1 = y + j;

                if (x1 >= 0 && x1 < width && y1 >= 0 && y1 < height) {
                    unsigned int idx1 = y1 * width + x1;
                    uchar3 inPixel = input[idx1];
                    sum.x += inPixel.x;
                    sum.y += inPixel.y;
                    sum.z += inPixel.z;

                    count++;
                }
            }
        }

        output[idx] = make_uchar3(sum.x / count, sum.y / count, sum.z / count);

    }
}