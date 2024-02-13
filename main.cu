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
    if (argc != 4) {
        std::cerr << "Usage: " << argv[0] << " <mode> <file_name>\n";
        return 1;
    }
    const std::string &input_picture_path = argv[1];
    const std::string &output_file_path = argv[2];
    int num_trials = atoi(argv[3]);
    ImageProcessor imageProcessor;


    std::vector<ProcessingInfo> processingInfos;
    GpuPowerMonitor gpuPowerMonitor;
    float power = gpuPowerMonitor.getPowerUsage(0);
    std::cout << "Initial Power: " << power << " Watts\n" << std::endl;
    Sleep(3000);

    for (int run_id = 1; run_id <= num_trials; ++run_id) {

        imageProcessor.ProcessImageCUDA(input_picture_path, output_file_path,
                                        true, run_id, processingInfos);

        imageProcessor.ProcessImageCPU(input_picture_path, output_file_path,
                                       false, run_id, processingInfos);


    }
    HelperFunctions::WriteSummaryToCSV(processingInfos, output_file_path + "summary.csv");

    return 0;
}
