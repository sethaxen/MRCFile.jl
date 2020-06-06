module MRC

using Dates, Statistics, CodecZlib, CodecBzip2

export MRCHeader, MRCExtendedHeader, MRCData
export cellangles,
    cellangles!,
    cellsize,
    cellsize!,
    data,
    eachmapcol,
    eachmaprow,
    eachmapsection,
    eachstackunit,
    extendedheader,
    gridsize,
    gridsize!,
    header,
    origin,
    origin!,
    start,
    start!,
    updateheader!,
    voxelaxes,
    voxelsize,
    voxelsize!

const GZ_MAGIC = (0x1f, 0x8b, 0x08)
const BZ2_MAGIC = (0x42, 0x5A, 0x68)
const MACHINE_STAMP_LITTLE = (0x44, 0x44, 0x00, 0x00)
const MACHINE_STAMP_BIG = (0x11, 0x11, 0x00, 0x00)
const HEADER_LENGTH = 1024
const MAP_NAME = "MAP "
const MODE_TO_TYPE = Dict(
    Int32(0) => Int8,
    Int32(1) => Int16,
    Int32(2) => Float32,
    Int32(3) => Complex{Int16},
    Int32(4) => ComplexF32,
    Int32(6) => UInt16,
)
const TYPE_TO_MODE = Dict(reverse(p) for p in MODE_TO_TYPE)
const MRC2014_VERSION = Int32(20140)
@enum MRCDataType Image ImageStack Volume VolumeStack Unknown

include("utils.jl")
include("header.jl")
include("extended_header.jl")
include("data.jl")
include("io.jl")

end # module
