function Base.read(
    fn::AbstractString,
    ::Type{T};
    kwargs...,
) where {T<:Union{MRCData,MRCHeader,MRCExtendedHeader}}
    return smartopen(io -> read(io, T; kwargs...), fn, "r")
end

"""
    read(io::IO, ::Type{T}) where {T<:MRCData}
    read(fn::AbstractString, ::Type{T}) where {T<:MRCData}

Read an instance of [`MRCData`](@ref) from an io stream or closed file.
If a filename is passed, the file is checked for gz or bz2 compression.
"""
read(::Any, ::Type{<:MRCData})
function Base.read(io::IO, ::Type{T}) where {T<:MRCData}
    header = read(io, MRCHeader)
    extendedheader = read(io, MRCExtendedHeader; header = header)
    d = MRCData(header, extendedheader)
    read!(io, d.data)
    return d
end

function Base.read(io::IO, ::Type{T}) where {T<:MRCHeader}
    names = fieldnames(T)
    types = T.types
    offsets = fieldoffsets(T)
    bytes = read!(io, Array{UInt8}(undef, HEADER_LENGTH))
    bytes_ptr = pointer(bytes)
    vals = GC.@preserve bytes [
        convertfield(names[i], types[i], bytes_ptr + offsets[i]) for i in 1:length(offsets)
    ]
    header = T(vals...)
    return header
end

function Base.read(
    io::IO,
    ::Type{T};
    length = 0,
    header = nothing,
) where {T<:MRCExtendedHeader}
    # TODO: use h.exttyp to identify extended header format and parse into a human-readable type
    if header !== nothing && length == 0
        length = header.nsymbt
    end
    data = read!(io, Array{UInt8}(undef, length))
    return T(data)
end
