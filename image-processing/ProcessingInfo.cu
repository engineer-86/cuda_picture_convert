//
// Created by Konrad Münch on 13.12.2023.
//



#include "ProcessingInfo.cuh"

ProcessingInfo::ProcessingInfo(int runId, std::string timestamp, const std::string &kind, const std::string &technology,
                               double time,
                               double power = 0.0)
        : runId(runId), timestamp(timestamp), kind(kind), technology(technology), time(time), power(power) {
}

