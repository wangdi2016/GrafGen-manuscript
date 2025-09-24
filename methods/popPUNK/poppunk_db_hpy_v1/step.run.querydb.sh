#!/bin/bash

#source /mnt/nfs/gigantor/ifs/DCEG/Projects/BB/DW/mambaforge/etc/profile.d/conda.sh
#mamba activate poppunk
source /Users/wangdi/apps/anaconda3/etc/profile.d/conda.sh
conda activate poppunk

hpy_db="Helicobacter_pylori_v1_refs"

# Step : Assign new genomes to existing model
/usr/bin/time -l poppunk_assign --db ${hpy_db} \
                                --query qfile.genome.txt \
                                --core \
                                --output poppunk_clusters \
                                --threads 1 > step.log.txt 2> step.usage.txt


