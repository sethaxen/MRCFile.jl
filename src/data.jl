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
    data = Array{dtype,length(data_size)}(undef, data_size)
    return MRCData(header, extendedheader, data)
end

header(d::MRCData) = d.header

extendedheader(d::MRCData) = d.extendedheader

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

origin(d::MRCData) = origin(header(d))

celldims(d::MRCData) = celldims(header(d))

cellangles(d::MRCData) = cellangles(header(d))

griddims(d::MRCData) = griddims(header(d))
