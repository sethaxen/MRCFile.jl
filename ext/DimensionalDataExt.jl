module DimensionalDataExt
using MRCFile
using DimensionalData
import DimensionalData: DimArray

"""
    DimArray(::MRCData)

Convert the MRC data into a `DimArray` from DimensionalData.jl.
The `DimArray` has `X`, `Y`, `Z` axes according to the voxel axes stored in the
header.
`parent(DimArray(mrc)) == mrc.data` holds.
"""
function DimArray(mrc::MRCData)
    axs = voxelaxes(header(mrc))
    dimaxs = map((D, ax) -> D(ax), (X, Y, Z), axs)
    DimArray(mrc.data, dimaxs)
end
end
