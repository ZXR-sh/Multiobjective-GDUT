function Summary = compare_test(varargin)
Root = fileparts(mfilename('fullpath'));
cd(Root);
addpath(genpath(Root));
rehash toolboxcache;

Defaults.runs   = 10;
Defaults.N      = 100;
Defaults.maxFE  = 10000;
Defaults.K      = 100;
Defaults.metrics = {'IGD','HV','GD'};
Defaults.problems = { ...
    struct('name','ZDT1','ctor',@ZDT1,'args',{{}}), ...
    struct('name','ZDT2','ctor',@ZDT2,'args',{{}}), ...
    struct('name','ZDT3','ctor',@ZDT3,'args',{{}}), ...
    struct('name','ZDT4','ctor',@ZDT4,'args',{{}}), ...
    struct('name','DTLZ1(M=3)','ctor',@DTLZ1,'args',{{'M',3}}), ...
    struct('name','DTLZ2(M=3)','ctor',@DTLZ2,'args',{{'M',3}}), ...
    struct('name','DTLZ3(M=3)','ctor',@DTLZ3,'args',{{'M',3}}), ...
    struct('name','DTLZ4(M=3)','ctor',@DTLZ4,'args',{{'M',3}}), ...
    struct('name','DTLZ2(M=5)','ctor',@DTLZ2,'args',{{'M',5}}) ...
    };

Opts = Defaults;
for i = 1 : 2 : numel(varargin)
    Opts.(varargin{i}) = varargin{i+1};
end

if ~isfield(Opts,'showProgress')
    Opts.showProgress = true;
end

Algs = { ...
    struct('name','MOEADM2M','ctor',@MOEADM2M,'param',{{Opts.K}}), ...
    struct('name','MOEADM2M_KT','ctor',@MOEADM2M_KT,'param',{{Opts.K,[],[],[],[],[],[],[]}}) ...
    };

nP = numel(Opts.problems);
nA = numel(Algs);
nR = Opts.runs;
nM = numel(Opts.metrics);

Scores  = nan(nP,nA,nR,nM);
Runtime = nan(nP,nA,nR);

if Opts.showProgress
    totalJobs = nP*nR*nA;
    fprintf('compare_test 开始：问题=%d，runs=%d，算法=%d，maxFE=%d，总任务=%d\n',nP,nR,nA,Opts.maxFE,totalJobs);
    fprintf('提示：默认 runs=10 且 maxFE=10000，可能需要较长时间；可用 compare_test(''runs'',1,''maxFE'',2000) 快速验证\n');
end

for p = 1 : nP
    proInfo = Opts.problems{p};
    for r = 1 : nR
        for a = 1 : nA
            if Opts.showProgress
                jobId = (p-1)*nR*nA + (r-1)*nA + a;
                fprintf('[%d/%d] %s | run=%d/%d | %s\n',jobId,totalJobs,proInfo.name,r,nR,Algs{a}.name);
            end
            rng(r,'twister');
            Problem = proInfo.ctor('N',Opts.N,'maxFE',Opts.maxFE,proInfo.args{:});
            Algorithm = Algs{a}.ctor('parameter',Algs{a}.param,'save',0,'run',r,'outputFcn',@(~,~)[]);
            Algorithm.Solve(Problem);
            P = Algorithm.result{end};
            for m = 1 : nM
                Scores(p,a,r,m) = Problem.CalMetric(Opts.metrics{m},P);
            end
            Runtime(p,a,r) = Algorithm.metric.runtime;
        end
    end
end

Summary = struct();
Summary.problems = cellfun(@(s)s.name,Opts.problems,'UniformOutput',false);
Summary.algorithms = cellfun(@(s)s.name,Algs,'UniformOutput',false);
Summary.metrics = Opts.metrics;
Summary.runs = nR;
Summary.N = Opts.N;
Summary.maxFE = Opts.maxFE;
Summary.K = Opts.K;
Summary.scores = Scores;
Summary.runtime = Runtime;
Summary.mean = squeeze(mean(Scores,3,'omitnan'));
Summary.std  = squeeze(std(Scores,0,3,'omitnan'));
Summary.runtime_mean = squeeze(mean(Runtime,3,'omitnan'));
Summary.runtime_std  = squeeze(std(Runtime,0,3,'omitnan'));

save(fullfile(Root,'Data','MOEADM2M_vs_MOEADM2M_KT_summary.mat'),'Summary');

disp('==== 对比结果（按问题-指标对照，使用均值 mean）====');
for p = 1 : nP
    disp(['问题',num2str(p),'：',Summary.problems{p}]);
    for m = 1 : nM
        metric = Summary.metrics{m};
        v1 = Summary.mean(p,1,m);
        v2 = Summary.mean(p,2,m);
        disp(sprintf('%s：  M2M:%.4e   KT:%.4e',metric,v1,v2));
    end
    disp(' ');
end
end
