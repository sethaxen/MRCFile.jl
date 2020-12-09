module MRC

using Dates, Statistics, Mmap, CodecZlib, CodecBzip2, CodecXz, TranscodingStreams

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
    read_mmap,
    start,
    start!,
    updateheader!,
    voxelaxes,
    voxelsize,
    voxelsize!

const COMPRESSIONS = (
    gz=(
        magic=b"\x1f\x8b\b",
        extension=".gz",
        compressor=GzipCompressorStream,
        decompressor=GzipDecompressorStream,
    ),
    bz2=(
        magic=b"BZh",
        extension=".bz2",
        compressor=Bzip2CompressorStream,
        decompressor=Bzip2DecompressorStream,
    ),
    xz=(
        magic=b"\xfd7zXZ\0",
        extension=".xz",
        compressor=XzCompressorStream,
        decompressor=XzDecompressorStream,
    ),
    none=(magic=b"", extension="", compressor=NoopStream, decompressor=NoopStream),
)
const COMPRESSOR_MAGICS = Dict(spec.magic => type for (type, spec) in pairs(COMPRESSIONS))
const COMPRESSOR_EXTENSIONS = Dict(
    spec.extension => type for (type, spec) in pairs(COMPRESSIONS)
)
@enum ByteOrder LittleEndian BigEndian
const MACHINE_STAMP_LITTLE = b"DD\0\0"
const MACHINE_STAMP_LITTLE_ALT = b"DA\0\0"
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
