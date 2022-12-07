library(data.table)

ff <- list.files(); ff <- ff[grep("ENS", ff)]

tmp <- data.table(file_name = ff, ix = 1:length(ff))

exons <- data.table()
for (i in tmp$ix) {
  ff <- tmp[i, file_name]
  dt <- fread(ff); dt[, Sequence := NULL]
  dt[, transcript := gsub("\\.csv", "", ff)]
  exons <- rbind(exons, dt)
}
colnames(exons) <- c("n", "exon_id", "start", "end", "start_phase", "end_phase", "length", "transcript")
exons <- exons[grep("ENS", exon_id), ]
exons[, ':=' (start = as.integer(gsub(",","",start)), end = as.integer(gsub(",","",end)),
              length = as.integer(gsub(",","",end)))]

tmp[, transcript := gsub("\\.csv", "", file_name)]
fwrite(tmp, "transcripts_table.txt", sep = "\t")

dt <- exons[, .(exon_id, start, end, length, transcript)]

exons <- data.table()
for (i in unique(dt$exon_id)) {
  tmp <- dt[exon_id == i, ]
  a <- tmp[1, .(exon_id, start, end, length)]
  a[, ':=' (n_transcripts = nrow(tmp), transcripts = paste0(tmp$transcript, collapse=","))]
  exons <- rbind(exons, a)
}
fwrite(exons, "unique_exons.txt", sep = "\t")
