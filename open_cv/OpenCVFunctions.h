//
// Created by arox on 12.12.2023.
//

#ifndef CUDA_TEST_OPENCVFUNCTIONS_H
#define CUDA_TEST_OPENCVFUNCTIONS_H


#include <opencv2/core/mat.hpp>
#include <chrono>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgproc/types_c.h>
#include <opencv2/imgproc/imgproc.hpp>
#include "../image-processing/ProcessingInfo.cuh"

class OpenCVFunctions {


private:
    double total_time_blur_;
    double total_time_hsv_;
    std::vector<double> single_times_blur_;
    std::vector<double> single_times_hsv_;
    cv::Mat image_blur_;
    cv::Mat image_hsv_;
    cv::Mat image_rgb_;
    int rows_;
    int columns_;
    std::string mode_;

public:
    const std::string &getMode() const;

    void setMode(const std::string &mode);

    const std::string &getOutputKind() const;

    void setOutputKind(const std::string &outputKind);

private:
    std::string output_kind_;

public:

    OpenCVFunctions();

    ~OpenCVFunctions();

    std::vector<double> GetTimesBlur() const;

    std::vector<double> GetTimesHSV() const;

    void AddTimeToBlur(double time);

    void AddTimeToHSV(double time);

    double getTotalTimeHSV();

    double getTotalTimeBlur();

    void SetTotalTime(double total_time);

    void SetTotalTimeBlur(double total_time);

    double LoadImage(const std::string &file_path);

    void SaveImage(const std::string &file_path, const std::string &output_kind);

    ProcessingInfo rgbToHsvOpenCV(int runId);

    ProcessingInfo rgbToBlurOpenCV(int runId);

    void ProcessImage(const std::string &input_picture_path, const std::string &output_picture_path,
                      std::vector<ProcessingInfo> &processingInfos, int runId);

};

#endif //CUDA_TEST_OPENCVFUNCTIONS_H
