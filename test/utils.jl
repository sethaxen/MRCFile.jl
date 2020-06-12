@testset "padtruncto!" begin
    x = [1, 2, 3]
    MRC.padtruncto!(x, 4)
    @test x == [1, 2, 3, 0]
    MRC.padtruncto!(x, 6; value = 1)
    @test x == [1, 2, 3, 0, 1, 1]
    MRC.padtruncto!(x, 3)
    @test x == [1, 2, 3]
    MRC.padtruncto!(x, 5; value = 1.0)
    @test x == [1, 2, 3, 1, 1]
end

