using KirUtils.Unknowns
using Test

@testset "Unknown" begin
  @testset "construct" begin
    @test repr(unknown) == "unknown"
    @test repr(Unknown(42.)) == "Unknown{Float64}(42.0)"
    @test repr(Unknown{Int64}(42)) == "Unknown{Int64}(42)"
    @test repr(Unknown(() -> 42)) == "Unknown{Any}(unknown)"
    @test repr(Unknown{Int64}(() -> 42)) == "Unknown{Int64}(unknown)"
  end
  
  @testset "isunknown" begin
    @test isunknown(unknown)
    @test isunknown(Unknown())
    @test isunknown(Unknown{Int64}(() -> 42))
  end
  
  @testset "load" begin
    let val = Unknown{Int64}(() -> 42)
      @test Unknowns.load(val) == 42
      @test val.value == 42
    end
  end
  
  @testset "load incorrect type" begin
    let val = Unknown{Float64}(() -> 42)
      @test_throws TypeError Unknowns.load(val) == 42
      @test isunknown(val)
    end
  end
  
  @testset "load unknown" begin
    let val = Unknown(42)
      @test Unknowns.load(val) == 42
      @test val.value == 42
    end
  end
end
