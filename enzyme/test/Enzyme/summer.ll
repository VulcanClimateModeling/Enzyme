; RUN: opt < %s %loadEnzyme -enzyme -inline -ipconstprop -deadargelim -mem2reg -instsimplify -adce -loop-deletion -correlated-propagation -simplifycfg -S | FileCheck %s

@.str = private unnamed_addr constant [25 x i8] c"xs[%d] = %f xp[%d] = %f\0A\00", align 1
@.str.1 = private unnamed_addr constant [7 x i8] c"n != 0\00", align 1
@.str.2 = private unnamed_addr constant [9 x i8] c"summer.c\00", align 1
@__PRETTY_FUNCTION__.summer = private unnamed_addr constant [40 x i8] c"double summer(double *restrict, size_t)\00", align 1
@.str.3 = private unnamed_addr constant [19 x i8] c"i print things %f\0A\00", align 1
@.str.4 = private unnamed_addr constant [7 x i8] c"n != 1\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local void @derivative(double* noalias %x, double* noalias %xp, i64 %n) local_unnamed_addr #0 {
entry:
  %0 = tail call double (double (double*, i64)*, ...) @__enzyme_autodiff(double (double*, i64)* nonnull @summer, double* %x, double* %xp, i64 %n)
  ret void
}

; Function Attrs: noinline nounwind uwtable
define internal double @summer(double* noalias nocapture readonly %x, i64 %n) #0 {
entry:
  %cmp = icmp eq i64 %n, 0
  br i1 %cmp, label %cond.false, label %cond.end

cond.false:                                       ; preds = %entry
  tail call void @__assert_fail(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.1, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i64 0, i64 0), i32 11, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @__PRETTY_FUNCTION__.summer, i64 0, i64 0)) #6
  unreachable

cond.end:                                         ; preds = %entry
  %call = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.3, i64 0, i64 0), double 0.000000e+00)
  %cmp1 = icmp eq i64 %n, 1
  br i1 %cmp1, label %cond.false3, label %for.body.preheader

cond.false3:                                      ; preds = %cond.end
  tail call void @__assert_fail(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.4, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i64 0, i64 0), i32 13, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @__PRETTY_FUNCTION__.summer, i64 0, i64 0)) #6
  unreachable

for.body.preheader:                               ; preds = %cond.end
  %0 = load double, double* %x, align 8, !tbaa !2
  br label %for.body.for.body_crit_edge

for.cond.cleanup:                                 ; preds = %for.body.for.body_crit_edge
  %sub = fsub fast double %0, %cond.i
  ret double %sub

for.body.for.body_crit_edge:                      ; preds = %for.body.for.body_crit_edge, %for.body.preheader
  %indvars.iv.next29 = phi i64 [ 1, %for.body.preheader ], [ %indvars.iv.next, %for.body.for.body_crit_edge ]
  %cond.i28 = phi double [ %0, %for.body.preheader ], [ %cond.i, %for.body.for.body_crit_edge ]
  %arrayidx9.phi.trans.insert = getelementptr inbounds double, double* %x, i64 %indvars.iv.next29
  %.pre = load double, double* %arrayidx9.phi.trans.insert, align 8, !tbaa !2
  %cmp.i = fcmp fast ogt double %cond.i28, %.pre
  %cond.i = select i1 %cmp.i, double %cond.i28, double %.pre
  %indvars.iv.next = add nuw i64 %indvars.iv.next29, 1
  %exitcond = icmp eq i64 %indvars.iv.next, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body.for.body_crit_edge
}

; Function Attrs: nounwind
declare double @__enzyme_autodiff(double (double*, i64)*, ...) #1

