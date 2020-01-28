clc
clear

%% ============================= Ԥ���� ===================================
% ������ʵ�ֶ�ȡ���ݣ��ֶ��޸ı�ǩ����ȡ����
dbstop if error
% ���ڲ����㷨��׼ȷ��
data = xlsread('D:\datasets\flameDecision.csv');

N_rat = 0.2;               % ����ǩ��������
err_rat = 0.2;            % ��������

m = size(data, 1);               % ��������

Y0 = data(:, end);               % ��ʵ��ǩ

X = data(:, 1:end-1);

% X = featureNormalize(X);       % ������һ��
[~, n] = size(X);                % ��������

N = ceil(m * N_rat);               % ����ǩ��������


Y0(Y0~= 1) = -1;                 % ���ǩΪ{-1�� 1}
Y = Y0;

labels = randperm(m, N);                 % �����ݼ�����N����ǩ
labels = sort(labels, 'ascend');
labels = labels';

err = randperm(N, round(N * err_rat));   % ���ѡȡһЩ��ǩΪ�����ǩ
err = sort(err, 'ascend');
Y(labels(err)) = -Y(labels(err));        % �ֶ��ؽ����ѡȡ��������ǩ�ĳɴ����ǩ��Y����һ�����������ǩ

x = X;   %%%%%%    �����������
y = Y0;  %%%%%%    ��ȷ�ı�ǩ
x(labels, :) = [];
y(labels) = [];

% u�൱��dc�ı�����vΪÿ�����Ӱ�췶Χϵ����v*dc
u = 0.01;
v = 1.5;
%% ============================= �㷨 ===================================
%%%%%%%%%%�������
% dcRatio = 0.01;
dist = EuclideanDist(X, X);
dist(find(dist==0)) = 0.01;

dist_L = EuclideanDist(X(labels, :), X(labels, :));     % ������ǩ����֮��ľ���
dist_L(find(dist_L==0)) = 0.01;

maxDist = max(max(dist));
% dc = dcRatio * maxDist;

%% ============================= ���ֹ���� =================================
% ����dp�����еķ�����ȡ���о���ӵ͵��ߵĵ�2%������Ϊ��ֹ���룬С��dc�ĵ�Ϊ�ھ�

dis = zeros((m-1)*m/2, 1);            % �������о���
num = 0;                              % numΪ���о������

for i = 1:m-1
    for j = i+1:m
        num = num + 1;
        dis(num) = dist(i, j);
    end
end

position = round(u*num);               % ȡ��u%�ĵ�Ϊ��ֹ����

sda = sort(dis,'ascend');
dc = sda(position);                    % ��ֹ����

doubt = [];
rest = 1:N;             % ʣ��δ���������

%% ============================= ѡȡ��ʼ�� =============================
% ����ÿ������ǩ������������С��dc�ĸ���������Ϊ���ھӣ��ҵ����б���Ϊ�ɿ�������
[init, Y, wrong] = findInitialSample(Y, labels, N, dc, dist_L);
record = init;
rest = setdiff(rest, init);         % ��rest��ɾ����ʼ������

%% ======================== ���е�Ԥ�⸽��������׼ȷ�� =========================
% ÿһ���µĳ�ʼ������ҪԤ�⸽��������׼ȷ��
% Ԥ������������׼ȷ����Ҫ��һ����Χ�ģ������������Χ����Ч

for i = 1:length(init)
    [record, rest, wrong, doubt, Y] = predictRoute(N, dist_L, v, dc, sda, init(i), rest, wrong, doubt, record, labels, Y);
end

record = [record, rest, doubt];

%% ============================= kNN���� =================================
% ʣ�����������kNN����

x = X;
y = Y0;                       % ����ʣ����������ʵ��ǩ
x(labels, :) = [];
y(labels) = [];

%predict_wlapknn = ClassificationKNN.fit(x, X(labels(record), :), Y(labels(record)), 3, 'euclidean', 'nearest' );
mdknn = ClassificationKNN.fit(X(labels(record), :), Y(labels(record)),'NumNeighbors',3);
predict_wlapknn = predict(mdknn, x);

% ����kNN�����׼ȷ�ʣ������
accwlap_knn = mean(predict_wlapknn == y)

