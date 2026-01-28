function Offspring = Operator(Algorithm, Problem, Parent1, Parent2)

    % 提取决策变量
    Parent1Decs = [Parent1.decs{:}];
    Parent2Decs = [Parent2.decs{:}];
    [N, D] = size(Parent1Decs);
    
    % 交叉操作
    rc = (2*rand(N,1)-1) .* (1-rand(N,1).^(-(1-Algorithm.FE/Algorithm.maxFE)^0.7));
    OffDec = Parent1Decs + repmat(rc, 1, D) .* (Parent1Decs - Parent2Decs);
    
    % 变异操作
    rm = 0.25 * (2*rand(N,D)-1) .* (1-rand(N,D).^(-(1-Algorithm.FE/Algorithm.maxFE)^0.7));
    Site = rand(N,D) < 1/D;
    Lower = repmat(Problem.lower, N, 1);
    Upper = repmat(Problem.upper, N, 1);
    OffDec(Site) = OffDec(Site) + rm(Site) .* (Upper(Site) - Lower(Site));
    
    % 边界处理
    temp1 = OffDec < Lower;
    temp2 = OffDec > Upper;
    rnd = rand(N,D);
    OffDec(temp1) = Lower(temp1) + 0.5 * rnd(temp1) .* (Parent1Decs(temp1) - Lower(temp1));
    OffDec(temp2) = Upper(temp2) - 0.5 * rnd(temp2) .* (Upper(temp2) - Parent1Decs(temp2));
    
    % 评估后代
    Offspring = Problem.evaluation(OffDec);
end