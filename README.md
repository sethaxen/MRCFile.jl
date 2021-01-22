# MRC.jl
![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
[![Build Status](https://github.com/sethaxen/MRC.jl/workflows/CI/badge.svg)](https://github.com/sethaxen/MRC.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![Coverage](https://codecov.io/gh/sethaxen/MRC.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/sethaxen/MRC.jl)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://sethaxen.github.io/MRC.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://sethaxen.github.io/MRC.jl/dev)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

MRC.jl implements the [MRC2014 format](https://www.ccpem.ac.uk/mrc_format/mrc2014.php) for storing image and volume data such as those produced by electron microscopy.
It offers the ability to read, edit, and write MRC files, as well as utility functions for extracting useful information from the headers.

The key type is `MRCData`, which contains the contents of the MRC file, accessible with `header` and `extendedheader`.
`MRCData` is an `AbstractArray` whose elements are those of the data portion of the file and can be accessed or modified accordingly.

## Installation

```julia
] add "https://github.com/sethaxen/MRC.jl"
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
ftp = FTP(hostname = "ftp.rcsb.org/pub/emdb/structures/EMD-$(emdid)/map")
dmap = read(download(ftp, "emd_$(emdid).map.gz"), MRCData)
close(ftp)
dmin, dmax = extrema(header(dmap))
drange = dmax - dmin

anim = @animate for xsection in eachmapsection(dmap)
    plot(RGB.((xsection .- dmin) ./ drange))
end

gif(anim, "emd-$(emdid)_slices.gif", fps = 30)
```

![EMD-5778 slices](https://github.com/sethaxen/MRC.jl/blob/master/docs/src/assets/emd-5778_slices.gif)

# Reading a map as a memory-mapped array

MRC files can be huge.
It is convenient then to load their data as [memory-mapped arrays](https://docs.julialang.org/en/v1/stdlib/Mmap/).
This is easy to do:

```julia
using MRC

path = "mymap.mrc" # path to large uncompressed MRC file
mrc = read_mmap(path, MRCData)
... # do something
```

Note that writing to memory-mapped arrays is currently not supported.

## Related packages

[mrcfile](https://github.com/ccpem/mrcfile) is a full-featured Python implementation of of the MRC2014 format.
