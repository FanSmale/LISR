function [init, Y, wrong] = findInitialSample(Y, labels, N, dc, dist_L)

wrong = [];
init = [];
block = cell(N,1);      % block������¼ÿ���������ھ�                               
major = zeros(N, 3);    % ��¼ÿ�������Ϣ��������ǩ�������������


for i = 1:N
        current_dist = dist_L(i, :);                  % ��ǰ���ʵĴ���ǩ��������������֮��ľ���           
        block{i} = find(current_dist<dc);             % ����С��dc������Ϊ��ǰ�������ھӣ�������
        table = tabulate(Y(labels(block{i})));        % ͳ�Ƹ���ǩ���ֵ�Ƶ��
        idMax = find(table(:, 3)==max(table(:, 3)));
        idMax = idMax(1);
        major(i, 3) = table(idMax, 3);               % ��¼������ͬ��ǩ�ı���
        major(i, 2) = sum(table(:, 2));               % ��¼������ͬ��ǩ������
        major(i, 1) = table(idMax, 1);               % ��¼������ͬ��ǩ���
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

