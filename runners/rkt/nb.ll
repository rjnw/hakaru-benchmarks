; ModuleID = 'module'
source_filename = "module"
target datalayout = "e-m:e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-f128:128:128-v64:64:64-v128:128:128-a:0:64-s0:64:64-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@gsl-rng = local_unnamed_addr global i8* null
@gsl_rng_taus = external local_unnamed_addr global i8*

; Function Attrs: nounwind readnone
define double @nat2prob(i64) local_unnamed_addr #0 {
entry:
  %v2 = uitofp i64 %0 to double
  %rea = tail call double @real2prob(double %v2)
  ret double %rea
}

; Function Attrs: norecurse nounwind readnone
define double @nat2real(i64) local_unnamed_addr #1 {
entry:
  %v2 = uitofp i64 %0 to double
  ret double %v2
}

; Function Attrs: norecurse nounwind readnone
define i64 @nat2int(i64 returned) local_unnamed_addr #1 {
entry:
  ret i64 %0
}

; Function Attrs: norecurse nounwind readnone
define i64 @int2nat(i64 returned) local_unnamed_addr #1 {
entry:
  ret i64 %0
}

; Function Attrs: norecurse nounwind readnone
define double @int2real(i64) local_unnamed_addr #1 {
entry:
  %v2 = sitofp i64 %0 to double
  ret double %v2
}

; Function Attrs: nounwind readnone
define double @prob2real(double) local_unnamed_addr #0 {
entry:
  %llv = tail call double @llvm.exp.f64(double %0)
  ret double %llv
}

; Function Attrs: nounwind readnone
define double @real2prob(double) local_unnamed_addr #0 {
entry:
  %llv = tail call double @llvm.log.f64(double %0)
  ret double %llv
}

; Function Attrs: norecurse nounwind readnone
define double @recip-nat(i64) local_unnamed_addr #1 {
entry:
  %v2 = uitofp i64 %0 to double
  %v3 = fdiv double 1.000000e+00, %v2
  ret double %v3
}

; Function Attrs: norecurse nounwind readnone
define double @recip-real(double) local_unnamed_addr #1 {
entry:
  %v2 = fdiv double 1.000000e+00, %0
  ret double %v2
}

; Function Attrs: norecurse nounwind readnone
define double @recip-prob(double) local_unnamed_addr #1 {
entry:
  %v2 = fsub double -0.000000e+00, %0
  ret double %v2
}

; Function Attrs: norecurse nounwind readnone
define double @root-prob-nat(double, i64) local_unnamed_addr #1 {
entry:
  %rec = tail call double @recip-nat(i64 %1)
  %v3 = fmul double %rec, %0
  ret double %v3
}

; Function Attrs: norecurse nounwind readnone
define double @exp-real2prob(double returned) local_unnamed_addr #1 {
entry:
  ret double %0
}

; Function Attrs: norecurse nounwind readnone
define double @fdiv-nat(i64, i64) local_unnamed_addr #1 {
entry:
  %v = uitofp i64 %0 to double
  %v3 = uitofp i64 %1 to double
  %v4 = fdiv double %v, %v3
  ret double %v4
}

; Function Attrs: nounwind readnone
define double @natpow(double, i64) local_unnamed_addr #0 {
entry:
  %v3 = trunc i64 %1 to i32
  %llv = tail call double @llvm.powi.f64(double %0, i32 %v3)
  ret double %llv
}

; Function Attrs: nounwind
define noalias <{ i64, i64* }>* @"make$array<nat>"(i64, i64*) local_unnamed_addr #2 {
entry:
  %malloccall = tail call i8* @malloc(i32 16)
  %v = bitcast i8* %malloccall to <{ i64, i64* }>*
  %gep = bitcast i8* %malloccall to i64*
  %gep3 = getelementptr i8, i8* %malloccall, i64 8
  %2 = bitcast i8* %gep3 to i64**
  store i64 %0, i64* %gep, align 8
  store i64* %1, i64** %2, align 8
  ret <{ i64, i64* }>* %v
}

; Function Attrs: nounwind
define noalias <{ i64, i64* }>* @"new-sized$array<nat>"(i64) local_unnamed_addr #2 {
entry:
  %1 = trunc i64 %0 to i32
  %mallocsize = shl i32 %1, 3
  %malloccall = tail call i8* @malloc(i32 %mallocsize)
  %v = bitcast i8* %malloccall to i64*
  %mak = tail call <{ i64, i64* }>* @"make$array<nat>"(i64 %0, i64* %v)
  %gep = getelementptr <{ i64, i64* }>, <{ i64, i64* }>* %mak, i64 0, i32 1
  %2 = bitcast i64** %gep to i8**
  %v49 = load i8*, i8** %2, align 8
  %v7 = shl nuw i64 %0, 3
tail call void @llvm.memset.p0i8.i64(i8* %v49, i8 0, i64 %v7, i32 1, i1 false)
  ret <{ i64, i64* }>* %mak
}

; Function Attrs: nounwind
define void @"free-sized$array<nat>"(<{ i64, i64* }>* nocapture) local_unnamed_addr #2 {
entry:
  %gep = getelementptr <{ i64, i64* }>, <{ i64, i64* }>* %0, i64 0, i32 1
  %1 = bitcast i64** %gep to i8**
  %v3 = load i8*, i8** %1, align 8
  tail call void @free(i8* %v3)
  %2 = bitcast <{ i64, i64* }>* %0 to i8*
  tail call void @free(i8* %2)
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, i64* }>* @"empty$array<nat>"() local_unnamed_addr #2 {
entry:
  %new = tail call <{ i64, i64* }>* @"new-sized$array<nat>"(i64 0)
  ret <{ i64, i64* }>* %new
}

; Function Attrs: norecurse nounwind readonly
define i64 @"get-size$array<nat>"(<{ i64, i64* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep2 = bitcast <{ i64, i64* }>* %0 to i64*
  %v = load i64, i64* %gep2, align 8
  ret i64 %v
}

; Function Attrs: norecurse nounwind readonly
define i64* @"get-data$array<nat>"(<{ i64, i64* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, i64* }>, <{ i64, i64* }>* %0, i64 0, i32 1
  %v = load i64*, i64** %gep, align 8
  ret i64* %v
}

; Function Attrs: norecurse nounwind readonly
define i64 @"get-index$array<nat>"(<{ i64, i64* }>* nocapture readonly, i64) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, i64* }>, <{ i64, i64* }>* %0, i64 0, i32 1
  %v = load i64*, i64** %gep, align 8
  %gep3 = getelementptr i64, i64* %v, i64 %1
  %v4 = load i64, i64* %gep3, align 8
  ret i64 %v4
}

; Function Attrs: norecurse nounwind
define void @"set-index!$array<nat>"(<{ i64, i64* }>* nocapture readonly, i64, i64) local_unnamed_addr #4 {
entry:
  %gep = getelementptr <{ i64, i64* }>, <{ i64, i64* }>* %0, i64 0, i32 1
  %v3 = load i64*, i64** %gep, align 8
  %gep5 = getelementptr i64, i64* %v3, i64 %1
  store i64 %2, i64* %gep5, align 8
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, double* }>* @"make$array<real>"(i64, double*) local_unnamed_addr #2 {
entry:
  %malloccall = tail call i8* @malloc(i32 16)
  %v = bitcast i8* %malloccall to <{ i64, double* }>*
  %gep = bitcast i8* %malloccall to i64*
  %gep3 = getelementptr i8, i8* %malloccall, i64 8
  %2 = bitcast i8* %gep3 to double**
  store i64 %0, i64* %gep, align 8
  store double* %1, double** %2, align 8
  ret <{ i64, double* }>* %v
}

