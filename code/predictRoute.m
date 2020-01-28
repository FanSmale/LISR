function [record, rest, wrong, doubt, Y] = predictRoute3(N, dist_L, v, dc, sda, init, rest, wrong, doubt, record, labels, Y)
% 这个版本的预测路线是每个块的样本都要处理

R = [];

R = init;
num = length(sda);

for i = 1:N
    init_dist = dist_L(init, :);
    block = find(init_dist<2*dc);
end

block = intersect(block, rest);

% 如果已经处理完所有的已标记样本，就退出循环
while ~isempty(rest)
    
    dist1 = dist_L(R, rest);                           % 计算剩余样本与已收集样本之间的距离
    q = find(sum(dist1, 1)==min(sum(dist1, 1)));       % 寻找距离与已预测样本之和最小的样本
    q = q(1);
    p = rest(q);                                       % 这是待预测样本
    dist2 = dist1(:, q);

%     q = find(dist_L(R(end), rest)==min(dist_L(R(end), rest)));
%     q = q(1);
%     p = rest(q);       
%     dist2 = dist_L(R, p);

    [~, idx] = sort(dist2, 'ascend');
    [row, ~] = find(dist2 < v*dc);                     % 提取能影响到待预测样本的已处理样本

    num_train = length(row);

    % 最多只取3个样本
    train = [];
    if num_train > 3                             
            for w = 1:3
                train(w) = R(idx(w));
            end
    elseif num_train > 0 && num_train <= 3
            for w = 1:num_train
                train(w) = R(idx(w));
            end
    else
        train = [];
    end

    % 距离太远，路线被中断，但如果block中还有样本未处理，那就重新找一个block中的样本作为备选点
    if isempty(train) && ~isempty(block)
        
        q = find(dist_L(init, block)==min(dist_L(init, block)));
        q = q(1);
        p = block(q);
        
        dist2 = dist_L(R, p);
        [~, idx] = sort(dist2, 'ascend');
        [row, ~] = find(dist2 < v*dc);                     % 提取能影响到待预测样本的已处理样本

        num_train = length(row);

        % 最多只取3个样本
        train = [];
        if num_train > 3                             
                for w = 1:3
                    train(w) = R(idx(w));
                end
        elseif num_train > 0 && num_train <= 3
                for w = 1:num_train
                    train(w) = R(idx(w));
                end
        else
            train = [];
        end
    end
    
    if isempty(train)
        break
    end
    
%     fprintf('按回车键继续\n');
%     pause;
%    plot([XX(labels(R(end)), 1), XX(labels(p), 1)], [XX(labels(R(end)), 2), XX(labels(p), 2)], 'color', 'k', 'linewidth', 2)
   
    % 初始化概率
    p_pos = 0;
    p_neg = 0;

    % 根据距离加入权重
    r = dist_L(p, train);                 % 提取训练样本与当前样本的距离
    weight = exp(1./r);
    weight = weight / sum(weight);

    % 预测附近样本的准确性（对于单个样本）
    for j = 1:length(train)
        a = find(sda==r);                 % 计算该距离在所有距离里面的排名
        a = a(end)/2;
        a = a / num;
        % 这就是拟合出来的统计误差函数，输入是当前距离的位次
        %phi = 0.32 * power(a, 3) - 0.71 * power(a, 2) + 0.63 * a + 0.21;  
        %%%%%%%%%单实例模型三次
        %phi = 1842 * power(a, 3) - 361.7 * power(a, 2) + 24.48 * a + 0.1528;  
        %%%%%%%%实例对模型三次
        phi = 0.1955 * power(a, 3) - 0.4812 * power(a, 2) + 0.4898 * a + 0.2472;
        %%%%%%%%实例对模型
      %  phi = 1.553 * power(a, 5) - 4.196 * power(a, 4) + 4.274 * power(a, 3) - 2.1797 * power(a, 2) + 0.7648 * a + 0.2365;  
        if Y(labels(train(j))) == 1
            p_pos = p_pos + weight(j) * (1 - phi);
            p_neg = p_neg + weight(j) * phi;
        else
            p_pos = p_pos + weight(j) * phi;
            p_neg = p_neg + weight(j) * (1 - phi);
        end
    end


    % 取预测概率较大的那个
    esti = sign(p_pos - p_neg);

    if Y(labels(p)) == esti
%          if abs(p_pos -p_neg) > 0.1
            R(end+1) = p;
            
%          else
%             doubt(end+1) = p;
%          end

    else      
        % 如果估计为错误，要当预测为正负概率的差大于30%才认为是错误
         if abs(p_pos -p_neg) > 0.1
            wrong(end+1) = p;
            R(end+1) = p;
            Y(labels(p)) = -Y(labels(p));
         else
             doubt(end+1) = p;  
         end
    end

    % 将已处理的样本在rest中删除
    block(block==p) = [];
    rest(rest==p) = [];

end

record = [record, R];
record = unique(record);
end