mutable struct MRCData{T<:Number,N,EH,D} <: AbstractArray{T,N}
    header::MRCHeader
    extendedheader::EH
    data::D
end
function MRCData(header, extendedheader, data::AbstractArray{T,N}) where {T,N}
    return MRCData{T,N,typeof(extendedheader),typeof(data)}(header, extendedheader, data)
end
function MRCData(header = MRCHeader(), extendedheader = MRCExtendedHeader())
    data_size = size(header)
    data_length = prod(data_size)
    dtype = datatype(header)
    dims = ndims(header)
    s = ntuple(i -> data_size[i], dims)
    data = Array{dtype,dims}(undef, s)
    return MRCData(header, extendedheader, data)
end
function MRCData(size::NTuple{3,<:Integer})
    header = MRCHeader()
    for i in 1:3
        setproperty!(header, (:nx, :ny, :nz)[i], size[i])
    end
    return MRCData(header)
end
MRCData(size::Integer...) = MRCData(size)

header(d::MRCData) = d.header

extendedheader(d::MRCData) = d.extendedheader

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
