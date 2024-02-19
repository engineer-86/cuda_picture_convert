// GpuPowerMonitorThread.cu
#include "GpuPowerMonitorThread.cuh"
#include <chrono>

GpuPowerMonitorThread::GpuPowerMonitorThread() : stopSignal(false) {}

GpuPowerMonitorThread::~GpuPowerMonitorThread() {
    stopMonitoring();
}

void GpuPowerMonitorThread::startMonitoring() {
    stopSignal = false;
    monitoringThread = std::thread(&GpuPowerMonitorThread::monitorFunction, this);
}

void GpuPowerMonitorThread::stopMonitoring() {
    stopSignal = true;
    if (monitoringThread.joinable()) {
        monitoringThread.join();
    }
}

std::vector<float> GpuPowerMonitorThread::getPowerReadings() const {
    std::lock_guard<std::mutex> lock(readingsMutex);
    return powerReadings;
}

void GpuPowerMonitorThread::monitorFunction() {
    GpuPowerMonitor gpuPowerMonitor;

    while (!stopSignal) {

        float powerUsage = gpuPowerMonitor.getPowerUsage(0); // GPU-Index 0

        {
            std::lock_guard<std::mutex> lock(readingsMutex);
            powerReadings.push_back(powerUsage);
        }
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}
