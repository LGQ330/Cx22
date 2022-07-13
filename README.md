# Cx22



## Download

### Source Images

```
Step 1: download the data source images at the following link and unzip the "png.zip" as the source directory
```

* [Images](https://mailustceducn-my.sharepoint.com/personal/nachifur_mail_ustc_edu_cn/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fnachifur%5Fmail%5Fustc%5Fedu%5Fcn%2FDocuments%2Fpaper%5Fshare%2FLLPC%2FCCEDD%2Ezip&parent=%2Fpersonal%2Fnachifur%5Fmail%5Fustc%5Fedu%5Fcn%2FDocuments%2Fpaper%5Fshare%2FLLPC&ga=1)

### Labels

```
Step 2: download the label datasets Cx22-*.
```

* [Cx22-Pair](https://github.com/LGQ330/Cx22/blob/main/Cx22-Pair.zip)

* [Cx22-Multi-Train]()                                ~ link will be made available here once our paper is accepted. 

* [Cx22-Multi-Test]()                                 ~ link will be made available here once our paper is accepted. 

  ```
  The paper submission information is as follows:
  
  ```

## Dataset Generation

### Unzip

```
Step 3: unzip the label dataset Cx22-* that downloaded in Step 2. And the folders will be of the following structure:

Cx22-*:    
    * cyto
    	- cyto_clumps.mat		 ~ the labels of cytoplasm clumps
    	- cyto_ins.mat			 ~ the labels of cytoplasm instances
    	- cyto_ins_bbox.mat		 ~ the bounding-box labels of cytoplasm instances
    	
    * nuc
    	- nuc_clumps.mat		 ~ the labels of nucleus clumps
    	- nuc_ins.mat			 ~ the labels of nucleus instances
    	- nuc_ins_bbox.mat 		 ~ the bounding-box labels of nucleus instances
    	
    * generator
    	- ImageDataGenerator.m	 ~ image generation codes
    	- ImageDataNames.mat	 ~ service for ImageDataGenerator.m
    	- ROIs_W_H.mat			~ service for ImageDataGenerator.m
    	- ROIs_x_y.mat			~ service for ImageDataGenerator.m
    	
    - CellNum.mat			    ~ number of cells in each generated image
    - OverlapRatio.mat			~ overlap ratio of each cytoplasm instance in each generated image
```
### Image Generation

```
Step 4: 
	First: run "ImageDataGenerator.m"
	Then: select the source directory created in Step 1
	Finally: waiting until the "ImageDataSet.mat" is generated. "ImageDataSet.mat" will be saved in the same directory of "ImageDataGenerator.m". "ImageDataSet.mat" records the images corresponding to the labels.
```
## Citation

If you find our work useful in your research, please consider citing:
```
The information will be made available here once our paper is accepted. The paper submission information is as follows:
```

## Terms of use

Terms of use: by downloading the Cx22 you agree to the following term:

- You will use the data only for non-commercial research and educational purposes.

## Contact

Please contact liuchee@mail.ustc.edu.cn if there is any question.
