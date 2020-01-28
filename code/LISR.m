clc
clear

%% ============================= 预处理 ===================================
% 本部分实现读取数据，手动修改标签，提取样本
dbstop if error
% 用于测试算法的准确度
data = xlsread('D:\datasets\flameDecision.csv');

N_rat = 0.2;               % 带标签样本个数
err_rat = 0.2;            % 噪声比例

m = size(data, 1);               % 样本个数

Y0 = data(:, end);               % 真实标签

X = data(:, 1:end-1);

% X = featureNormalize(X);       % 特征归一化
[~, n] = size(X);                % 特征个数

N = ceil(m * N_rat);               % 带标签样本个数


Y0(Y0~= 1) = -1;                 % 令标签为{-1， 1}
Y = Y0;

labels = randperm(m, N);                 % 给数据集打上N个标签
labels = sort(labels, 'ascend');
labels = labels';

err = randperm(N, round(N * err_rat));   % 随机选取一些标签为错误标签
err = sort(err, 'ascend');
Y(labels(err)) = -Y(labels(err));        % 手动地将随机选取的样本标签改成错误标签，Y含有一定比例错误标签

x = X;   %%%%%%    待分类的数据
y = Y0;  %%%%%%    正确的标签
x(labels, :) = [];
y(labels) = [];

% u相当于dc的比例，v为每个点的影响范围系数，v*dc
u = 0.01;
v = 1.5;
%% ============================= 算法 ===================================
%%%%%%%%%%计算距离
% dcRatio = 0.01;
dist = EuclideanDist(X, X);
dist(find(dist==0)) = 0.01;

dist_L = EuclideanDist(X(labels, :), X(labels, :));     % 各带标签样本之间的距离
dist_L(find(dist_L==0)) = 0.01;

maxDist = max(max(dist));
% dc = dcRatio * maxDist;

%% ============================= 求截止距离 =================================
% 根据dp聚类中的方法，取所有距离从低到高的第2%个距离为截止距离，小于dc的点为邻居

dis = zeros((m-1)*m/2, 1);            % 这是所有距离
num = 0;                              % num为所有距离个数

for i = 1:m-1
    for j = i+1:m
        num = num + 1;
        dis(num) = dist(i, j);
    end
end

position = round(u*num);               % 取第u%的点为截止距离

sda = sort(dis,'ascend');
dc = sda(position);                    % 截止距离

doubt = [];
rest = 1:N;             % 剩余未处理的样本

%% ============================= 选取初始点 =============================
% 对于每个带标签的样本，距离小于dc的附近样本作为其邻居，找到所有被认为可靠的样本
[init, Y, wrong] = findInitialSample(Y, labels, N, dc, dist_L);
record = init;
rest = setdiff(rest, init);         % 在rest中删除初始点样本

%% ======================== 并行地预测附近样本的准确性 =========================
% 每一个新的初始样本都要预测附近样本的准确性
% 预测其他样本的准确性是要有一定范围的，若超出这个范围则无效

for i = 1:length(init)
    [record, rest, wrong, doubt, Y] = predictRoute(N, dist_L, v, dc, sda, init(i), rest, wrong, doubt, record, labels, Y);
end

record = [record, rest, doubt];

%% ============================= kNN分类 =================================
% 剩余的样本采用kNN分类

x = X;
y = Y0;                       % 这是剩余样本的真实标签
x(labels, :) = [];
y(labels) = [];

%predict_wlapknn = ClassificationKNN.fit(x, X(labels(record), :), Y(labels(record)), 3, 'euclidean', 'nearest' );
mdknn = ClassificationKNN.fit(X(labels(record), :), Y(labels(record)),'NumNeighbors',3);
predict_wlapknn = predict(mdknn, x);

% 计算kNN分类的准确率，并输出
accwlap_knn = mean(predict_wlapknn == y)

