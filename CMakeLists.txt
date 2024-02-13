cmake_minimum_required(VERSION 3.18.4)
project(cuda_test LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

if (WIN32)
    set(OpenCV_DIR "C:/opencv/build/")
    set(NVML_LIB_PATH "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.2/lib/x64/nvml.lib")

elseif (UNIX AND NOT APPLE)
    set(OpenCV_DIR "/usr/local/lib/cmake/opencv4")
endif ()

find_package(OpenCV REQUIRED)
find_package(OpenMP REQUIRED)

include_directories(${OpenCV_INCLUDE_DIRS})

add_executable(
        cuda_test main.cu
        device/DeviceInfo.cu
        image-processing/ImageProcessor.cu
        image-processing/ImageProcessor.cuh
        device/DeviceKernel.cu
        device/DeviceKernel.cuh
        image-processing/ImageProcessorHelper.cu
        image-processing/ImageProcessorHelper.cuh
        host/HostSystem.cu
        host/HostSystem.cuh
        helper/HelperFunctions.cu
        helper/HelperFunctions.cuh
        image-processing/ProcessingInfo.cu
        image-processing/ProcessingInfo.cuh
        helper/GpuPowerMonitor.cuh
        helper/GpuPowerMonitor.cu
        helper/GpuPowerMonitorThread.cu
        helper/GpuPowerMonitorThread.cuh

)

set_target_properties(cuda_test PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)

target_link_libraries(cuda_test PUBLIC ${OpenCV_LIBS} ${NVML_LIB_PATH})

if (OpenMP_CXX_FOUND)
    target_link_libraries(cuda_test PUBLIC OpenMP::OpenMP_CXX)
    if (UNIX)
        target_compile_options(cuda_test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler -fopenmp>)
    elseif (WIN32)
        target_compile_options(cuda_test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler /openmp>)
    endif ()
endif ()

if (NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 52)
endif ()

if (UNIX)
    set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler -W -Wall")
endif ()

set_target_properties(cuda_test PROPERTIES CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")

if (MSVC)
    string(REGEX REPLACE "/W[0-9]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif ()
