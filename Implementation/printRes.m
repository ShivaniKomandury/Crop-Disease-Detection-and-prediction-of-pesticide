function [] = printRes(did)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if did==0
    A = imread('0.png');
elseif did==1
    A = imread('1.png');
elseif did==2
    A = imread('2.png');
elseif did==3
    A = imread('3.png');
end
 
figure,imshow(A);

end

