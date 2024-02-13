//
// Created by Konrad Münch on 12.12.2023.
//

#include "../image-processing/ImageProcessor.cuh"
#include "../image-processing/ProcessingInfo.cuh"

#ifndef CUDA_TEST_HELPERFUNTIONS_CUH
#define CUDA_TEST_HELPERFUNTIONS_CUH

class HelperFunctions {
public:
    static void
    calcExecutionTimeImageProcessor(const ImageProcessor &imageProcessorTime, int trials, bool gpu_available);

    static void WriteSummaryToCSV(const std::vector<ProcessingInfo> &data, const std::string &csvFilePath);

    static std::string HelperFunctions::getCurrentTimestamp();
    static void HelperFunctions::showAvailableOmpThreads();
    static void HelperFunctions::setOmpThreads(int num_threads);
};

#endif //CUDA_TEST_HELPERFUNTIONS_CUH
