struct MRCData{T<:Number,N,EH,D} <: AbstractArray{T,N}
    header::MRCHeader
    extendedheader::EH
    data::D
end
function MRCData(header, extendedheader, data::AbstractArray{T,N}) where {T,N}
    return MRCData{T,N,typeof(extendedheader),typeof(data)}(header, extendedheader, data)
end
function MRCData(header, extendedheader = MRCExtendedHeader())
    data_size = size(header)
    data_length = prod(data_size)
    dtype = datatype(header)
    dims = ndims(header)
    s = ntuple(i -> data_size[i], dims)
    data = Array{dtype,dims}(undef, s)
    return MRCData(header, extendedheader, data)
end

header(d::MRCData) = d.header

extendedheader(d::MRCData) = d.extendedheader

firsttwo(t::Tuple) = ntuple(i -> t[i], 2)

cellangles(d::MRCData) = cellangles(header(d))
cellangles(d::MRCData{<:Any,2}) = firsttwo(cellangles(header(d)))

cellsize(d::MRCData) = cellsize(header(d))
cellsize(d::MRCData{<:Any,2}) = firsttwo(cellsize(header(d)))

gridsize(d::MRCData) = gridsize(header(d))
gridsize(d::MRCData{<:Any,2}) = firsttwo(gridsize(header(d)))

origin(d::MRCData) = origin(header(d))
origin(d::MRCData{<:Any,2}) = firsttwo(origin(header(d)))

start(d::MRCData) = start(header(d))
start(d::MRCData{<:Any,2}) = firsttwo(start(header(d)))

voxelaxes(d::MRCData, i) = voxelaxes(header(d), i)
voxelaxes(d::MRCData) = voxelaxes(header(d))
voxelaxes(d::MRCData{<:Any,2}) = firsttwo(voxelaxes(header(d)))

voxelsize(d::MRCData, i) = voxelsize(header(d), i)
voxelsize(d::MRCData) = voxelsize(header(d))
voxelsize(d::MRCData{<:Any,2}) = firsttwo(voxelsize(header(d)))

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
