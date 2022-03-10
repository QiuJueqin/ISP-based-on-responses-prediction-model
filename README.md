## 简介

本仓库提供了我的博士论文[《基于原始响应值预测模型的数码相机图像信号处理方法与技术研究》](thesis.pdf)相关代码及实验数据

## 数据

所有数据存储于 OneDrive，合计约129GB。若无特别说明则均含有 Nikon D3x 与 SONY ILCE7 两台相机的 raw 数据及实验结果

- [噪声标定](https://1drv.ms/u/s!AniPeh_FlASDhmCI5AXdhKiJpYMZ?e=iL36AM)（41.3GB）
- [原始响应值预测](https://1drv.ms/u/s!AniPeh_FlASDhmLCEpMaGO9TlcgP?e=eZuJNf)（78.6GB）
- [空间非均匀性标定](https://1drv.ms/u/s!AniPeh_FlASDhl98vdIwhpr601gX?e=jmuGF2)（139MB，仅含 Nikon D3x）
- [自动白平衡](https://1drv.ms/u/s!AniPeh_FlASDhmESwk9tooJqmpuF?e=wDhiHi)（8.2GB，仅含 Nikon D3x）
- [颜色校正](https://1drv.ms/u/s!AniPeh_FlASDhl0S20CELt5yBY45?e=YOkyrE)（1.2GB）
- [高光谱图像](https://1drv.ms/u/s!AniPeh_FlASDhl51MDpnAQYmuod7?e=2D7elO)（352MB，收集自公开数据集）


## 测试环境

- Windows 10
- MATLAB R2018a/R2018b


### MATLAB 所需工具箱

- Computer Vision System Toolbox
- Curve Fitting Toolbox
- Image Processing Toolbox
- Optimization Toolbox
- Parallel Computing Toolbox
- Statistics and Machine Learning Toolbox



## 更新日志

- 2020.05.18 - 上传数据
- 2019.12.18 - 定稿
- 2019.12.17 - 根据答辩组意见进行修改
- 2019.12.04 - 根据盲审意见进行修改
- 2019.07.04 - 完成论文初稿


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


## Data

All data is stored in OneDrive, with total size of 129GB.

- [Noise calibration](https://1drv.ms/u/s!AniPeh_FlASDhmCI5AXdhKiJpYMZ?e=iL36AM) (41.3GB, Nikon D3x and SONY ILCE7)
- [Response prediction](https://1drv.ms/u/s!AniPeh_FlASDhmLCEpMaGO9TlcgP?e=eZuJNf) (78.6GB, Nikon D3x and SONY ILCE7)
- [Non-uniformity correction](https://1drv.ms/u/s!AniPeh_FlASDhl98vdIwhpr601gX?e=jmuGF2) (139MB, only Nikon D3x)
- [Auto white-balance](https://1drv.ms/u/s!AniPeh_FlASDhmESwk9tooJqmpuF?e=wDhiHi) (8.2GB, only Nikon D3x)
- [Color correction](https://1drv.ms/u/s!AniPeh_FlASDhl0S20CELt5yBY45?e=YOkyrE) (1.2GB, Nikon D3x and SONY ILCE7)
- [Hyperspectral images](https://1drv.ms/u/s!AniPeh_FlASDhl51MDpnAQYmuod7?e=2D7elO) (352MB, collected from public datasets)


## Test Environment

- Windows 10
- MATLAB R2018a/R2018b


### Required MATLAB Toolboxes

- Computer Vision System Toolbox
- Curve Fitting Toolbox
- Image Processing Toolbox
- Optimization Toolbox
- Parallel Computing Toolbox
- Statistics and Machine Learning Toolbox



## ChangeLog

- 2020.05.18 - upload data
- 2019.12.18 - thesis completed
- 2019.12.17 - revised as per comments by examining committee
- 2019.12.04 - revised as per comments by anonymous reviewers
- 2019.07.04 - initial draft completed


## License

Copyright 2019 Qiu Jueqin

Licensed under [GPL-3.0](http://www.gnu.org/licenses/).
