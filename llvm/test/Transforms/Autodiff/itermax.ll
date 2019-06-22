; RUN: opt < %s -lower-autodiff -inline -mem2reg -adce -aggressive-instcombine -instsimplify -early-cse-memssa -simplifycfg -correlated-propagation -adce -S | FileCheck %s

; Function Attrs: nounwind uwtable
define dso_local void @dsincos(double* noalias %x, double* noalias %xp, i64 %n) local_unnamed_addr #0 {
entry:
  %0 = tail call double (double (double*, i64)*, ...) @llvm.autodiff.p0f_f64p0f64i64f(double (double*, i64)* nonnull @iterA, double* %x, double* %xp, i64 %n)
  ret void
}

; Function Attrs: noinline norecurse nounwind readonly uwtable
define internal double @iterA(double* noalias nocapture readonly %x, i64 %n) #1 {
entry:
  %0 = load double, double* %x, align 8, !tbaa !2
  %exitcond11 = icmp eq i64 %n, 0
  br i1 %exitcond11, label %for.cond.cleanup, label %for.body.for.body_crit_edge

for.cond.cleanup:                                 ; preds = %for.body.for.body_crit_edge, %entry
  %cond.i.lcssa = phi double [ %0, %entry ], [ %cond.i, %for.body.for.body_crit_edge ]
  ret double %cond.i.lcssa

for.body.for.body_crit_edge:                      ; preds = %entry, %for.body.for.body_crit_edge
  %indvars.iv.next13 = phi i64 [ %indvars.iv.next, %for.body.for.body_crit_edge ], [ 1, %entry ]
  %cond.i12 = phi double [ %cond.i, %for.body.for.body_crit_edge ], [ %0, %entry ]
  %arrayidx2.phi.trans.insert = getelementptr inbounds double, double* %x, i64 %indvars.iv.next13
  %.pre = load double, double* %arrayidx2.phi.trans.insert, align 8, !tbaa !2
  %cmp.i = fcmp fast ogt double %cond.i12, %.pre
  %cond.i = select i1 %cmp.i, double %cond.i12, double %.pre
  %indvars.iv.next = add nuw i64 %indvars.iv.next13, 1
  %exitcond = icmp eq i64 %indvars.iv.next13, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body.for.body_crit_edge
}

; Function Attrs: nounwind
declare double @llvm.autodiff.p0f_f64p0f64i64f(double (double*, i64)*, ...) #2

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #1 = { noinline norecurse nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.1.0 "}
!2 = !{!3, !3, i64 0}
!3 = !{!"double", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}


; CHECK: define internal {} @diffeiterA(double* noalias nocapture readonly %x, double* %"x'", i64 %n)
; CHECK-NEXT: entry:
; CHECK-NEXT:   %malloccall = tail call i8* @malloc(i64 %n)
; CHECK-NEXT:   %cmp.i_malloccache = bitcast i8* %malloccall to i1*
; CHECK-NEXT:   %0 = load double, double* %x, align 8, !tbaa !2
; CHECK-NEXT:   %exitcond11 = icmp eq i64 %n, 0
; CHECK-NEXT:   br i1 %exitcond11, label %invertfor.cond.cleanup, label %for.body.for.body_crit_edge.preheader

; CHECK: for.body.for.body_crit_edge.preheader:            ; preds = %entry
; CHECK-NEXT:   %1 = add i64 %n, -1
; CHECK-NEXT:   br label %for.body.for.body_crit_edge

