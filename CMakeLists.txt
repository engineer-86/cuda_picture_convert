cmake_minimum_required(VERSION 3.18.4)
project(cuda_test LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

if (WIN32)
    set(OpenCV_DIR "C:/opencv/build/")
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
        open_cv/OpenCVFunctions.cpp
        open_cv/OpenCVFunctions.h
        helper/HelperFunctions.cu
        helper/HelperFunctions.cuh
        image-processing/ProcessingInfo.cu
        image-processing/ProcessingInfo.cuh
)

set_target_properties(cuda_test PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)

target_link_libraries(cuda_test PUBLIC ${OpenCV_LIBS})
if (OpenMP_CXX_FOUND)
    target_link_libraries(cuda_test PUBLIC OpenMP::OpenMP_CXX)
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
