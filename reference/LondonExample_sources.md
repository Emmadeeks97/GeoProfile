# Example London sources

Dummy sources associated with the crimes in LondonExample_crimes.

## Usage

``` r
data(LondonExample_sources)
```

## Format

an object of class `list`.

## Examples

``` r
if (FALSE) { # interactive()
plot(LondonExample_crimes$latitude, LondonExample_crimes$longitude, xlab = "lon", ylab = "lat")
points(LondonExample_sources$latitude, LondonExample_sources$longitude, pch = 15, col = "blue")
}
```
