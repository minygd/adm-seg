close all
clear all
%addpath('../../matlabfiltering');
addpath('~/Disney/matlabfiltering');
whichset='val';
fileID = fopen(['msra10k/list/' whichset '_id.txt']);
imgnames = textscan(fileID,'%s');
imgnames = imgnames{1};
fclose(fileID);
initialization_energies = [];
network_energies = [];
nc_energies = [];
sigmargb=15;
sigmaxy = 300;

for imgid =1:20
    
imgname = imgnames{imgid};
img = imread(['~/Disney/data/MSRA10K/Imgs/' imgname '.jpg']);
[H W C] = size(img);

largeimg = zeros(513,513,3,'uint8');
largeimg(1:H, 1:W, :) = img;
%figure,imshow(img);
%axis on

% initialization
load(['msra10k/features/deeplab_vgg16/' whichset '/fc8/' imgname '_blob_0.mat']); % data is of WxHxC
probmap = data(1:(min(W,size(data,1))), 1:(min(H,size(data,2))),:);
probmap = canonicalForm( probmap );
[~,a] = max(probmap,[],3);
%figure,imagesc(a);
figure,subplot(1,3,1);
imshow(encodesegmentation( img, a ));title('initialization');
initialization_energy = computeNC( img, probmap, sigmargb, sigmaxy );
initialization_energies = [initialization_energies initialization_energy];

% NC algorithm
[ ncsegmentation ] = runNC( img, probmap, sigmargb, sigmaxy,0.000001);
%return
[~,a] = max(ncsegmentation,[],3);
subplot(1,3,2);imshow(encodesegmentation( img, a ));title('NC algorithm');
nc_energy = computeNC(img, ncsegmentation, sigmargb, sigmaxy);
nc_energies = [nc_energies nc_energy];

% NC network
load(['msra10k/featuresncrgb/deeplab_vgg16/' whichset '/fc8/' imgname '_blob_0.mat']); % data is of WxHxC
probmap = data(1:(min(W,size(data,1))), 1:(min(H,size(data,2))),:);
probmap = canonicalForm( probmap );
[~,a] = max(probmap,[],3);
%figure,imagesc(a);
subplot(1,3,3);imshow(encodesegmentation( img, a ));title('NC network');
network_energy = computeNC( img, probmap, sigmargb, sigmaxy );
network_energies = [network_energies network_energy];


continue;
[a] = max(data,[],3);
figure;
numlabels = 2;
for i=1:2
    probmap = data(:,:,i)';
    probmap = probmap(1:H,1:W);
    if numlabels==21
        subplot(3,7,i),imagesc(probmap);
        title([num2str(i) ' ' classes{i}]);axis off
    else
        subplot(1,numlabels,i),imagesc(probmap);
        axis equal
        axis off
    end
    colormap jet
    caxis([0 1])
    %colorbar
end

end

disp(['mean initialization energies: ' num2str(mean(initialization_energies))]);
disp(['mean NC energies: ' num2str(mean(nc_energies))]);
disp(['mean network energies: ' num2str(mean(network_energies))]);
