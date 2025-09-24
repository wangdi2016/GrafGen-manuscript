# LD pruning --maf 0.01 --indep-pairwise 10 5 0.01 

hpylori.vcf.gz is copied from core.vcf.gz

## Step1 for LD pruning
```
nohup ./step1.ld.sh > step1.ld.log
```

### PLINK command

```
# LD prune r^2 < 0.01 (≈ r < 0.1)
plink2 --pfile hpylori.id --maf 0.01 --indep-pairwise 10 5 0.01 --out hpylori_ld
```

## Step2 for LD pruning grid
```
nohup ./step2.ldgrid.sh > step2.ldgrid.log
```
