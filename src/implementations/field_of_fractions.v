Require theory.fields.
Require Import Morphisms Ring abstract_algebra theory.rings.

Inductive Frac R `{e : Equiv R} `{one : RingZero R} : Type := frac { num: R; den: R; den_nonzero: den ≠ 0 }.
  (* We used to have [den] and [den_nonzero] bundled, which did work relatively nicely with Program, but the
   extra messyness in proofs etc turned out not to be worth it. *)
Implicit Arguments frac [[R] [e] [one]].
Implicit Arguments num [[R] [e] [one]].
Implicit Arguments den [[R] [e] [one]].
Implicit Arguments den_nonzero [[R] [e] [one]].

Section contents.
Context `{IntegralDomain R}.
Context `{∀ z : R, NeZero z → LeftCancellation (.*.) z}.

Add Ring R: (stdlib_ring_theory R).

Global Program Instance Frac_equiv: Equiv (Frac R) := λ x y, num x * den y = num y * den x.

(* Global with a high priority to avoid "Evar ??? not declared" messages... *)
Global Instance: Setoid (Frac R) | 1.
Proof with auto.
  split; red; unfold equiv, Frac_equiv.
    reflexivity.
   intros x y E. symmetry...
  intros [nx dx] [ny dy] [nz dz] V W. simpl in *.
  apply (left_cancellation_ne_0 (.*.) dy)...
  do 2 rewrite associativity. 
  do 2 rewrite (commutativity dy).
  rewrite V, <- W. ring.
Qed.

Global Instance Frac_dec `{∀ x y, Decision (x = y)} : ∀ x y: Frac R, Decision (x = y) 
  := λ x y, decide (num x * den y = num y * den x).

(* injection from R *)
Global Program Instance Frac_inject: Inject R (Frac R) := λ r, frac r 1 _.
Next Obligation. exact (ne_zero 1). Qed.

Instance: Proper ((=) ==> (=)) inject.
Proof. intros x1 x2 E. unfold equiv, Frac_equiv. simpl. rewrite E. reflexivity. Qed.

(* Relations, operations and constants *)
Global Program Instance Frac_plus: RingPlus (Frac R) :=
  λ x y, frac (num x * den y + num y * den x) (den x * den y) _.
Next Obligation. destruct x, y. simpl. apply mult_ne_zero; assumption. Qed.

Global Instance Frac_0: RingZero (Frac R) := ('0 : Frac R).
Global Instance Frac_1: RingOne (Frac R) := ('1 : Frac R).

Global Instance Frac_inv: GroupInv (Frac R) := λ x, frac (- num x) (den x) (den_nonzero x).

Global Program Instance Frac_mult: RingMult (Frac R) := λ x y, frac (num x * num y) (den x * den y) _.
Next Obligation. destruct x, y. simpl. apply mult_ne_zero; assumption. Qed.

Ltac unfolds := unfold Frac_inv, Frac_plus, equiv, Frac_equiv in *; simpl in *.
Ltac ring_on_ring := repeat intro; unfolds; try ring.

Lemma Frac_nonzero_num x : x ≠ 0 ↔ num x ≠ 0.
Proof.
  split; intros E F; apply E; unfolds.
   rewrite F. ring.
  rewrite right_identity in F.
  rewrite F. apply left_absorb.
Qed.

Global Program Instance Frac_mult_inv: MultInv (Frac R) := λ x, frac (den x) (num x) _.
Next Obligation. apply Frac_nonzero_num. assumption. Qed.

Instance: Proper ((=) ==> (=) ==> (=)) Frac_plus.
Proof with try ring.
  intros x x' E y y' E'. unfolds.
  transitivity (num x * den x' * den y * den y' + num y * den y' * den x * den x')...
  rewrite E, E'...
Qed.

Instance: Proper ((=) ==> (=)) Frac_inv.
Proof. 
  intros x y E. unfolds. 
  rewrite <-distr_opp_mult_l, E. ring. 
Qed.

Instance: Proper ((=) ==> (=) ==> (=)) Frac_mult.
Proof with try ring.
  intros x y E x0 y0 E'. unfolds.
  transitivity (num x * den y * (num x0 * den y0))...
  rewrite E, E'...
Qed.

Instance: Ring (Frac R).
Proof. repeat (split; try apply _); ring_on_ring. Qed.

Instance: Proper ((=) ==> (=)) Frac_mult_inv.
Proof.
  intros [x N] [x' N'] E. unfolds.
  symmetry.
  rewrite (commutativity (den x')), (commutativity (den x)).
  assumption.
Qed.

Global Instance: Field (Frac R).
Proof.
  constructor; try apply _.
   unfold NeZero. unfolds.
   do 2 rewrite mult_1_r.
   apply (ne_zero 1).
  intros [x Ex]. ring_on_ring.
Qed.

(* A final word about inject *)
Global Instance: SemiRing_Morphism Frac_inject.
Proof.
  repeat (constructor; try apply _); try reflexivity.
   intros x y. change ((x + y) * (1 * 1) = (x * 1 + y * 1) * 1). ring.
  intros x y. change ((x * y) * (1 * 1) = x * y * 1). ring.
Qed.

Global Instance: Injective Frac_inject.
Proof. 
  repeat (constructor; try apply _).
  intros x y. unfolds. do 2 rewrite mult_1_r. intuition.
Qed.
End contents.
