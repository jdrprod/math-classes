Require Import
  Ring Program Morphisms
  abstract_algebra.
Require
  theory.setoids varieties.monoid.

Section group_props. 
  Context `{Group G}.

  Lemma inv_involutive x: - - x = x.
  Proof.
   rewrite <- (left_identity x) at 2.
   rewrite <- (left_inverse (- x)).
   rewrite <- associativity.
   rewrite left_inverse.
   rewrite right_identity.
   reflexivity.
  Qed.

  Global Instance: Injective (-).
  Proof.
   constructor.
    intros x y E.
    rewrite <- (inv_involutive x), <- (inv_involutive y), E. reflexivity.
   constructor; apply _.
  Qed.

  Lemma inv_0: - mon_unit = mon_unit.
  Proof. rewrite <- (left_inverse mon_unit) at 2. rewrite right_identity. reflexivity. Qed.

  Global Instance: ∀ z : G, LeftCancellation sg_op z.
  Proof.
   intros z x y E.
   rewrite <-(left_identity x), <-(left_inverse z), <-associativity.
   rewrite E.
   rewrite associativity, left_inverse, left_identity.
   reflexivity.
  Qed.  

  Global Instance: ∀ z : G, RightCancellation sg_op z.
  Proof.
   intros z x y E.
   rewrite <-(right_identity x), <-(right_inverse z), associativity.
   rewrite E.
   rewrite <-associativity, right_inverse, right_identity.
   reflexivity.
  Qed.  

  Lemma sg_inv_distr `{!AbGroup G} x y: - (x & y) = - x & - y.
  Proof.
   rewrite <- (left_identity (- x & - y)).
   rewrite <- (left_inverse (x & y)).
   rewrite <- associativity.
   rewrite <- associativity.
   rewrite (commutativity (- x) (- y)).
   rewrite (associativity y).
   rewrite right_inverse.
   rewrite left_identity.
   rewrite right_inverse.
   rewrite right_identity.
   reflexivity.
  Qed.
End group_props.

Section groupmor_props. 
  Context `{Group A} `{Group B} {f : A → B} `{!Monoid_Morphism f}.

  Lemma preserves_inv x: f (- x) = - f x.
  Proof.
    apply (left_cancellation sg_op (f x)).
    rewrite <-preserves_sg_op.
    do 2 rewrite right_inverse.
    apply preserves_mon_unit.
  Qed.
End groupmor_props.

Lemma stdlib_semiring_theory R `{SemiRing R} : Ring_theory.semi_ring_theory 0 1 (+) (.*.) (=).
Proof with try reflexivity.
  constructor; intros.
         apply left_identity.
        apply commutativity.
       apply associativity.
      apply left_identity.
     apply left_absorb.
    apply commutativity.
   apply associativity.
  apply distribute_r.
Qed.

(* Coq does not allow us to apply [left_cancellation (.*.\) z] for a [z] for which we do not have [NeZero z]
    in our context. Therefore we need [left_cancellation_ne_0] to help us out. *)
Section cancellation.
  Context `{e : Equiv A} (op : A → A → A) `{!RingZero A}.

  Lemma left_cancellation_ne_0 `{∀ z, NeZero z → LeftCancellation op z} z : z ≠ 0 → LeftCancellation op z.
  Proof. auto. Qed.

  Lemma right_cancellation_ne_0 `{∀ z, NeZero z → RightCancellation op z} z : z ≠ 0 → RightCancellation op z.
  Proof. auto. Qed.
End cancellation.

