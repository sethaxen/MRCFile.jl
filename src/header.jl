mutable struct MRCHeader
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

function Base.show(io::IO, ::MIME"text/plain", h::MRCHeader)
    print(io, "MRCHeader(")
    for f in fieldnames(typeof(h))
        print(io, "\n    $(f) = $(getfield(h, f)),")
    end
    print(io, "\n)")
    return nothing
end

function Base.copyto!(hto::MRCHeader, hfrom::MRCHeader)
    hto === hfrom && return hto
    for f in fieldnames(typeof(hto))
        setfield!(hto, f, getfield(hfrom, f))
    end
    return hto
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

Base.size(h::MRCHeader) = (h.nx, h.ny, h.nz)

Base.length(h::MRCHeader) = prod(size(h))

function Base.ndims(h::MRCHeader)
    mrcdtype = mrcdatatype(h)
    return if mrcdtype == Image
        2
    elseif mrcdtype in (ImageStack, Volume, Unknown)
        3
    else
        error("Data type of $(mrcdtype) is not currently supported.")
    end
end

cellangles(h::MRCHeader) = (h.cellb_alpha, h.cellb_beta, h.cellb_gamma)

cellsize(h::MRCHeader) = (h.cella_x, h.cella_y, h.cella_z)

gridsize(h::MRCHeader) = (h.mx, h.my, h.mz)

origin(h::MRCHeader) = (h.origin_x, h.origin_y, h.origin_z)

start(h::MRCHeader) = (h.nxstart, h.nystart, h.nzstart)

voxelaxes(h::MRCHeader, i) = StepRangeLen(start(h)[i], voxelsize(h)[i], size(h)[i])
voxelaxes(h::MRCHeader) = ntuple(i -> voxelaxes(h, i), Val(3))

voxelsize(h::MRCHeader, i) = cellsize(h)[i] / gridsize(h)[i]
voxelsize(h::MRCHeader) = ntuple(i -> voxelsize(h, i), Val(3))

Base.minimum(h::MRCHeader) = h.dmin

Base.maximum(h::MRCHeader) = h.dmax

Statistics.mean(h::MRCHeader) = h.dmean

function mrcdatatype(nz, mz, ispg)
    return if ispg == 0
        ifelse(mz == 1, Image, ImageStack)
    elseif ispg == 1 && mz == nz
        Volume
    elseif ispg ∈ 401:630
        VolumeStack
    else
        Unknown
    end
end
mrcdatatype(header) = mrcdatatype(header.nz, header.mz, header.ispg)

function datatype(mode)
    if !haskey(MODE_TO_TYPE, mode)
        error("Mode $(mode) does not correspond to a known data type.")
    end
    return MODE_TO_TYPE[mode]
end
datatype(header::MRCHeader) = datatype(header.mode)
