(* nasty because Zplus depends on Pminus which is a bucket of FAIL *)
Require 
  interfaces.naturals theory.naturals peano_naturals theory.nat_pow.
Require Import
  BinInt Morphisms Ring Program Arith ZBinary
  abstract_algebra interfaces.integers
  theory.categories theory.rings 
  signed_binary_positives
  interfaces.additional_operations
  nonneg_integers_naturals.

(* canonical names: *)
Instance z_equiv: Equiv BinInt.Z := eq.
Instance: RingPlus BinInt.Z := BinInt.Zplus.
Instance: RingZero BinInt.Z := BinInt.Z0.
Instance: RingOne BinInt.Z := BinInt.Zpos BinPos.xH.
Instance: RingMult BinInt.Z := BinInt.Zmult.
Instance: GroupInv BinInt.Z := BinInt.Zopp.
  (* some day we'd like to do this with [Existing Instance] *)

(* propers: *)
Instance: Proper ((=) ==> (=) ==> (=)) BinInt.Zplus.
Proof. unfold equiv, z_equiv. repeat intro. subst. reflexivity. Qed.
Instance: Proper ((=) ==> (=) ==> (=)) BinInt.Zmult.
Proof. unfold equiv, z_equiv. repeat intro. subst. reflexivity. Qed.
Instance: Proper ((=) ==> (=)) BinInt.Zopp.
Proof. unfold equiv, z_equiv. repeat intro. subst. reflexivity. Qed.

(* properties: *)
Instance: Associative BinInt.Zplus := BinInt.Zplus_assoc.
Instance: Associative BinInt.Zmult := BinInt.Zmult_assoc.
Instance: Commutative BinInt.Zplus := BinInt.Zplus_comm.
Instance: Commutative BinInt.Zmult := BinInt.Zmult_comm.
Instance: Distribute BinInt.Zmult BinInt.Zplus :=
  { distribute_l := BinInt.Zmult_plus_distr_r; distribute_r := BinInt.Zmult_plus_distr_l }.
Instance: LeftIdentity BinInt.Zplus 0 := BinInt.Zplus_0_l.
Instance: RightIdentity BinInt.Zplus 0 := BinInt.Zplus_0_r.
Instance: LeftIdentity BinInt.Zmult 1 := BinInt.Zmult_1_l.
Instance: RightIdentity BinInt.Zmult 1 := BinInt.Zmult_1_r.
Instance: LeftInverse BinInt.Zplus BinInt.Zopp 0 := BinInt.Zplus_opp_l.
Instance: RightInverse BinInt.Zplus BinInt.Zopp 0 := BinInt.Zplus_opp_r.

(* structures: *)
Instance: Equivalence (@eq BinInt.Z). (* this should not be necessary, seems like a regression bug *)
Instance: Setoid BinInt.Z.
Instance: SemiGroup _ (op:=BinInt.Zplus).
Instance: SemiGroup _ (op:=BinInt.Zmult).
Instance: Monoid _ (op:=BinInt.Zplus) (unit:=BinInt.Z0).
Instance: Monoid _ (op:=BinInt.Zmult) (unit:=BinInt.Zpos BinPos.xH).
Instance: CommutativeMonoid _ (op:=BinInt.Zmult) (unit:=BinInt.Zpos BinPos.xH).
Instance: @Group _ _ (BinInt.Zplus) (BinInt.Z0) _.
Instance: AbGroup BinInt.Z (op:=BinInt.Zplus) (unit:=BinInt.Z0).
Program Instance: Ring BinInt.Z.

(* misc: *)
Instance: ∀ x y: BinInt.Z, Decision (x = y) := ZArith_dec.Z_eq_dec.

Add Ring Z: (stdlib_ring_theory BinInt.Z).

Definition map_Z `{RingPlus R} `{RingZero R} `{RingOne R} `{GroupInv R} (z: Z): R :=
  match z with
  | Z0 => 0
  | Zpos p => map_pos p
  | Zneg p => - map_pos p
  end.

Instance inject: IntegersToRing Z := λ B _ _ _ _ _, @map_Z B _ _ _ _.

Section for_another_ring.
  Context `{Ring R}.

  Add Ring R: (stdlib_ring_theory R).

  Lemma preserves_Zplus x y: map_Z (x + y) = map_Z x + map_Z y.
  Proof with try reflexivity; try assumption; try ring.
   destruct x as [| x | x ]; simpl...
    destruct y as [| y | y]; simpl...
     apply preserves_Pplus.
    case_eq (Pcompare x y Eq); intros E; simpl.
      rewrite (Pcompare_Eq_eq _ _ E)...
     rewrite preserves_Pminus...
    apply preserves_Pminus.
    unfold Plt.
    rewrite (ZC1 _ _ E)...
   destruct y as [| y | y ]; simpl...
    case_eq (Pcompare x y Eq); intros E; simpl.
      rewrite (Pcompare_Eq_eq _ _ E)...
     rewrite preserves_Pminus...
    rewrite preserves_Pminus...
    unfold Plt.
    rewrite (ZC1 _ _ E)...
   rewrite preserves_Pplus...
  Qed.

  Lemma preserves_Zmult x y: map_Z (x * y) = map_Z x * map_Z y.
  Proof with try reflexivity; try ring.
   destruct x; simpl; intros...
    destruct y; simpl...
     apply preserves_Pmult.
    rewrite preserves_Pmult...
   destruct y; simpl...
    rewrite preserves_Pmult...
   rewrite preserves_Pmult...
  Qed.

  Instance: Proper ((=) ==> (=)) map_Z.
  Proof. unfold equiv, z_equiv. repeat intro. subst. reflexivity. Qed.

  Hint Resolve preserves_Zplus preserves_Zmult.
  Hint Constructors Monoid_Morphism SemiGroup_Morphism.

  Global Instance map_Z_ring_mor: SemiRing_Morphism map_Z.
  Proof. repeat (constructor; auto with typeclass_instances; try reflexivity; try apply _). Qed.

  Section with_another_morphism.
    Context map_Z' `{!SemiRing_Morphism (map_Z': Z → R)}.

    Let agree_on_0: map_Z Z0 = map_Z' Z0.
    Proof. symmetry. apply preserves_0. Qed.

    Let agree_on_1: map_Z 1%Z = map_Z' 1%Z.
    Proof. symmetry. apply preserves_1. Qed.

    Let agree_on_positive p: map_Z (Zpos p) = map_Z' (Zpos p).
    Proof with try reflexivity.
     induction p; simpl.
       rewrite IHp.
       rewrite xI_in_ring_terms.
       rewrite agree_on_1.
       do 2 rewrite <- preserves_sg_op...
      rewrite IHp.
      rewrite xO_in_ring_terms.
      rewrite <- preserves_sg_op...
     apply agree_on_1.
    Qed.

    Let agree_on_negative p: map_Z (Zneg p) = map_Z' (Zneg p).
    Proof with try reflexivity.
     intros.
     replace (Zneg p) with (- (Zpos p))...
     do 2 rewrite preserves_inv.
     rewrite <- agree_on_positive...
    Qed.

    Lemma same_morphism: integers_to_ring Z R = map_Z'.
    Proof.
     intros [].
       intros y E. rewrite <- E.
       apply agree_on_0.
      intros p y E. rewrite <- E.
      apply agree_on_positive.
     intros p y E. rewrite <- E.
     apply agree_on_negative.
    Qed.

  End with_another_morphism.
End for_another_ring.

Instance: Initial (ring.object Z).
Proof.
  apply integer_initial. intros. apply same_morphism. auto.
Qed.
Instance: Integers Z.

Instance: Order Z := Zle.

Instance: RingOrder Zle.
Proof.
  repeat (split; try apply _).
    exact Zorder.Zle_antisym.
   intros x y E. apply Zorder.Zplus_le_compat_l. assumption.
  intros x E y F. apply Zorder.Zmult_le_0_compat; assumption.
Qed.

Instance: TotalOrder Zle.
Proof with intuition. 
  intros x y.
  destruct (Zorder.Zle_or_lt x y)...
  right. apply Zorder.Zlt_le_weak...
Qed.

Lemma Zlt_coincides x y : (x < y)%Z ↔ x < y.
Proof with trivial.
  split.
   intro. split. apply Zorder.Zlt_le_weak... apply Zorder.Zlt_not_eq...
  intros [E1 E2]. destruct (Zorder.Zle_lt_or_eq _ _ E1)... destruct E2...
Qed.

(* * Embedding of the Peano naturals into Z *)
Instance: Proper ((=) ==> (=)) Z_of_nat.
Proof.
  intros x y E.
  rewrite E. reflexivity.
Qed.

Instance: SemiRing_Morphism Z_of_nat.
Proof.
  repeat (split; try apply _).
  exact Znat.inj_plus.
  exact Znat.inj_mult.
Qed.

Local Obligation Tactic := idtac.
(* Efficient nat_pow *)
Program Instance Zpow: NatPow Z (Z⁺) := Z.pow.
Next Obligation with try reflexivity; auto with zarith.
  intros x n. 
  pose proof (@nat_pow.nat_pow_spec_from_properties _ _ _ _ _ _ _ (Z⁺) _ _ _ _ _ _ _ (λ (x : Z) (n : Z⁺), Z.pow x ('n))) as P. (* Fix me! *)
  apply P. 
  (* change (nat_pow_spec x n ((λ x n, Z.pow x ('n)) x n)).  This is stupid... pattern is not helpful either *)
  (* apply nat_pow.nat_pow_spec_from_properties. *)
    intros x1 y1 E1 [x2 Ex2] [y2 Ey2] E2. 
    unfold equiv, NonNeg_equiv in E2. simpl in *. rewrite E1, E2...
   intros x1. apply Z.pow_0_r.
  intros x1 n1. rewrite preserves_plus, preserves_1.  
  rewrite <-(Z.pow_1_r x1) at 2. apply Z.pow_add_r...
  destruct n1...
Qed.

(* Efficient shiftl *)
Program Instance: ShiftLeft Z (Z⁺) := λ x y, Z.shiftl x y. 
Next Obligation.
  intros x [y Ey].
  apply Z.shiftl_mul_pow2.
  apply Ey.
Qed.

Program Instance: Abs Z := Zabs.
Next Obligation with trivial.
  intros x. 
  split; intros E.
   apply Z.abs_eq...
  apply Z.abs_neq...
Qed.
