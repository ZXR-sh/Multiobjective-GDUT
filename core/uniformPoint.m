function [W, K] = uniformPoint(K, M)
    if M == 2
        % 二维情况：均匀分布在单位圆上
        angles = linspace(0, pi/2, K);
        W = [cos(angles); sin(angles)]';
    else
        % 高维情况：使用随机方法生成近似均匀分布
        W = zeros(K, M);
        for i = 1:K
            w = rand(1, M);
            W(i, :) = w / sum(w);
        end
    end
    K = size(W, 1);
end