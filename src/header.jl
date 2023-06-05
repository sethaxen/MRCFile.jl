"""
    MRCHeader

An MRC header.

    MRCHeader()
    MRCHeader(; kwargs...)

Construct a header with suitable defaults, optionally substituting any provided entries.

See the [MRC2014 format spec](https://www.ccpem.ac.uk/mrc_format/mrc2014.php) for a
description of the header fields.
"""
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
    label::NTuple{10,String}
end
function MRCHeader(; kwargs...)
    h = MRCHeader(
        ntuple(_ -> 0, Val(13))..., # nx, ny, nz, mode, nxstart, nystart, nzstart, mx, my, mz, cella_x, cella_y, cella_z
        90, # cellb_alpha
        90, # cellb_beta
        90, # cellb_gamma
        1, # mapc
        2, # mapr
        3, # maps
        0, # dmin
        -1, # dmax < dmin means both are undetermined
        -2, # dmean < min(dmin, dmax) means dmean is undetermined
        1, # ispg, is a volume
        0, # nsymbt, empty extended header
        ntuple(_ -> UInt8(0), Val(8)), # extra
        "", # exttyp
        MRC2014_VERSION, # nversion
        ntuple(_ -> UInt8(0), Val(84)), # extra
        ntuple(_ -> 0, Val(3))..., # origin
        MAP_NAME, # map
        NTuple{4,UInt8}(machstfrombyteorder()), # machst
        -1, # rms < 0 means rms is undetermined
        1, # nlabl
        (
            "Created by MRCFile.jl at $(Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))",
            ntuple(_ -> "", Val(9))...,
        ), # label
    )
    for (k, v) in pairs(kwargs)
        setproperty!(h, k, v)
    end
    return h
end

Base.sizeof(::Type{MRCHeader}) = 1024

function Base.show(io::IO, ::MIME"text/plain", h::MRCHeader)
    print(io, "MRCHeader(")
    for f in fieldnames(typeof(h))
        v = sprint(show, getfield(h, f); context=io)
        print(io, "\n    $(f) = $(v),")
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

function bytestoentry(name, type, pointer)
    name === :exttyp && return _unsafe_string(pointer, 4)
    name === :map && return _unsafe_string(pointer, 4)
    name === :label && return ntuple(Val(10)) do i
        return strip(_unsafe_string(pointer + (i - 1) * 80, 80), ' ')
    end
    return unsafe_load(convert(Ptr{type}, pointer))
end

function entrytobytes(name, value)
    name === :exttyp && return padtruncto!(Vector{UInt8}(value), 4)
    name === :map && return padtruncto!(Vector{UInt8}(value), 4)
    name === :label && return vcat(ntuple(Val(10)) do i
        return padtruncto!(Vector{UInt8}(value[i]), 80)
    end...)
    return reinterpret(UInt8, [value])
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

"""
    cellangles(h::MRCHeader) -> (α, β, γ)

Get cell angles in degrees.
"""
cellangles(h::MRCHeader) = (h.cellb_alpha, h.cellb_beta, h.cellb_gamma)

"""
    cellangles!(h::MRCHeader, (α, β, γ))

Set cell angles in degrees.
"""
function cellangles!(h::MRCHeader, cellb)
    h.cellb_alpha = cellb[1]
    h.cellb_beta = cellb[2]
    h.cellb_gamma = cellb[3]
    return cellb
end
cellangles!(h::MRCHeader, cellb::Number) = cellangles!(h, ntuple(_ -> cellb, Val(3)))

"""
    cellsize(h::MRCHeader) -> (x, y, z)

Get cell dimensions in angstroms.
"""
cellsize(h::MRCHeader) = (h.cella_x, h.cella_y, h.cella_z)

"""
    cellsize!(h::MRCHeader, (x, y, z))

Set cell dimensions in angstroms.
"""
function cellsize!(h::MRCHeader, cella)
    h.cella_x = cella[1]
    h.cella_y = cella[2]
    h.cella_z = cella[3]
    return cella
