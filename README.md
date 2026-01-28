# Multiobjective-GDUT

<pre>
Multiobjective-GDUT/
├── core/
│   ├── AlgorithmBase.m       # 算法基类
│   ├── Associate.m           # 解与子问题关联分配
│   ├── MOEADM2M.m            # M2M算法主类实现
│   ├── Operator.m            # 交叉与变异操作
│   └── uniformPoint.m        # 参考向量生成工具
├── metrics/
│   ├── HV.m                  # 超体积指标
│   ├── IGD.m                 # 反转世代距离
│   └── Spacing.m             # 间距指标
├── problems/
│   ├── benchmarks/
│   │   └── ZDT/
│   │       └── ZDT1.m        # ZDT1测试问题
│   └── utils/
│       └── ProblemBase.m     # 问题基类
├── utils/
│   ├── CrowdingDistance.m    # 拥挤距离计算
│   └── NDSort.m              # 非支配排序
└── README.md                 
</pre>