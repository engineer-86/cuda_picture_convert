#include <iostream>
#include <string>
#include "device/DeviceInfo.cuh"
#include "image-processing/ImageProcessor.cuh"
#include "device/DeviceInfo.cuh"
#include "open_cv/OpenCVFunctions.h"
#include "helper/HelperFunctions.cuh"
#include <cstdlib>

int main(int argc, char **argv) {
    if (argc != 4) {
        std::cerr << "Usage: " << argv[0] << " <mode> <file_name>\n";
        return 1;
    }
    const std::string &input_picture_path = argv[1];
    const std::string &output_file_path = argv[2];
    int num_trials = atoi(argv[3]);
    ImageProcessor imageProcessor;
    OpenCVFunctions openCvFunctions;
    std::vector<ProcessingInfo> processingInfos;

    for (int run_id = 1; run_id <= num_trials; ++run_id) {
        imageProcessor.ProcessImageCUDA(input_picture_path, output_file_path,
                                        true, run_id, processingInfos);

        imageProcessor.ProcessImageCPU(input_picture_path, output_file_path,
                                       false, run_id, processingInfos);

        openCvFunctions.ProcessImage(input_picture_path, output_file_path,
                                     processingInfos, run_id);
    }
    HelperFunctions::WriteSummaryToCSV(processingInfos, output_file_path + "summary.csv");

    return 0;
}
