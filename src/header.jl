struct MRCHeader
    nx::Int32
    ny::Int32
    nz::Int32
    mode::Int32
    nxstart::Int32
    nystart::Int32
    nzstart::Int32
    mx::Int32
    my::Int32
    mz::Int32
    cella_x::Float32
    cella_y::Float32
    cella_z::Float32
    cellb_alpha::Float32
    cellb_beta::Float32
    cellb_gamma::Float32
    mapc::Int32
    mapr::Int32
    maps::Int32
    dmin::Float32
    dmax::Float32
    dmean::Float32
    ispg::Int32
    nsymbt::Int32
    extra1::NTuple{8,UInt8}
    exttyp::String
    nversion::Int32
    extra2::NTuple{84,UInt8}
    origin_x::Float32
    origin_y::Float32
    origin_z::Float32
    map::String
    machst::NTuple{4,UInt8}
    rms::Float32
    nlabl::Int32
    label::Vector{String}
end

function Base.getproperty(h::MRCHeader, f::Symbol)
    f === :origin && return (h.origin_x, h.origin_y, h.origin_z)
    f === :cella && return (h.cella_x, h.cella_y, h.cella_z)
    f === :cellb && return (h.cellb_alpha, h.cellb_beta, h.cellb_gamma)
    return getfield(h, f)
end

function sizeoffield(name, type)
    name === :exttyp && return 4
    name === :map && return 4
    name === :label && return 800
    return sizeof(type)
end

function convertfield(name, type, pointer)
    # TODO: strip 0 bytes from ends of strings
    name === :exttyp && return unsafe_string(convert(Ptr{UInt8}, pointer), 4)
    name === :map && return unsafe_string(convert(Ptr{UInt8}, pointer), 4)
    name === :label && return map(1:10) do i
        return unsafe_string(convert(Ptr{UInt8}, pointer + (i - 1) * 80), 80)
    end
    return unsafe_load(convert(Ptr{type}, pointer))
end

swapbytes(val) = val
swapbytes(val::Number) = bswap(val)
swapbytes(val::NTuple{N,Number}) where {N} = map(bswap, val)
function swapbytes(h::MRCHeader)
    vals = map(fieldnames(typeof(h))) do n
        return swapbytes(getfield(h, n))
    end
    return typeof(h)(vals...)
end

@generated function fieldoffsets(::Type{T}) where {T}
    sizes = map(sizeoffield, fieldnames(T), T.types)
    offsets = cumsum(sizes)
    pop!(offsets)
    pushfirst!(offsets, 0)
    return offsets
end

origin(h::MRCHeader) = (x = h.origin_x, y = h.origin_y, z = h.origin_z)

celldims(h::MRCHeader) = (x = h.cella_x, y = h.cella_y, z = h.cella_z)

function cellangles(h::MRCHeader)
    return (alpha = h.cellb_alpha, beta = h.cellb_beta, gamma = h.cellb_gamma)
end

griddims(h::MRCHeader) = (x = h.mx, y = h.my, z = h.mz)