; Function Attrs: nounwind
define noalias <{ i64, double* }>* @"new-sized$array<real>"(i64) local_unnamed_addr #2 {
entry:
  %1 = trunc i64 %0 to i32
  %mallocsize = shl i32 %1, 3
  %malloccall = tail call i8* @malloc(i32 %mallocsize)
  %v = bitcast i8* %malloccall to double*
  %mak = tail call <{ i64, double* }>* @"make$array<real>"(i64 %0, double* %v)
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %mak, i64 0, i32 1
  %2 = bitcast double** %gep to i8**
  %v49 = load i8*, i8** %2, align 8
  %v7 = shl nuw i64 %0, 3
tail call void @llvm.memset.p0i8.i64(i8* %v49, i8 0, i64 %v7, i32 1, i1 false)
  ret <{ i64, double* }>* %mak
}

; Function Attrs: nounwind
define void @"free-sized$array<real>"(<{ i64, double* }>* nocapture) local_unnamed_addr #2 {
entry:
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %0, i64 0, i32 1
  %1 = bitcast double** %gep to i8**
  %v3 = load i8*, i8** %1, align 8
  tail call void @free(i8* %v3)
  %2 = bitcast <{ i64, double* }>* %0 to i8*
  tail call void @free(i8* %2)
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, double* }>* @"empty$array<real>"() local_unnamed_addr #2 {
entry:
  %new = tail call <{ i64, double* }>* @"new-sized$array<real>"(i64 0)
  ret <{ i64, double* }>* %new
}

; Function Attrs: norecurse nounwind readonly
define i64 @"get-size$array<real>"(<{ i64, double* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep2 = bitcast <{ i64, double* }>* %0 to i64*
  %v = load i64, i64* %gep2, align 8
  ret i64 %v
}

; Function Attrs: norecurse nounwind readonly
define double* @"get-data$array<real>"(<{ i64, double* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %0, i64 0, i32 1
  %v = load double*, double** %gep, align 8
  ret double* %v
}

; Function Attrs: norecurse nounwind readonly
define double @"get-index$array<real>"(<{ i64, double* }>* nocapture readonly, i64) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %0, i64 0, i32 1
  %v = load double*, double** %gep, align 8
  %gep3 = getelementptr double, double* %v, i64 %1
  %v4 = load double, double* %gep3, align 8
  ret double %v4
}

; Function Attrs: norecurse nounwind
define void @"set-index!$array<real>"(<{ i64, double* }>* nocapture readonly, i64, double) local_unnamed_addr #4 {
entry:
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %0, i64 0, i32 1
  %v3 = load double*, double** %gep, align 8
  %gep5 = getelementptr double, double* %v3, i64 %1
  store double %2, double* %gep5, align 8
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, double* }>* @"make$array<prob>"(i64, double*) local_unnamed_addr #2 {
entry:
  %malloccall = tail call i8* @malloc(i32 16)
  %v = bitcast i8* %malloccall to <{ i64, double* }>*
  %gep = bitcast i8* %malloccall to i64*
  %gep3 = getelementptr i8, i8* %malloccall, i64 8
  %2 = bitcast i8* %gep3 to double**
  store i64 %0, i64* %gep, align 8
  store double* %1, double** %2, align 8
  ret <{ i64, double* }>* %v
}

; Function Attrs: nounwind
define noalias <{ i64, double* }>* @"new-sized$array<prob>"(i64) local_unnamed_addr #2 {
entry:
  %1 = trunc i64 %0 to i32
  %mallocsize = shl i32 %1, 3
  %malloccall = tail call i8* @malloc(i32 %mallocsize)
  %v = bitcast i8* %malloccall to double*
  %mak = tail call <{ i64, double* }>* @"make$array<prob>"(i64 %0, double* %v)
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %mak, i64 0, i32 1
  %2 = bitcast double** %gep to i8**
  %v49 = load i8*, i8** %2, align 8
  %v7 = shl nuw i64 %0, 3
tail call void @llvm.memset.p0i8.i64(i8* %v49, i8 0, i64 %v7, i32 1, i1 false)
  ret <{ i64, double* }>* %mak
}

; Function Attrs: nounwind
define void @"free-sized$array<prob>"(<{ i64, double* }>* nocapture) local_unnamed_addr #2 {
entry:
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %0, i64 0, i32 1
  %1 = bitcast double** %gep to i8**
  %v3 = load i8*, i8** %1, align 8
  tail call void @free(i8* %v3)
  %2 = bitcast <{ i64, double* }>* %0 to i8*
  tail call void @free(i8* %2)
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, double* }>* @"empty$array<prob>"() local_unnamed_addr #2 {
entry:
  %new = tail call <{ i64, double* }>* @"new-sized$array<prob>"(i64 0)
  ret <{ i64, double* }>* %new
}

; Function Attrs: norecurse nounwind readonly
define i64 @"get-size$array<prob>"(<{ i64, double* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep2 = bitcast <{ i64, double* }>* %0 to i64*
  %v = load i64, i64* %gep2, align 8
  ret i64 %v
}

; Function Attrs: norecurse nounwind readonly
define double* @"get-data$array<prob>"(<{ i64, double* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %0, i64 0, i32 1
  %v = load double*, double** %gep, align 8
  ret double* %v
}

; Function Attrs: norecurse nounwind readonly
define double @"get-index$array<prob>"(<{ i64, double* }>* nocapture readonly, i64) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %0, i64 0, i32 1
  %v = load double*, double** %gep, align 8
  %gep3 = getelementptr double, double* %v, i64 %1
  %v4 = load double, double* %gep3, align 8
  ret double %v4
}

; Function Attrs: norecurse nounwind
define void @"set-index!$array<prob>"(<{ i64, double* }>* nocapture readonly, i64, double) local_unnamed_addr #4 {
entry:
  %gep = getelementptr <{ i64, double* }>, <{ i64, double* }>* %0, i64 0, i32 1
  %v3 = load double*, double** %gep, align 8
  %gep5 = getelementptr double, double* %v3, i64 %1
  store double %2, double* %gep5, align 8
  ret void
}

define void @init-rng() local_unnamed_addr #5 {
entry:
  %gsl_rng_taus = load i8*, i8** @gsl_rng_taus, align 8
  %gsl = tail call i8* @gsl_rng_alloc(i8* %gsl_rng_taus)
  store i8* %gsl, i8** @gsl-rng, align 8
  ret void
}

define double @uniform(double, double) local_unnamed_addr #5 {
entry:
  %gsl-rng = load i8*, i8** @gsl-rng, align 8
  %gsl = tail call double @gsl_ran_flat(i8* %gsl-rng, double %0, double %1)
  ret double %gsl
}

