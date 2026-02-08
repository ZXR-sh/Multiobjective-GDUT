function [New,GradCache] = KT(Problem,Centers,Phi,W,Neigh,SimMat,StagList,GradCache,Opts)
% KT：对停滞子问题进行梯度知识迁移，生成并返回已评价的新解

Kstag = numel(StagList);
D     = size(Centers,2);
Nmax  = max(1,round(Opts.rNew*Problem.N));

TolDec2 = 1e-24;

% 多步长生成多个梯度新解
if isfield(Opts,'stepScales') && ~isempty(Opts.stepScales)
    stepScales = Opts.stepScales;
else
    stepScales = [0.5,1,2];
end

checkAssign = true;
if isfield(Opts,'checkAssign')
    checkAssign = logical(Opts.checkAssign);
end

NewCell = cell(Nmax,1);
Xlist   = zeros(Nmax,D);
cnt     = 0;

range = Problem.upper - Problem.lower;
range(range<=0) = 1;

for t = 1 : Kstag
    k = StagList(t);
    x = Centers(k,:);
    w = W(k,:);
    z = Opts.z;

    % (1) 估计/复用本子问题梯度（有限差分 + 缓存）
    if GradCache.has(k) && norm(x-GradCache.x(k,:)) < 1e-9
        g = GradCache.g(k,:);
    else
        g = Tool("fdgrad",Problem,x,w,Opts.delta,z);
        GradCache.x(k,:)   = x;
        GradCache.g(k,:)   = g;
        GradCache.has(k,1) = true;
    end

    % (2) 从相似子问题迁移梯度（相似度加权融合）
    neigh = Neigh{k};
    if ~isempty(neigh)
        valid = neigh(GradCache.has(neigh));
        if ~isempty(valid)
            ws = SimMat(k,valid);
            if any(ws>0)
                ws = ws./sum(ws);
                g_share = ws*GradCache.g(valid,:);
            else
                g_share = zeros(1,D);
            end
        else
            g_share = zeros(1,D);
        end
    else
        g_share = zeros(1,D);
    end

    g_eff = Opts.localW*g + (1-Opts.localW)*g_share;
    if any(~isfinite(g_eff)) || all(abs(g_eff) < 1e-12)
        continue;
    end
    nrm = norm(g_eff);
    if nrm == 0 || ~isfinite(nrm)
        continue;
    end

    % 梯度下降方向（标量化目标的下降方向）
    dir = -g_eff./nrm;
    s_center = Phi(k);

    % (3) 多步长生成多个候选梯度新解
    for ss = 1 : numel(stepScales)
        stepLen = (stepScales(ss)*Opts.step).*range;
        x_new   = x + stepLen.*dir;
        x_new   = Problem.CalDec(x_new);

        % (4) 注入解去重
        if cnt > 0
            d2 = sum((Xlist(1:cnt,:) - x_new).^2,2);
            if any(d2 <= TolDec2)
                continue;
            end
        end

        % (5) 评价并做“显著改进”筛选
        Pnew  = Problem.Evaluation(x_new);
        s_new = scalar_tch_local(Pnew.objs,w,z);
        if ~(s_new < s_center - Opts.epsImp)
            continue;
        end

        % (6) 要求新解仍匹配目标子问题 k（避免被 associate 分到其它子问题）
        if checkAssign
            obj = Pnew.objs;
            wn  = sqrt(sum(W.^2,2));
            wn(wn==0) = eps;
            on  = norm(obj);
            if on == 0 || ~isfinite(on)
                on = eps;
            end
            sims = (W*obj')./(wn*on);
            [~,aid] = max(sims);
            if aid ~= k
                continue;
            end
        end

        cnt = cnt + 1;
        Xlist(cnt,:)   = x_new;
        NewCell{cnt,1} = Pnew;
        if cnt >= Nmax
            break;
        end
    end

    if cnt >= Nmax
        break;
    end
end

if cnt == 0
    New = [];
else
    New = [NewCell{1:cnt}];
end
end

function val = scalar_tch_local(Obj,w,z)
w   = max(w,1e-12);
Obj = abs(Obj - z);
val = max(Obj.*w,[],2);
end
