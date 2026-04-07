# Draw from Dirichlet process mixture model

Provides random draws from a 2D spatial Dirichlet process mixture model.
Both sigma and tau are defined in units of kilometres, representing the
average distance that an observations lies from a source, and the
average distance that a source lies from the centre point respectively.
In contrast, the location of the centre point and the locations of the
final output crime sites are defined in units of degrees lat/long to
facilitate spatial analysis.

## Usage

``` r
rDPM(
  n,
  sigma = 1,
  tau = 10,
  priorMean_longitude = -0.1277,
  priorMean_latitude = 51.5074,
  alpha = 1
)
```

## Arguments

- n:

  number of draws.

- sigma:

  standard deviation of dispersal distribution, in units of kilometres.

- tau:

  standard deviation of prior on source locations (i.e. average
  distances of sources from centre point), in units of kilometres.

- priorMean_longitude:

  location of prior mean on source locations in degrees longitude.

- priorMean_latitude:

  location of prior mean on source locations in degrees latitude.

- alpha:

  concentration parameter of Dirichlet process model. Large alpha
  implies many distinct sources, while small alpha implies only a few
  sources.

## Details

Output includes the lat/long locations of the points drawn from the DPM
model, along with the underlying group allocation (i.e. which points
belong to which sources) and the lat/long locations of the sources.

## Examples

``` r
if (FALSE) { # interactive()
# produces clusters of points from sources centred on QMUL
rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude = 51.5235505,
alpha=1, sigma=1, tau=3)
# same, but increasing alpha to generate more clusters
rDPM(50, priorMean_longitude = -0.04217491, priorMean_latitude = 51.5235505,
alpha=5, sigma=1, tau=3)
}
```