define double @normal(double, double) local_unnamed_addr #5 {
entry:
  %gsl-rng = load i8*, i8** @gsl-rng, align 8
  %pro = tail call double @prob2real(double %1)
  %gsl = tail call double @gsl_ran_gaussian(i8* %gsl-rng, double %pro)
  %v = fadd double %gsl, %0
  ret double %v
}

define double @beta(double, double) local_unnamed_addr #5 {
entry:
  %pro = tail call double @prob2real(double %0)
  %pro3 = tail call double @prob2real(double %1)
  %bet = tail call double @betafuncreal(double %pro, double %pro3)
  ret double %bet
}

define double @realbetafunc(double, double) local_unnamed_addr #5 {
entry:
  %bet = tail call double @betafuncreal(double %0, double %1)
  %pro = tail call double @prob2real(double %bet)
  ret double %pro
}

define double @betafuncreal(double, double) local_unnamed_addr #5 {
entry:
  %gsl = tail call double @gsl_sf_lnbeta(double %0, double %1)
  ret double %gsl
}

define double @betafunc(double, double) local_unnamed_addr #5 {
entry:
  %pro = tail call double @prob2real(double %0)
  %pro3 = tail call double @prob2real(double %1)
  %bet = tail call double @betafuncreal(double %pro, double %pro3)
  ret double %bet
}

define double @gamma(double, double) local_unnamed_addr #5 {
entry:
  %gsl-rng = load i8*, i8** @gsl-rng, align 8
  %pro = tail call double @prob2real(double %0)
  %pro3 = tail call double @prob2real(double %1)
  %gsl = tail call double @gsl_ran_gamma(i8* %gsl-rng, double %pro, double %pro3)
  %rea = tail call double @real2prob(double %gsl)
  ret double %rea
}

define double @gammaFunc(double) local_unnamed_addr #5 {
entry:
  %pro = tail call double @prob2real(double %0)
  %gsl = tail call double @gsl_sf_gamma(double %pro)
  %rea = tail call double @real2prob(double %gsl)
  ret double %rea
}

define i64 @categorical-real(double*, i64) local_unnamed_addr #5 {
entry:
  %gsl = tail call i8* @gsl_ran_discrete_preproc(i64 %1, double* %0)
  %gsl-rng = load i8*, i8** @gsl-rng, align 8
  %gsl4 = tail call i64 @gsl_ran_discrete(i8* %gsl-rng, i8* %gsl)
  tail call void @gsl_ran_discrete_free(i8* %gsl)
  ret i64 %gsl4
}

define i64 @categorical(<{ i64, double* }>* nocapture readonly) local_unnamed_addr #5 {
entry:
  %get = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* %0)
  %1 = trunc i64 %get to i32
  %mallocsize = shl i32 %1, 3
  %malloccall = tail call i8* @malloc(i32 %mallocsize)
  br label %loop-block

loop-block:                                       ; preds = %loop-block, %entry
  %i.018 = phi i64 [ 0, %entry ], [ %v11, %loop-block ]
  %2 = bitcast i8* %malloccall to double*
  %get7 = tail call double @"get-index$array<prob>"(<{ i64, double* }>* %0, i64 %i.018)
  %pro = tail call double @prob2real(double %get7)
  %scevgep = getelementptr double, double* %2, i64 %i.018
  store double %pro, double* %scevgep, align 8
  %v11 = add nuw i64 %i.018, 1
  %get4 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* %0)
  %3 = add i64 %v11, -1
  %ipred = icmp ult i64 %3, %get4
  br i1 %ipred, label %loop-block, label %afterloop-block

afterloop-block:                                  ; preds = %loop-block
  %4 = bitcast i8* %malloccall to double*
  %cat = tail call i64 @categorical-real(double* nonnull %4, i64 %get4)
  tail call void @free(i8* nonnull %malloccall)
  ret i64 %cat
}

; Function Attrs: nounwind readnone
define double @"add$2&prob"(double, double) local_unnamed_addr #0 {
entry:
  %pro = tail call double @prob2real(double %0)
  %pro3 = tail call double @prob2real(double %1)
  %v = fadd double %pro, %pro3
  %rea = tail call double @real2prob(double %v)
  ret double %rea
}

; Function Attrs: norecurse nounwind readnone
define i64 @"add$2&nat"(i64, i64) local_unnamed_addr #1 {
entry:
  %v = add nuw i64 %1, %0
  ret i64 %v
}

; Function Attrs: nounwind
define noalias <{ <{ i64, i64* }>*, i64 }>* @"make$pair<array<nat>*.unit>"(<{ i64, i64* }>*, i64) local_unnamed_addr #2 {
entry:
  %malloccall = tail call i8* @malloc(i32 16)
  %v = bitcast i8* %malloccall to <{ <{ i64, i64* }>*, i64 }>*
  %gep = bitcast i8* %malloccall to <{ i64, i64* }>**
  %gep3 = getelementptr i8, i8* %malloccall, i64 8
  %2 = bitcast i8* %gep3 to i64*
  store <{ i64, i64* }>* %0, <{ i64, i64* }>** %gep, align 8
  store i64 %1, i64* %2, align 8
  ret <{ <{ i64, i64* }>*, i64 }>* %v
}

; Function Attrs: norecurse nounwind readonly
define <{ i64, i64* }>* @"car$pair<array<nat>*.unit>"(<{ <{ i64, i64* }>*, i64 }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep2 = bitcast <{ <{ i64, i64* }>*, i64 }>* %0 to <{ i64, i64* }>**
  %v = load <{ i64, i64* }>*, <{ i64, i64* }>** %gep2, align 8
  ret <{ i64, i64* }>* %v
}

; Function Attrs: norecurse nounwind readonly
define i64 @"cdr$pair<array<nat>*.unit>"(<{ <{ i64, i64* }>*, i64 }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ <{ i64, i64* }>*, i64 }>, <{ <{ i64, i64* }>*, i64 }>* %0, i64 0, i32 1
  %v = load i64, i64* %gep, align 8
  ret i64 %v
}

; Function Attrs: norecurse nounwind
define void @"set-car!$pair<array<nat>*.unit>"(<{ <{ i64, i64* }>*, i64 }>* nocapture, <{ i64, i64* }>*) local_unnamed_addr #4 {
entry:
  %gep3 = bitcast <{ <{ i64, i64* }>*, i64 }>* %0 to <{ i64, i64* }>**
  store <{ i64, i64* }>* %1, <{ i64, i64* }>** %gep3, align 8
  ret void
}

; Function Attrs: norecurse nounwind
define void @"set-cdr!$pair<array<nat>*.unit>"(<{ <{ i64, i64* }>*, i64 }>* nocapture, i64) local_unnamed_addr #4 {
entry:
  %gep = getelementptr <{ <{ i64, i64* }>*, i64 }>, <{ <{ i64, i64* }>*, i64 }>* %0, i64 0, i32 1
  store i64 %1, i64* %gep, align 8
  ret void
}

; Function Attrs: nounwind
define noalias <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* @"make$pair<array<array<nat>*>*.unit>"(<{ i64, <{ i64, i64* }>** }>*, i64) local_unnamed_addr #2 {
entry:
  %malloccall = tail call i8* @malloc(i32 16)
  %v = bitcast i8* %malloccall to <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>*
  %gep = bitcast i8* %malloccall to <{ i64, <{ i64, i64* }>** }>**
  %gep3 = getelementptr i8, i8* %malloccall, i64 8
  %2 = bitcast i8* %gep3 to i64*
  store <{ i64, <{ i64, i64* }>** }>* %0, <{ i64, <{ i64, i64* }>** }>** %gep, align 8
  store i64 %1, i64* %2, align 8
  ret <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* %v
}

