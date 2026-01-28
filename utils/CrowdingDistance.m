function CrowdDis = CrowdingDistance(Objs)
    % 计算拥挤距离
    % 输入:
    %   Objs - 目标值矩阵 (N x M)
    % 输出:
    %   CrowdDis - 拥挤距离向量 (N x 1)
    
    [n, m] = size(Objs);
    CrowdDis = zeros(n, 1);
    
    % 对每个目标单独计算
    for i = 1:m
        % 获取当前目标值
        f = Objs(:, i);
        
        % 找到最小和最大值
        [minVal, minIdx] = min(f);
        [maxVal, maxIdx] = max(f);
        
        % 边界点的拥挤距离设为无穷大
        CrowdDis(minIdx) = Inf;
        CrowdDis(maxIdx) = Inf;
        
        % 对中间点排序
        sortedIdx = sortrows([f, (1:n)'], 1);
        
        % 计算拥挤距离
        for j = 2:n-1
            idx = sortedIdx(j, 2);
            prevIdx = sortedIdx(j-1, 2);
            nextIdx = sortedIdx(j+1, 2);
            CrowdDis(idx) = CrowdDis(idx) + ...
                (Objs(nextIdx, i) - Objs(prevIdx, i)) / ...
                (maxVal - minVal + eps);
        end
    end
end