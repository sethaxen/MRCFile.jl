
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
    exttyp::String # String
    nversion::Int32
    extra2::NTuple{84,UInt8}
    origin_x::Float32
    origin_y::Float32
    origin_z::Float32
    map::String # String
    machst::NTuple{4,UInt8}
    rms::Float32
    nlabl::Int32
    label::Vector{String} # NTuple{10,String}
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

function swapbytes(name, val)
    name === :exttyp && return val
    name === :map && return val
    name === :label && return val
    return ntoh(val)
end
swapbytes(name, val::Tuple) = map(ntoh, val)
swapbytes(name, val::Number) = ntoh(val)
function swapbytes(h::MRCHeader)
    vals = map(fieldnames(typeof(h))) do n
        return swapbytes(n, getfield(h, n))
    end
    return typeof(h)(vals...)
end

@generated function fieldoffsets(::Type{T}) where {T}
    sizes = map(sizeoffield, fieldnames(T), T.types)
    offsets = cumsum(sizes)
    sz = pop!(offsets)
    pushfirst!(offsets, 0)
    return offsets
end

origin(h::MRCHeader) = (x = h.origin_x, y = h.origin_y, z = h.origin_z)

celldims(h::MRCHeader) = (x = h.cella_x, y = h.cella_y, z = h.cella_z)

function cellangles(h::MRCHeader)
    return (alpha = h.cellb_alpha, beta = h.cellb_beta, gamma = h.cellb_gamma)
end

griddims(h::MRCHeader) = (x = h.mx, y = h.my, z = h.mz)