Section semiring_props.
  Context `{SemiRing R}.

  Global Instance plus_0_r: RightIdentity (+) 0 := right_identity.
  Global Instance plus_0_l: LeftIdentity (+) 0 := left_identity.
  Global Instance mult_1_l: LeftIdentity (.*.) 1 := left_identity.
  Global Instance mult_1_r: RightIdentity (.*.) 1 := right_identity.

  Global Instance mult_0_r: RightAbsorb (.*.) 0.
  Proof. intro. rewrite commutativity. apply left_absorb. Qed.

  Global Instance: ∀ r : R, Monoid_Morphism (r *.).
  Proof.
   repeat (constructor; try apply _).
    apply distribute_l.
   apply right_absorb.
  Qed.
End semiring_props.

Section semiringmor_props. 
  Context `{SemiRing_Morphism A B f}.

  Lemma preserves_0: f 0 = 0.
  Proof (@preserves_mon_unit _ _ _ _ _ _ _ _ f _). 
  Lemma preserves_1: f 1 = 1.
  Proof (@preserves_mon_unit _ _ _ _ _ _ _ _ f _).
  Lemma preserves_mult: ∀ x y, f (x * y) = f x * f y.
  Proof. intros. apply preserves_sg_op. Qed.
  Lemma preserves_plus: ∀ x y, f (x + y) = f x + f y.
  Proof. intros. apply preserves_sg_op. Qed.

  Context `{!SemiRing B}.
  Lemma preserves_2: f 2 = 2.
  Proof. unfold "2". rewrite preserves_plus. rewrite preserves_1. reflexivity. Qed.

  Context `{!Injective f}.
  Lemma injective_not_0 x : x ≠ 0 → f x ≠ 0.
  Proof.
    intros E G. apply E. 
    apply (injective f). rewrite preserves_0. assumption.
  Qed.

  Lemma injective_not_1 x : x ≠ 1 → f x ≠ 1.
  Proof.
    intros E G. apply E. 
    apply (injective f). rewrite preserves_1. assumption.
  Qed.
End semiringmor_props.

Lemma right_cancel_from_left `{Setoid R} `{!Commutative op} `{!LeftCancellation op z} : RightCancellation op z.
Proof.
  intros x y E.
  apply (left_cancellation op z).
  rewrite (commutativity z x), (commutativity z y). assumption.
Qed.

Lemma stdlib_ring_theory R `{Ring R} : 
  Ring_theory.ring_theory 0 1 (+) (.*.) (λ x y, x - y) (-) (=).
Proof.
 constructor; intros.
         apply left_identity.
        apply commutativity.
       apply associativity.
      apply left_identity.
     apply commutativity.
    apply associativity.
   apply distribute_r.
  reflexivity.
 apply (right_inverse x).
Qed.

