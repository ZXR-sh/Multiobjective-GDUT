
Multiobjective-GDUT/

├── core/                     # 核心算法实现

│   ├── MOEADM2M.m            # M2M算法主类实现
│   ├── Operator.m            # 交叉与变异操作
│   ├── Associate.m           # 解与子问题关联分配
│   ├── uniformPoint.m        # 参考向量生成工具
│   └── AlgorithmBase.m       # 算法基类

├── problems/                 # 优化问题定义

│   ├── benchmarks/           # 标准测试问题集
│   │   ├── ZDT/              # ZDT系列问题
│   │   │   ├── ZDT1.m
│   ├── utils/                # 问题工具函数
│   │   └── ProblemBase.m     # 问题基类

├── metrics/                  # 性能评估指标

│   ├── IGD.m                 # 反转世代距离
│   ├── HV.m                  # 超体积指标
│   ├── Spacing.m             # 间距指标

├── experiments/              # 实验管理

├── research/                 # 创新

├── utils/                    # 通用工具函数

│   ├── NDSort.m              # 非支配排序
│   ├── CrowdingDistance.m    # 拥挤距离计算

├── tests/                    # 测试用例
