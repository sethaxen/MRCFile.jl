module MRC

export data, header, extended_header, origin, celldims, cellangles, griddims
export MRCHeader, MRCExtendedHeader, MRCData

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

include("utils.jl")
include("header.jl")
include("extended_header.jl")
include("data.jl")
include("io.jl")

end # module
