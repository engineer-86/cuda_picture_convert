//
// Created by KonradMünch on 16.10.2023.
//
#include <iostream>
#include "DeviceInfo.cuh"

void getDeviceInfo() {
    int deviceCount = 0;
    cudaGetDeviceCount(&deviceCount);
    for (int device = 0; device < deviceCount; ++device) {
        cudaDeviceProp deviceProp{};
        cudaGetDeviceProperties(&deviceProp, device);
        std::cout << "Device " << device << ": " << deviceProp.name << std::endl;
        std::cout << "  CUDA Version: " << deviceProp.major << "." << deviceProp.minor << std::endl;
        std::cout << "  V-RAM: " << deviceProp.totalGlobalMem / (1024 * 1024) << " MB" << std::endl;
        std::cout << "  Multiprocessor Count: " << deviceProp.multiProcessorCount << std::endl;
        std::cout << "  Max Threads Per Block: " << deviceProp.maxThreadsPerBlock << std::endl;
        std::cout << "  Clock rate:" << deviceProp.clockRate / 1000 << "Mhz" << std::endl;
    }
}

