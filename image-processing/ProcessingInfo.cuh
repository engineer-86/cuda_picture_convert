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
    double time;

    ProcessingInfo(int runId, const std::string &kind,
                   const std::string &technology,
                   double time);
};

#endif // CUDA_TEST_PROCESSINGINFO_CUH

