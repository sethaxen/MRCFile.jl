# MRCFile Example

## Example 1

This example downloads a map of [TRPV1](https://www.emdataresource.org/EMD-5778) and animates slices taken through the map.

To set-up this example, install FTPClient and Plots with

```julia
using Pkg
Pkg.add("FTPClient")
Pkg.add("Plots")
```

```julia
using MRCFile, FTPClient, Plots

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

![EMD-5778 slices](https://github.com/sethaxen/MRCFile.jl/blob/main/docs/src/assets/emd-5778_slices.gif)