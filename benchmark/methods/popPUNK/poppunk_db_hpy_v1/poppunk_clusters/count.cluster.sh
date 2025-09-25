awk 'BEGIN{FS=OFS=","} {print $2}' poppunk_clusters_clusters.csv | sort | uniq | wc -l
