
@testset "Test the LS version of the OMP" begin

    ψ = randn(100, 20)
    u = randn(100)
    m, n = size(ψ)

    ctrue = ψ\u

    # Force a greedy approach over the entire set of indices
    # With LS
    idxls, cls, ϵls = lsomp(ψ, u; invert = true, verbose = true, ϵrel = eps())

    @test norm(ctrue[idxls]-cls)<1e-14
    
    # Residual error must decrease
    @test all(ϵls[2:end]-ϵls[1:end-1] .< 0) == true

    for k=1:n
        cverif = view(ψ,:, idxls[1:k])\u
        @test abs(ϵls[k+1] - norm(u - view(ψ,:, idxls[1:k])*cverif))<1e-14
    end
end


@testset "Test the QR version of the OMP" begin

    ψ = randn(100, 20)
    u = randn(100)
    m, n = size(ψ)
    ctrue = ψ\u

    # Force a greedy approach over the entire set of indices
    # With QR
    idxqr, cqr, ϵqr = qromp(ψ, u; invert = true, verbose = true, ϵrel = eps())

    @test norm(ctrue[idxqr]-cqr)<1e-14

    # Residual error must decrease
    @test all(ϵqr[2:end]-ϵqr[1:end-1] .< 0) == true

    for k=1:n
        cverif = view(ψ,:, idxqr[1:k])\u
        @test abs(ϵqr[k+1] - norm(u - view(ψ,:, idxqr[1:k])*cverif))<1e-14
    end
end

@testset "Check that LS and QR versions are consistent" begin

    ψ = randn(100, 20)
    u = randn(100)
    ctrue = ψ\u

    # Force a greedy approach over the entire set of indices
    # With LS
    idxls, cls, ϵls = lsomp(ψ, u; invert = true, verbose = true, ϵrel = eps())

    # With QR
    idxqr, cqr, ϵqr = qromp(ψ, u; invert = true, verbose = true, ϵrel = eps())

    @test norm(ctrue[idxls]-cls)<1e-14
    @test norm(ctrue[idxqr]-cqr)<1e-14
    # @test all(ϵls - ϵqr .>= 0) == true
end
