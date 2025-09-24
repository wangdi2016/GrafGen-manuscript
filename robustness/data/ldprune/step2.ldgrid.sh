#!/usr/bin/env bash
set -euo pipefail

PFILE=${1:-hpylori.id}
OUTDIR=${2:-ldgrid}
mkdir -p "$OUTDIR"

# Count total variants and post-MAF (>0.01) variants
plink2 --pfile "$PFILE" --allow-extra-chr --write-snplist --out "$OUTDIR/all" >/dev/null
TOTAL=$(wc -l < "$OUTDIR/all.snplist")

plink2 --pfile "$PFILE" --allow-extra-chr --maf 0.01 --write-snplist --out "$OUTDIR/maf01" >/dev/null
POSTMAF=$(wc -l < "$OUTDIR/maf01.snplist")

# Header
printf "grid\tr2\twindow_kb\tstep_var\tkept\tpct_postmaf\tpct_total\tfile\n" > "$OUTDIR/ld_grid_summary.tsv"

# Grid A: vary r^2 (window=10 kb, step=5 variants)
for r2 in 0.01 0.02 0.05 0.10; do
  tag="r2_${r2}"
  plink2 --pfile "$PFILE" --allow-extra-chr --maf 0.01 \
         --indep-pairwise 10 5 $r2 --out "$OUTDIR/$tag" >/dev/null
  KEPT=$(wc -l < "$OUTDIR/$tag.prune.in")
  PCT_POST=$(awk -v k="$KEPT" -v n="$POSTMAF" 'BEGIN{if(n>0) printf "%.1f", 100*k/n; else print "NA"}')
  PCT_TOT=$(awk  -v k="$KEPT" -v n="$TOTAL"  'BEGIN{if(n>0) printf "%.1f", 100*k/n; else print "NA"}')
  printf "r2\t%s\t10\t5\t%d\t%s\t%s\t%s\n" "$r2" "$KEPT" "$PCT_POST" "$PCT_TOT" "$OUTDIR/$tag.prune.in" >> "$OUTDIR/ld_grid_summary.tsv"
done

# Grid B: vary window (r^2=0.01, step=5 variants)
for win in 5 10 25 50; do
  tag="win_${win}"
  plink2 --pfile "$PFILE" --allow-extra-chr --maf 0.01 \
         --indep-pairwise $win 5 0.01 --out "$OUTDIR/$tag" >/dev/null
  KEPT=$(wc -l < "$OUTDIR/$tag.prune.in")
  PCT_POST=$(awk -v k="$KEPT" -v n="$POSTMAF" 'BEGIN{if(n>0) printf "%.1f", 100*k/n; else print "NA"}')
  PCT_TOT=$(awk  -v k="$KEPT" -v n="$TOTAL"  'BEGIN{if(n>0) printf "%.1f", 100*k/n; else print "NA"}')
  printf "window\t0.01\t%s\t5\t%d\t%s\t%s\t%s\n" "$win" "$KEPT" "$PCT_POST" "$PCT_TOT" "$OUTDIR/$tag.prune.in" >> "$OUTDIR/ld_grid_summary.tsv"
done

# Nicely aligned view
echo
echo "== LD grid summary =="
column -t -s $'\t' "$OUTDIR/ld_grid_summary.tsv" | tee "$OUTDIR/ld_grid_summary.pretty.txt"

echo
echo "Wrote:"
echo " - $OUTDIR/ld_grid_summary.tsv        (machine-readable)"
echo " - $OUTDIR/ld_grid_summary.pretty.txt (aligned for quick copy into docs)"

## make plot
nohup Rscript ldgrid.R > ldgrid.log