; Function Attrs: norecurse nounwind readonly
define <{ i64, <{ i64, i64* }>** }>* @"car$pair<array<array<nat>*>*.unit>"(<{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep2 = bitcast <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* %0 to <{ i64, <{ i64, i64* }>** }>**
  %v = load <{ i64, <{ i64, i64* }>** }>*, <{ i64, <{ i64, i64* }>** }>** %gep2, align 8
  ret <{ i64, <{ i64, i64* }>** }>* %v
}

; Function Attrs: norecurse nounwind readonly
define i64 @"cdr$pair<array<array<nat>*>*.unit>"(<{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>, <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* %0, i64 0, i32 1
  %v = load i64, i64* %gep, align 8
  ret i64 %v
}

; Function Attrs: norecurse nounwind
define void @"set-car!$pair<array<array<nat>*>*.unit>"(<{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* nocapture, <{ i64, <{ i64, i64* }>** }>*) local_unnamed_addr #4 {
entry:
  %gep3 = bitcast <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* %0 to <{ i64, <{ i64, i64* }>** }>**
  store <{ i64, <{ i64, i64* }>** }>* %1, <{ i64, <{ i64, i64* }>** }>** %gep3, align 8
  ret void
}

; Function Attrs: norecurse nounwind
define void @"set-cdr!$pair<array<array<nat>*>*.unit>"(<{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* nocapture, i64) local_unnamed_addr #4 {
entry:
  %gep = getelementptr <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>, <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* %0, i64 0, i32 1
  store i64 %1, i64* %gep, align 8
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, <{ i64, i64* }>** }>* @"make$array<array<nat>*>"(i64, <{ i64, i64* }>**) local_unnamed_addr #2 {
entry:
  %malloccall = tail call i8* @malloc(i32 16)
  %v = bitcast i8* %malloccall to <{ i64, <{ i64, i64* }>** }>*
  %gep = bitcast i8* %malloccall to i64*
  %gep3 = getelementptr i8, i8* %malloccall, i64 8
  %2 = bitcast i8* %gep3 to <{ i64, i64* }>***
  store i64 %0, i64* %gep, align 8
  store <{ i64, i64* }>** %1, <{ i64, i64* }>*** %2, align 8
  ret <{ i64, <{ i64, i64* }>** }>* %v
}

; Function Attrs: nounwind
define noalias <{ i64, <{ i64, i64* }>** }>* @"new-sized$array<array<nat>*>"(i64) local_unnamed_addr #2 {
entry:
  %1 = trunc i64 %0 to i32
  %mallocsize = shl i32 %1, 3
  %malloccall = tail call i8* @malloc(i32 %mallocsize)
  %v = bitcast i8* %malloccall to <{ i64, i64* }>**
  %mak = tail call <{ i64, <{ i64, i64* }>** }>* @"make$array<array<nat>*>"(i64 %0, <{ i64, i64* }>** %v)
  %gep = getelementptr <{ i64, <{ i64, i64* }>** }>, <{ i64, <{ i64, i64* }>** }>* %mak, i64 0, i32 1
  %2 = bitcast <{ i64, i64* }>*** %gep to i8**
  %v49 = load i8*, i8** %2, align 8
  %v7 = shl nuw i64 %0, 3
tail call void @llvm.memset.p0i8.i64(i8* %v49, i8 0, i64 %v7, i32 1, i1 false)
  ret <{ i64, <{ i64, i64* }>** }>* %mak
}

; Function Attrs: nounwind
define void @"free-sized$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* nocapture) local_unnamed_addr #2 {
entry:
  %gep = getelementptr <{ i64, <{ i64, i64* }>** }>, <{ i64, <{ i64, i64* }>** }>* %0, i64 0, i32 1
  %1 = bitcast <{ i64, i64* }>*** %gep to i8**
  %v3 = load i8*, i8** %1, align 8
  tail call void @free(i8* %v3)
  %2 = bitcast <{ i64, <{ i64, i64* }>** }>* %0 to i8*
  tail call void @free(i8* %2)
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, <{ i64, i64* }>** }>* @"empty$array<array<nat>*>"() local_unnamed_addr #2 {
entry:
  %new = tail call <{ i64, <{ i64, i64* }>** }>* @"new-sized$array<array<nat>*>"(i64 0)
  ret <{ i64, <{ i64, i64* }>** }>* %new
}

; Function Attrs: norecurse nounwind readonly
define i64 @"get-size$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep2 = bitcast <{ i64, <{ i64, i64* }>** }>* %0 to i64*
  %v = load i64, i64* %gep2, align 8
  ret i64 %v
}

; Function Attrs: norecurse nounwind readonly
define <{ i64, i64* }>** @"get-data$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, <{ i64, i64* }>** }>, <{ i64, <{ i64, i64* }>** }>* %0, i64 0, i32 1
  %v = load <{ i64, i64* }>**, <{ i64, i64* }>*** %gep, align 8
  ret <{ i64, i64* }>** %v
}

; Function Attrs: norecurse nounwind readonly
define <{ i64, i64* }>* @"get-index$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* nocapture readonly, i64) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, <{ i64, i64* }>** }>, <{ i64, <{ i64, i64* }>** }>* %0, i64 0, i32 1
  %v = load <{ i64, i64* }>**, <{ i64, i64* }>*** %gep, align 8
  %gep3 = getelementptr <{ i64, i64* }>*, <{ i64, i64* }>** %v, i64 %1
  %v4 = load <{ i64, i64* }>*, <{ i64, i64* }>** %gep3, align 8
  ret <{ i64, i64* }>* %v4
}

; Function Attrs: norecurse nounwind
define void @"set-index!$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* nocapture readonly, i64, <{ i64, i64* }>*) local_unnamed_addr #4 {
entry:
  %gep = getelementptr <{ i64, <{ i64, i64* }>** }>, <{ i64, <{ i64, i64* }>** }>* %0, i64 0, i32 1
  %v3 = load <{ i64, i64* }>**, <{ i64, i64* }>*** %gep, align 8
  %gep5 = getelementptr <{ i64, i64* }>*, <{ i64, i64* }>** %v3, i64 %1
  store <{ i64, i64* }>* %2, <{ i64, i64* }>** %gep5, align 8
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, <{ i64, i64* }>* }>* @"make$pair<unit.array<nat>*>"(i64, <{ i64, i64* }>*) local_unnamed_addr #2 {
entry:
  %malloccall = tail call i8* @malloc(i32 16)
  %v = bitcast i8* %malloccall to <{ i64, <{ i64, i64* }>* }>*
  %gep = bitcast i8* %malloccall to i64*
  %gep3 = getelementptr i8, i8* %malloccall, i64 8
  %2 = bitcast i8* %gep3 to <{ i64, i64* }>**
  store i64 %0, i64* %gep, align 8
  store <{ i64, i64* }>* %1, <{ i64, i64* }>** %2, align 8
  ret <{ i64, <{ i64, i64* }>* }>* %v
}

