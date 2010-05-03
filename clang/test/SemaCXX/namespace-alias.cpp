// RUN: %clang_cc1 -fsyntax-only -verify %s

namespace N { struct X { }; };

namespace A = N;

int B; // expected-note {{previous definition is here}}
namespace B = N; // expected-error {{redefinition of 'B' as different kind of symbol}}

namespace C { } // expected-note {{previous definition is here}}
namespace C = N; // expected-error {{redefinition of 'C'}}

int i;
namespace D = i; // expected-error {{expected namespace name}}

namespace E = N::Foo; // expected-error {{expected namespace name}}

namespace F {
  namespace A { namespace B { } } // expected-note {{candidate found by name lookup is 'F::A::B'}}
  namespace B { } // expected-note {{candidate found by name lookup is 'F::B'}}
  using namespace A;
  namespace D = B; // expected-error {{reference to 'B' is ambiguous}}
}

namespace G { 
  namespace B = N;
}

namespace H {
  namespace A1 { }
  namespace A2 { }

  // These all point to A1.
  namespace B = A1; // expected-note {{previous definition is here}}
  namespace B = A1;
  namespace C = B;
  namespace B = C;

  namespace B = A2; // expected-error {{redefinition of 'B' as different kind of symbol}}
}

namespace I { 
  namespace A1 { int i; }
  
  namespace A2 = A1;
}

int f() {
  return I::A2::i;
}

namespace J {
  namespace A { 
    namespace B { void func (); }
  }

  namespace C = A;

  using namespace C::B;

  void g() {
    func();
  }
}

namespace K {
  namespace KA { void func(); }

  void f() {
    namespace KB = KA;
    KB::func();
  }

  template <class T> void g() {
    namespace KC = KA;
    KC::func();
  }
  template void g<int>();
  template void g<long>();

  void h() {
    KB::func(); // expected-error {{undeclared identifier 'KB'}}
    KC::func(); // expected-error {{undeclared identifier 'KC'}}
  }
}

// PR6341
namespace A = N;
namespace N { }
namespace A = N;

A::X nx;

namespace PR7014 {
  namespace X
  {
    namespace Y {}
  }

  using namespace X;

  namespace Y = X::Y;
}