end
cellsize!(h::MRCHeader, cella::Number) = cellsize!(h, ntuple(_ -> cella, Val(3)))

"""
    gridsize(h::MRCHeader) -> (x, y, z)

Get size of sampling grid in angstroms.
"""
gridsize(h::MRCHeader) = (h.mx, h.my, h.mz)

"""
    gridsize!(h::MRCHeader, (x, y, z))

Set size of sampling grid in angstroms.
"""
function gridsize!(h::MRCHeader, m)
    h.mx = m[1]
    h.my = m[2]
    h.mz = m[3]
    return m
end
gridsize!(h::MRCHeader, m::Number) = gridsize!(h, ntuple(_ -> m, Val(3)))

"""
    origin(h::MRCHeader) -> (x, y, z)

Get phase origin in pixels or origin of subvolume in angstroms.
"""
origin(h::MRCHeader) = (h.origin_x, h.origin_y, h.origin_z)

"""
    origin!(h::MRCHeader, (x, y, z))

Set phase origin in pixels or origin of subvolume in angstroms.
"""
function origin!(h::MRCHeader, origin)
    h.origin_x = origin[1]
    h.origin_y = origin[2]
    h.origin_z = origin[3]
    return origin
end
origin!(h::MRCHeader, origin::Number) = origin!(h, ntuple(_ -> origin, Val(3)))

"""
    start(h::MRCHeader) -> (nx, ny, nz)

Get location of first column, first row, and first section in unit cell.
"""
start(h::MRCHeader) = (h.nxstart, h.nystart, h.nzstart)

"""
    start!(h::MRCHeader, (nx, ny, nz))

Set location of first column, first row, and first section in unit cell.
"""
function start!(h::MRCHeader, nstart)
    h.nxstart = nstart[1]
    h.nystart = nstart[2]
    h.nzstart = nstart[3]
    return nstart
end
start!(h::MRCHeader, nstart::Number) = start!(h, ntuple(_ -> nstart, Val(3)))

"""
    voxelaxes(h::MRCHeader, i) -> StepRangeLen
    voxelaxes(h::MRCHeader) -> NTuple{3,StepRangeLen}

Get range of voxel positions along axis `i` or all axes.
"""
voxelaxes(h::MRCHeader, i) = StepRangeLen(origin(h)[i], voxelsize(h)[i], size(h)[i])
voxelaxes(h::MRCHeader) = ntuple(i -> voxelaxes(h, i), Val(3))

"""
    voxelsize(h::MRCHeader, i)
    voxelsize(h::MRCHeader)

Get size of dimension `i` of voxel in angstroms.
"""
function voxelsize(h::MRCHeader, i)
    cs = cellsize(h)[i]
    return iszero(cs) ? cs : cs / gridsize(h)[i]
end
voxelsize(h::MRCHeader) = ntuple(i -> voxelsize(h, i), Val(3))

"""
    voxelsize!(h::MRCHeader, s, i)
    voxelsize!(h::MRCHeaders, (x, y, z))

Set size of dimension `i` of voxel in angstroms.
"""
function voxelsize!(h::MRCHeader, s, i)
    setproperty!(h, (:cella_x, :cella_y, :cella_z)[i], s * getfield(h, (:mx, :my, :mz)[i]))
    return s
end
function voxelsize!(h::MRCHeader, s)
    voxelsize!(h, s[1], 1)
    voxelsize!(h, s[2], 2)
    voxelsize!(h, s[3], 3)
    return s
end

Base.minimum(h::MRCHeader) = h.dmin

Base.maximum(h::MRCHeader) = h.dmax

Base.extrema(h::MRCHeader) = (minimum(h), maximum(h))

Statistics.mean(h::MRCHeader) = h.dmean

function mrcdatatype(nz, mz, ispg)
    return if ispg == 0
        ifelse(nz/mz == 1, Image, ImageStack)
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
