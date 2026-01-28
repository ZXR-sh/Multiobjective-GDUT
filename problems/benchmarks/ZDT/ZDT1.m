% ZDT1 测试问题  双目标优化问题，凸Pareto前沿
classdef ZDT1 < ProblemBase
    
    methods
        function obj = ZDT1()
            obj@ProblemBase('ZDT1', 2, 30, zeros(1,30), ones(1,30));
            obj.N = 100; % 默认种群大小
            obj.maxFE = 25000; % 默认最大评估次数
        end
        
        % 评估ZDT1的目标函数
        function Objs = evaluateObjectives(obj, Dec)
            
            % 第一个目标函数
            f1 = Dec(1);
            
            % 计算g
            n = length(Dec);
            g = 1 + 9 * sum(Dec(2:n)) / (n-1);
            
            % 计算第二个目标函数
            h = 1 - sqrt(f1 / g);
            f2 = g * h;
            
            % 返回目标值
            Objs = [f1, f2];
        end
        
        function TruePF = getTruePF(obj, numPoints)
            % 获取ZDT1的真实Pareto前沿
            if nargin < 2
                numPoints = 100;
            end
            
            f1 = linspace(0, 1, numPoints);
            f2 = 1 - sqrt(f1);
            TruePF = [f1', f2'];
        end
    end
end