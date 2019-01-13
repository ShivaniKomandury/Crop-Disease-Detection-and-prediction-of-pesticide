function [predicted_labels,nn_index,accuracy] = KNN(k,data,labels,t_data,t_labels)
if nargin < 4
    error('Too few input arguments.')
elseif nargin < 5
    t_labels=[];
    accuracy=0;
end

if size(data,2)~=size(t_data,2)
    error('data should have the same dimensionality');
end

if mod(k,2)==0
    error('to reduce the chance of ties, please choose odd k');
end

predicted_labels=zeros(size(t_data,1),1);
ed=zeros(size(t_data,1),size(data,1));  
ind=zeros(size(t_data,1),size(data,1)); 
k_nn=zeros(size(t_data,1),k); 

for test_point=1:size(t_data,1)
    for train_point=1:size(data,1)
       
        ed(test_point,train_point)=sqrt(...
            sum((t_data(test_point,:)-data(train_point,:)).^2));
    end
    [ed(test_point,:),ind(test_point,:)]=sort(ed(test_point,:));
end

k_nn=ind(:,1:k);
nn_index=k_nn(:,1);
 
for i=1:size(k_nn,1)
    options=unique(labels(k_nn(i,:)'));
    max_count=0;
    max_label=0;
    for j=1:length(options)
        L=length(find(labels(k_nn(i,:)')==options(j)));
        if L>max_count
            max_label=options(j);
            max_count=L;
        end
    end
    predicted_labels(i)=max_label;
end

if isempty(t_labels)==0
    accuracy=length(find(predicted_labels==t_labels))/size(t_data,1);
end







