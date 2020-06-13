"""
    MRCData{T<:Number,N,EH<:MRCExtendedHeader,D<:AbstractArray{T,N}} <: AbstractArray{T,N}

Container for electron density data loaded from an MRC file.

Each instance of `MRCData` carries with it a header and extended header, respectively
accessed with [`header`](@ref) and [`extendedheader`](@ref).

If changes are made to the header, extended header, or the data, call [`updateheader!`](@ref)
before writing to file to ensure the header is stil consistent with the data.

    MRCData()

Create an empty array.

    MRCData(header[, extendedheader])

Create an array whose size is indicated by the entries in `header`.

    MRCData(size)
    MRCData(size...)

Create an array of the specified size.
"""
struct MRCData{T<:Number,N,EH,D} <: AbstractArray{T,N}
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

"""
    header(data::MRCData) -> MRCHeader

Get header.
"""
header(d::MRCData) = d.header

"""
    extendedheader(data::MRCData) -> MRCExtendedHeader

Get extended header.
"""
extendedheader(d::MRCData) = d.extendedheader

"""
    updateheader!(data::MRCData; statistics = true)

Update the header stored in `data` from the data and its extended header.
Set `statistics=false` to avoid computing summary statistics from the data.
"""
function updateheader!(d::MRCData; statistics = true)
    h = header(d)

    # update size
    s = size(d)
    for i in eachindex(s)
        setproperty!(h, (:nx, :ny, :nz)[i], s[i])
    end

    # update space group
    if length(s) == 2
        h.nz = 1
        h.mz = 1
        if h.ispg < 0 || h.ispg > 230
            h.ispg = 0
        end
    elseif length(s) == 3 && h.ispg == 0
        h.ispg == 1
    end

    # misc
    h.mode = TYPE_TO_MODE[eltype(d)]
    h.nsymbt = bytesize(extendedheader(d))
    h.nlabl = sum(s -> length(rstrip(s)) > 0, h.label)

    # update statistics
    if statistics
        h.dmin, h.dmax = extrema(d)
        dmean = mean(d)
        h.dmean, h.rms = dmean, stdm(d, dmean; corrected = false)
    end

    return h
end

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

function Base.IndexStyle(::Type{A}) where {T,N,EH,D,A<:MRCData{T,N,EH,D}}
    return Base.IndexStyle(D)
end

"""
    eachmaprow(d::MRCData)

Return an iterator over map rows.
"""
eachmaprow(d::MRCData) = eachslice(d; dims = header(d).mapr)

"""
    eachmapcol(d::MRCData)

Return an iterator over columns.
"""
eachmapcol(d::MRCData) = eachslice(d; dims = header(d).mapc)

"""
    eachmapsection(d::MRCData)

Return an iterator over sections.
"""
eachmapsection(d::MRCData) = eachslice(d; dims = header(d).maps)

"""
    eachstackunit(d::MRCData)

Return an iterator over elements of stacks.
"""
function eachstackunit(d::MRCData)
    h = header(d)
    mrcdtype = mrcdatatype(h)
    return if mrcdtype ∈ (Volume, Image)
        (d for _ in 1:1)
    elseif mrcdtype == ImageStack
        eachmapsection(d)
    else
        error("Volume stacks not currently supported.")
    end
end
