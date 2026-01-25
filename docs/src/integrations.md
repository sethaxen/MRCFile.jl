# Integrations

## DimensionalData.jl

If you have the DimensionalData.jl package loaded, you can call `DimArray(mrc)`
for an `mrc::MRCData` and obtain a `DimArray` that has `X`, `Y`, and `Z` axes
representing the voxel axes given in `header(mrc)`, possibly permuted depending
on the `mapc`, `mapr`, and `maps` entries in the header.

```docs
DimArray(::MRCData)
```
