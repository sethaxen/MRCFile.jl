module DimensionalDataExt
using MRCFile
using DimensionalData
import DimensionalData: DimArray

"""
    DimArray(::MRCData)

Convert the MRC data into a `DimArray` from DimensionalData.jl.

The `DimArray` has `X`, `Y`, `Z` axes according to the voxel axes stored in the
header.

While the names of the axes may be permuted according to the `mapc`, `mapr`, and
`maps` entries in the header, the `DimArray` is always equal to the `MRCData`
array.
"""
function DimArray(mrc::MRCData)
    h = header(mrc)
    axs = voxelaxes(h)
    dimnames = map(Base.Fix1(getindex, (X, Y, Z)), (h.mapc, h.mapr, h.maps))
    dimaxs = map((D, ax) -> D(ax), dimnames, axs)
    DimArray(mrc.data, dimaxs)
end
end