; CHECK: for.body.for.body_crit_edge:                      ; preds = %for.body.for.body_crit_edge, %for.body.for.body_crit_edge.preheader
; CHECK-NEXT:   %indvar = phi i64 [ 0, %for.body.for.body_crit_edge.preheader ], [ %2, %for.body.for.body_crit_edge ]
; CHECK-NEXT:   %cond.i12 = phi double [ %cond.i, %for.body.for.body_crit_edge ], [ %0, %for.body.for.body_crit_edge.preheader ]
; CHECK-NEXT:   %2 = add i64 %indvar, 1
; CHECK-NEXT:   %3 = icmp ult i64 %indvar, %1
; CHECK-NEXT:   %arrayidx2.phi.trans.insert = getelementptr inbounds double, double* %x, i64 %2
; CHECK-NEXT:   %.pre = load double, double* %arrayidx2.phi.trans.insert, align 8, !tbaa !2
; CHECK-NEXT:   %cmp.i = fcmp fast ogt double %cond.i12, %.pre
; CHECK-NEXT:   %4 = getelementptr i1, i1* %cmp.i_malloccache, i64 %indvar
; CHECK-NEXT:   store i1 %cmp.i, i1* %4
; CHECK-NEXT:   %cond.i = select i1 %cmp.i, double %cond.i12, double %.pre
; CHECK-NEXT:   br i1 %3, label %for.body.for.body_crit_edge, label %invertfor.cond.cleanup

; CHECK: invertentry:                                      ; preds = %invertfor.body.for.body_crit_edge.preheader, %invertfor.cond.cleanup
; CHECK-NEXT:   %"'de.0" = phi double [ %diffecond.i12, %invertfor.body.for.body_crit_edge.preheader ], [ 1.000000e+00, %invertfor.cond.cleanup ]
; CHECK-NEXT:   %5 = load double, double* %"x'"
; CHECK-NEXT:   %6 = fadd fast double %5, %"'de.0"
; CHECK-NEXT:   store double %6, double* %"x'"
; CHECK-NEXT:   ret {} undef

; CHECK: invertfor.body.for.body_crit_edge.preheader:      ; preds = %invertfor.body.for.body_crit_edge
; CHECK-NEXT:   tail call void @free(i8* nonnull %malloccall)
; CHECK-NEXT:   br label %invertentry

; CHECK: invertfor.cond.cleanup.loopexit:                  ; preds = %invertfor.cond.cleanup
; CHECK-NEXT:   %7 = add i64 %n, -1
; CHECK-NEXT:   br label %invertfor.body.for.body_crit_edge

; CHECK: invertfor.cond.cleanup:                           ; preds = %for.body.for.body_crit_edge, %entry
; CHECK-NEXT:   %8 = xor i1 %exitcond11, true
; CHECK-NEXT:   br i1 %8, label %invertfor.cond.cleanup.loopexit, label %invertentry

; CHECK: invertfor.body.for.body_crit_edge:                ; preds = %invertfor.cond.cleanup.loopexit, %invertfor.body.for.body_crit_edge
; CHECK-NEXT:   %"cond.i'de.0" = phi double [ 1.000000e+00, %invertfor.cond.cleanup.loopexit ], [ %diffecond.i12, %invertfor.body.for.body_crit_edge ]
; CHECK-NEXT:   %"indvar'phi" = phi i64 [ %7, %invertfor.cond.cleanup.loopexit ], [ %9, %invertfor.body.for.body_crit_edge ]
; CHECK-NEXT:   %9 = sub i64 %"indvar'phi", 1
; CHECK-NEXT:   %10 = getelementptr i1, i1* %cmp.i_malloccache, i64 %"indvar'phi"
; CHECK-NEXT:   %11 = load i1, i1* %10
; CHECK-NEXT:   %diffecond.i12 = select i1 %11, double %"cond.i'de.0", double 0.000000e+00
; CHECK-NEXT:   %diffe.pre = select i1 %11, double 0.000000e+00, double %"cond.i'de.0"
; CHECK-NEXT:   %12 = add i64 %"indvar'phi", 1
; CHECK-NEXT:   %"arrayidx2.phi.trans.insert'ip" = getelementptr double, double* %"x'", i64 %12
; CHECK-NEXT:   %13 = load double, double* %"arrayidx2.phi.trans.insert'ip"
; CHECK-NEXT:   %14 = fadd fast double %13, %diffe.pre
; CHECK-NEXT:   store double %14, double* %"arrayidx2.phi.trans.insert'ip"
; CHECK-NEXT:   %15 = icmp ne i64 %"indvar'phi", 0
; CHECK-NEXT:   br i1 %15, label %invertfor.body.for.body_crit_edge, label %invertfor.body.for.body_crit_edge.preheader
; CHECK-NEXT: }
