+++
title = "How to join 2 scala maps using cats"
date = 2025-10-10

[taxonomies]
categories = ["scala"]
tags = ["coding", "scala"]
+++

The following code snippet performs a full outer join between 2 scala Maps.

If using scala 2.12, you will need the `-Ypartial-unification` compiler flag.

```scala
import cats.Semigroup
import cats.data.Ior
import cats.syntax.all.*

def join[K, V1, V2](m1: Map[K, V1], m2: Map[K, V2]): Map[K, Ior[V1, V2]] = {
  def rightWins[A]: Semigroup[A] = Semigroup.instance { case (_, right) => right }
  implicit val semigroupV1 = rightWins[V1]
  implicit val semigroupV2 = rightWins[V2]

  m1.fmap(_.leftIor[V2]) |+| m2.fmap(_.rightIor[V1])
}

val m1 = Map("a" -> 1, "b" -> 2)
val m2 = Map("a" -> "foo", "c" -> "bar")

join(m1, m2)
// Map(a -> Ior.Both(1,foo), c -> Ior.Right(bar), b -> Ior.Left(2))
```
