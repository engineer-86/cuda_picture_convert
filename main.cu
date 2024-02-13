#include <iostream>
#include <string>
#include "device/DeviceInfo.cuh"
#include "image-processing/ImageProcessor.cuh"
#include "device/DeviceInfo.cuh"
#include "helper/HelperFunctions.cuh"
#include "helper/GpuPowerMonitor.cuh"
#include <cstdlib>
#include<windows.h>


int main(int argc, char **argv) {
    if (argc != 5) {
        std::cerr << "Usage: " << argv[0] << " <mode> <file_name>\n";
        return 1;
    }
    const std::string &input_picture_path = argv[1];
    const std::string &output_file_path = argv[2];
    int num_runs = atoi(argv[3]);
    int num_threads = atoi(argv[4]);
    HelperFunctions::setOmpThreads(num_threads);
    ImageProcessor imageProcessor;


    std::vector<ProcessingInfo> processingInfos;
    GpuPowerMonitor gpuPowerMonitor;
    float power = gpuPowerMonitor.getPowerUsage(0);
    std::cout << "Initial Power: " << power << " Watts\n" << std::endl;
    Sleep(3000);

    for (int run_id = 1; run_id <= num_runs; ++run_id) {
        imageProcessor.ProcessImageCUDA(input_picture_path, output_file_path, true,
                                        run_id, processingInfos);
    }

    for (int run_id = 1; run_id <= num_runs; ++run_id) {
        imageProcessor.ProcessImageCPU(input_picture_path, output_file_path, false,
                                       run_id, processingInfos);
    }

    HelperFunctions::WriteSummaryToCSV(processingInfos, output_file_path + "summary.csv");
    std::cout << "Power after runs: " << power << " Watts\n" << std::endl;
    Sleep(3000);

    return 0;
}
