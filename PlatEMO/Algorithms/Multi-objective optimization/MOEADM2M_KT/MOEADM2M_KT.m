classdef MOEADM2M_KT < ALGORITHM

    methods
        function main(Algorithm,Problem)
            [K,Tstag,epsImp,rNew,step,neigh,localW,delta] = Algorithm.ParameterSet(100,10,1e-6,0.08,0.05,5,0.8,1e-6);

            [W,K]      = UniformPoint(K,Problem.M);
            Problem.N  = ceil(Problem.N/K)*K;
            S          = Problem.N/K;
            Population = Problem.Initialization();
            Population = associate(Population,W,S);

            [SimMat,Neigh] = Tool("sim",W,neigh);
            GradCache      = Tool("gradcache",K,Problem.D);
            BestPhi        = inf(K,1);
            Stall          = zeros(K,1);

            while Algorithm.NotTerminated(Population)
                MatingPoolLocal      = randi(S,S,K) + repmat(0:S:S*(K-1),S,1);
                MatingPoolGlobal     = randi(Problem.N,1,Problem.N);
                rnd                  = rand(S,K) < 0.7;
                MatingPoolLocal(rnd) = MatingPoolGlobal(rnd);
                Offspring  = Operator(Problem,Population,Population(MatingPoolLocal(:)));
                Population = associate([Population,Offspring],W,S);

                [Centers,Phi,z] = Tool("centers",Population,W,S);
                improved         = Phi < BestPhi - epsImp;
                BestPhi(improved) = Phi(improved);
                Stall(improved)   = 0;
                Stall(~improved)  = Stall(~improved) + 1;
                StagList          = find(Stall >= Tstag);

                if ~isempty(StagList)
                    % 停滞触发：仅对停滞子问题做梯度知识迁移并注入改进解
                    Opts.localW = localW;
                    Opts.step   = step;
                    Opts.rNew   = rNew;
                    Opts.delta  = delta;
                    Opts.z      = z;
                    Opts.epsImp = epsImp;

                    % KT 直接返回已评价的新解
                    [New,GradCache] = KT(Problem,Centers,Phi,W,Neigh,SimMat,StagList,GradCache,Opts);
                    if ~isempty(New)
                        Population = associate([Population,New],W,S);
                    end
                    Stall(StagList) = 0;
                end
            end
        end
    end
end
