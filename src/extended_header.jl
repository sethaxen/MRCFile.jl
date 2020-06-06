mutable struct MRCExtendedHeader{T}
    data::T
end
MRCExtendedHeader() = MRCExtendedHeader(UInt8[])
