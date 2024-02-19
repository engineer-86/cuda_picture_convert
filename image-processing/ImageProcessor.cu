//
// Created by Konrad Münch on 04.11.2023.
//

#include "ImageProcessor.cuh"
#include <iostream>
#include "../device/DeviceKernel.cuh"
#include <chrono>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/types_c.h>
#include "../host/HostSystem.cuh"
#include "../helper/GpuPowerMonitor.cuh"
#include "../helper/HelperFunctions.cuh"
#include "../helper/GpuPowerMonitorThread.cuh"


ImageProcessor::ImageProcessor() : total_time_blur_(0.0),
                                   total_time_hsv_(0.0),
                                   mode_("CPU"),
                                   output_kind_("RGB") {

}

ImageProcessor::~ImageProcessor() {}

void ImageProcessor::LoadImage(const std::string &file_name) {
    this->image_rgb_ = cv::imread(file_name, cv::IMREAD_UNCHANGED);
    if (image_rgb_.empty()) {
        throw std::runtime_error("Error: Unable to read the image file.");
    }
    rows_ = image_rgb_.rows;
    columns_ = image_rgb_.cols;
}


void ImageProcessor::SaveImage(const std::string &file_path, const std::string &output_kind, bool mode) {
    std::string calc_mode = mode ? "cuda" : "cpu";

    if (output_kind == "blur") {
        cv::imwrite(file_path + calc_mode + "_" + "blur.jpeg", this->image_blur_);
    } else if
            (output_kind == "hsv") {
        cv::imwrite(file_path + calc_mode + "_"  "hsv.jpeg", this->image_hsv_);
    } else {
        cv::imwrite(file_path + calc_mode + "_"  "rgb.jpeg", this->image_rgb_);
    }
}

const cv::Mat &ImageProcessor::GetImage() const {
    return this->image_rgb_;
}

void ImageProcessor::ProcessImageCUDA(const std::string &input_picture_path,
                                      const std::string &output_picture_path,
                                      bool is_gpu_available, int runId,
                                      std::vector<ProcessingInfo> &infos) {


    std::cout << "Try to load Image: " << input_picture_path << std::endl;
    this->LoadImage(input_picture_path);

    std::cout << "Convert Pictures to HSV and BLUR with GPU." << std::endl;
    infos.push_back(this->ConvertRGBtoHSVCuda(runId));
    infos.push_back(this->AddBoxBlurCuda(runId));


    std::cout << "Save Image: " << output_picture_path << std::endl;
    this->SaveImage(output_picture_path, "hsv", is_gpu_available);
    this->SaveImage(output_picture_path, "blur", is_gpu_available);;
}

void ImageProcessor::ProcessImageCPU(const std::string &input_picture_path,
                                     const std::string &output_picture_path,
                                     bool is_gpu_available, int runId,
                                     std::vector<ProcessingInfo> &infos) {

    std::cout << "Try to load Image: " << input_picture_path << std::endl;
    this->LoadImage(input_picture_path);

    std::cout << "Convert Pictures to HSV and BLUR with CPU." << std::endl;
    infos.push_back(this->ConvertRGBtoHSVHost(runId));
    infos.push_back(this->AddBoxBlurHost(runId));


    std::cout << "Save Image: " << output_picture_path << std::endl;
    this->SaveImage(output_picture_path, "hsv", is_gpu_available);
    this->SaveImage(output_picture_path, "blur", is_gpu_available);
}

