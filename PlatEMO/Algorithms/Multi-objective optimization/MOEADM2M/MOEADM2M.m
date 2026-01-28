%MOEA/D-M2M算法实现 将多目标优化问题分解为多个简单多目标子问题
classdef MOEADM2M<AlgorithmBase
    properties
        K%参考向量数量
        W%参考向量集合
        S%子问题数量
    end

    methods
        function obj = MOEADM2M()
            obj@AlgorithmBase('MOEADM2M');
            obj.K = 10; % 默认参考向量数量
        end

        %主程序
        function Population=main(obj,Problem)
            obj.K = obj.getParameter(1, 10);
            obj.maxFE = Problem.maxFE;
            
            % 生成参考向量
            [obj.W, obj.K] = obj.uniformPoint(obj.K, Problem.M);
            
            % 调整种群大小为K的整数倍
            Problem.N = ceil(Problem.N / obj.K) * obj.K;
            obj.S = Problem.N / obj.K;
            
            % 初始化种群
            Population = Problem.initialization();
            
            % 将种群分配到子问题
            Population = obj.associate(Population, obj.W, obj.S);
            
            while obj.NotTerminated()
                MatingPoolLocal = obj.generateMatingPoolLocal();
                MatingPoolGlobal = obj.generateMatingPoolGlobal(Problem.N);
                MatingPool = obj.mixMatingPools(MatingPoolLocal, MatingPoolGlobal);
                Offspring = obj.operator(Problem, Population, Population(MatingPool(:)));
                Population = obj.associate([Population, Offspring], obj.W, obj.S);
            end
        end

        %生成均匀分布的参考向量
        function [W,K]=UniformPoint(obj,K,M)
            %输入；K-参考向量数量 M-目标数量
            %输出；W-参考向量集合 K-参考向量数量
            if M==2
                angles=linspace(0,pi/2,K);
                W=[cos(angles),sin(angles)]';
            else
                W=zeros(K,M);
                for i=1:M
                    w=rand(1,M);
                    W(1,:)=w/sum(w);
                end
            end
            K=size(W,1);
        end


        %生成局部交配池
        function MatingPoolLocal = generateMatingPoolLocal(obj)
            MatingPoolLocal = zeros(obj.S, obj.K);
            for i = 1:obj.K
                MatingPoolLocal(:, i) = randi(obj.S, obj.S, 1) + (i-1)*obj.S;
            end
            obj.FE = obj.FE + obj.S * obj.K;
        end

        %生成全局交配池
        function MatingPoolGlobal = generateMatingPoolGlobal(obj, totalN)
            MatingPoolGlobal = randi(totalN, 1, totalN);
            obj.FE = obj.FE + totalN;
        end

        %混合局部与全局交配池
        function MatingPool = mixMatingPools(obj, MatingPoolLocal, MatingPoolGlobal)
            [S, K] = size(MatingPoolLocal);
            mask = rand(S, K) < 0.7;
            MatingPool = MatingPoolLocal;
            MatingPool(mask) = MatingPoolGlobal(mask);
        end

    end
end