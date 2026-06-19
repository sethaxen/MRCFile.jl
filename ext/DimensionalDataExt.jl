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
    #! format: off
    dimaxs = (
        (X, Y, Z)[h.mapc](axs[1]),
        (X, Y, Z)[h.mapr](axs[2]),
        (X, Y, Z)[h.maps](axs[3]),
    )
    #! format: on
    return DimArray(mrc.data, dimaxs)
end
end
