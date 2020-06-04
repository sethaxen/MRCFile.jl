module MRC

export MRCHeader, MRCExtendedHeader, MRCVolume
export data, header, extended_header, origin, celldims, cellangles, griddims

const HEADER_LENGTH = 1024

include("utils.jl")
include("header.jl")
include("extended_header.jl")
include("data.jl")
include("io.jl")

end # module
