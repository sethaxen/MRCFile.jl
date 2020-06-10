module MRC

using Dates, Statistics, CodecZlib, CodecBzip2, CodecXz

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

const GZ_MAGIC = b"\x1f\x8b\b"
const BZ2_MAGIC = b"BZh"
const XZ_MAGIC = b"\xfd7zXZ\0"
const MACHINE_STAMP_LITTLE = b"DD\0\0"
const MACHINE_STAMP_BIG = b"\x11\x11\0\0"
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
