function [init, Y, wrong] = findInitialSample(Y, labels, N, dc, dist_L)

wrong = [];
init = [];
block = cell(N,1);      % block用来记录每个样本的邻居                               
major = zeros(N, 3);    % 记录每个块的信息：多数标签类别、数量、比例


for i = 1:N
        current_dist = dist_L(i, :);                  % 当前访问的带标签样本与其他样本之间的距离           
        block{i} = find(current_dist<dc);             % 距离小于dc的样本为当前样本的邻居（含自身）
        table = tabulate(Y(labels(block{i})));        % 统计各标签出现的频率
        idMax = find(table(:, 3)==max(table(:, 3)));
        idMax = idMax(1);
        major(i, 3) = table(idMax, 3);               % 记录多数相同标签的比例
        major(i, 2) = sum(table(:, 2));               % 记录多数相同标签的数量
        major(i, 1) = table(idMax, 1);               % 记录多数相同标签类别
end


for i = 1:N
    if major(i, 2) >= 7
        if major(i, 2) <= 15 && major(i, 3) >= 90 || major(i, 2) > 30 && major(i, 3) >= 85
            init(end+1) = i;
            if Y(labels(i)) ~= major(i, 1)
                Y(labels(i))  = -Y(labels(i));
                wrong(end+1) = i;
            end
        end
   
    else
        if major(i, 3) == 100 && major(i, 2) >= 4
            init(end+1) = i;
        end
    end
%     if major(i, 2) >= 3
%         if major(i, 3) == 100 && major(i, 2) == 3 || major(i, 2) > 4 && major(i, 3) >= 88
%                 init(end+1) = i;
%                 if Y(labels(i)) ~= major(i, 1)
%                     Y(labels(i))  = -Y(labels(i));
%                     wrong(end+1) = i;
%                 end
%         end
%     end
end
% init1 = find(major(:, 2) >= 10);
% init2 = find(major(:, 3) > 87);
% init = intersect(init1, init2);
% init = init';
end