; Function Attrs: norecurse nounwind readonly
define i64 @"car$pair<unit.array<nat>*>"(<{ i64, <{ i64, i64* }>* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep2 = bitcast <{ i64, <{ i64, i64* }>* }>* %0 to i64*
  %v = load i64, i64* %gep2, align 8
  ret i64 %v
}

; Function Attrs: norecurse nounwind readonly
define <{ i64, i64* }>* @"cdr$pair<unit.array<nat>*>"(<{ i64, <{ i64, i64* }>* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, <{ i64, i64* }>* }>, <{ i64, <{ i64, i64* }>* }>* %0, i64 0, i32 1
  %v = load <{ i64, i64* }>*, <{ i64, i64* }>** %gep, align 8
  ret <{ i64, i64* }>* %v
}

; Function Attrs: norecurse nounwind
define void @"set-car!$pair<unit.array<nat>*>"(<{ i64, <{ i64, i64* }>* }>* nocapture, i64) local_unnamed_addr #4 {
entry:
  %gep3 = bitcast <{ i64, <{ i64, i64* }>* }>* %0 to i64*
  store i64 %1, i64* %gep3, align 8
  ret void
}

; Function Attrs: norecurse nounwind
define void @"set-cdr!$pair<unit.array<nat>*>"(<{ i64, <{ i64, i64* }>* }>* nocapture, <{ i64, i64* }>*) local_unnamed_addr #4 {
entry:
  %gep = getelementptr <{ i64, <{ i64, i64* }>* }>, <{ i64, <{ i64, i64* }>* }>* %0, i64 0, i32 1
  store <{ i64, i64* }>* %1, <{ i64, i64* }>** %gep, align 8
  ret void
}

; Function Attrs: nounwind
define noalias <{ i64, <{ i64, <{ i64, i64* }>** }>* }>* @"make$pair<unit.array<array<nat>*>*>"(i64, <{ i64, <{ i64, i64* }>** }>*) local_unnamed_addr #2 {
entry:
  %malloccall = tail call i8* @malloc(i32 16)
  %v = bitcast i8* %malloccall to <{ i64, <{ i64, <{ i64, i64* }>** }>* }>*
  %gep = bitcast i8* %malloccall to i64*
  %gep3 = getelementptr i8, i8* %malloccall, i64 8
  %2 = bitcast i8* %gep3 to <{ i64, <{ i64, i64* }>** }>**
  store i64 %0, i64* %gep, align 8
  store <{ i64, <{ i64, i64* }>** }>* %1, <{ i64, <{ i64, i64* }>** }>** %2, align 8
  ret <{ i64, <{ i64, <{ i64, i64* }>** }>* }>* %v
}

; Function Attrs: norecurse nounwind readonly
define i64 @"car$pair<unit.array<array<nat>*>*>"(<{ i64, <{ i64, <{ i64, i64* }>** }>* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep2 = bitcast <{ i64, <{ i64, <{ i64, i64* }>** }>* }>* %0 to i64*
  %v = load i64, i64* %gep2, align 8
  ret i64 %v
}

; Function Attrs: norecurse nounwind readonly
define <{ i64, <{ i64, i64* }>** }>* @"cdr$pair<unit.array<array<nat>*>*>"(<{ i64, <{ i64, <{ i64, i64* }>** }>* }>* nocapture readonly) local_unnamed_addr #3 {
entry:
  %gep = getelementptr <{ i64, <{ i64, <{ i64, i64* }>** }>* }>, <{ i64, <{ i64, <{ i64, i64* }>** }>* }>* %0, i64 0, i32 1
  %v = load <{ i64, <{ i64, i64* }>** }>*, <{ i64, <{ i64, i64* }>** }>** %gep, align 8
  ret <{ i64, <{ i64, i64* }>** }>* %v
}

; Function Attrs: norecurse nounwind
define void @"set-car!$pair<unit.array<array<nat>*>*>"(<{ i64, <{ i64, <{ i64, i64* }>** }>* }>* nocapture, i64) local_unnamed_addr #4 {
entry:
  %gep3 = bitcast <{ i64, <{ i64, <{ i64, i64* }>** }>* }>* %0 to i64*
  store i64 %1, i64* %gep3, align 8
  ret void
}

; Function Attrs: norecurse nounwind
define void @"set-cdr!$pair<unit.array<array<nat>*>*>"(<{ i64, <{ i64, <{ i64, i64* }>** }>* }>* nocapture, <{ i64, <{ i64, i64* }>** }>*) local_unnamed_addr #4 {
entry:
  %gep = getelementptr <{ i64, <{ i64, <{ i64, i64* }>** }>* }>, <{ i64, <{ i64, <{ i64, i64* }>** }>* }>* %0, i64 0, i32 1
  store <{ i64, <{ i64, i64* }>** }>* %1, <{ i64, <{ i64, i64* }>** }>** %gep, align 8
  ret void
}

; Function Attrs: nounwind readnone
define double @"add$3&prob"(double, double, double) local_unnamed_addr #0 {
entry:
  %pro = tail call double @prob2real(double %0)
  %pro3 = tail call double @prob2real(double %1)
  %v = fadd double %pro, %pro3
  %rea = tail call double @real2prob(double %v)
  ret double %rea
}

; Function Attrs: norecurse nounwind readnone
define double @"mul$3&real"(double, double, double) local_unnamed_addr #1 {
entry:
  %v = fmul double %0, %1
  %v4 = fmul double %v, %2
  ret double %v4
}

; Function Attrs: norecurse nounwind readnone
define double @"add$2&real"(double, double) local_unnamed_addr #1 {
entry:
  %v = fadd double %0, %1
  ret double %v
}

; Function Attrs: norecurse nounwind readnone
define i64 @"add$2&int"(i64, i64) local_unnamed_addr #1 {
entry:
  %v = add nsw i64 %1, %0
  ret i64 %v
}

; Function Attrs: norecurse nounwind readnone
define i64 @"mul$2&int"(i64, i64) local_unnamed_addr #1 {
entry:
  %v = mul nsw i64 %1, %0
  ret i64 %v
}

; Function Attrs: norecurse nounwind readnone
define i64 @"reject$nat"() local_unnamed_addr #1 {
entry:
  ret i64 0
}

; Function Attrs: argmemonly norecurse nounwind readonly speculatable
define i64 @prog(<{ i64, double* }>* noalias nocapture nonnull readonly, <{ i64, double* }>* noalias nocapture nonnull readonly, <{ i64, i64* }>* noalias nocapture nonnull readonly, <{ i64, i64* }>* noalias nocapture nonnull readonly, <{ i64, i64* }>* noalias nocapture nonnull readonly, i64) local_unnamed_addr #6 {
entry:
  %get340 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %1) #9
  %ipred341 = icmp eq i64 %get340, 0
  br i1 %ipred341, label %afterloop-block, label %loop-block.preheader

loop-block.preheader:                             ; preds = %entry
  br label %loop-block

