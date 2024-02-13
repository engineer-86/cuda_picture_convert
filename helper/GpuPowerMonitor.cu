//
// Created by arox on 13.02.2024.
//

#include "GpuPowerMonitor.cuh"


GpuPowerMonitor::GpuPowerMonitor() {
    initNVML();
}

GpuPowerMonitor::~GpuPowerMonitor() {
    shutdownNVML();
}

void GpuPowerMonitor::initNVML() {
    nvmlReturn_t result = nvmlInit();
    if (NVML_SUCCESS != result) {
        throw std::runtime_error("Failed to initialize NVML: " + std::string(nvmlErrorString(result)));
    }
}

void GpuPowerMonitor::shutdownNVML() {
    nvmlShutdown();
}

float GpuPowerMonitor::getPowerUsage(unsigned int gpuIndex) const {
    nvmlDevice_t device;
    nvmlReturn_t result = nvmlDeviceGetHandleByIndex(gpuIndex, &device);
    if (NVML_SUCCESS != result) {
        throw std::runtime_error("Failed to get handle for device " + std::to_string(gpuIndex) + ": " +
                                 std::string(nvmlErrorString(result)));
    }

    unsigned int power;
    result = nvmlDeviceGetPowerUsage(device, &power);
    if (NVML_SUCCESS != result) {
        throw std::runtime_error("Failed to get power usage for device " + std::to_string(gpuIndex) + ": " +
                                 std::string(nvmlErrorString(result)));
    }

    return (float) power / 1000.0f;
}