# Abort if any conditions is not TRUE

Abort if any conditions is not TRUE

## Usage

``` r
cli_stopifnot(
  condition,
  message = "condition is not TRUE",
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
