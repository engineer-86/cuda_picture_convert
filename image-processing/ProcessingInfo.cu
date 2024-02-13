//
// Created by Konrad Münch on 13.12.2023.
//



#include "ProcessingInfo.cuh"

ProcessingInfo::ProcessingInfo(int runId, const std::string &kind, const std::string &technology, double time,
                               double power = 0.0)
        : runId(runId), kind(kind), technology(technology), time(time), power(power) {
}

