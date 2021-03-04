export qrfactUnblocked, updateqrfactUnblocked!

# Add the non in=place version of qrfactUnblocked! defined in
# https://github.com/JuliaLang/julia/blob/master/stdlib/LinearAlgebra/src/qr.jl
function qrfactUnblocked(A::AbstractMatrix{T}, arg...; kwargs...) where T
    LinearAlgebra.require_one_based_indexing(A)
    AA = similar(A, LinearAlgebra._qreltype(T), size(A))
    copyto!(AA, A)
    return LinearAlgebra.qrfactUnblocked!(AA, arg...; kwargs...)
end

function updateqrfactUnblocked!(S::QR{T,Array{T,2}}, a::AbstractVector{T}) where {T}
    m, n = size(S.factors)
    # Add one entry to F.τ
    push!(S.τ, 0.0)

    # Add one column to F.factors
    factors = hcat(S.factors, S.Q'*a)

    @inbounds for k = n+1:min(m - 1 + !(T<:Real), n+1)
        x = view(factors, k:m, k)
        τk = LinearAlgebra.reflector!(x)
        S.τ[k] = τk
        LinearAlgebra.reflectorApply!(x, τk, view(factors, k:m, k + 1:n + 1))
    end
    return QR(factors, S.τ)
end



# struct UpdatableQR{T} <: Factorization{T}  begin
#     factors::Array{Array{T,1},1}
#     τ::Array{Float64,1}
# end
#
# function UpdatableQR(A::AbstractMatrix{T}) where T
#     return UpdatableQR{T}
# end
#
# function updateqrfactUnblocked!(S::UpdatableQR{T}, a::AbstractVector{T}) where {T}
#     m, n = size(S.factors)
#     # Add one entry to F.τ
#     push!(S.τ, 0.0)
#
#     # Add one column to F.factors
#     push!(S.factors, S.Q'*a)
#
#     @inbounds for k = n+1:min(m - 1 + !(T<:Real), n+1)
#         x = view(factors, k:m, k)
#         τk = LinearAlgebra.reflector!(x)
#         S.τ[k] = τk
#         LinearAlgebra.reflectorApply!(x, τk, view(factors, k:m, k + 1:n + 1))
#     end
#     S = QR(factors, S.τ)
#     return S
# end