# priorityq

[![Package Version](https://img.shields.io/hexpm/v/priorityq)](https://hex.pm/packages/priorityq)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/priorityq/)

A priority queue implementation based on max [pairing heaps](https://www.cs.cmu.edu/~sleator/papers/pairing-heaps.pdf). Written in pure Gleam.

## Installation

Add `priorityq` to your Gleam project

```sh
gleam add priorityq
```

## Usage

```gleam
import gleam/int
import priorityq

pub fn main() {
  priorityq.new(int.compare) |> priorityq.is_empty // -> True

  let pq = priorityq.from_list([1, 5], int.compare)
  pq |> priorityq.push(10) |> priorityq.peek // -> 10
  pq |> priorityq.pop |> priorityq.size // -> 1
}
```

Further documentation can be found at <https://hexdocs.pm/priorityq>.

## Development

```sh
gleam test  # Run the tests
```
