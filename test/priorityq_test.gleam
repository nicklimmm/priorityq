import gleam/int
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import priorityq

pub fn main() {
  gleeunit.main()
}

pub fn peek_test() {
  priorityq.from_list([3, 10, 1], int.compare)
  |> priorityq.peek
  |> should.equal(Some(10))

  priorityq.new(int.compare)
  |> priorityq.peek
  |> should.equal(None)
}

pub fn push_test() {
  let pq =
    priorityq.from_list([3, 10, 1], int.compare)
    |> priorityq.push(15)

  pq
  |> priorityq.size
  |> should.equal(4)
  pq
  |> priorityq.peek
  |> should.equal(Some(15))
}

pub fn pop_test() {
  let pq =
    priorityq.from_list([3, 10, 1], int.compare)
    |> priorityq.pop

  pq
  |> priorityq.size
  |> should.equal(2)
  pq
  |> priorityq.peek
  |> should.equal(Some(3))
}

pub fn is_empty_test() {
  priorityq.new(int.compare)
  |> priorityq.is_empty
  |> should.be_true

  priorityq.from_list([3, 1, 2], int.compare)
  |> priorityq.is_empty
  |> should.be_false
}

pub fn size_test() {
  priorityq.new(int.compare)
  |> priorityq.size
  |> should.equal(0)

  priorityq.from_list([3, 1, 2], int.compare)
  |> priorityq.size
  |> should.equal(3)
}
