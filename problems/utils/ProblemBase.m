%优化问题基类
classdef ProblemBase < handle
 
    properties
        name     % 问题名称
        N        % 种群大小
        M        % 目标数量
        D        % 决策变量维度
        lower    % 决策变量下界
        upper    % 决策变量上界
        maxFE    % 最大评估次数
        FE       % 当前评估次数
    end
    
    methods
        function obj = ProblemBase(name, M, D, lower, upper)
            obj.name = name;
            obj.M = M;
            obj.D = D;
            obj.lower = lower;
            obj.upper = upper;
            obj.FE = 0;
        end

        % 初始化种群
        function Population = initialization(obj)
            
            Decs = obj.lower + rand(obj.N, obj.D) .* (obj.upper - obj.lower);
            Population = obj.evaluation(Decs);
        end
        
        % 评估决策变量
        function Population = evaluation(obj, Decs)
            
            N = size(Decs, 1);
            Population = struct('decs', {}, 'objs', {});
            
            for i = 1:N
                % 计算目标值
                Objs = obj.evaluateObjectives(Decs(i, :));
                
                % 创建解结构
                Population(i).decs = Decs(i, :);
                Population(i).objs = Objs;
                
                obj.FE = obj.FE + 1;
            end
        end
        
        % 评估单个解的目标值
        function Objs = evaluateObjectives(obj, Dec)
            
            error('ProblemBase:evaluateObjectives', 'Subclasses must implement the evaluateObjectives method.');
        end
    end
end