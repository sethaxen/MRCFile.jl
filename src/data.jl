struct MRCVolume{T<:Number,N,EH,D} <: AbstractArray{T,N}
    header::MRCHeader
    extendedheader::EH
    data::D
end
function MRCVolume(header, extendedheader, data::AbstractArray{T,N}) where {T,N}
    return MRCVolume{T,N,typeof(extendedheader),typeof(data)}(header, extendedheader, data)
end
function MRCVolume(header, extendedheader = MRCExtendedHeader())
    data_size = (header.nx, header.ny, header.nz)
    data_length = prod(data_size)
    if !haskey(MODE_TO_TYPE, header.mode)
        error("Mode $(header.mode) does not correspond to a known data type.")
    end
    dtype = MODE_TO_TYPE[header.mode]
    data = Array{dtype,length(data_size)}(undef, data_size)
    return MRCVolume(header, extendedheader, data)
end

header(d::MRCVolume) = d.header

extendedheader(d::MRCVolume) = d.extendedheader

@inline Base.parent(d::MRCVolume) = d.data

@inline Base.getindex(d::MRCVolume, idx::Int...) = getindex(parent(d), idx...)

@inline Base.setindex!(d::MRCVolume, val, idx::Int...) = setindex!(parent(d), val, idx...)

Base.size(d::MRCVolume) = size(parent(d))
Base.size(d::MRCVolume, i) = size(parent(d), i)

Base.ndims(d::MRCVolume) = ndims(parent(d))

Base.length(d::MRCVolume) = length(parent(d))

Base.iterate(d::MRCVolume, idx...) = iterate(parent(d), idx...)

Base.lastindex(d::MRCVolume) = lastindex(parent(d))

function Base.similar(d::MRCVolume)
    return MRCVolume(header(d), extendedheader(d), similar(parent(d)))
end

origin(d::MRCVolume) = origin(d.header)

celldims(d::MRCVolume) = celldims(d.header)

cellangles(d::MRCVolume) = cellangles(d.header)

griddims(d::MRCVolume) = griddims(d.header)
