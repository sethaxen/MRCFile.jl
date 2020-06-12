"""
    MRCExtendedHeader{T}

Extended header of an MRC file.

    MRCExtendedHeader(data)

Store `data` in an extended header. `data` must be directly writeable to a file with
`write(::IO, data)`.

    MRCExtendedHeader()

Create an extended header whose data is an empty `Vector{UInt8}`.
"""
mutable struct MRCExtendedHeader{T}
    data::T
end
MRCExtendedHeader() = MRCExtendedHeader(UInt8[])
