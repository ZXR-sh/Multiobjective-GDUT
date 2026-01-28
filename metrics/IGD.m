function igd = IGD(approxPF, truePF)
    % 计算IGD指标
    % 输入:
    %   approxPF - 近似Pareto前沿 (N x M)
    %   truePF - 真实Pareto前沿 (P x M)
    % 输出:
    %   igd - IGD值
    
    [N, M] = size(approxPF);
    [P, ~] = size(truePF);
    
    % 计算每个真实解到近似前沿的最小距离
    distances = zeros(P, 1);
    for i = 1:P
        minDist = inf;
        for j = 1:N
            dist = norm(truePF(i,:) - approxPF(j,:));
            if dist < minDist
                minDist = dist;
            end
        end
        distances(i) = minDist;
    end
    
    % 计算IGD
    igd = sum(distances) / P;
end