; Function Attrs: nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #2 {
entry:
  %xs = alloca [10 x double], align 16
  %xp = alloca [10 x double], align 16
  %0 = bitcast [10 x double]* %xs to i8*
  call void @llvm.lifetime.start.p0i8(i64 80, i8* nonnull %0) #1
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %0, i8 0, i64 80, i1 false)
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  %1 = bitcast [10 x double]* %xp to i8*
  call void @llvm.lifetime.start.p0i8(i64 80, i8* nonnull %1) #1
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %1, i8 0, i64 80, i1 false)
  %arraydecay = getelementptr inbounds [10 x double], [10 x double]* %xs, i64 0, i64 0
  %arraydecay1 = getelementptr inbounds [10 x double], [10 x double]* %xp, i64 0, i64 0
  call void @derivative(double* nonnull %arraydecay, double* nonnull %arraydecay1, i64 10)
  br label %for.body7

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv27 = phi i64 [ 0, %entry ], [ %indvars.iv.next28, %for.body ]
  %2 = trunc i64 %indvars.iv27 to i32
  %conv = sitofp i32 %2 to double
  %arrayidx = getelementptr inbounds [10 x double], [10 x double]* %xs, i64 0, i64 %indvars.iv27
  store double %conv, double* %arrayidx, align 8, !tbaa !2
  %indvars.iv.next28 = add nuw nsw i64 %indvars.iv27, 1
  %exitcond29 = icmp eq i64 %indvars.iv.next28, 10
  br i1 %exitcond29, label %for.cond.cleanup, label %for.body

for.cond.cleanup6:                                ; preds = %for.body7
  call void @llvm.lifetime.end.p0i8(i64 80, i8* nonnull %1) #1
  call void @llvm.lifetime.end.p0i8(i64 80, i8* nonnull %0) #1
  ret i32 0

for.body7:                                        ; preds = %for.body7, %for.cond.cleanup
  %indvars.iv = phi i64 [ 0, %for.cond.cleanup ], [ %indvars.iv.next, %for.body7 ]
  %arrayidx9 = getelementptr inbounds [10 x double], [10 x double]* %xs, i64 0, i64 %indvars.iv
  %3 = load double, double* %arrayidx9, align 8, !tbaa !2
  %arrayidx11 = getelementptr inbounds [10 x double], [10 x double]* %xp, i64 0, i64 %indvars.iv
  %4 = load double, double* %arrayidx11, align 8, !tbaa !2
  %5 = trunc i64 %indvars.iv to i32
  %call = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i64 0, i64 0), i32 %5, double %3, i32 %5, double %4)
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 10
  br i1 %exitcond, label %for.cond.cleanup6, label %for.body7
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #3

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1) #3

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #3

; Function Attrs: nounwind
declare dso_local i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #4

; Function Attrs: noreturn nounwind
declare dso_local void @__assert_fail(i8*, i8*, i32, i8*) local_unnamed_addr #5

attributes #0 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind }
attributes #4 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #5 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #6 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.1.0 "}
!2 = !{!3, !3, i64 0}
!3 = !{!"double", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}


; CHECK: define internal void @diffesummer(double* noalias nocapture readonly %x, double* %"x'", i64 %n) #0 {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %cmp = icmp eq i64 %n, 0
; CHECK-NEXT:   br i1 %cmp, label %cond.false, label %cond.end

; CHECK: cond.false:                                       ; preds = %entry
; CHECK-NEXT:   tail call void @__assert_fail(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.1, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i64 0, i64 0), i32 11, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @__PRETTY_FUNCTION__.summer, i64 0, i64 0)) #6
; CHECK-NEXT:   unreachable

; CHECK: cond.end:                                         ; preds = %entry
; CHECK-NEXT:   %call = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.3, i64 0, i64 0), double 0.000000e+00)
; CHECK-NEXT:   %cmp1 = icmp eq i64 %n, 1
; CHECK-NEXT:   br i1 %cmp1, label %cond.false3, label %for.body.preheader

; CHECK: cond.false3:                                      ; preds = %cond.end
; CHECK-NEXT:   tail call void @__assert_fail(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.4, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.2, i64 0, i64 0), i32 13, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @__PRETTY_FUNCTION__.summer, i64 0, i64 0)) #6
; CHECK-NEXT:   unreachable

; CHECK: for.body.preheader:                               ; preds = %cond.end
; CHECK-NEXT:   %0 = load double, double* %x, align 8, !tbaa !2
; CHECK-NEXT:   %1 = add i64 %n, -2
; CHECK-NEXT:   %2 = add i64 %n, -2
; CHECK-NEXT:   %3 = add nuw i64 %2, 1
; CHECK-NEXT:   %malloccall = tail call noalias nonnull i8* @malloc(i64 %3)
; CHECK-NEXT:   %cmp.i_malloccache = bitcast i8* %malloccall to i1*
; CHECK-NEXT:   br label %for.body.for.body_crit_edge

