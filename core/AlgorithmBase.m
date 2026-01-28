%算法基类
classdef AlgorithmBase<handle
    properties
        FE%当前评估次数
        maxFE%最大评估次数
        Parameters%算法参数列表
        name%算法名称
    end

    methods
        function obj=AlgorithmBase(name)
            obj.name = name;
            obj.FE=0;
            obj.maxFE=100000;
            obj.Parameters={};
        end

        function param=getParameter(obj,index,defaultValue)
            if numel(obj.Parameters) >= index && ~isempty(obj.Parameters{index})
                param = obj.Parameters{index};
            else
                param = defaultValue;
            end
        end

        function bool = NotTerminated(obj)
            bool = obj.FE < obj.maxFE;
        end
        
        function Population = main(obj, Problem)
            error('AlgorithmBase:main', 'Subclasses must implement the main method.');
        end
    end
end