loop-block:                                       ; preds = %loop-block.preheader, %loop-block
  %ci8.0343 = phi i64 [ %add8, %loop-block ], [ 0, %loop-block.preheader ]
  %sm1.0342 = phi double [ %add, %loop-block ], [ 0.000000e+00, %loop-block.preheader ]
  %get6 = tail call double @"get-index$array<prob>"(<{ i64, double* }>* nonnull %1, i64 %ci8.0343) #9
  %add = tail call double @"add$2&prob"(double %sm1.0342, double %get6) #9
  %add8 = tail call i64 @"add$2&nat"(i64 %ci8.0343, i64 1) #9
  %ipred = icmp ult i64 %add8, %get340
  br i1 %ipred, label %loop-block, label %afterloop-block

afterloop-block:                                  ; preds = %loop-block, %entry
  %sm1.0.lcssa = phi double [ 0.000000e+00, %entry ], [ %add, %loop-block ]
  %get10 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %2) #9
  %new = tail call <{ i64, i64* }>* @"new-sized$array<nat>"(i64 %get10) #9
  %mak = tail call <{ <{ i64, i64* }>*, i64 }>* @"make$pair<array<nat>*.unit>"(<{ i64, i64* }>* %new, i64 0) #9
  %get12 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %2) #9
  %new13 = tail call <{ i64, <{ i64, i64* }>** }>* @"new-sized$array<array<nat>*>"(i64 %get12) #9
  %get19337 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %2) #9
  %ipred20338 = icmp eq i64 %get19337, 0
  br i1 %ipred20338, label %afterloop-block16, label %loop-block15.preheader

loop-block15.preheader:                           ; preds = %afterloop-block
  br label %loop-block15

loop-block15:                                     ; preds = %loop-block15.preheader, %loop-block15
  %storemerge312339 = phi i64 [ %add27, %loop-block15 ], [ 0, %loop-block15.preheader ]
  %get24 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %1) #9
  %new25 = tail call <{ i64, i64* }>* @"new-sized$array<nat>"(i64 %get24) #9
  tail call void @"set-index!$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* %new13, i64 %storemerge312339, <{ i64, i64* }>* %new25) #9
  %add27 = tail call i64 @"add$2&nat"(i64 %storemerge312339, i64 1) #9
  %get19 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %2) #9
  %ipred20 = icmp ult i64 %add27, %get19
  br i1 %ipred20, label %loop-block15, label %afterloop-block16

afterloop-block16:                                ; preds = %loop-block15, %afterloop-block
  %mak29 = tail call <{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* @"make$pair<array<array<nat>*>*.unit>"(<{ i64, <{ i64, i64* }>** }>* %new13, i64 0) #9
  %get31 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %0) #9
  %new32 = tail call <{ i64, i64* }>* @"new-sized$array<nat>"(i64 %get31) #9
  %mak33 = tail call <{ i64, <{ i64, i64* }>* }>* @"make$pair<unit.array<nat>*>"(i64 0, <{ i64, i64* }>* %new32) #9
  %get35 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %1) #9
  %new36 = tail call <{ i64, <{ i64, i64* }>** }>* @"new-sized$array<array<nat>*>"(i64 %get35) #9
  %get42334 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %1) #9
  %ipred43335 = icmp eq i64 %get42334, 0
  br i1 %ipred43335, label %afterloop-block39, label %loop-block38.preheader

loop-block38.preheader:                           ; preds = %afterloop-block16
  br label %loop-block38

loop-block38:                                     ; preds = %loop-block38.preheader, %loop-block38
  %storemerge311336 = phi i64 [ %add50, %loop-block38 ], [ 0, %loop-block38.preheader ]
  %get47 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %0) #9
  %new48 = tail call <{ i64, i64* }>* @"new-sized$array<nat>"(i64 %get47) #9
  tail call void @"set-index!$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* %new36, i64 %storemerge311336, <{ i64, i64* }>* %new48) #9
  %add50 = tail call i64 @"add$2&nat"(i64 %storemerge311336, i64 1) #9
  %get42 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %1) #9
  %ipred43 = icmp ult i64 %add50, %get42
  br i1 %ipred43, label %loop-block38, label %afterloop-block39

afterloop-block39:                                ; preds = %loop-block38, %afterloop-block16
  %mak52 = tail call <{ i64, <{ i64, <{ i64, i64* }>** }>* }>* @"make$pair<unit.array<array<nat>*>*>"(i64 0, <{ i64, <{ i64, i64* }>** }>* %new36) #9
  %get58331 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %3) #9
  %ipred59332 = icmp eq i64 %get58331, 0
  br i1 %ipred59332, label %afterloop-block55, label %loop-block54.preheader

loop-block54.preheader:                           ; preds = %afterloop-block39
  br label %loop-block54

loop-block54:                                     ; preds = %loop-block54.preheader, %ife112
  %storemerge310333 = phi i64 [ %add134, %ife112 ], [ 0, %loop-block54.preheader ]
  %get62 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %4, i64 %storemerge310333) #9
  %car = tail call <{ i64, i64* }>* @"car$pair<array<nat>*.unit>"(<{ <{ i64, i64* }>*, i64 }>* %mak) #9
  %get68 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %car, i64 %get62) #9
  %add69 = tail call i64 @"add$2&nat"(i64 %get68, i64 1) #9
  tail call void @"set-index!$array<nat>"(<{ i64, i64* }>* %car, i64 %get62, i64 %add69) #9
  %get72 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %4, i64 %storemerge310333) #9
  %get75 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %3, i64 %storemerge310333) #9
  %car77 = tail call <{ i64, <{ i64, i64* }>** }>* @"car$pair<array<array<nat>*>*.unit>"(<{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* %mak29) #9
  %get79 = tail call <{ i64, i64* }>* @"get-index$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* %car77, i64 %get72) #9
  %get86 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %get79, i64 %get75) #9
  %add87 = tail call i64 @"add$2&nat"(i64 %get86, i64 1) #9
  tail call void @"set-index!$array<nat>"(<{ i64, i64* }>* %get79, i64 %get75, i64 %add87) #9
  %get90 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %4, i64 %storemerge310333) #9
  %ipred92 = icmp eq i64 %get90, %5
  br i1 %ipred92, label %ife, label %else

afterloop-block55:                                ; preds = %ife112, %afterloop-block39
  %get136 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %0) #9
  %new137 = tail call <{ i64, double* }>* @"new-sized$array<prob>"(i64 %get136) #9
  %get143327 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %0) #9
  %ipred144328 = icmp eq i64 %get143327, 0
  br i1 %ipred144328, label %afterloop-block140, label %loop-block139.preheader

loop-block139.preheader:                          ; preds = %afterloop-block55
  br label %loop-block139

else:                                             ; preds = %loop-block54
  %get97 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %2, i64 %get90) #9
  %cdr = tail call <{ i64, i64* }>* @"cdr$pair<unit.array<nat>*>"(<{ i64, <{ i64, i64* }>* }>* %mak33) #9
  %get103 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %cdr, i64 %get97) #9
  %add104 = tail call i64 @"add$2&nat"(i64 %get103, i64 1) #9
  tail call void @"set-index!$array<nat>"(<{ i64, i64* }>* %cdr, i64 %get97, i64 %add104) #9
  br label %ife

ife:                                              ; preds = %loop-block54, %else
  %get107 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %4, i64 %storemerge310333) #9
  %ipred109 = icmp eq i64 %get107, %5
  br i1 %ipred109, label %ife112, label %else111

