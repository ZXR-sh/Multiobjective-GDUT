
# Multiobjective-GDUT

多目标优化算法框架，基于 MOEA/D-M2M 算法实现。

## 项目结构

Multiobjective-GDUT/ ├── core/ # 核心算法实现 │ ├── AlgorithmBase.m # 算法基类 │ ├── Associate.m # 解与子问题关联分配 │ ├── MOEADM2M.m # M2M算法主类实现 │ ├── Operator.m # 交叉与变异操作 │ └── uniformPoint.m # 参考向量生成工具 ├── metrics/ # 性能评估指标 │ ├── HV.m # 超体积指标 │ ├── IGD.m # 反转世代距离 │ └── Spacing.m # 间距指标 ├── problems/ # 优化问题定义 │ ├── benchmarks/ # 标准测试问题集 │ │ └── ZDT/ # ZDT系列问题 │ │ └── ZDT1.m # ZDT1测试问题 │ └── utils/ # 问题工具函数 │ └── ProblemBase.m # 问题基类 ├── utils/ # 通用工具函数 │ ├── CrowdingDistance.m # 拥挤距离计算 │ └── NDSort.m # 非支配排序
