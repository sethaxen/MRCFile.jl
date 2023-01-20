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
function Base.read(io::IO, ::Type{T}; compress=:auto) where {T<:MRCData}
    if compress == :auto
        compress = checkmagic(io)
    end
    newio = decompressstream(io, compress)
    header = read(newio, MRCHeader)
    extendedheader = read(newio, MRCExtendedHeader; header=header)
    d = MRCData(header, extendedheader)
    read!(newio, d.data)
    close(newio)
    map!(bswaptoh(header.machst), d.data, d.data)
    return d
end
function Base.read(fn::AbstractString, ::Type{T}; compress=:auto) where {T<:MRCData}
    return open(fn; read=true) do io
        return read(io, T; compress=compress)
    end
end

function Base.read(io::IO, ::Type{T}) where {T<:MRCHeader}
    names = fieldnames(T)
    types = T.types
    offsets = fieldoffsets(T)
    bytes = read!(io, Array{UInt8}(undef, HEADER_LENGTH))
    machst = bytes[213:216] # look ahead to machst
    bytes_ptr = pointer(bytes)
    vals = GC.@preserve bytes [
        bytestoentry(names[i], types[i], bytes_ptr + offsets[i]) for i in 1:length(offsets)
    ]
    map!(bswaptoh(machst), vals, vals)
    header = T(vals...)
    return header
end

function Base.read(io::IO, ::Type{T}; length=0, header=nothing) where {T<:MRCExtendedHeader}
    # TODO: use h.exttyp to identify extended header format and parse into a human-readable type
    if header !== nothing && length == 0
        length = header.nsymbt
    end
    data = read!(io, Array{UInt8}(undef, length))
    return T(data)
end

"""
    read_mmap(io::IO, ::Type{MRCData})
    read_mmap(path::AbstractString, ::Type{MRCData})

Read MRC file or stream, using a memory-mapped array to access the data.
"""
function read_mmap(io::IO, ::Type{MRCData})
    head = read(io, MRCHeader)
    exthead = read(io, MRCExtendedHeader; header=head)
    arraytype = Array{MRC.datatype(head),ndims(head)}
    data = Mmap.mmap(io, arraytype, size(head)[1:ndims(head)])
    return MRCData(head, exthead, data)
end
function read_mmap(path::AbstractString, T::Type{MRCData})
    return open(path, "r") do io
        return read_mmap(io, T)
    end
end

"""
    write(io::IO, ::MRCData; compress = :none, unit_vsize = 4096, buffer = nothing)
    write(fn::AbstractString, ::MRCData; compress = :auto, unit_vsize = 4096, buffer = nothing)

Write an instance of [`MRCData`](@ref) to an IO stream or new file.
Use `compress` to specify the compression with the following options:
- `:auto`: Infer one of the below compression types from the file extension
- `:gz`: GZ
- `:bz2`: BZ2
- `:xz`: XZ
- `:none`: no compression

The parameter `unit_vsize` specifies the size (in bytes) of an intermediate
buffer that is used to speed up the writing.

You can also directly provide a preallocated buffer as a `Vector`.
In that case, `unit_vsize` has no effect.
Note that `eltype(buffer)` must match the data type of the MRC data.
"""
write(::Any, ::MRCData)
function Base.write(io::IO, d::MRCData; compress=:none, unit_vsize=4096, buffer::Union{Nothing, Vector}=nothing)
    newio = compressstream(io, compress)
    h = header(d)
    sz = write(newio, h)
    sz += write(newio, extendedheader(d))
    T = datatype(h)
    data = parent(d)
    fswap = bswapfromh(h.machst)
    unit_vsize = div(unit_vsize, sizeof(T))
    if buffer === nothing
        buffer = Vector{T}(undef, unit_vsize)
    end
    buffer::Vector{T}
    # If `buffer` was provided as a parameter then `unit_vsize` is redundant and
    # we must make sure that it matches `buffer`.
    unit_vsize = length(buffer)
    vlen = length(data)
    vrem = vlen % unit_vsize
    if vrem != 0
        @inbounds @views buffer[1:vrem] .= fswap.(T.(data[1:vrem]))
        @inbounds @views sz += write(newio, buffer[1:vrem])
    end
    for i in (vrem + 1):unit_vsize:vlen
        @inbounds @views buffer .= fswap.(T.(data[i:i + unit_vsize - 1]))
        @inbounds sz += write(newio, buffer)
    end
    write(newio, TranscodingStreams.TOKEN_END)
    flush(newio)
    return sz
end
function Base.write(fn::AbstractString, object::T; compress=:auto, kwargs...) where {T<:Union{MRCData}}
    if compress == :auto
        compress = checkextension(fn)
    end
    return open(fn; write=true) do io
        return write(io, object; compress=compress, kwargs...)
    end
end

function Base.write(io::IO, header::MRCHeader)
    names = fieldnames(typeof(header))
    bytes = UInt8[]
    fswap = bswapfromh(header.machst)
    for name in names
        append!(bytes, entrytobytes(name, fswap(getfield(header, name))))
    end
    return write(io, bytes)
end

Base.write(io::IO, eh::MRCExtendedHeader) = write(io, eh.data)
