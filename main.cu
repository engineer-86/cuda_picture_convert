#include <iostream>
#include <string>
#include <vector>
#include "device/DeviceInfo.cuh"
#include "image-processing/ImageProcessor.cuh"
#include "helper/HelperFunctions.cuh"
#include "helper/GpuPowerMonitor.cuh"
#include <windows.h>


void showUserMenu(bool& useCUDA, bool& useCPU, int& numThreads, int& numRuns);

int main(int argc, char **argv) {
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " <input_picture_path> <output_file_path>\n";
        return 1;
    }

    const std::string input_picture_path = argv[1];
    const std::string output_file_path = argv[2];
    bool use_cuda = false, use_gpu = false;
    int num_threads, num_runs;

    showUserMenu(use_cuda, use_gpu, num_threads, num_runs);

    std::vector<ProcessingInfo> processingInfos;
    GpuPowerMonitor gpuPowerMonitor;

    float power = gpuPowerMonitor.getPowerUsage(0);
    getDeviceInfo();
    std::cout << "Initial Power: " << power << " Watts\n" << std::endl;
    Sleep(3000);

    ImageProcessor imageProcessor;

    for (int run_id = 1; run_id <= num_runs; ++run_id) {
        if (use_cuda) {
            imageProcessor.ProcessImageCUDA(input_picture_path, output_file_path, true, run_id, processingInfos);
        }
        if (use_gpu) {
            HelperFunctions::setOmpThreads(num_threads);
            imageProcessor.ProcessImageCPU(input_picture_path, output_file_path, false, run_id, processingInfos);
        }
    }

    HelperFunctions::WriteSummaryToCSV(processingInfos, output_file_path + "/summary.csv");
    std::cout << "Power after runs: " << gpuPowerMonitor.getPowerUsage(0) << " Watts\n" << std::endl;
    Sleep(3000);

    return 0;
}

void showUserMenu(bool& useCUDA, bool& useCPU, int& numThreads, int& numRuns) {
    std::cout << "Select processing modes (multiple choices allowed):\n";
    std::cout << "1. CUDA (GPU)\n";
    std::cout << "2. CPU\n";
    std::cout << "3. Both\n";
    int choice;
    std::cin >> choice;

    switch (choice) {
        case 1:
            useCUDA = true;
            break;
        case 2:
            useCPU = true;
            break;
        case 3:
            useCUDA = true;
            useCPU = true;
            break;
        default:
            std::cerr << "Invalid choice. Defaulting to CPU.\n";
            useCPU = true;
    }

    if (useCPU || useCUDA) {
        std::cout << "Enter number of runs: ";
        std::cin >> numRuns;
    }

    if (useCPU) {
        std::cout << "Enter number of threads for CPU processing: ";
        std::cin >> numThreads;
    } else {
        numThreads = 0;
    }
}