else111:                                          ; preds = %ife
  %get115 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %3, i64 %storemerge310333) #9
  %get120 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %2, i64 %get107) #9
  %cdr122 = tail call <{ i64, <{ i64, i64* }>** }>* @"cdr$pair<unit.array<array<nat>*>*>"(<{ i64, <{ i64, <{ i64, i64* }>** }>* }>* %mak52) #9
  %get124 = tail call <{ i64, i64* }>* @"get-index$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* %cdr122, i64 %get115) #9
  %get131 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %get124, i64 %get120) #9
  %add132 = tail call i64 @"add$2&nat"(i64 %get131, i64 1) #9
  tail call void @"set-index!$array<nat>"(<{ i64, i64* }>* %get124, i64 %get120, i64 %add132) #9
  br label %ife112

ife112:                                           ; preds = %ife, %else111
  %add134 = tail call i64 @"add$2&nat"(i64 %storemerge310333, i64 1) #9
  %get58 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %3) #9
  %ipred59 = icmp ult i64 %add134, %get58
  br i1 %ipred59, label %loop-block54, label %afterloop-block55

loop-block139:                                    ; preds = %loop-block139.preheader, %afterloop-block168
  %get143330 = phi i64 [ %get143, %afterloop-block168 ], [ %get143327, %loop-block139.preheader ]
  %storemerge329 = phi i64 [ %add293, %afterloop-block168 ], [ 0, %loop-block139.preheader ]
  %new147 = tail call <{ i64, i64* }>* @"new-sized$array<nat>"(i64 %get143330) #9
  %get153313 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %2) #9
  %ipred154314 = icmp eq i64 %get153313, 0
  br i1 %ipred154314, label %afterloop-block150, label %loop-block149.preheader

loop-block149.preheader:                          ; preds = %loop-block139
  br label %loop-block149

afterloop-block140:                               ; preds = %afterloop-block168, %afterloop-block55
  %get296 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %2) #9
  %ipred297 = icmp ugt i64 %get296, %5
  br i1 %ipred297, label %then298, label %else299

loop-block149:                                    ; preds = %loop-block149.preheader, %loop-block149
  %storemerge309315 = phi i64 [ %add165, %loop-block149 ], [ 0, %loop-block149.preheader ]
  %get157 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %2, i64 %storemerge309315) #9
  %get162 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %new147, i64 %get157) #9
  %add163 = tail call i64 @"add$2&nat"(i64 %get162, i64 1) #9
  tail call void @"set-index!$array<nat>"(<{ i64, i64* }>* %new147, i64 %get157, i64 %add163) #9
  %add165 = tail call i64 @"add$2&nat"(i64 %storemerge309315, i64 1) #9
  %get153 = tail call i64 @"get-size$array<nat>"(<{ i64, i64* }>* nonnull %2) #9
  %ipred154 = icmp ult i64 %add165, %get153
  br i1 %ipred154, label %loop-block149, label %afterloop-block150

afterloop-block150:                               ; preds = %loop-block149, %loop-block139
  %get171322 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %0) #9
  %ipred172323 = icmp eq i64 %get171322, 0
  br i1 %ipred172323, label %afterloop-block168, label %loop-block167.lr.ph

loop-block167.lr.ph:                              ; preds = %afterloop-block150
  %get209318 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %1) #9
  %get171 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %0) #9
  br label %loop-block167

loop-block167:                                    ; preds = %loop-block167.lr.ph, %afterloop-block206
  %add253326 = phi double [ 1.000000e+00, %loop-block167.lr.ph ], [ %add253, %afterloop-block206 ]
  %add203325 = phi double [ 1.000000e+00, %loop-block167.lr.ph ], [ %add203, %afterloop-block206 ]
  %storemerge303324 = phi i64 [ 0, %loop-block167.lr.ph ], [ %add255, %afterloop-block206 ]
  br label %loop-entry173

afterloop-block168:                               ; preds = %afterloop-block206, %afterloop-block150
  %pr4289 = phi double [ 1.000000e+00, %afterloop-block150 ], [ %add203, %afterloop-block206 ]
  %pr1258 = phi double [ 1.000000e+00, %afterloop-block150 ], [ %add253, %afterloop-block206 ]
  %get171.lcssa = phi i64 [ 0, %afterloop-block150 ], [ %get171, %afterloop-block206 ]
  %pro = tail call double @prob2real(double %pr1258) #9
  %nat261 = tail call i64 @nat2int(i64 %get171.lcssa) #9
  %add262 = tail call i64 @"add$2&int"(i64 %nat261, i64 -1) #9
  %get265 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* nonnull %2, i64 %5) #9
  %nat266 = tail call i64 @nat2int(i64 %get265) #9
  %ipred267 = icmp sge i64 %add262, %nat266
  %ipred272 = icmp eq i64 %storemerge329, %get265
  %v273 = and i1 %ipred272, %ipred267
  %. = zext i1 %v273 to i64
  %nat278 = tail call i64 @nat2int(i64 %.) #9
  %mul = tail call i64 @"mul$2&int"(i64 %nat278, i64 -1) #9
  %get281 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %new147, i64 %storemerge329) #9
  %nat282 = tail call i64 @nat2int(i64 %get281) #9
  %add283 = tail call i64 @"add$2&int"(i64 %mul, i64 %nat282) #9
  %int = tail call double @int2real(i64 %add283) #9
  %get286 = tail call double @"get-index$array<prob>"(<{ i64, double* }>* nonnull %0, i64 %storemerge329) #9
  %pro287 = tail call double @prob2real(double %get286) #9
  %add288 = tail call double @"add$2&real"(double %int, double %pro287) #9
  %rec = tail call double @recip-prob(double %pr4289) #9
  %pro290 = tail call double @prob2real(double %rec) #9
  %mul291 = tail call double @"mul$3&real"(double %pro, double %add288, double %pro290) #9
  %rea = tail call double @real2prob(double %mul291) #9
  tail call void @"set-index!$array<prob>"(<{ i64, double* }>* %new137, i64 %storemerge329, double %rea) #9
  %add293 = tail call i64 @"add$2&nat"(i64 %storemerge329, i64 1) #9
  %get143 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %0) #9
  %ipred144 = icmp ult i64 %add293, %get143
  br i1 %ipred144, label %loop-block139, label %afterloop-block140

loop-entry173:                                    ; preds = %loop-block174, %loop-block167
  %add198316 = phi double [ %add198, %loop-block174 ], [ 1.000000e+00, %loop-block167 ]
  %storemerge307 = phi i64 [ %add200, %loop-block174 ], [ 0, %loop-block167 ]
  %6 = icmp eq i64 %storemerge303324, %storemerge329
  br i1 %6, label %then180, label %ife182

loop-block174:                                    ; preds = %ife182
  %cdr191 = tail call <{ i64, i64* }>* @"cdr$pair<unit.array<nat>*>"(<{ i64, <{ i64, i64* }>* }>* %mak33) #9
  %get193 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %cdr191, i64 %storemerge303324) #9
  %nat = tail call double @nat2prob(i64 %get193) #9
  %nat195 = tail call double @nat2prob(i64 %storemerge307) #9
  %add197 = tail call double @"add$3&prob"(double %nat, double %nat195, double %sm1.0.lcssa) #9
  %add198 = tail call double @"add$2&prob"(double %add198316, double %add197) #9
  %add200 = tail call i64 @"add$2&nat"(i64 %storemerge307, i64 1) #9
  br label %loop-entry173

