abstract type AbstractMRCExtendedHeader end

"""
    MRCExtendedHeader{T}

Extended header of an MRC file.

    MRCExtendedHeader(data)

Store `data` in an extended header. `data` must be directly writeable to a file with
`write(::IO, data)`.

    MRCExtendedHeader()

Create an extended header whose data is an empty `Vector{UInt8}`.
"""
mutable struct MRCExtendedHeader{T} <: AbstractMRCExtendedHeader
    data::T
end
MRCExtendedHeader() = MRCExtendedHeader(UInt8[])

Base.sizeof(eh::MRCExtendedHeader) = sizeof(eh.data)

# FEI extended header

const FEI_FIELD_LENGTHS = Dict(
    :microscope_type => 16,
    :d_number => 16,
    :application => 16,
    :application_version => 16,
    :objective_lens_mode => 16,
    :high_magnification_mode => 16,
    :illumination_mode => 16,
    :camera_name => 16,
    :stem_detector_name => 16,
    :element => 16,
    :input_stack_filename => 80,
)

mutable struct FEI1ExtendedHeader <: AbstractMRCExtendedHeader
    metadata_size::Int32
    metadata_version::Int32
    bitmask1::UInt32
    timestamp::Float64
    microscope_type::String
    d_number::String
    application::String
    application_version::String
    ht::Float64
    dose::Float64
    alpha_tilt::Float64
    beta_tilt::Float64
    xstage::Float64
    ystage::Float64
    zstage::Float64
    tilt_axis_angle::Float64
    dual_axis_rotation::Float64
    pixel_size_x::Float64
    pixel_size_y::Float64
    extra::NTuple{48,UInt8}
    defocus::Float64
    stem_defocus::Float64
    applied_defocus::Float64
    instrument_mode::Int32
    projection_mode::Int32
    objective_lens_mode::String
    high_magnification_mode::String
    probe_mode::Int32
    eftem_on::Bool
    magnification::Float64
    bitmask2::UInt32
    camera_length::Float64
    spot_index::Int32
    illuminated_area::Float64
    intensity::Float64
    convergence_angle::Float64
    illumination_mode::String
    wide_convergence_angle_range::Bool
    slit_inserted::Bool
    slit_width::Float64
    acceleration_voltage_offset::Float64
    drift_tube_voltage::Float64
    energy_shift::Float64
    shift_offset_x::Float64
    shift_offset_y::Float64
    shift_x::Float64
    shift_y::Float64
    integration_time::Float64
    binning_width::Int32
    binning_height::Int32
    camera_name::String
    readout_area_left::Int32
    readout_area_top::Int32
    readout_area_right::Int32
    readout_area_bottom::Int32
    ceta_noise_reduction::Bool
    ceta_frames_summed::Int32
    direct_detector_electron_counting::Bool
    direct_detector_align_frames::Bool
    camera_param_reserved_0::Int32
    camera_param_reserved_1::Int32
    camera_param_reserved_2::Int32
    camera_param_reserved_3::Int32
    bitmask3::UInt32
    camera_param_reserved_4::Int32
    camera_param_reserved_5::Int32
    camera_param_reserved_6::Int32
    camera_param_reserved_7::Int32
    camera_param_reserved_8::Int32
    camera_param_reserved_9::Int32
    phase_plate::Bool
    stem_detector_name::String
    gain::Float64
    offset::Float64
    stem_param_reserved_0::Int32
    stem_param_reserved_1::Int32
    stem_param_reserved_2::Int32
    stem_param_reserved_3::Int32
    stem_param_reserved_4::Int32
    dwell_time::Float64
    frame_time::Float64
    scan_size_left::Int32
    scan_size_top::Int32
    scan_size_right::Int32
    scan_size_bottom::Int32
    full_scan_fov_x::Float64
    full_scan_fov_y::Float64
    element::String
    energy_interval_lower::Float64
    energy_interval_higher::Float64
    method::Int32
    is_dose_fraction::Bool
    fraction_number::Int32
    start_frame::Int32
    end_frame::Int32
    input_stack_filename::String
    bitmask4::UInt32
    alpha_tilt_min::Float64
    alpha_tilt_max::Float64
end

function sizeoffield(::Type{<:FEI1ExtendedHeader}, fname, ftype)
    return if haskey(FEI_FIELD_LENGTHS, fname)
        FEI_FIELD_LENGTHS[fname]
    else
        sizeof(ftype)
    end
end

function Base.read(io::IO, ::Type{T}; header = nothing) where {T<:FEI1ExtendedHeader}
    names = fieldnames(T)
    types = T.types
    offsets, sz = fieldoffsets(T)
    bytes = read!(io, Array{UInt8}(undef, sz))
    bytes_ptr = pointer(bytes)
    # vals = GC.@preserve bytes [
    #     bytestoentry(names[i], types[i], bytes_ptr + offsets[i]) for i in 1:length(offsets)
    # ]
    vals = Any[]
    for i in eachindex(offsets)
        v = if types[i] <: String
            _strip_unsafe_string(bytes_ptr + offsets[i], FEI_FIELD_LENGTHS[names[i]])
        else
            bytestoentry(names[i], types[i], bytes_ptr + offsets[i])
        end
        push!(vals, v)
    end
    @show vals
    machst = header === nothing ? MACHINE_STAMP_LITTLE : header.machst
    map!(bswaptoh(machst), vals, vals)
    extendedheader = T(vals...)
    return extendedheader
end

function Base.show(io::IO, ::MIME"text/plain", h::FEI1ExtendedHeader)
    print(io, "FEI1ExtendedHeader(")
    for f in fieldnames(typeof(h))
        v = sprint(show, getfield(h, f); context = io)
        print(io, "\n    $(f) = $(v),")
    end
    print(io, "\n)")
    return nothing
end

function sizeoffield(::Type{<:FEI1ExtendedHeader}, fname, ftype)
    return if haskey(FEI_FIELD_LENGTHS, fname)
        FEI_FIELD_LENGTHS[fname]
    else
        sizeof(ftype)
    end
end
