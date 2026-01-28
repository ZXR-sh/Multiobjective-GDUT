function hv = HV(approxPF, Problem)
    % 计算HV指标
    % 输入:
    %   approxPF - 近似Pareto前沿 (N x M)
    %   Problem - 问题定义（用于获取参考点）
    % 输出:
    %   hv - HV值
    
    % 获取参考点（通常为真实Pareto前沿最差点偏移10%）
    if isfield(Problem, 'getTruePF')
        truePF = Problem.getTruePF();
    else
        % 如果没有真实前沿，使用近似方法
        truePF = approxPF;
    end
    refPoint = max(truePF) * 1.1;
    
    % 二维问题计算HV
    if size(approxPF, 2) == 2
        % 排序
        [f1, idx] = sort(approxPF(:,1));
        f2 = approxPF(idx, 2);
        
        % 计算HV
        hv = 0;
        for i = 1:length(f1)-1
            hv = hv + (f1(i+1) - f1(i)) * (refPoint(2) - f2(i));
        end
        hv = hv + (refPoint(1) - f1(end)) * (refPoint(2) - f2(end));
    else
        % 高维情况：使用近似方法
        hv = -prod(refPoint - min(approxPF));
    end
end