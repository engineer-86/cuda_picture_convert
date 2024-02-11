//
// Created by Konrad Münch on 04.11.2023.
//

#ifndef CUDA_TEST_IMAGEPROCESSOR_CUH
#define CUDA_TEST_IMAGEPROCESSOR_CUH

#include <opencv2/core.hpp>
#include <opencv2/opencv.hpp>
#include <string>
#include "ProcessingInfo.cuh"

class ImageProcessor {

private:
    cv::Mat image_rgb_;
    cv::Mat image_hsv_;
    cv::Mat image_blur_;
    int rows_;
    int columns_;
    double total_time_blur_;
    double total_time_hsv_;
    std::vector<double> single_times_cuda_blur_;
    std::vector<double> single_times_cuda_hsv_;
    std::string mode_;

public:
    const std::string &getMode() const;

    void setMode(const std::string &mode);

    const std::string &getOutputKind() const;

    void setOutputKind(const std::string &outputKind);

private:
    std::string output_kind_;

public:
    ImageProcessor();

    ~ImageProcessor();

    void ProcessImageCUDA(const std::string &input_picture_path,
                          const std::string &output_picture_path,
                          bool is_gpu_available, int runId,
                          std::vector<ProcessingInfo> &infos);

    void ProcessImageCPU(const std::string &input_picture_path,
                         const std::string &output_picture_path,
                         bool is_gpu_available, int runId,
                         std::vector<ProcessingInfo> &infos);

    void LoadImage(const std::string &file_name);

    void SaveImage(const std::string &file_path, const std::string &output_kind, bool mode);

    [[nodiscard]] const cv::Mat &GetImage() const;

    ProcessingInfo ConvertRGBtoHSVCuda(int runId);

    ProcessingInfo ConvertRGBtoHSVHost(int runId);

    ProcessingInfo AddBoxBlurCuda(int runId);

    ProcessingInfo AddBoxBlurHost(int runId);

    std::vector<uchar3> ImageToVector();

    std::vector<double> GetTimesCUDABlur() const;

    std::vector<double> GetTimesCUDAHSV() const;

    void AddTimeToCUDABlur(double time);

    void AddTimeToCUDAHSV(double time);

    std::vector<double> GetTimesCPUBlur() const;

    std::vector<double> GetTimesCPUHSV() const;

    void AddTimeToCPUBlur(double time);

    void AddTimeToCPUHSV(double time);


    double getTotalTimeBlur() const;

    double getTotalTimeHSV() const;

    void SetTotalTimeBlur(double total_time);

    void SetTotalTimeHSV(double total_time);

    template<typename T>
    void VectorToImage(const std::vector<T> &output, const std::string &convert_mode);
};

#endif //CUDA_TEST_IMAGEPROCESSOR_CUH
