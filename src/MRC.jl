module MRC

using Statistics
using CodecZlib, CodecBzip2

export MRCHeader, MRCExtendedHeader, MRCData
export cellangles,
    cellangles!,
    cellsize,
    cellsize!,
    data,
    extendedheader,
    gridsize,
    gridsize!,
    header,
    origin,
    origin!,
    start,
    start!,
    voxelaxes,
    voxelsize,
    voxelsize!

const GZ_MAGIC = (0x1f, 0x8b, 0x08)
const BZ2_MAGIC = (0x42, 0x5A, 0x68)
const HEADER_LENGTH = 1024
const MODE_TO_TYPE = Dict(
    Int32(0) => Int8,
    Int32(1) => Int16,
    Int32(2) => Float32,
    Int32(3) => Complex{Int16},
    Int32(4) => ComplexF32,
    Int32(6) => UInt16,
)
const TYPE_TO_MODE = Dict(reverse(p) for p in MODE_TO_TYPE)
@enum MRCDataType Image ImageStack Volume VolumeStack Unknown

include("utils.jl")
include("header.jl")
include("extended_header.jl")
include("data.jl")
include("io.jl")

end # module
