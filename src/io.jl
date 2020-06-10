function Base.read(
    fn::AbstractString,
    ::Type{T};
    kwargs...,
) where {T<:Union{MRCData,MRCHeader,MRCExtendedHeader}}
    return open(fn; read = true) do io
        type = checkmagic(io)
        newio = decompresstream(io, type)
        return read(newio, T; kwargs...)
    end
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
        bytestoentry(names[i], types[i], bytes_ptr + offsets[i]) for i in 1:length(offsets)
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

function Base.write(
    fn::AbstractString,
    object::T;
    kwargs...,
) where {T<:Union{MRCData,MRCHeader,MRCExtendedHeader}}
    type = checkextension(fn)
    return open(fn; write = true) do io
        newio = compresstream(io, type)
        return write(newio, object; kwargs...)
    end
end

function Base.write(io::IO, header::MRCHeader; kwargs...)
    names = fieldnames(typeof(header))
    bytes = UInt8[]
    for name in names
        append!(bytes, entrytobytes(name, getfield(header, name)))
    end
    return write(io, bytes)
end

Base.write(io::IO, eh::MRCExtendedHeader) = write(io, eh.data)

function Base.write(io::IO, d::MRCData)
    sz = write(io, header(d))
    sz += write(io, extendedheader(d))
    T = datatype(header(d))
    data = parent(d)
    if T !== eltype(data)
        data = T.(data)
    end
    sz += write(io, data)
    return sz
end
