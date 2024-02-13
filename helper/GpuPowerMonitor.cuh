//
// Created by Konrad Münch on 13.02.2024.
//

#ifndef CUDA_TEST_GPUPOWERMONITOR_CUH
#define CUDA_TEST_GPUPOWERMONITOR_CUH

#include <nvml.h>
#include <stdexcept>
#include <string>

class GpuPowerMonitor {
public:
    GpuPowerMonitor();

    ~GpuPowerMonitor();

    float getPowerUsage(unsigned int gpuIndex) const;

private:
    void initNVML();

    void shutdownNVML();
//
//    unsigned int *power;
//    nvmlDevice_t *device;


};


#endif //CUDA_TEST_GPUPOWERMONITOR_CUH
