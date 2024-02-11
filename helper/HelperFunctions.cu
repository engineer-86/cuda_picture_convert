//
// Created by Konrad Münch on 12.12.2023.
//

#include "HelperFunctions.cuh"
#include <fstream>
#include <fstream>
#include <iomanip>

void HelperFunctions::WriteSummaryToCSV(const std::vector<ProcessingInfo> &data, const std::string &csvFilePath) {
    std::ofstream csvFile;
    csvFile.open(csvFilePath);

    csvFile << "ID(RUN),Mode,Technology,Times(s)\n";

    for (const auto &item: data) {
        csvFile << item.runId << "," << item.kind << "," << item.technology <<
                "," << std::fixed << std::setprecision(7) << item.time << "\n";
    }

    csvFile.close();
}


void HelperFunctions::calcExecutionTimeImageProcessor(const ImageProcessor &imageProcessorTime, int trials,
                                                      bool gpu_available) {
    std::string device = "CUDA";
    if (!gpu_available) { device = "CPU"; }

    std::string average_duration_hsv = "Average " + device + " duration for HSV: " +
                                       std::to_string(imageProcessorTime.getTotalTimeHSV() / trials) +
                                       " Seconds";

    std::string average_duration_blur = "Average " + device + " duration for BLUR: " +
                                        std::to_string(imageProcessorTime.getTotalTimeBlur() / trials) +
                                        " Seconds";

    std::cout << average_duration_hsv + "\n" + average_duration_blur << std::endl;
}

void HelperFunctions::calcExecutionTimeOpenCV(OpenCVFunctions &imageProcessorTimeCV, int trials) {
    std::string device = "OPENCV";


    std::string average_duration_hsv = "Average " + device + " duration for HSV: " +
                                       std::to_string(imageProcessorTimeCV.getTotalTimeHSV() / trials) +
                                       " Seconds";

    std::string average_duration_blur = "Average " + device + " duration for BLUR: " +
                                        std::to_string(imageProcessorTimeCV.getTotalTimeBlur() / trials) +
                                        " Seconds";

    std::cout << average_duration_hsv + "\n" + average_duration_blur << std::endl;
};
