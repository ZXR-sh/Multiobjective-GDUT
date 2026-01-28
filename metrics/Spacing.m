function spacing = Spacing(approxPF)
    % 计算Spacing指标
    % 输入:
    %   approxPF - 近似Pareto前沿 (N x M)
    % 输出:
    %   spacing - Spacing值
    
    N = size(approxPF, 1);
    
    % 计算每个解到最近邻的距离
    distances = zeros(N, 1);
    for i = 1:N
        minDist = inf;
        for j = 1:N
            if i ~= j
                dist = norm(approxPF(i,:) - approxPF(j,:));
                if dist < minDist
                    minDist = dist;
                end
            end
        end
        distances(i) = minDist;
    end
    
    % 计算平均距离
    dbar = mean(distances);
    
    % 计算Spacing
    spacing = sqrt(sum((distances - dbar).^2) / N);
end