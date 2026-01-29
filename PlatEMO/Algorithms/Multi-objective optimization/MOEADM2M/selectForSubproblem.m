% 从合并种群中为每个子问题选择 S 个最优解
function SelectedPop = selectForSubproblem(Pop, K, S)
    SelectedPop = repmat(SOLUTION(), K*S, 1);
    currentIdx = 1;

    for subIdx = 1:K
        % 找出属于当前子问题的所有解
        members = Pop([Pop.subproblem_id] == subIdx);
        if isempty(members)
            continue;
        end
        
        % 选择策略：按与参考向量的距离排序，选择最近的 S 个
        distances = zeros(length(members), 1);
        w = members(1).W_ref; 

        for i = 1:length(members)
            obj = members(i).objs;
            projLength = dot(obj, w) / dot(w, w);
            projPoint = projLength * w;
            distances(i) = norm(obj - projPoint);
        end
        
        % 按距离升序排序
        [~, sortedIdx] = sort(distances, 'ascend');
        members = members(sortedIdx);
        
        % 选择前 min(S, length(members)) 个
        numToSelect = min(S, length(members));
        SelectedPop(currentIdx:currentIdx+numToSelect-1) = members(1:numToSelect);
        currentIdx = currentIdx + numToSelect;
    end

    % 移除末尾可能存在的空 SOLUTION
    SelectedPop = SelectedPop(1:currentIdx-1);
end