#!/usr/bin/env bash
#SBATCH -A naiss2023-22-479
#SBATCH -p node
#SBATCH -n 1
#SBATCH -o 20231027_Mummy_w_Europe_ite.txt
#SBATCH -t 7-00:00:00
#SBATCH -J FS_mummy_Wite
#SBATCH --mail-type=ALL

fs Hp2.cp -idfile MummyEurope_aln.list -phasefiles MummyEurope_aln.phase -recombfiles MummyEurope_aln.recombfile -ploidy 1 -s3iters 200000 -numskip 1000 -go
#fs Hp.cp -idfile MummyEurope_aln.list -phasefiles MummyEurope_aln.phase -recombfiles MummyEurope_aln.recombfile -ploidy 1 -go