afterloop-block175:                               ; preds = %ife182
  %7 = icmp eq i64 %get209318, 0
  %add203 = tail call double @"add$2&prob"(double %add203325, double %add198316) #9
  br i1 %7, label %afterloop-block206, label %loop-block205.lr.ph

loop-block205.lr.ph:                              ; preds = %afterloop-block175
  %get209 = tail call i64 @"get-size$array<prob>"(<{ i64, double* }>* nonnull %1) #9
  br label %loop-block205

then180:                                          ; preds = %loop-entry173
  %car184 = tail call <{ i64, i64* }>* @"car$pair<array<nat>*.unit>"(<{ <{ i64, i64* }>*, i64 }>* %mak) #9
  %get186 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %car184, i64 %5) #9
  br label %ife182

ife182:                                           ; preds = %loop-entry173, %then180
  %storemerge308 = phi i64 [ %get186, %then180 ], [ 0, %loop-entry173 ]
  %ipred188 = icmp ult i64 %storemerge307, %storemerge308
  br i1 %ipred188, label %loop-block174, label %afterloop-block175

loop-block205:                                    ; preds = %loop-block205.lr.ph, %afterloop-block213
  %add248321 = phi double [ 1.000000e+00, %loop-block205.lr.ph ], [ %add248, %afterloop-block213 ]
  %storemerge304320 = phi i64 [ 0, %loop-block205.lr.ph ], [ %add250, %afterloop-block213 ]
  br label %loop-entry211

afterloop-block206:                               ; preds = %afterloop-block213, %afterloop-block175
  %pr2252 = phi double [ 1.000000e+00, %afterloop-block175 ], [ %add248, %afterloop-block213 ]
  %add253 = tail call double @"add$2&prob"(double %add253326, double %pr2252) #9
  %add255 = tail call i64 @"add$2&nat"(i64 %storemerge303324, i64 1) #9
  %ipred172 = icmp ult i64 %add255, %get171
  br i1 %ipred172, label %loop-block167, label %afterloop-block168

loop-entry211:                                    ; preds = %loop-block212, %loop-block205
  %add243317 = phi double [ %add243, %loop-block212 ], [ 1.000000e+00, %loop-block205 ]
  %storemerge305 = phi i64 [ %add245, %loop-block212 ], [ 0, %loop-block205 ]
  %8 = icmp eq i64 %storemerge303324, %storemerge329
  br i1 %8, label %then218, label %ife220

loop-block212:                                    ; preds = %ife220
  %cdr231 = tail call <{ i64, <{ i64, i64* }>** }>* @"cdr$pair<unit.array<array<nat>*>*>"(<{ i64, <{ i64, <{ i64, i64* }>** }>* }>* %mak52) #9
  %get233 = tail call <{ i64, i64* }>* @"get-index$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* %cdr231, i64 %storemerge304320) #9
  %get235 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %get233, i64 %storemerge303324) #9
  %nat236 = tail call double @nat2prob(i64 %get235) #9
  %nat238 = tail call double @nat2prob(i64 %storemerge305) #9
  %get241 = tail call double @"get-index$array<prob>"(<{ i64, double* }>* nonnull %1, i64 %storemerge304320) #9
  %add242 = tail call double @"add$3&prob"(double %nat236, double %nat238, double %get241) #9
  %add243 = tail call double @"add$2&prob"(double %add243317, double %add242) #9
  %add245 = tail call i64 @"add$2&nat"(i64 %storemerge305, i64 1) #9
  br label %loop-entry211

afterloop-block213:                               ; preds = %ife220
  %add248 = tail call double @"add$2&prob"(double %add248321, double %add243317) #9
  %add250 = tail call i64 @"add$2&nat"(i64 %storemerge304320, i64 1) #9
  %ipred210 = icmp ult i64 %add250, %get209
  br i1 %ipred210, label %loop-block205, label %afterloop-block206

then218:                                          ; preds = %loop-entry211
  %car222 = tail call <{ i64, <{ i64, i64* }>** }>* @"car$pair<array<array<nat>*>*.unit>"(<{ <{ i64, <{ i64, i64* }>** }>*, i64 }>* %mak29) #9
  %get224 = tail call <{ i64, i64* }>* @"get-index$array<array<nat>*>"(<{ i64, <{ i64, i64* }>** }>* %car222, i64 %5) #9
  %get226 = tail call i64 @"get-index$array<nat>"(<{ i64, i64* }>* %get224, i64 %storemerge304320) #9
  br label %ife220

ife220:                                           ; preds = %loop-entry211, %then218
  %storemerge306 = phi i64 [ %get226, %then218 ], [ 0, %loop-entry211 ]
  %ipred228 = icmp ult i64 %storemerge305, %storemerge306
  br i1 %ipred228, label %loop-block212, label %afterloop-block213

then298:                                          ; preds = %afterloop-block140
  %cat = tail call i64 @categorical(<{ i64, double* }>* %new137) #9
  ret i64 %cat

else299:                                          ; preds = %afterloop-block140
  ret i64 0
}

; Function Attrs: nounwind readnone speculatable
declare double @llvm.exp.f64(double) #7

; Function Attrs: nounwind readnone speculatable
declare double @llvm.log.f64(double) #7

; Function Attrs: nounwind readnone speculatable
declare double @llvm.powi.f64(double, i32) #7

; Function Attrs: nounwind
declare noalias i8* @malloc(i32) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #8

; Function Attrs: nounwind
declare void @free(i8* nocapture) local_unnamed_addr #2

declare i8* @gsl_rng_alloc(i8*) local_unnamed_addr #5

declare double @gsl_ran_flat(i8*, double, double) local_unnamed_addr #5

declare double @gsl_ran_gaussian(i8*, double) local_unnamed_addr #5

declare double @gsl_sf_lnbeta(double, double) local_unnamed_addr #5

declare double @gsl_ran_gamma(i8*, double, double) local_unnamed_addr #5

declare double @gsl_sf_gamma(double) local_unnamed_addr #5

declare i8* @gsl_ran_discrete_preproc(i64, double*) local_unnamed_addr #5

declare i64 @gsl_ran_discrete(i8*, i8*) local_unnamed_addr #5

declare void @gsl_ran_discrete_free(i8*) local_unnamed_addr #5

; Function Attrs: nounwind
declare void @llvm.stackprotector(i8*, i8**) #9

attributes #0 = { nounwind readnone "no-frame-pointer-elim"="false" }
attributes #1 = { norecurse nounwind readnone "no-frame-pointer-elim"="false" }
attributes #2 = { nounwind "no-frame-pointer-elim"="false" }
attributes #3 = { norecurse nounwind readonly "no-frame-pointer-elim"="false" }
attributes #4 = { norecurse nounwind "no-frame-pointer-elim"="false" }
attributes #5 = { "no-frame-pointer-elim"="false" }
attributes #6 = { argmemonly norecurse nounwind readonly speculatable "no-frame-pointer-elim"="false" }
attributes #7 = { nounwind readnone speculatable "no-frame-pointer-elim"="false" }
attributes #8 = { argmemonly nounwind "no-frame-pointer-elim"="false" }
attributes #9 = { nounwind }
