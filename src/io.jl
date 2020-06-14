"""
    read(io::IO, ::Type{T}; compress = :auto) where {T<:MRCData}
    read(fn::AbstractString, ::Type{T}; compress = :auto) where {T<:MRCData}

Read an instance of [`MRCData`](@ref) from an IO stream or existing file.
Use `compress` to specify the decompression with the following options:
- `:auto`: Infer one of the below compression types from the file
- `:gz`: GZ
- `:bz2`: BZ2
- `:xz`: XZ
- `:none`: no compression
"""
read(::Any, ::Type{<:MRCData})
function Base.read(io::IO, ::Type{T}; compress = :auto) where {T<:MRCData}
    if compress == :auto
        compress = checkmagic(io)
    end
    newio = decompressstream(io, compress)
    header = read(newio, MRCHeader)
    extendedheader = read(newio, MRCExtendedHeader; header = header)
    d = MRCData(header, extendedheader)
    read!(newio, d.data)
    close(newio)
    return d
end
function Base.read(fn::AbstractString, ::Type{T}; compress = :auto) where {T<:MRCData}
    return open(fn; read = true) do io
        return read(io, T; compress = compress)
    end
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

"""
    write(io::IO, ::MRCData; compress = :none)
    write(fn::AbstractString, ::MRCData; compress = :auto)

Write an instance of [`MRCData`](@ref) to an IO stream or new file.
Use `compress` to specify the compression with the following options:
- `:auto`: Infer one of the below compression types from the file extension
- `:gz`: GZ
- `:bz2`: BZ2
- `:xz`: XZ
- `:none`: no compression
"""
write(::Any, ::MRCData)
function Base.write(io::IO, d::MRCData; compress = :none)
    newio = compressstream(io, compress)
    sz = write(newio, header(d))
    sz += write(newio, extendedheader(d))
    T = datatype(header(d))
    data = parent(d)
    if T !== eltype(data)
        data = T.(data)
    end
    sz += write(newio, data)
    close(newio)
    return sz
end
function Base.write(
    fn::AbstractString,
    object::T;
    compress = :auto,
) where {T<:Union{MRCData}}
    if compress == :auto
        compress = checkextension(fn)
    end
    return open(fn; write = true) do io
        return write(io, object; compress = compress)
    end
end

function Base.write(io::IO, header::MRCHeader)
    names = fieldnames(typeof(header))
    bytes = UInt8[]
    for name in names
        append!(bytes, entrytobytes(name, getfield(header, name)))
    end
    return write(io, bytes)
end

Base.write(io::IO, eh::MRCExtendedHeader) = write(io, eh.data)
