# Abort if any condition is TRUE

Abort if any condition is TRUE

## Usage

``` r
cli_stopif(
  condition,
  message = "condition is TRUE",
  call = rlang::caller_env()
)
```

## Arguments

- condition:

  Condition to evaluate when deciding when to error

- message:

  Message to include in the error.

- call:

  Environment within which to emit the error (defaults to caller
  environment).

## Value

Nothing
