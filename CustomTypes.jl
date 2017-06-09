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
