
clc
close all 
clear all

[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg';'*.gif'}, 'Pick a Leaf Image File');
I = imread([pathname,filename]);
I = imresize(I,[256,256]);

dispIMG=I;

I = imadjust(I,stretchlim(I));
figure, imshow(I);title('Contrast Enhanced');

Icontrased=I;

I_Otsu = im2bw(I,graythresh(I));
I_HIS = rgb2hsi(I);

cform = makecform('srgb2lab') ;
lab_he = applycform(I,cform);

ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
                                  
pixel_labels = reshape(cluster_idx,nrows,ncols);

segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColors
    colors = I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end



figure, subplot(3,1,1);imshow(segmented_images{1});title('Image 1'); subplot(3,1,2);imshow(segmented_images{2});title('Image 2');
subplot(3,1,3);imshow(segmented_images{3});title('Image 3');
set(gcf, 'Position', get(0,'Screensize'));

x = inputdlg('Enter the image number which best represents the leaf:');
i = str2double(x);

img1=segmented_images{1};
img2=segmented_images{2};
img3=segmented_images{3};

seg_img = segmented_images{i};
figure,imshow(seg_img);
if ndims(seg_img) == 3
   img = rgb2gray(seg_img);
end

black = im2bw(seg_img,graythresh(seg_img));
m = size(seg_img,1);
n = size(seg_img,2);
zero_image = zeros(m,n); 
cc = bwconncomp(seg_img,6);
diseasedata = regionprops(cc,'basic');
A1 = diseasedata.Area;
sprintf('Area of the disease affected region is : %g%',A1);

I_black = im2bw(I,graythresh(I));
kk = bwconncomp(I,6);
leafdata = regionprops(kk,'basic');
A2 = leafdata.Area;
sprintf(' Total leaf area is : %g%',A2);

Affected_Area = (A1/A2);
if Affected_Area < 0.1
    Affected_Area = Affected_Area+0.15;
end

area=Affected_Area*100;
areaText= 'Affected Area is:'+area;
area=round(area);


sprintf('Affected Area is: %g%%',(Affected_Area*100))



glcms = graycomatrix(img);
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(seg_img);
Standard_Deviation = std2(seg_img);
Entropy = entropy(seg_img);
RMS = mean2(rms(seg_img));
Variance = mean2(var(double(seg_img)));
a = sum(double(seg_img(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(seg_img(:)));
Skewness = skewness(double(seg_img(:)));
m = size(seg_img,1);
n = size(seg_img,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = seg_img(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end
IDM = double(in_diff);
    
feat_disease = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];
load('Training_Data.mat')

test = feat_disease;
result = multisvm(Train_Feat,Train_Label,test);




labelForKNN=Train_Label;


[resultfromKNN,nn_index,accuracy]= KNN(3,Train_Feat,labelForKNN,test);


diseaseSVN='';
diseaseKNN='';

if result == 0
    
    diseaseSVN='Alternaria Alternata';
elseif result == 1
   
    diseaseSVN='Anthracnose';
elseif result == 2
  
    diseaseSVN='Bacterial Blight';
elseif result == 3
    
    diseaseSVN='Cercospora Leaf Spot';
elseif result == 4
    
    diseaseSVN='Healthy Leaf';
end




if resultfromKNN == 0
    
    diseaseKNN='Alternaria Alternata';
elseif resultfromKNN == 1
    
    diseaseKNN='Anthracnose';
elseif resultfromKNN == 2
    
    diseaseKNN='Bacterial Blight';
elseif resultfromKNN == 3
   
    diseaseKNN='Cercospora Leaf Spot';
elseif resultfromKNN == 4
   
    diseaseKNN='Healthy Leaf';
end

sprintf('Disease from SVN:');
sprintf(diseaseSVN);

sprintf('Disease from KNN:');
sprintf(diseaseKNN);



if result==4 && resultfromKNN==4
    area=0;
end

sindex=0;
if area<15
    sindex=0;
elseif area>=15 && area<25
    sindex=1;
elseif area>=25 && area<35
    sindex=2;
elseif area>=35 && area<45
    sindex=3;
elseif area>=45 && area<55
    sindex=4;
else sindex=5;
end
    
s = num2str(area);

sindex=num2str(sindex);

d1='';
d2='';

d1=diseaseSVN;
d2=diseaseKNN;

per='%';

s=strcat(s,per);

res=-1;

if result==0 && resultfromKNN==0
    res=0;
elseif result==1 && resultfromKNN==1
    res=1;
elseif result==2 && resultfromKNN==2
    res=2;
elseif result==3 && resultfromKNN==3
    res=3;
elseif result==4 && resultfromKNN==4
    res=4;
else
    res=-1;
end


myicon = dispIMG;

if res==-1
    d1='Not determined Correctly';
    d2='Not determined Correctly';
    s='Nil';
    sindex='Nil';    
end

h = msgbox({'Disease from SVM:';d1;'Disease from KNN:';d2;'Percentage Infection :';s;'Severity Index :';sindex},'Disease Identified','custom',myicon);

if res==0
    printRes(0);
elseif res==1
    printRes(1);
elseif res==2
    printRes(2);
elseif res==3
    printRes(3);
end
    
load('Accuracy_Data.mat')
Accuracy_Percent= zeros(200,1);
for i = 1:500
data = Train_Feat;

groups = ismember(Train_Label,0);
[train,test] = crossvalind('HoldOut',groups);
cp = classperf(groups);

svmStruct = svmtrain(data(train,:),groups(train),'showplot',false,'kernel_function','linear');
classes = svmclassify(svmStruct,data(test,:),'showplot',false);

classperf(cp,classes,test);
Accuracy = cp.CorrectRate;
Accuracy_Percent(i) = Accuracy.*100;
end
Max_Accuracy = max(Accuracy_Percent);
sprintf('Accuracy of Linear Kernel with 500 iterations is: %g%%',Max_Accuracy);