Section ring_props. 
  Context `{Ring R}.

  Add Ring R: (stdlib_ring_theory R).

  Instance: LeftAbsorb (.*.) 0.
  Proof. intro. ring. Qed.

  Global Instance Ring_Semi: SemiRing R.
  Proof. repeat (constructor; try apply _). Qed.

  Lemma plus_opp_r x: x + -x = 0. Proof. ring. Qed.
  Lemma plus_opp_l x: -x + x = 0. Proof. ring. Qed.
  Lemma plus_mul_distribute_r x y z: (x + y) * z = x * z + y * z. Proof. ring. Qed.
  Lemma plus_mul_distribute_l x y z: x * (y + z) = x * y + x * z. Proof. ring. Qed.
  Lemma opp_swap x y: x + - y = - (y + - x). Proof. ring. Qed.
  Lemma plus_opp_distr x y: - (x + y) = - x + - y. Proof. ring. Qed.
  Lemma opp_mult a: -a = -(1) * a. Proof. ring. Qed.
  Lemma distr_opp_mult_l a b: -(a * b) = -a * b. Proof. ring. Qed.
  Lemma distr_opp_mult_r a b: -(a * b) = a * -b. Proof. ring. Qed.
  Lemma opp_mult_opp a b: -a * -b = a * b. Proof. ring. Qed.
  Lemma opp_0: -0 = 0. Proof. ring. Qed.
  Lemma ring_distr_opp a b: -(a+b) = -a+-b. Proof. ring. Qed.

  Lemma equal_by_zero_sum x y : x + - y = 0 ↔ x = y.
  Proof. 
    split; intros E. 
     rewrite <- (plus_0_l y). rewrite <- E. ring. 
    rewrite E. ring.
  Qed.

  Lemma inv_zero_prod_l x y : -x * y = 0 ↔ x * y = 0.
  Proof with trivial.
    split; intros E.
     apply (injective (-)). rewrite distr_opp_mult_l, opp_0...
    apply (injective (-)). rewrite distr_opp_mult_l, inv_involutive, opp_0...
  Qed.

  Lemma inv_zero_prod_r x y : x * -y = 0 ↔ x * y = 0.
  Proof. rewrite (commutativity x (-y)), (commutativity x y). apply inv_zero_prod_l. Qed.

  Lemma units_dont_divide_zero (x: R) `{!RingMultInverse x} `{!RingUnit x}: ¬ ZeroDivisor x.
    (* todo: we don't want to have to mention RingMultInverse *)
  Proof with try ring.
   intros [x_nonzero [z [z_nonzero xz_zero]]].
   apply z_nonzero.
   transitivity (1 * z)...
   rewrite <- ring_unit_mult_inverse.
   transitivity (x * z * ring_mult_inverse x)...
   rewrite xz_zero...
  Qed.

  Lemma mult_ne_zero `{!NoZeroDivisors R} (x y: R) : x ≠ 0 → y ≠ 0 → x * y ≠ 0.
  Proof. repeat intro. apply (no_zero_divisors x). split; eauto. Qed.

  Context `{!NoZeroDivisors R} `{∀ x y, Stable (x = y)}.

  Global Instance ring_mult_left_cancel :  ∀ z, NeZero z → LeftCancellation (.*.) z.
  Proof with intuition.
   intros z z_nonzero x y E.
   apply stable.
   intro U.
   apply (mult_ne_zero z (x +- y) (ne_zero z)). 
    intro. apply U. apply equal_by_zero_sum...
   rewrite distribute_l, E. ring.
  Qed.

  Global Instance: ∀ z, NeZero z → RightCancellation (.*.) z.
  Proof. intros ? ?. apply right_cancel_from_left. Qed.
End ring_props.

Section ringmor_props. 
  Context `{Ring A} `{Ring B} {f : A → B} `{!SemiRing_Morphism f}.

  Lemma preserves_minus x y : f (x - y) = f x - f y.
  Proof.
    rewrite <-preserves_inv.
    apply preserves_plus.
  Qed.
End ringmor_props.

Section from_stdlib_ring_theory.
  Context
    `(H: @ring_theory R zero one pl mu mi op e)
    `{!@Setoid R e}
    `{!Proper (e ==> e ==> e) pl}
    `{!Proper (e ==> e ==> e) mu}
    `{!Proper (e ==> e) op}.

  Add Ring R2: H.

  Definition from_stdlib_ring_theory: @Ring R e pl mu zero one op.
  Proof.
   repeat (constructor; try assumption); repeat intro
   ; unfold equiv, mon_unit, sg_op, ring_mult, ring_plus, group_inv; ring.
  Qed.
End from_stdlib_ring_theory.

Section morphism_composition.
  Context (A B C: Type)
    `{!RingMult A} `{!RingPlus A} `{!RingOne A} `{!RingZero A} `{!Equiv A}
    `{!RingMult B} `{!RingPlus B} `{!RingOne B} `{!RingZero B} `{!Equiv B}
    `{!RingMult C} `{!RingPlus C} `{!RingOne C} `{!RingZero C} `{!Equiv C}
    (f: A → B) (g: B → C).

  Global Instance id_semiring_morphism `{!SemiRing A}: SemiRing_Morphism id.

  Global Instance compose_semiring_morphisms
    `{!SemiRing_Morphism f} `{!SemiRing_Morphism g}: SemiRing_Morphism (g ∘ f).
  Proof.
   fold (g ∘ f).
   constructor; try apply _.
    apply semiringmor_a.
   apply semiringmor_b.
  Qed.
End morphism_composition.
