# Reuse saved calibration and shared-rater scores. No simulation or refitting.
pkgload::load_all('.',quiet=TRUE)
out <- 'validation-results/model-maps-20260923'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
writeLines(c('Maps: fixed/rater coefficient plus unweighted mean step; other effects zero.',
 'No composite calibration interval; only conditional Person whiskers.',
 'Person comparisons: center at fitted population mean, keep Rasch logit unit.',
 'Independent ordinary EAP/SD/tail integration: 1e-7; fitted zero-testlet reduction: 1e-5.',
 'No Person/model difference intervals, fit cutoff, coverage or accuracy claim.'),file.path(out,'protocol.txt'))
o <- readRDS('validation-results/extended-comparison-20260923/ordinary.rds')
t <- readRDS('validation-results/response-diagnostics-20260923/testlet-workflow.rds')
r <- readRDS('validation-results/random-rater-scoring-20260923/workflow.rds')
ordinary <- if(file.exists(file.path(out,'ordinary-scores.rds'))) readRDS(file.path(out,'ordinary-scores.rds')) else score_mfrm_persons(o)
mfrm_validate_person_scores(o,ordinary)
saveRDS(ordinary,file.path(out,'ordinary-scores.rds'))
stopifnot(all(ordinary$table$Status=='available_conditional'))
# Keep the whole source roster while selecting returned Persons.
testlet <- if(file.exists(file.path(out,'testlet-scores.rds'))) readRDS(file.path(out,'testlet-scores.rds')) else score_mfrm_persons(t$fit,persons=head(ordinary$table$Person,4))
mfrm_validate_person_scores(t$fit,testlet)
saveRDS(testlet,file.path(out,'testlet-scores.rds'))
stopifnot(all(testlet$table$Status=='available_conditional'),nrow(testlet$scoring_data)==768)
for(name in c('testlet','random')) {
 fit <- if(name=='testlet') t$fit else r$fit
 scores <- if(name=='testlet') testlet else r$scores
 mfrm_validate_person_scores(fit,scores)
 reference <- ordinary
 reference$table <- ordinary$table[match(scores$table$Person,ordinary$table$Person),]
 cmp <- compare_mfrm(o,fit,person_scores=list(reference,scores))
 # Existing response summaries are reused; no new shared-rater integrals.
 diagnostics <- if(name=='testlet') t$diagnostics else readRDS('validation-results/response-diagnostics-20260923/random-workflow.rds')$diagnostics
 res <- mfrm_results(fit,scores=scores,comparison=cmp,response_diagnostics=diagnostics)
 saveRDS(res,file.path(out,paste0(name,'-results.rds')))
 saveRDS(cmp,file.path(out,paste0(name,'-comparison.rds')))
 for(type in c('wright','fit_pathway')) {
   png(file.path(out,paste0(name,'-',type,'.png')),width=1400,height=1000,res=144)
   plot(res,type=type)
   dev.off()
   payload <- plot(res,type=type,draw=FALSE)
   saveRDS(payload,file.path(out,paste0(name,'-',type,'-plot.rds')))
   ggplot2::ggsave(file.path(out,paste0(name,'-',type,'-mono.png')),
     as_ggplot(plot(res,type=type,draw=FALSE,palette='mono',show_title=FALSE,show_notes=FALSE)),width=10,height=6.5,dpi=144)
 }
 exported <- export_mfrm_results(res,output_dir=file.path(out,paste0(name,'-archive')),preset='starter',acknowledge_sensitive=TRUE,overwrite=TRUE)
 stopifnot(nrow(exported$plot_errors)==0)
 saveRDS(exported,file.path(out,paste0(name,'-export.rds')))
}
z <- readRDS('validation-results/extended-comparison-20260923/zero-reference.rds')
zs <- score_mfrm_persons(z$ordinary,persons=head(ordinary$table$Person,4))
zt <- score_mfrm_persons(z$zero_testlet,persons=zs$table$Person)
zcmp <- compare_mfrm(z$ordinary,z$zero_testlet,person_scores=list(zs,zt))
d <- zcmp$persons$table
error <- c(EAP=max(abs(d$Difference)),SD=max(abs(d$ConditionalSDReference-d$ConditionalSDComparison)),
 Lower=max(abs(d$LowerReference-d$LowerComparison)),Upper=max(abs(d$UpperReference-d$UpperComparison)))
stopifnot(all(error<1e-5))
saveRDS(list(comparison=zcmp,error=error),file.path(out,'zero-testlet.rds'))
write.csv(data.frame(Quantity=names(error),MaximumDifference=error,Tolerance=1e-5),file.path(out,'numerical-summary.csv'),row.names=FALSE)
print(error)
capture.output(sessionInfo(),file=file.path(out,'session-info.txt'))
