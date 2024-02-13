//
// Created by Konrad Münch on 13.12.2023.
//

#ifndef CUDA_TEST_PROCESSINGINFO_CUH
#define CUDA_TEST_PROCESSINGINFO_CUH

#include <string>

class ProcessingInfo {
public:
    int runId;
    std::string kind;
    std::string technology;
    float time;
    float power;
    std::string timestamp;

    ProcessingInfo(int runId, std::string timestamp, const std::string &kind,
                   const std::string &technology,
                   double time, double power);
};

#endif // CUDA_TEST_PROCESSINGINFO_CUH

