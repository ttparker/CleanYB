type SystemParameters
  Jzz::Float64
  Jpm::Float64
  Jpmpm::Float64
  Jzpm::Float64
  T::Float64
  L::Int64
  thermalizationSweeps::Int64
  equilibriumSweeps::Int64
end

function SystemParameters()
  SystemParameters(0., 0., 0., 0., 0., 0, 0, 0)
end

type RawRunData
  T::Float64
  energyList::Vector{Float64}
  psiList::Vector{Complex{Float64}}
end

type SystemSummary
  params::SystemParameters
  Ts::Vector{Float64}
  avgEnergies::Vector{Float64}
  energyVariances::Vector{Float64}
  absAvgPsis::Vector{Float64}
  avgAbsPsis::Vector{Float64}
  absAvgPsi2s::Vector{Float64}
  avgAbsPsi2s::Vector{Float64}
end

function SystemSummary()
  SystemSummary(SystemParameters(), Float64[], Float64[], Float64[], Float64[], Float64[], Float64[], Float64[])
end