; CHECK: for.body.for.body_crit_edge:                      ; preds = %for.body.for.body_crit_edge, %for.body.preheader
; CHECK-NEXT:   %indvar = phi i64 [ %indvar.next, %for.body.for.body_crit_edge ], [ 0, %for.body.preheader ]
; CHECK-NEXT:   %cond.i28 = phi double [ %0, %for.body.preheader ], [ %cond.i, %for.body.for.body_crit_edge ]
; CHECK-NEXT:   %4 = add i64 %indvar, 1
; CHECK-NEXT:   %5 = icmp ult i64 %indvar, %1
; CHECK-NEXT:   %arrayidx9.phi.trans.insert = getelementptr inbounds double, double* %x, i64 %4
; CHECK-NEXT:   %.pre = load double, double* %arrayidx9.phi.trans.insert, align 8, !tbaa !2
; CHECK-NEXT:   %cmp.i = fcmp fast ogt double %cond.i28, %.pre
; CHECK-NEXT:   %6 = getelementptr i1, i1* %cmp.i_malloccache, i64 %indvar
; CHECK-NEXT:   store i1 %cmp.i, i1* %6
; CHECK-NEXT:   %cond.i = select i1 %cmp.i, double %cond.i28, double %.pre
; CHECK-NEXT:   %indvar.next = add i64 %indvar, 1
; CHECK-NEXT:   br i1 %5, label %for.body.for.body_crit_edge, label %invertfor.cond.cleanup

; CHECK: invertfor.body.preheader:                         ; preds = %invertfor.body.for.body_crit_edge
; CHECK-NEXT:   tail call void @free(i8* nonnull %malloccall)
; CHECK-NEXT:   %7 = load double, double* %"x'"
; CHECK-NEXT:   %8 = fadd fast double %7, %20
; CHECK-NEXT:   store double %8, double* %"x'"
; CHECK-NEXT:   %9 = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.3, i64 0, i64 0), double 0.000000e+00)
; CHECK-NEXT:   ret

; CHECK: invertfor.cond.cleanup:                           ; preds = %for.body.for.body_crit_edge
; CHECK-NEXT:   %10 = add i64 %n, -2
; CHECK-NEXT:   br label %invertfor.body.for.body_crit_edge

; CHECK: invertfor.body.for.body_crit_edge:                ; preds = %invertfor.body.for.body_crit_edge, %invertfor.cond.cleanup
; CHECK-NEXT:   %"cond.i'de.0" = phi double [ -1.000000e+00, %invertfor.cond.cleanup ], [ %diffecond.i28, %invertfor.body.for.body_crit_edge ]
; CHECK-NEXT:   %"'de.0" = phi double [ 1.000000e+00, %invertfor.cond.cleanup ], [ %20, %invertfor.body.for.body_crit_edge ]
; CHECK-NEXT:   %"indvar'phi" = phi i64 [ %10, %invertfor.cond.cleanup ], [ %11, %invertfor.body.for.body_crit_edge ]
; CHECK-NEXT:   %11 = sub i64 %"indvar'phi", 1
; CHECK-NEXT:   %12 = getelementptr i1, i1* %cmp.i_malloccache, i64 %"indvar'phi"
; CHECK-NEXT:   %13 = load i1, i1* %12
; CHECK-NEXT:   %diffecond.i28 = select i1 %13, double %"cond.i'de.0", double 0.000000e+00
; CHECK-NEXT:   %diffe.pre = select i1 %13, double 0.000000e+00, double %"cond.i'de.0"
; CHECK-NEXT:   %14 = add i64 %"indvar'phi", 1
; CHECK-NEXT:   %"arrayidx9.phi.trans.insert'ipg" = getelementptr double, double* %"x'", i64 %14
; CHECK-NEXT:   %15 = load double, double* %"arrayidx9.phi.trans.insert'ipg"
; CHECK-NEXT:   %16 = fadd fast double %15, %diffe.pre
; CHECK-NEXT:   store double %16, double* %"arrayidx9.phi.trans.insert'ipg"
; CHECK-NEXT:   %17 = icmp ne i64 %"indvar'phi", 0
; CHECK-NEXT:   %18 = select i1 %17, double %diffecond.i28, double 0.000000e+00
; CHECK-NEXT:   %19 = select i1 %17, double 0.000000e+00, double %diffecond.i28
; CHECK-NEXT:   %20 = fadd fast double %"'de.0", %19
; CHECK-NEXT:   br i1 %17, label %invertfor.body.for.body_crit_edge, label %invertfor.body.preheader
; CHECK-NEXT: }
