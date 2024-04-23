import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Gt}

pub opaque type PriorityQueue(t) {
  PriorityQueue(data: PairingHeap(t), cmp: Cmp(t))
}

type PairingHeap(t) {
  Empty
  NonEmpty(PairingTree(t))
}

type Cmp(t) =
  fn(t, t) -> Order

type PairingTree(t) {
  PairingTree(val: t, children: List(PairingTree(t)), len: Int)
}

pub fn new(cmp: Cmp(t)) -> PriorityQueue(t) {
  PriorityQueue(Empty, cmp)
}

fn from_pairing_tree(tree: PairingTree(t), cmp: Cmp(t)) -> PriorityQueue(t) {
  PriorityQueue(NonEmpty(tree), cmp)
}

fn one(val: t, cmp: Cmp(t)) -> PriorityQueue(t) {
  PriorityQueue(NonEmpty(PairingTree(val, [], len: 1)), cmp)
}

pub fn is_empty(pq: PriorityQueue(t)) -> Bool {
  pq.data == Empty
}

pub fn len(pq: PriorityQueue(t)) -> Int {
  case pq.data {
    Empty -> 0
    NonEmpty(tree) -> tree.len
  }
}

pub fn peek(pq: PriorityQueue(t)) -> Option(t) {
  case pq.data {
    Empty -> None
    NonEmpty(tree) -> Some(tree.val)
  }
}

fn merge(pq1: PriorityQueue(t), pq2: PriorityQueue(t)) -> PriorityQueue(t) {
  case pq1.cmp == pq2.cmp {
    False -> panic as "inconsistent cmp function"
    True ->
      case pq1.data, pq2.data {
        Empty, _ -> pq2
        _, Empty -> pq1
        NonEmpty(tree1), NonEmpty(tree2) -> {
          let new_len = tree1.len + tree2.len
          case pq1.cmp(tree1.val, tree2.val) {
            Gt ->
              PriorityQueue(
                NonEmpty(PairingTree(
                  tree1.val,
                  [tree2, ..tree1.children],
                  new_len,
                )),
                pq1.cmp,
              )
            _ ->
              PriorityQueue(
                NonEmpty(PairingTree(
                  tree2.val,
                  [tree1, ..tree2.children],
                  new_len,
                )),
                pq1.cmp,
              )
          }
        }
      }
  }
}

pub fn push(pq: PriorityQueue(t), val: t) -> PriorityQueue(t) {
  merge(one(val, pq.cmp), pq)
}

pub fn pop(pq: PriorityQueue(t)) -> PriorityQueue(t) {
  case pq.data {
    Empty -> pq
    NonEmpty(tree) -> merge_pairs(tree.children, pq.cmp)
  }
}

fn merge_pairs(trees: List(PairingTree(t)), cmp: Cmp(t)) -> PriorityQueue(t) {
  case trees {
    [] -> PriorityQueue(Empty, cmp)
    [tree] -> from_pairing_tree(tree, cmp)
    [tree1, tree2, ..rest] ->
      merge(from_pairing_tree(tree1, cmp), from_pairing_tree(tree2, cmp))
      |> merge(merge_pairs(rest, cmp))
  }
}
