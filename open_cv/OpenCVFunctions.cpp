//
// Created by Konrad Münch on 12.12.2023.
//

#include <opencv2/imgcodecs.hpp>
#include "OpenCVFunctions.h"
#include "../image-processing/ProcessingInfo.cuh"

OpenCVFunctions::OpenCVFunctions() : total_time_blur_(0.0),
                                     total_time_hsv_(0.0),
                                     mode_("OPENCV"),
                                     output_kind_("RGB") {

}

OpenCVFunctions::~OpenCVFunctions() {}


ProcessingInfo OpenCVFunctions::rgbToBlurOpenCV(int runId) {
    auto start = std::chrono::high_resolution_clock::now();
    cv::blur(this->image_rgb_, this->image_blur_, cv::Size(10, 10));
    auto finish = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(finish - start).count();
    this->AddTimeToBlur(duration);
    //   this->SetTotalTimeBlur(duration);

    return ProcessingInfo(runId, "blur", "OPENCV", duration);
}

ProcessingInfo OpenCVFunctions::rgbToHsvOpenCV(int runId) {
    auto start = std::chrono::high_resolution_clock::now();
    cv::cvtColor(this->image_rgb_, this->image_hsv_, CV_BGR2HSV);
    auto finish = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(finish - start).count();
    this->AddTimeToHSV(duration);
    //  this->SetTotalTimeHSV(duration);

    return ProcessingInfo(runId, "hsv", "OPENCV", duration);
}

void OpenCVFunctions::SetTotalTime(double total_time) {
    this->total_time_hsv_ += total_time;
}

double OpenCVFunctions::getTotalTimeHSV() {
    return this->total_time_hsv_;
}

double OpenCVFunctions::getTotalTimeBlur() {
    return this->total_time_blur_;
}


void OpenCVFunctions::SetTotalTimeBlur(double total_time) {
    this->total_time_blur_ += total_time;
}

double OpenCVFunctions::LoadImage(const std::string &file_path) {
    this->image_rgb_ = cv::imread(file_path, cv::IMREAD_UNCHANGED);
    if (image_rgb_.empty()) {
        throw std::runtime_error("Error: Unable to read the image file.");
    }
    rows_ = image_rgb_.rows;
    columns_ = image_rgb_.cols;
}

void OpenCVFunctions::SaveImage(const std::string &file_path, const std::string &output_kind) {
    std::string calc_mode = "openCV";

    if (output_kind == "blur") {
        cv::imwrite(file_path + calc_mode + "_" + "blur.jpeg", this->image_blur_);
    } else if
            (output_kind == "hsv") {
        cv::imwrite(file_path + calc_mode + "_"  "hsv.jpeg", this->image_hsv_);
    } else {
        cv::imwrite(file_path + calc_mode + "_"  "rgb.jpeg", this->image_rgb_);
    }
}

void OpenCVFunctions::ProcessImage(const std::string &input_picture_path,
                                   const std::string &output_picture_path,
                                   std::vector<ProcessingInfo> &processingInfos, int runId) {
    this->LoadImage(input_picture_path);


    auto infoHSV = this->rgbToHsvOpenCV(runId);
    this->SaveImage(output_picture_path, "hsv");
    processingInfos.push_back(infoHSV);


    auto infoBlur = this->rgbToBlurOpenCV(runId);
    this->SaveImage(output_picture_path, "blur");
    processingInfos.push_back(infoBlur);
}


void OpenCVFunctions::AddTimeToBlur(double time) {
    single_times_blur_.push_back(time);
}

void OpenCVFunctions::AddTimeToHSV(double time) {
    single_times_hsv_.push_back(time);
}

std::vector<double> OpenCVFunctions::GetTimesBlur() const {
    return single_times_blur_;
}

std::vector<double> OpenCVFunctions::GetTimesHSV() const {
    return single_times_hsv_;
}


const std::string &OpenCVFunctions::getMode() const {
    return mode_;
}

void OpenCVFunctions::setMode(const std::string &mode) {
    mode_ = mode;
}

const std::string &OpenCVFunctions::getOutputKind() const {
    return output_kind_;
}

void OpenCVFunctions::setOutputKind(const std::string &outputKind) {
    output_kind_ = outputKind;
}
