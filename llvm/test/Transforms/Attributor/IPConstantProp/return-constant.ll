; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -passes=attributor -aa-pipeline='basic-aa' -attributor-disable=false -attributor-max-iterations-verify -attributor-max-iterations=1 < %s | FileCheck %s

; FIXME: icmp folding is missing

define i1 @invokecaller(i1 %C) personality i32 (...)* @__gxx_personality_v0 {
; CHECK-LABEL: define {{[^@]+}}@invokecaller
; CHECK-SAME: (i1 [[C:%.*]]) #0 personality i32 (...)* @__gxx_personality_v0
; CHECK-NEXT:    [[X:%.*]] = call i32 @foo(i1 [[C]])
; CHECK-NEXT:    br label [[OK:%.*]]
; CHECK:       OK:
; CHECK-NEXT:    ret i1 true
; CHECK:       FAIL:
; CHECK-NEXT:    unreachable
;
  %X = invoke i32 @foo( i1 %C ) to label %OK unwind label %FAIL             ; <i32> [#uses=1]
OK:
  %Y = icmp ne i32 %X, 0          ; <i1> [#uses=1]
  ret i1 %Y
FAIL:
  %exn = landingpad {i8*, i32}
  cleanup
  ret i1 false
}

define internal i32 @foo(i1 %C) {
; CHECK-LABEL: define {{[^@]+}}@foo
; CHECK-SAME: (i1 [[C:%.*]])
; CHECK-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; CHECK:       T:
; CHECK-NEXT:    ret i32 52
; CHECK:       F:
; CHECK-NEXT:    ret i32 52
;
  br i1 %C, label %T, label %F

T:              ; preds = %0
  ret i32 52

F:              ; preds = %0
  ret i32 52
}

define i1 @caller(i1 %C) {
; CHECK-LABEL: define {{[^@]+}}@caller
; CHECK-SAME: (i1 [[C:%.*]])
; CHECK-NEXT:    ret i1 true
;
  %X = call i32 @foo( i1 %C )             ; <i32> [#uses=1]
  %Y = icmp ne i32 %X, 0          ; <i1> [#uses=1]
  ret i1 %Y
}

declare i32 @__gxx_personality_v0(...)
