gzip -dcf Ensembl-homo_sapiens-101-cdna.fa.gz | grep ">" | tr -d ">" | cut -d " " -f 1,4,7 | tr ".:" "\t" | cut -f 1,3,5 > Homo_sapiens.101.transcriptGeneTable.txt

