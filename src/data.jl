@enum MRCDataType Image ImageStack Volume VolumeStack Unknown

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

struct MRCData{T<:Number,N,EH,D} <: AbstractArray{T,N}
    header::MRCHeader
    extendedheader::EH
    data::D
end
function MRCData(header, extendedheader, data::AbstractArray{T,N}) where {T,N}
    return MRCData{T,N,typeof(extendedheader),typeof(data)}(header, extendedheader, data)
end
function MRCData(header, extendedheader = MRCExtendedHeader())
    data_size = (header.nx, header.ny, header.nz)
    data_length = prod(data_size)
    if !haskey(MODE_TO_TYPE, header.mode)
        error("Mode $(header.mode) does not correspond to a known data type.")
    end
    dtype = MODE_TO_TYPE[header.mode]
    datatype = mrcdatatype(header)
    dims = if datatype == Image
        2
    elseif datatype in (ImageStack, Volume, Unknown)
        3
    else
        error("Data type of $(datatype) is not currently supported.")
    end
    data = Array{dtype,dims}(undef, data_size[1:dims])
    if dtype === UInt16 # make array actually usable by appearing signed
        data = reinterpret(Int16, data)
    end
    return MRCData(header, extendedheader, data)
end

header(d::MRCData) = d.header

extendedheader(d::MRCData) = d.extendedheader

cellangles(d::MRCData) = cellangles(header(d))
cellangles(d::MRCData{<:Any,2}) = cellangles(header(d))[1:2]

cellsize(d::MRCData) = cellsize(header(d))
cellsize(d::MRCData{<:Any,2}) = cellsize(header(d))[1:2]

gridsize(d::MRCData) = gridsize(header(d))
gridsize(d::MRCData{<:Any,2}) = gridsize(header(d))[1:2]

origin(d::MRCData) = origin(header(d))
origin(d::MRCData{<:Any,2}) = origin(header(d))[1:2]

start(d::MRCData) = start(header(d))
start(d::MRCData{<:Any,2}) = start(header(d))[1:2]

voxelaxes(d::MRCData, i) = voxelaxes(header(d), i)
voxelaxes(d::MRCData) = voxelaxes(header(d))
voxelaxes(d::MRCData{<:Any,2}) = voxelaxes(header(d))[1:2]

voxelsize(d::MRCData, i) = voxelsize(header(d), i)
voxelsize(d::MRCData) = voxelsize(header(d))
voxelsize(d::MRCData{<:Any,2}) = voxelsize(header(d))[1:2]

# Array overloads
@inline Base.parent(d::MRCData) = d.data

@inline Base.getindex(d::MRCData, idx::Int...) = getindex(parent(d), idx...)

@inline Base.setindex!(d::MRCData, val, idx::Int...) = setindex!(parent(d), val, idx...)

Base.size(d::MRCData) = size(parent(d))
Base.size(d::MRCData, i) = size(parent(d), i)

Base.ndims(d::MRCData) = ndims(parent(d))

Base.length(d::MRCData) = length(parent(d))

Base.iterate(d::MRCData, idx...) = iterate(parent(d), idx...)

Base.lastindex(d::MRCData) = lastindex(parent(d))

function Base.similar(d::MRCData)
    return typeof(d)(header(d), extendedheader(d), similar(parent(d)))
end
