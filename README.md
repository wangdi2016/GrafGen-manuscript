# GrafGen-benchmark

## Benchmarking GrafGen, fastBAPS, popPUNK, and fineSTRUCTURE

This git repo is used for the benchmark GrafGen, fastaBAPS, popPUNK and fineSTRUCTURE in GrafGen manuscript.

### 1. Obtain the software and installation

#### GrafGen V2 beta (HpGP26695 as reference)
```
git clone -b v2.0_beta https://github.com/wheelerb/GrafGen
```

#### fastBAPS
```
git clone https://github.com/gtonkinhill/fastbaps
```

#### PopPUNK
```
git clone https://github.com/bacpop/PopPUNK

# Download PopPUNK database

https://www.bacpop.org/poppunk/
```

### fineSTRUCTURE
```
git clone https://github.com/danjlawson/finestructure4
```

### 2. Benchmark

To check the performance of GrafGen, we benchmarked it with fastBAPS [x], PopPUNK[x] and fineSTRUCTURE[x]. Since we had knew the fact that fineSTRUCTURE is CPU intensive for large dataset, like HpGP[x], we did not re-run it again and just used the previous result with the same dataset to compare the agreement with GrafGen.  Also, the reason we used fastBAPS instead of BAPS was that BAPS was written in MATLAB code and we had an issue to compile it.  fastBAPS was a successor of BAPS with improved speed and features.

To compare the performance of these methods, we used Adjusted Rand Index (ARI, ranging from -1 to 1) and Normalized Mutual Information (NMI, ranging from 0 to 1) to evaluates the similarity between any two clustering assignments. Both have 1 for perfect match and 0 for random labeling. PopPUNK gives more than 980 clusters either using the software provided H. pylori database or our customed database. So we did not include PopPUNK for further evaluation. The results from fastBAPS gave us three clusters for single level assignment and 5, 7, 8, and 13 at multi-level assignment. We selected 8 cluster assignment for comparison since it is close to 9 clusters from GrafGen. fastBAPS shows higher agreement with the GrafGen(reference clustering) than fineSTRUCTURE, in terms of both ARI (0.711 vs. 0.625) and NMI (0.722 vs. 0.643). The difference is moderate, but fastBAPS appears to produce cluster assignments more consistent with the GrafGen. The benchmarking code can be access https://github.com/wangdi2016/GrafGen-benchmark.git


