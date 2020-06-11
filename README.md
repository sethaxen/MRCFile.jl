# MRC.jl

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg) -->
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![CI](https://github.com/JuliaManifolds/Manifolds.jl/workflows/CI/badge.svg)](https://github.com/sethaxen/MRC.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![codecov.io](http://codecov.io/github/sethaxen/MRC.jl/coverage.svg?branch=master)](http://codecov.io/github/sethaxen/MRC.jl?branch=master)
<!--
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://sethaxen.github.io/MRC.jl/stable)
[![Documentation](https://img.shields.io/badge/docs-master-blue.svg)](https://sethaxen.github.io/MRC.jl/dev)
-->

## Installation

```julia
using Pkg
Pkg.add("https://github.com/sethaxen/MRC.jl")
```

## Example

This example downloads a map of [TRPV1](https://www.emdataresource.org/EMD-5778) and animates slices taken through the map.

To set-up this example, install FTPClient and Plots with

```julia
using Pkg
Pkg.add("FTPClient")
Pkg.add("Plots")
```

```julia
using MRC, FTPClient, Plots

emdid = 5778 # TRPV1
ftp = FTP(hostname="ftp.rcsb.org/pub/emdb/structures/EMD-$(emdid)/map")
dmap = read(download(ftp, "emd_$(emdid).map.gz"), MRCData)
close(ftp)

anim = @animate for xsection in eachmapcol(dmap)
    plot(xsection)
end

gif(anim, "emd-$(emdid)_slices.gif", fps = 15)
```
