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

header!(d::MRCData, h::MRCHeader) = copyto!(header(d), h)

extendedheader(d::MRCData) = d.extendedheader

extendedheader!(d::MRCData, data) = extendedheader(d).data = data
extendedheader!(d::MRCData, eh::MRCExtendedHeader) = extendedheader!(d, eh.data)

@inline firsttwo(t) = (t[1], t[2])

for f in (:cellangles, :cellsize, :gridsize, :origin, :start, :voxelsize)
    f! = Symbol(f, !)
    @eval begin
        $(f)(d::MRCData) = $(f)(header(d))
        $(f)(d::MRCData{<:Any,2}) = firsttwo($(f)(header(d)))

        $(f!)(d::MRCData, v) = $(f!)(header(d), v)
        $(f!)(d::MRCData{<:Any,2}, v::Number) = firsttwo($(f!)(header(d)), (v, v, zero(v)))
    end
end

voxelaxes(d::MRCData, i) = voxelaxes(header(d), i)

voxelsize(d::MRCData, i) = voxelsize(header(d), i)

voxelsize!(d::MRCData, s, i) = voxelsize!(header(d), s, i)

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
