## Project Overview

This project is designed to showcase advanced image processing techniques using CUDA, a parallel computing platform and
API model created by Nvidia. It focuses on applying HSV (Hue, Saturation, Value) conversion and blurring effects to
images, leveraging the power of GPU for accelerated processing. The application is structured to compare the performance
of CUDA-based processing against traditional CPU methods and OpenCV implementations. This comparison is vital in
understanding the efficiency gains offered by GPU processing in the field of image manipulation and computer vision
tasks.

### HSV, BLUR

- CUDA Implementation:

  Load an image and perform HSV (Hue, Saturation, Value) conversion.
  Apply a blur effect using CUDA for parallel processing.


- Sequential Comparison:

  Implement a CPU-based sequential approach for the same image processing tasks (HSV conversion and blurring).
  This serves as a benchmark to compare against the CUDA implementation.


- OpenCV Utilization:

  Employ OpenCV for both HSV conversion and blurring tasks.
  Generate comparative values to evaluate the performance of CUDA and CPU implementations.

### Code style guidelines

Following the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html#Naming):

| Element                | Notation                            | Example               |
|------------------------|-------------------------------------|-----------------------|
| Classes                | CamelCase                           | `MyExcitingClass`     |
| Methods                | CamelCase                           | `MyExcitingMethod()`  |
| Class Member Functions | CamelCase                           | `MyExcitingMethod()`  |
| Variables              | snake_case                          | `my_variable`         |
| Class Members          | snake_case with trailing underscore | `my_member_variable_` |

### Configuration

1. **Prepare**:
    - Open a terminal session and navigate to your project directory.
    - Issue the command to create a new directory for the output files:
      ```bash
      mkdir build
      ```
    - Navigate to the `build` directory with the command:
      ```bash
      cd build
      ```

2. **Build**:
    - Issue the command to generate the build files:
      ```bash
      cmake ..
      ```
    - Then go back to parent folder and issue the command to build the project:
      ```bash
      make
      ```

   Now the executable files are ready.


3. **Program arguments**:

- `input_picture_path`: Specify the path to the input image. It can be absolute or relative to the executable,
  e.g., `pictures/harold_in.jpg`.
- `output_picture_path`: Specify the path for saving output images and logs.
- `runs`: Define the number of iterations to run each image processing operation.

4. **Run the program**:

    - Execute the binary file with the arguments for LINUX:
      ```bash
      ./cuda_test pictures/harold.jpeg /output 1 
      ```

    - Execute the binary file with the arguments for WINDOWS:
         ```bash
         .\cuda_test.exe C:\coding\htw\cuda_hsv_blur\pictures\harold.jpeg C:\coding\htw\cuda_hsv_blur\output\ 1
         ```

5. **Results**:

The pictures for each technology (CUDA,CPU and OPENCV) will be saved under the output path.
A summary with all metrics will be created under the output path in format csv.

## Statistics and Plots

This Python script provides an easy way to generate visualizations and summary statistics from a CSV file containing
performance data for image processing technologies.

### Requirements Installation

Before running the script, you need to install the required Python (Python3.10 is recommended !) libraries listed
in `requirements.txt`. You can install these dependencies using the following command:

```bash
pip install -r requirements.txt
```

### How to Use the Script

```bash
python statistics.py /path/to/input/data.csv /path/to/output/directory
```

### Generated Outputs

`all_means.png`: Bar plot image file of the mean times.

`dot_plot.png`: Dot plot image file of times for all technologies.

`stats.csv`: CSV file with summary statistics of times.

