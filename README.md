# GrafGen-manuscript

This git repo is used for the benchmark GrafGen, fastaBAPS, popPUNK and fineSTRUCTURE, test the robustness for the GrafGen manuscript.

# 1. Benchmarking GrafGen, fastBAPS, popPUNK, and fineSTRUCURE

This git repo is used for the benchmark GrafGen, fastaBAPS, popPUNK and fineSTRUCTURE in GrafGen manuscript.

## Step 1. Obtain software and installation

### GrafGen V2 beta (HpGP26695 as reference)
```
git clone -b v2.0_beta https://github.com/wheelerb/GrafGen
```

### fastBAPS
```
git clone https://github.com/gtonkinhill/fastbaps
```

### PopPUNK
```
git clone https://github.com/bacpop/PopPUNK

# Download PopPUNK database

https://www.bacpop.org/poppunk/
```

### fineSTRUCTURE
```
git clone https://github.com/danjlawson/finestructure4
```
## Step 2. Benchmark

### Step 2.1 Description
To check the performance of GrafGen, we benchmarked it with fastBAPS [x], PopPUNK[x] and fineSTRUCTURE[x]. Since we had knew the fact that fineSTRUCTURE is CPU intensive for large dataset, like HpGP[x], we did not re-run it again and just used the previous result with the same dataset to compare the agreement with GrafGen.  Also, the reason we used fastBAPS instead of BAPS was that BAPS was written in MATLAB code and we had an issue to compile it.  fastBAPS was a successor of BAPS with improved speed and features.

To compare the performance of these methods, we used Adjusted Rand Index (ARI, ranging from -1 to 1) and Normalized Mutual Information (NMI, ranging from 0 to 1) to evaluates the similarity between any two clustering assignments. Both have 1 for perfect match and 0 for random labeling. 

```
ARI evaluates the similarity between two clustering assignments by measuring how many pairs of points are assigned consistently (either together or apart) in both clusterings.

Key points:

Corrects for chance groupings (hence "adjusted").

Values range from -1 to 1:

1 = perfect match
0 = random labeling (expected by chance)
< 0 = worse than random (rare in practice)

Use case: Best when you care about exact pairwise cluster assignments.
```

```
NMI measures the amount of shared information between two clusterings, based on entropy (information theory).

Key points:

Values range from 0 to 1:

1 = identical clustering
0 = no mutual information (completely different)

Use case: Best when cluster labels may be permuted or unequal in size but structure is still similar. 
```
### Summary of Differences: 
|       |                               |                    |                              |
|-------|-------------------------------|--------------------|------------------------------|
|Metric |Sensitive to Label Permutation?|Accounts for Chance?|Best For                      |
|ARI    |No(invariant to label names)   |Yes                 |Matching cluster assignments  |
|NMI    |No (also label-invariant)      |No                  |Matching information/structure|


PopPUNK gives more than 980 clusters either using the software provided H. pylori database or our customed database. So we did not include PopPUNK for further evaluation. The results from fastBAPS gave us three clusters for single level assignment and 5, 7, 8, and 13 at multi-level assignment. We selected 8 cluster assignment for comparison since it is close to 9 clusters from GrafGen. fastBAPS shows higher agreement with the GrafGen(reference clustering) than fineSTRUCTURE, in terms of both ARI (0.711 vs. 0.625) and NMI (0.722 vs. 0.643). The difference is moderate, but fastBAPS appears to produce cluster assignments more consistent with the GrafGen.

### Step 2.2 The similarity of cluster assignments among methods

|Method      |ARI  |NMI  |
|------------|-----|-----|
|fastBAPS_c5 |0.673|0.672|
|fastBAPS_c7 |0.711|0.722|
|fastBAPS_c8 |0.711|0.722|
|fastBAPS_c13|0.711|0.722|
|FS          |0.647|0.617|
|FSsub       |0.625|0.643|
|PopPUNK     |0.001|0.267|

# 2. Check robustness
We use full set of SNPs and LD pruned (r<0.1) to check the robustness of GrafGen. 
The results show an near perfect agreement.

<img width="1308" height="633" alt="Screenshot 2025-09-24 at 6 46 12 PM" src="https://github.com/user-attachments/assets/71d5818c-5102-4b01-bda4-00390886722a" />



