function [record, rest, wrong, doubt, Y] = predictRoute3(N, dist_L, v, dc, sda, init, rest, wrong, doubt, record, labels, Y)
% ����汾��Ԥ��·����ÿ�����������Ҫ����

R = [];

R = init;
num = length(sda);

for i = 1:N
    init_dist = dist_L(init, :);
    block = find(init_dist<2*dc);
end

block = intersect(block, rest);

% ����Ѿ����������е��ѱ�����������˳�ѭ��
while ~isempty(rest)
    
    dist1 = dist_L(R, rest);                           % ����ʣ�����������ռ�����֮��ľ���
    q = find(sum(dist1, 1)==min(sum(dist1, 1)));       % Ѱ�Ҿ�������Ԥ������֮����С������
    q = q(1);
    p = rest(q);                                       % ���Ǵ�Ԥ������
    dist2 = dist1(:, q);

%     q = find(dist_L(R(end), rest)==min(dist_L(R(end), rest)));
%     q = q(1);
%     p = rest(q);       
%     dist2 = dist_L(R, p);

    [~, idx] = sort(dist2, 'ascend');
    [row, ~] = find(dist2 < v*dc);                     % ��ȡ��Ӱ�쵽��Ԥ���������Ѵ�������

    num_train = length(row);

    % ���ֻȡ3������
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

    % ����̫Զ��·�߱��жϣ������block�л�������δ�����Ǿ�������һ��block�е�������Ϊ��ѡ��
    if isempty(train) && ~isempty(block)
        
        q = find(dist_L(init, block)==min(dist_L(init, block)));
        q = q(1);
        p = block(q);
        
        dist2 = dist_L(R, p);
        [~, idx] = sort(dist2, 'ascend');
        [row, ~] = find(dist2 < v*dc);                     % ��ȡ��Ӱ�쵽��Ԥ���������Ѵ�������

        num_train = length(row);

        % ���ֻȡ3������
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
    
%     fprintf('���س�������\n');
%     pause;
%    plot([XX(labels(R(end)), 1), XX(labels(p), 1)], [XX(labels(R(end)), 2), XX(labels(p), 2)], 'color', 'k', 'linewidth', 2)
   
    % ��ʼ������
    p_pos = 0;
    p_neg = 0;

    % ���ݾ������Ȩ��
    r = dist_L(p, train);                 % ��ȡѵ�������뵱ǰ�����ľ���
    weight = exp(1./r);
    weight = weight / sum(weight);

    % Ԥ�⸽��������׼ȷ�ԣ����ڵ���������
    for j = 1:length(train)
        a = find(sda==r);                 % ����þ��������о������������
        a = a(end)/2;
        a = a / num;
        % �������ϳ�����ͳ�������������ǵ�ǰ�����λ��
        %phi = 0.32 * power(a, 3) - 0.71 * power(a, 2) + 0.63 * a + 0.21;  
        %%%%%%%%%��ʵ��ģ������
        %phi = 1842 * power(a, 3) - 361.7 * power(a, 2) + 24.48 * a + 0.1528;  
        %%%%%%%%ʵ����ģ������
        phi = 0.1955 * power(a, 3) - 0.4812 * power(a, 2) + 0.4898 * a + 0.2472;
        %%%%%%%%ʵ����ģ��
      %  phi = 1.553 * power(a, 5) - 4.196 * power(a, 4) + 4.274 * power(a, 3) - 2.1797 * power(a, 2) + 0.7648 * a + 0.2365;  
        if Y(labels(train(j))) == 1
            p_pos = p_pos + weight(j) * (1 - phi);
            p_neg = p_neg + weight(j) * phi;
        else
            p_pos = p_pos + weight(j) * phi;
            p_neg = p_neg + weight(j) * (1 - phi);
        end
    end


    % ȡԤ����ʽϴ���Ǹ�
    esti = sign(p_pos - p_neg);

    if Y(labels(p)) == esti
%          if abs(p_pos -p_neg) > 0.1
            R(end+1) = p;
            
%          else
%             doubt(end+1) = p;
%          end

    else      
        % �������Ϊ����Ҫ��Ԥ��Ϊ�������ʵĲ����30%����Ϊ�Ǵ���
         if abs(p_pos -p_neg) > 0.1
            wrong(end+1) = p;
            R(end+1) = p;
            Y(labels(p)) = -Y(labels(p));
         else
             doubt(end+1) = p;  
         end
    end

    % ���Ѵ����������rest��ɾ��
    block(block==p) = [];
    rest(rest==p) = [];

end

record = [record, R];
record = unique(record);
end