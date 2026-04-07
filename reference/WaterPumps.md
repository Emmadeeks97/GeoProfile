# Cholera sources

Locations of the neighbourhood water pumps near the site of the 1854
cholera outbreak. The Broad Street pump was the source of the outbreak.

## Usage

``` r
data(WaterPumps)
```

## Format

an object of class `list`.

## Examples

``` r
if (FALSE) { # interactive()
plot(Cholera$latitude, Cholera$longitude, xlab = "lon", ylab = "lat")
points(WaterPumps$latitude, WaterPumps$longitude,  pch = 15, col = "blue")
}
```
