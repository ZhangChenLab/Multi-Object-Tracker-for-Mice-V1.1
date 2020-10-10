# Multi-Object Tracker for Mice (MOT-Mice)
**Keywords: Multi-object tracking, Multicamera, Mouse group, Deep learning, Object detection, Faster R-CNN, Tracklets fusion** <br>
Zhang Chen Lab, Capital Medical University

## Introduction
Multi-Object Tracker for Mice (MOT-Mice) system uses the Faster R-CNN deep learning algorithm with geometric transformations in combination with multicamera/multi-image fusion technology to track individual unmarked mice.
MOT-Mice wsystem includes primary (a top-view) camera and auxiliary (multiple side-view) cameras.

## File description
***code***: Function liberary.  <br>
***CameraCalibration***: Checkboard images and code used for camera calibration. <br>
***model***: Trained trace prediction model, and mouse detection models for mouse detection (***Download from cloud disk first***). <br>
***Videos of mouse group***: Multicamera videos of mouse group (***Download from cloud disk first***). Top-view camera: camera4. Side-view cameras: camera1,2,3. <br>
***imgs***: Descriptional images.  <br>

## Configuration
MOT-Mice was developed and tested on MATLAB R2019b using an Nvidia GeForce GTX 1080 Ti GPU with 11 GB memory.

## Run the MOT-Mice system
#### Camera calibration
Processing the files in the folder of ***CameraCalibration***. <br>
Run ***CameraCalibration_V1.m*** to achieve camera calibration. <br>
<img src="imgs/CameraCalibration-2.png" height="150px" width="auto"/> 

#### Mouse detection (MOT-OD) and identity pairing (MOT-IP)
Processing the files in the folder of ***Videos of mouse group***. <br>
First, run ***Step1_MOT_ObjectDetect_IdPairing.m*** to detect all mouse individuals and generate tracklets.  <br>
<img src="imgs/MOT_OD .png" height="150px" width="auto"/>    <br>
Second, run ***Step2_MOT_SingleCameraFusion.m*** to fuse tracklets for each camera.  <br>
<img src="imgs/MOT_IP.png" height="160px" width="auto"/>    <br>
Third, run ***Step3_MOT_MultiCameraFusion.m*** to fuse tracklets using multicamera.  <br>

#### Postprocessing by manual checking and correction (MOT-CC)
