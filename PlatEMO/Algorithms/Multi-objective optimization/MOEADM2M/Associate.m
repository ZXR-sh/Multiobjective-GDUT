function Population = Associate(Population, W, S)
    K = size(W, 1);
    N = length(Population);
    
    % 计算每个解到参考向量的余弦相似度
    similarity = zeros(N, K);
    for i = 1:K
        for j = 1:N
            % 计算余弦相似度
            similarity(j, i) = dot(Population(j).objs, W(i, :)) / ...
                (norm(Population(j).objs) * norm(W(i, :)) + eps);
        end
    end
    
    % 为每个解分配最相似的参考向量
    [~, assignment] = max(similarity, [], 2);
    
    % 为每个子问题分配恰好S个解
    partition = zeros(S, K);
    for i = 1:K
        current = find(assignment == i);
        currentCount = length(current);
        
        if currentCount < S
            % 不足S个，随机补充
            additional = setdiff(randi(N, S - currentCount, 1), current);
            partition(1:currentCount, i) = current;
            partition(currentCount+1:end, i) = additional;
        elseif currentCount > S
            % 超过S个，使用非支配排序和拥挤距离筛选
            subPopulation = Population(current);
            
            % 非支配排序
            [FrontNo, MaxFNo] = NDSort(subPopulation.objs, S);
            
            % 处理最差层
            Last = find(FrontNo == MaxFNo);
            if ~isempty(Last)
                % 计算拥挤距离
                CrowdDis = CrowdingDistance(subPopulation(Last).objs);
                [~, rank] = sort(CrowdDis, 'descend');
                
                % 保留拥挤距离较大的解
                keepCount = min(length(Last), S - sum(FrontNo < MaxFNo));
                FrontNo(Last(rank(keepCount+1:end))) = inf;
            end
            
            % 选择最终解
            current = current(FrontNo <= MaxFNo);
            
            % 确保恰好S个解
            if length(current) < S
                additional = setdiff(randi(N, S - length(current), 1), current);
                current = [current; additional];
            end
            partition(:, i) = current(1:S);
        else
            partition(:, i) = current;
        end
    end

    Population = Population(partition(:));
end