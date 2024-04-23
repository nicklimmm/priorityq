import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Gt}

/// A priority queue implemented with a max pairing heap.
///
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
  PairingTree(val: t, children: List(PairingTree(t)), size: Int)
}

/// Creates an empty priority queue.
///
/// ## Examples
///
/// ```gleam
/// import gleam/int
///
/// new(int.compare) // -> PriorityQueue(Int)
/// ```
///
pub fn new(cmp: Cmp(t)) -> PriorityQueue(t) {
  PriorityQueue(Empty, cmp)
}

/// Creates a priority queue from a list.
///
/// Runs in linear time.
///
/// ## Examples
///
/// ```gleam
/// import gleam/int
///
/// from_list([1, 10, 5], int.compare) // -> PriorityQueue(Int)
/// ```
///
pub fn from_list(ls: List(t), cmp: Cmp(t)) -> PriorityQueue(t) {
  new(cmp)
  |> list.fold(ls, _, push)
}

fn from_pairing_tree(tree: PairingTree(t), cmp: Cmp(t)) -> PriorityQueue(t) {
  PriorityQueue(NonEmpty(tree), cmp)
}

fn one(val: t, cmp: Cmp(t)) -> PriorityQueue(t) {
  PriorityQueue(NonEmpty(PairingTree(val, [], size: 1)), cmp)
}

/// Returns whether the priority queue is empty.
///
/// Runs in constant time.
///
/// ## Examples
///
/// ```gleam
/// import gleam/int
///
/// new(int.compare) |> is_empty() // -> True
/// from_list([0], int.compare) |> is_empty() // -> False
/// ```
///
pub fn is_empty(pq: PriorityQueue(t)) -> Bool {
  pq.data == Empty
}

/// Returns the number of elements in the priority queue.
///
/// Runs in constant time.
///
/// ## Examples
///
/// ```gleam
/// import gleam/int
///
/// from_list([1, 2, 3], int.compare) |> size() // -> 3
/// ```
///
pub fn size(pq: PriorityQueue(t)) -> Int {
  case pq.data {
    Empty -> 0
    NonEmpty(tree) -> tree.size
  }
}

/// Returns the maximum value in the priority queue.
///
/// ## Examples
///
/// ```gleam
/// import gleam/int
///
/// new(int.compare) |> peek() // -> None
/// from_list([1, 10, 5], int.compare) |> peek() // -> 10
/// ```
///
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
          let new_size = tree1.size + tree2.size
          case pq1.cmp(tree1.val, tree2.val) {
            Gt ->
              PriorityQueue(
                NonEmpty(PairingTree(
                  tree1.val,
                  [tree2, ..tree1.children],
                  new_size,
                )),
                pq1.cmp,
              )
            _ ->
              PriorityQueue(
                NonEmpty(PairingTree(
                  tree2.val,
                  [tree1, ..tree2.children],
                  new_size,
                )),
                pq1.cmp,
              )
          }
        }
      }
  }
}

/// Pushes a value into the priority queue.
///
/// Runs in constant time.
///
/// ## Examples
///
/// ```gleam
/// import gleam/int
///
/// new(int.compare) |> push(10) // -> PriorityQueue(Int)
/// ```
///
pub fn push(pq: PriorityQueue(t), val: t) -> PriorityQueue(t) {
  merge(one(val, pq.cmp), pq)
}

/// Pops the maximum value from the priority queue.
///
/// Runs in amortized logarithmic time.
///
/// ## Examples
///
/// ```gleam
/// import gleam/int
///
/// from_list([0]) |> pop() // -> PriorityQueue(Int)
/// ```
///
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
