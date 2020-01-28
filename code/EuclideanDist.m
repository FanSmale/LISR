function dist = EuclideanDist(X, Y)

[m1, n1] = size(X);
[m2, n2] = size(Y);
dist = zeros(m1, m2);
if n1 ~= n2
    error('输入数据矩阵的列数应相等');
else
    for i = 1:m1
        for j = 1:m2
            diff1 = X(i, :) - Y(j, :);
            diff2 = power(diff1, 2);
            dist(i, j) = sqrt(sum(diff2));
        end
    end
    
end
end

