%工具函数
function varargout=Tool(op,varargin)
    if isstring(op)
        op = char(op);
    end
    op = lower(op);

    switch lower(op)
        %余弦相似度矩阵
        case "cosinesim"
            A=varargin{1};
            B=varargin{2};
            varargout{1}=cosinesim(A,B);
        
        %静态相似度矩阵+相思子问题列表
        case "sim"
            W=varargin{1};
            neighNum=varargin{2};

            K=size(W,1);
            neighNum=min(neighNum,K-1);

            SimMat=cosinesim(W,W);
            SimMat(1:K+1:end)=0;

            Neigh=cell(K,1);
            for k=1 : K
                [~,ord]=sort(SimMat(k,:),'descend');
                ord(ord==k)=[];
                if neighNum > 0
                    Neigh{k}=ord(1:neighNum);
                else
                    Neigh{k}=[];
                end
            end
            varargout{1}=SimMat;
            varargout{2}=Neigh;
        
        %梯度缓存
        case "gradcache"
            K = varargin{1};
            D = varargin{2};
            Cache.x = zeros(K,D);
            Cache.g = zeros(K,D);
            Cache.has = false(K,1);
            varargout{1} = Cache;
        
        %决策修复
        case "repair"
            Problem = varargin{1};
            X       = varargin{2};
            varargout{1} = Problem.CalDec(X);
        
        %计算每个子问题的中心解与停滞判定指标
        case "centers"
            % 输入：
            %   Population : 已按 associate 重排后的种群（每个子问题连续 S 个体）
            %   W          : K×M 参考向量
            %   S          : 每个子问题个体数
            % 输出：
            %   Centers    : K×D 中心解（决策变量）
            %   Phi        : K×1 该中心解对应的标量指标值（越小越好）
            %   z          : 1×M 理想点（用于标量化）

            Population = varargin{1};
            W          = varargin{2};
            S          = varargin{3};

            K      = size(W,1);
            PopDec = Population.decs;
            PopObj = Population.objs;

            % 理想点：每个目标维度的当前最小值
            z = min(PopObj,[],1);

            Centers = zeros(K,size(PopDec,2));
            Phi     = zeros(K,1);

            for i = 1 : K
                idx  = (i-1)*S+1 : i*S;
                objs = PopObj(idx,:);

                % 中心解定义：与参考向量夹角最小
                sim = cosinesim(objs,W(i,:));
                [~,bestPos] = max(sim);
                Centers(i,:) = PopDec(idx(bestPos),:);

                % 停滞判定指标
                Phi(i,1) = scalar_tch(objs(bestPos,:),W(i,:),z);
            end

            varargout{1} = Centers;
            varargout{2} = Phi;
            varargout{3} = z;
        
        %有限差分估计标量指标梯度
        case "fdgrad"
            Problem = varargin{1};
            x       = varargin{2};
            w       = varargin{3};
            delta   = varargin{4};
            z       = varargin{5};

            x  = Problem.CalDec(x);
            P1 = Problem.Evaluation(x);
            s1 = scalar_tch(P1.objs,w,z);

            D  = size(x,2);
            g  = zeros(1,D);

            range = Problem.upper - Problem.lower;
            range(range<=0) = 1;

            for d = 1 : D
                h = max(delta*range(d),1e-12);
                x2    = x;
                x2(d) = x2(d) + h;
                x2    = Problem.CalDec(x2);

                P2 = Problem.Evaluation(x2);
                s2 = scalar_tch(P2.objs,w,z);

                g(d) = (s2 - s1) / h;
            end

            varargout{1} = g;

        otherwise
            error('Tool:UnknownOp','未知操作：%s',op);
    end
end

%余弦相似度
function Sim = cosinesim(A,B)
        An = sqrt(sum(A.^2,2));
        Bn = sqrt(sum(B.^2,2));
        An(An==0) = eps;
        Bn(Bn==0) = eps;
    
        Sim = (A*B') ./ (An*Bn');
        Sim(~isfinite(Sim)) = 0;
end

%标量化
function val = scalar_tch(Obj,w,z)
        w = max(w,1e-12);
        Obj = abs(Obj - z);
        val = max(Obj.*w,[],2);
    end