ProcessingInfo ImageProcessor::ConvertRGBtoHSVCuda(int runId) {

    cv::Mat image = this->GetImage();
    int width = this->columns_;
    int height = this->rows_;
    uchar3 *d_input;
    float3 *d_output;


    cudaMalloc(&d_input, width * height * sizeof(uchar3));
    cudaMalloc(&d_output, width * height * sizeof(float3));
    cudaMemcpy(d_input, image.ptr<uchar>(0), width * height * sizeof(uchar3),
               cudaMemcpyHostToDevice);

    dim3 blockSize(32, 32);
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);


    cudaEvent_t start, stop;
    float duration;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord( start, 0 );

    auto start_time = std::chrono::high_resolution_clock::now();
    GpuPowerMonitorThread gpuPowerMonitorThread;
    gpuPowerMonitorThread.startMonitoring();

    // 8.1.2. Using CUDA GPU Timers
    // https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html

    ConvertRGBtoHSVKernel<<<gridSize, blockSize>>>(d_input, d_output, width, height);

    cudaEventRecord( stop, 0 );
    cudaEventSynchronize( stop );
    cudaEventElapsedTime(&duration, start, stop );
    cudaEventDestroy( start );
    cudaEventDestroy( stop );

    auto finish = std::chrono::high_resolution_clock::now();

    this->AddTimeToCUDAHSV(duration);
    this->SetTotalTimeHSV(duration);

    cudaGetLastError();
    cudaDeviceSynchronize();
    // stop power measure thread
    gpuPowerMonitorThread.stopMonitoring();


    auto timestamp = HelperFunctions::getCurrentTimestamp();

    cv::Mat hsv_image(height, width, CV_32FC3);
    cudaMemcpy(hsv_image.ptr<float>(0), d_output, width * height * sizeof(float3),
               cudaMemcpyDeviceToHost);

    cudaFree(d_input);
    cudaFree(d_output);

    this->image_hsv_ = hsv_image;
    auto powers = gpuPowerMonitorThread.getPowerReadings();

    return ProcessingInfo(runId, timestamp, "hsv", "CUDA", duration,
                          gpuPowerMonitorThread.getPowerReadings());
}

#include <chrono>


ProcessingInfo ImageProcessor::AddBoxBlurCuda(int runId) {

    cv::Mat image = this->GetImage();
    int width = this->columns_;
    int height = this->rows_;
    uchar3 *d_input;
    uchar3 *d_output;

    cudaMalloc(&d_input, width * height * sizeof(uchar3));
    cudaMalloc(&d_output, width * height * sizeof(uchar3));
    cudaMemcpy(d_input, image.ptr<uchar>(0), width * height * sizeof(uchar3),
               cudaMemcpyHostToDevice);

    dim3 blockSize(32, 32);
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);


    auto start = std::chrono::high_resolution_clock::now();
    GpuPowerMonitor gpuPowerMonitor;
    float startPower = gpuPowerMonitor.getPowerUsage(0);

    AddBoxBlurKernel<<<gridSize, blockSize>>>(d_input, d_output, width, height);


    auto finish = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(finish - start).count();
    this->AddTimeToCUDABlur(duration);
    this->SetTotalTimeBlur(duration);

    cudaGetLastError();
    cudaDeviceSynchronize();
    float endPower = gpuPowerMonitor.getPowerUsage(0); // GPU-Index 0
    auto timestamp = HelperFunctions::getCurrentTimestamp();
    float averagePower = (startPower + endPower) / 2.0f;


    cv::Mat blurred_image(height, width, CV_8UC3);
    cudaMemcpy(blurred_image.ptr<float>(0), d_output, width * height * sizeof(uchar3),
               cudaMemcpyDeviceToHost);

    cudaFree(d_input);
    cudaFree(d_output);

    this->image_blur_ = blurred_image;


    return ProcessingInfo(runId, timestamp, "blur", "CUDA", duration, averagePower);

}


ProcessingInfo ImageProcessor::ConvertRGBtoHSVHost(int runId) {
    cv::Mat image = this->GetImage();
    int width = image.cols;
    int height = image.rows;

    std::vector<uchar3> input = this->ImageToVector();
    std::vector<float3> output(width * height);

    auto start = std::chrono::high_resolution_clock::now();

    ConvertRGBtoHSV(input.data(), output.data(), width, height);
    auto timestamp = HelperFunctions::getCurrentTimestamp();
    auto finish = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(finish - start).count();

    this->AddTimeToCPUHSV(duration);
    this->SetTotalTimeHSV(duration);


    this->VectorToImage(output, "hsv");
    return ProcessingInfo(runId, timestamp, "hsv", "CPU", duration, 0.0);
}

