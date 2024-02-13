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

    csvFile << "ID(RUN),Timestamp,Mode,Technology,Execution times(s),Power(Watts)\n";

    for (const auto &item: data) {
        csvFile << item.runId << "," << item.timestamp << "," << item.kind << "," << item.technology <<
                "," << std::fixed << std::setprecision(7) << item.time << "," << item.power << "\n";
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


std::string HelperFunctions::getCurrentTimestamp() {

    auto now = std::chrono::system_clock::now();

    auto now_c = std::chrono::system_clock::to_time_t(now);
    std::tm now_tm = *std::localtime(&now_c);
    auto now_ms = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()) % 1000;

    std::stringstream ss;
    ss << std::put_time(&now_tm,
                        "%H:%M:%S") << '.' << std::setfill('0') << std::setw(3) << now_ms.count();

    return ss.str();
}