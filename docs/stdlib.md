# DripStd Standard Library

DripStd ships as a Julia package in `stdlib/DripStd`. Any DripLang program can bring it into scope with:

```drip
plug DripStd
```

The package exports four themed modules plus their most common helpers at the top level.

## Basic

| Helper | Description |
|--------|-------------|
| `spill(args...)` | Print arguments followed by a newline. |
| `lowkey_spill(args...)` | Print arguments without a newline. |
| `vibe_check(condition, message)` | Assert that a condition is true; throws `AssertionError` otherwise. |
| `assert_no_cap(condition, message)` | Alias for `vibe_check`. |
| `prompt(message)` | Display a prompt and read a line from standard input. |
| `slay(value)` | Log the value with a `slay:` prefix and return it. |

## Collections

| Helper | Description |
|--------|-------------|
| `lineup(iterable)` | Collect any iterable into a `Vector`. |
| `link_up(collections...)` | Concatenate vectors in the order provided. |
| `glow_map(f, iterable)` | Map `f` across the iterable. |
| `lowkey_filter(f, iterable)` | Filter by predicate `f`. |
| `group_chat(f, iterable)` | Group items by the key returned from `f`, yielding a `Dict`. |
| `drip_zip(iterables...)` | Zip iterables and collect the result. |

## Math

| Helper | Description |
|--------|-------------|
| `drip_sum(xs)` | Sum numeric iterables. |
| `drip_mean(xs)` | Compute the arithmetic mean (throws on empty input). |
| `drip_median(xs)` | Median via sorted copy (throws on empty input). |
| `energy(xs)` | Sum of squares, handy for norms. |
| `normalize(xs)` | L2-normalize a real vector, returning zero vector if all zeros. |

## Debug

| Helper | Description |
|--------|-------------|
| `receipts(value)` | Print a debug representation and return the original value. |
| `bench(fn; warmups=1, repeats=5)` | Execute `fn` repeatedly and report timing statistics in milliseconds. |
| `bench!(label, fn; kwargs...)` | Run `bench` and emit a formatted summary tagged with `label`. |

### Example

```drip
plug DripStd

flex stats(vals)
    vibe_check(!isempty(vals), "need data")
    return (
        total = drip_sum(vals),
        mean = drip_mean(vals),
        energy = energy(vals)
    )
yeet
```

The DripStd package is versioned independently, so you can ship application-specific extensions by adding Julia files under `stdlib/DripStd/src` and updating `Project.toml`.
