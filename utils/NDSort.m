function [FrontNo, MaxFNo] = NDSort(Objs, N)
    % 非支配排序实现
    % 输入:
    %   Objs - 目标值矩阵 (N x M)
    %   N - 需要保留的解数量
    % 输出:
    %   FrontNo - 每个解的前沿编号
    %   MaxFNo - 最大前沿编号
    
    [n, m] = size(Objs);
    
    % 初始化
    FrontNo = inf(n, 1);
    MaxFNo = 0;
    
    % 计算支配关系
    dominationCounter = zeros(n, 1);
    dominatedSet = cell(n, 1);
    
    for i = 1:n
        for j = 1:n
            if i ~= j
                if dominates(Objs(i,:), Objs(j,:))
                    dominatedSet{i} = [dominatedSet{i}, j];
                elseif dominates(Objs(j,:), Objs(i,:))
                    dominationCounter(i) = dominationCounter(i) + 1;
                end
            end
        end
    end
    
    % 分配前沿
    remaining = n;
    while remaining > 0 && MaxFNo * N < n
        MaxFNo = MaxFNo + 1;
        currentFront = find(dominationCounter == 0);
        
        % 分配前沿编号
        FrontNo(currentFront) = MaxFNo;
        
        % 更新支配计数器
        for i = currentFront
            for j = dominatedSet{i}
                dominationCounter(j) = dominationCounter(j) - 1;
            end
        end
        
        dominationCounter(currentFront) = -1; % 标记为已处理
        remaining = remaining - length(currentFront);
    end
    
    % 如果还有剩余解，将它们分配到最后一个前沿
    if remaining > 0
        MaxFNo = MaxFNo + 1;
        currentFront = find(FrontNo == inf);
        FrontNo(currentFront) = MaxFNo;
    end
end

function flag = dominates(f1, f2)
    % 检查f1是否支配f2
    flag = all(f1 <= f2) && any(f1 < f2);
end