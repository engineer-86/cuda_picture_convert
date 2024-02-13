//
// Created by arox on 13.02.2024.
//

#ifndef CUDA_TEST_GPUPOWERMONITORTHREAD_CUH
#define CUDA_TEST_GPUPOWERMONITORTHREAD_CUH

#include <thread>
#include <atomic>
#include <vector>
#include <chrono>
#include <atomic>
#include <mutex>
#include "GpuPowerMonitor.cuh"

class GpuPowerMonitorThread {
public:
    GpuPowerMonitorThread();
    ~GpuPowerMonitorThread();

    void startMonitoring();
    void stopMonitoring();
    std::vector<float> getPowerReadings() const;

private:
    mutable std::mutex readingsMutex;
    std::vector<float> powerReadings;
    std::atomic<bool> stopSignal;
    std::thread monitoringThread;

    void monitorFunction();
};

#endif // CUDA_TEST_GPUPOWERMONITORTHREAD_H
