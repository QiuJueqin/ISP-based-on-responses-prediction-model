## 简介

本仓库提供了我的博士论文[《基于原始响应值预测模型的数码相机图像信号处理方法与技术研究》](thesis.pdf)相关代码。



## 测试环境

* Windows 10

* MATLAB R2018b


### MATLAB 所需工具箱

```
* Computer Vision System Toolbox

* Curve Fitting Toolbox

* Image Processing Toolbox

* Optimization Toolbox

* Parallel Computing Toolbox

* Statistics and Machine Learning Toolbox
```


## 更新日志

* 2019.07.04 - 完成论文初稿

* 2019.12.04 - 根据盲审意见进行修改

* 2019.12.17 - 根据答辩组意见进行修改

* 2019.12.18 - 定稿



## 目录结构

```
.
+---chapter1
+---chapter2
|   +---colorimetry                         色度学基础
|   |   \---figures    
|   \---radiometry_photometry               辐射度学、光度学基础
|       \---figures    
+---chapter3    
|   +---camera_noise				    
|   |   +---calibration                     图像传感器噪声标定
|   |   |   \---figures    
|   |   \---correction                      噪声修正
|   |       \---figures    
|   \---imaging_simulation_model    
|       +---parameters_estimation           原始响应值构成模型参数估计
|       |   +---comparisons    
|       |   |   +---PCA    
|       |   |   \---RBFN    
|       |   \---figures    
|       \---preliminaries                   成像系统非线性特性预实验
|           \---figures    
+---chapter4    
|   +---color_correction                    颜色校正			
|   |   \---figures    
|   +---metamer_mismatching                 同色异谱与颜色失真
|   |   \---figures    
|   +---nonuniformity_correction            空间非均匀性校正
|   |   \---figures
|   +---post_processing
|   |   \---chromatic_adaptation_transform  色适应变换后处理
|   |       \---figures
|   \---white_balance_correction            自动白平衡（颜色恒常性）
|       +---comparisons    
|       |   +---figures    
|       |   +---grayedge    
|       |   \---weng    
|       +---gamut_mapping                   2D色域映射算法
|       |   +---figures    
|       |   \---utils    
|       +---neutral_pixels_statistics       中性色像素直方图统计算法
|       |   \---figures    
|       \---orthogonal_chromatic_plane      正交色度平面
+---chapter5    
|   +---luminance_estimation                场景亮度估计
|   +---neutral_region                      预设中性色区域选取
|   |   \---figures    
|   +---orthogonal_chromatic_plane          正交色度平面参数优化
|   |   \---figures    
|   \---standard_gamut                      设备相关标准色域计算
|       \---figures    
+---chapter6    
+---config                                  项目配置
+---data    
\---utils    
    +---cie_diagram                         色品图绘制
    +---export_fig                          矢量图导出工具
    +---legendflex                          图注工具
    \---regtool                             正则化工具
```

<br />

<br />

***

<br />

<br />

## Intro

This repository contains codes for my doctoral thesis: [*Study on methodology and technology of digital camera image signal processing based on raw responses prediction model*](thesis.pdf) (zh-cn).



## ChangeLog

* 2019.07.04 - initial draft completed

* 2019.12.04 - revised as per comments by anonymous reviewers

* 2019.12.17 - revised as per comments by examining committee

* 2019.12.18 - thesis completed


## License

Copyright 2019 Qiu Jueqin

Licensed under [GPL-3.0](http://www.gnu.org/licenses/).