ProcessingInfo ImageProcessor::AddBoxBlurHost(int runId) {
    cv::Mat image = this->GetImage();
    int width = image.cols;
    int height = image.rows;

    std::vector<uchar3> input = this->ImageToVector();
    std::vector<uchar3> output(width * height);

    auto start = std::chrono::high_resolution_clock::now();

    AddBoxBlur(input.data(), output.data(), width, height);
    auto timestamp = HelperFunctions::getCurrentTimestamp();
    auto finish = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(finish - start).count();

    this->AddTimeToCPUBlur(duration);
    this->SetTotalTimeBlur(duration);
    this->VectorToImage(output, "blur");
    return ProcessingInfo(runId, timestamp, "blur", "CPU", duration, 0.0);
}


std::vector<uchar3> ImageProcessor::ImageToVector() {
    cv::Mat image = this->GetImage();
    int width = image.cols;
    int height = image.rows;

    // input and output vectors
    std::vector<uchar3> input(width * height);

    // convert mat-pic to cv vector with 2 nested for loops

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; x++) {
            cv::Vec3b pixel = image.at<cv::Vec3b>(y, x);
            input[y * width + x] = make_uchar3(pixel[2], pixel[1], pixel[0]); // BGR to RGB
        }
    }

    return input;
}

template<typename T>
void ImageProcessor::VectorToImage(const std::vector<T> &output, const std::string &convert_mode) {
    cv::Mat image = this->GetImage();
    int width = image.cols;
    int height = image.rows;


    cv::Mat *target_image = nullptr;
    if (convert_mode == "hsv") {
        target_image = &this->image_hsv_;
    } else if (convert_mode == "blur") {
        target_image = &this->image_blur_;
    }

    if (!target_image) {

        throw std::invalid_argument("Please provide convert mode: hsv or blur");
    }


    if (std::is_same<T, uchar3>::value) {
        *target_image = cv::Mat(height, width, CV_8UC3);
    } else if (std::is_same<T, float3>::value) {
        *target_image = cv::Mat(height, width, CV_32FC3);
    }


    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            T hsv = output[y * width + x];
            if (std::is_same<T, uchar3>::value) {
                target_image->at<cv::Vec3b>(y, x) = cv::Vec3b(hsv.x, hsv.y, hsv.z);
            } else if (std::is_same<T, float3>::value) {
                target_image->at<cv::Vec3f>(y, x) = cv::Vec3f(hsv.x, hsv.y, hsv.z);
            }
        }
    }
}

double ImageProcessor::getTotalTimeBlur() const {
    return total_time_blur_;
}

double ImageProcessor::getTotalTimeHSV() const {
    return total_time_hsv_;
}

void ImageProcessor::SetTotalTimeHSV(double total_time) {
    this->total_time_hsv_ += total_time;
}

void ImageProcessor::SetTotalTimeBlur(double total_time) {
    this->total_time_blur_ += total_time;
}

void ImageProcessor::AddTimeToCUDABlur(double time) {
    single_times_cuda_blur_.push_back(time);
}

void ImageProcessor::AddTimeToCUDAHSV(double time) {
    single_times_cuda_hsv_.push_back(time);
}

std::vector<double> ImageProcessor::GetTimesCUDABlur() const {
    return single_times_cuda_blur_;
}

std::vector<double> ImageProcessor::GetTimesCUDAHSV() const {
    return single_times_cuda_hsv_;
}

void ImageProcessor::AddTimeToCPUBlur(double time) {
    single_times_cuda_blur_.push_back(time);
}

void ImageProcessor::AddTimeToCPUHSV(double time) {
    single_times_cuda_hsv_.push_back(time);
}

std::vector<double> ImageProcessor::GetTimesCPUBlur() const {
    return single_times_cuda_blur_;
}

std::vector<double> ImageProcessor::GetTimesCPUHSV() const {
    return single_times_cuda_hsv_;
}

const std::string &ImageProcessor::getMode() const {
    return mode_;
}

void ImageProcessor::setMode(const std::string &mode) {
    mode_ = mode;
}

const std::string &ImageProcessor::getOutputKind() const {
    return output_kind_;
}

void ImageProcessor::setOutputKind(const std::string &outputKind) {
    output_kind_ = outputKind;
}

