function [meanDice70, ...
          FNR70_object, ...
          meanTPR70_pixel, ...
          meanFPR70_pixel, ...
          stdDice70, ...
          stdTPR70_pixel, ...
          stdFPR70_pixel, ...
          STDFNo_70] ...
          = evaluateCytoSegmentation(CytoGroundTruth, SegmentationResult)

%% Version: 0.10        Date: 02 January, 2014
%
% Function:
%          [meanDice70, ...
%           FNR70_object, ...
%           meanTPR70_pixel, ...
%           meanFPR70_pixel, ...
%           stdDice70, ...
%           stdTPR70_pixel, ...
%           stdFPR70_pixel, ...
%           STDFNo_70] ...
%           = evaluateCytoSegmentation(CytoGroundTruth, SegmentationResult)
%
% [Usage]:
%      CytoGroundTruth - Ground truth of Cytoplasm (Matlab Cell type, each member 
%                        represents an image).
%      SegmentationResult - Segmentation results of your algorithm (Matlab Cell 
%                        type, each member represents an image).
%
%      You need to write a script to call this function by the following rules:
%
%      1. "CytoGroundTruth" and "SegmentationResult" should have the same sequence 
%         in images, i.e., CytoGroundTruth(10,1) and SegmentationResult(10,1)
%         denote to the same image.
%
%      2. But the sequence of the cell masks in each image can be not the same,
%         since this function can automatically detect the qualified (Dice > 0.7)
%         cell mask in each image and match it with corresponding cell mask of 
%         ground truth in the same image. For example,
%               "CytoGroundTruth{10,1}{5,1}" and "SegmentationResult{10,1}{3,1}"
%               can denotes to the same cell.
%
%      3. If your algorithm misses some cell (false negative) in an image,
%         it does not affect the automatically cell mask matching process,
%         since we only consider the segmentation results with Dice > 0.7.
    
    %+---------------------------------+
    %| Load Segmentation Result, LSF_5 |
    %+---------------------------------+
    LSF_5 = SegmentationResult;

    %+---------------------------------+
    %|  Load Ground Truth of Cytoplasm |
    %+---------------------------------+
    TMI_TrainSet_Mask = CytoGroundTruth;

    %+-----------------------------------------+
    %| Cyto Ground Truth - Segmentation Result |
    %|                Matching                 |
    %+-----------------------------------------+
    MappingList_by_Image = cell(size(TMI_TrainSet_Mask,1),1);   % Mapping List Set: Cytoplasm Ground Truth - Segmentation Result
    for i = 1:size(TMI_TrainSet_Mask,1)
        CytoGTSet_i = TMI_TrainSet_Mask{i,1};   % Cytoplasm Ground Truth Set for image i
        CytoSRSet_i = LSF_5{i,1};               % Cytoplasm Segmentation Result Set for image i

        MappingList_i = zeros(1,2);             % Mapping List for image i: Cytoplasm Ground Truth - Segmentation Result
        id_mapping = 1;
        
        %+---------------------------+
        %| Matching List for image i |
        %+---------------------------+
        for j = 1:size(CytoGTSet_i,1)
            CytoGT_j = CytoGTSet_i{j,1};
            id_GT_j = find(CytoGT_j == 1);

            CompareList = [];
            numHitCell = 1;
            
            for k = 1:size(CytoSRSet_i,1)
                if ~ismember(k,MappingList_i(:,2))
                    id_SR_k = find(CytoSRSet_i{k,1} == 1);

                    CompareList(numHitCell,1) = (size(intersect(id_GT_j, id_SR_k),1) / size(union(id_GT_j, id_SR_k),1));
                    CompareList(numHitCell,2) = k;
                    numHitCell = numHitCell + 1;
                end
            end

            if ~isempty(CompareList)
                %+-----------------------------+
                %| If no match, False Negative |
                %+-----------------------------+
                if max(CompareList(:,1)) == 0
                    continue;
                end
                %+---------------------------+
                %| Argmax_k (CompareList(:)) |
                %+---------------------------+
                id_match_j_k = find(CompareList(:,1) == max(CompareList(:,1)));

                if size(id_match_j_k,1) > 1
                    id_match_j_k = id_match_j_k(1,1);
                end

                MappingList_i(id_mapping,1) = j;             % ID in Ground Truth
                MappingList_i(id_mapping,2) = CompareList(id_match_j_k,2);  % ID in Segmentation Result
                id_mapping = id_mapping + 1;
            end
        end
        %+-----------------------------+
        %|   Copy to Image Set Level   |
        %+-----------------------------+
        if isequal(MappingList_i, [0,0])
            continue;
        end
        MappingList_by_Image{i,1} = MappingList_i;
    end

    %+----------------------------------+
    %|      Compute Dice TPR, FPR       |
    %|          (Pixel Level)           |
    %+----------------------------------+
    Dice_by_Image = cell(size(TMI_TrainSet_Mask,1),1);      % Dice (ZSI)
    TPR_pixel_by_Image = cell(size(TMI_TrainSet_Mask,1),1); % True Positive Rate, pixel level
    FPR_pixel_by_Image = cell(size(TMI_TrainSet_Mask,1),1); % False Positive Rate, pixel level

    for i = 1:size(TMI_TrainSet_Mask,1)  
        MappingList_i = MappingList_by_Image{i,1};
        
        %+------------------------------+
        %|    If all cells are lost!    |
        %+------------------------------+
        if isequal(MappingList_i, [0,0]) || isempty(MappingList_i)
            num_i = size(TMI_TrainSet_Mask{i,1},1);
            for j = 1:num_i
                JI_by_Image{i,1}{j,1} = 0;
                Dice_by_Image{i,1}{j,1} = 0;
                TPR_pixel_by_Image{i,1}{j,1} = 0;
                FPR_pixel_by_Image{i,1}{j,1} = 0;
                FNR_pixel_by_Image{i,1}{j,1} = 1;
                TNR_pixel_by_Image{i,1}{j,1} = 1;
            end
        else
            for j = 1:size(MappingList_i,1)
                id_CytoGT_j = MappingList_i(j,1);
                id_CytoSR_j = MappingList_i(j,2);
                CytoGT_j = TMI_TrainSet_Mask{i,1}{id_CytoGT_j,1};
                CytoSR_j = LSF_5{i,1}{id_CytoSR_j,1};

                %+------------------------------------------------+
                %| Call the Multiple Measures Evaluation Function |
                %+------------------------------------------------+
                [ JI_by_Image{i,1}{j,1}, ...
                  Dice_by_Image{i,1}{j,1}, ...
                  TPR_pixel_by_Image{i,1}{j,1}, ...
                  FPR_pixel_by_Image{i,1}{j,1}, ...
                  FNR_pixel_by_Image{i,1}{j,1}, ...
                  TNR_pixel_by_Image{i,1}{j,1}, ...
                ] = SegEvaluateJIDiceTPRFPR( CytoSR_j, CytoGT_j );
            end
        end
    end

    %+-------------------------------------+
    %| Compute Measures By Dice thresholds |
    %+-------------------------------------+
    thr_Dice_70 = 0.7;

    Qualified_Dice_70 = [];
    Qualified_TPR_pixel_70 = [];
    Qualified_FPR_pixel_70 = [];
       num_Qualified_JI_70 = 1;
   
    Qualified_CellNumber_per_Image_70 = zeros(size(TMI_TrainSet_Mask,1),1);


    for i = 1:size(Dice_by_Image,1)
        for j = 1:size(Dice_by_Image{i,1},1)
            if Dice_by_Image{i,1}{j,1} > thr_Dice_70
                Qualified_Dice_70(num_Qualified_JI_70,1) = Dice_by_Image{i,1}{j,1};
                Qualified_TPR_pixel_70(num_Qualified_JI_70,1) = TPR_pixel_by_Image{i,1}{j,1};
                Qualified_FPR_pixel_70(num_Qualified_JI_70,1) = FPR_pixel_by_Image{i,1}{j,1};
                num_Qualified_JI_70 = num_Qualified_JI_70 + 1;
                
                Qualified_CellNumber_per_Image_70(i,1) = Qualified_CellNumber_per_Image_70(i,1) + 1;
            end
        end
    end

    %+--------------------------------------------------+
    %| Compute Mean Values for each "good segmentation" |
    %+--------------------------------------------------+
    meanDice70 = mean(Qualified_Dice_70(:));
    stdDice70 = std(Qualified_Dice_70(:));

    
    meanTPR70_pixel = mean(Qualified_TPR_pixel_70(:));
    stdTPR70_pixel = std(Qualified_TPR_pixel_70(:));

    meanFPR70_pixel = mean(Qualified_FPR_pixel_70(:));
    stdFPR70_pixel = std(Qualified_FPR_pixel_70(:));

    %+-----------------------------+
    %|      Object Level FNR       |
    %+-----------------------------+
    CellNumber_in_GroundTruth = 0;
    for i = 1:size(TMI_TrainSet_Mask,1)
        CellNumber_in_GroundTruth = CellNumber_in_GroundTruth + size(TMI_TrainSet_Mask{i,1},1);
    end
    
    FNR70_object = (CellNumber_in_GroundTruth - size(Qualified_Dice_70,1)) / CellNumber_in_GroundTruth;
    
    %+-----------------------------+
    %|      Object Level FNR       |
    %|           (Std)             |
    %+-----------------------------+
    FNo_per_img_70 = zeros(size(TMI_TrainSet_Mask,1),1);

    for i = 1:size(TMI_TrainSet_Mask,1)
        CellNumber_in_ImageGT_i = size(TMI_TrainSet_Mask{i,1},1);
        FNo_per_img_70(i,1) = (CellNumber_in_ImageGT_i - Qualified_CellNumber_per_Image_70(i,1)) / CellNumber_in_ImageGT_i;
    end
    
    STDFNo_70 = std(FNo_per_img_70(:));
end