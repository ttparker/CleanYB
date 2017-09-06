type Yb
  # system parameters:
  L::Int64
  T::Float64
  # n.n. coupling matrices:
  Ja1::Matrix{Float64}
  Ja2::Matrix{Float64}
  Ja3::Matrix{Float64}

  spins::Array{Float64, 3}  # first index is n_2, second is n_3
  energy::Float64
  MA::Vector{Float64}  # Total (i.e. extensive) magnetizations
  MB::Vector{Float64}
  MC::Vector{Float64}
  MD::Vector{Float64}
  CA::Vector{Complex{Float64}}
  CB::Vector{Complex{Float64}}
  CC::Vector{Complex{Float64}}
  CD::Vector{Complex{Float64}}
  N::Int64
end

function Yb(params::SystemParameters)
  Ja1 = [2*(params.Jpm+params.Jpmpm) 0 0; 0 2*(params.Jpm-params.Jpmpm) params.Jzpm; 0 params.Jzpm params.Jzz]
  Ja2 = [2*params.Jpm-params.Jpmpm -sqrt(3)*params.Jpmpm -sqrt(3)/2*params.Jzpm; -sqrt(3)*params.Jpmpm 2*params.Jpm+params.Jpmpm -1/2*params.Jzpm; -sqrt(3)/2*params.Jzpm -1/2*params.Jzpm params.Jzz]
  Ja3 = [2*params.Jpm-params.Jpmpm sqrt(3)*params.Jpmpm sqrt(3)/2*params.Jzpm; sqrt(3)*params.Jpmpm 2*params.Jpm+params.Jpmpm -1/2*params.Jzpm; sqrt(3)/2*params.Jzpm -1/2*params.Jzpm params.Jzz]

  # initialize spins randomly:
  spins = Array{Float64, 3}(params.L, params.L, 3)  # first index is n_2, second is n_3
  initialOrientations = rand(params.L, params.L, 2)
  for i in 1:params.L
    for j in 1:params.L
      spins[i, j, :] = randomSpin(initialOrientations[i, j, 1], initialOrientations[i, j, 2])
    end
  end
  # measure the energy of the initial spin configuration:
  energy = 0.
  for n2 in 1:params.L
    for n3 in 1:params.L
      nw = mod1(n2 + 1, params.L)
      sw = mod1(n3 + 1, params.L)
      energy += dot(spins[n2, n3, :], Ja1 * spins[nw, sw, :] + Ja2 * spins[nw, n3, :] + Ja3 * spins[n2, sw, :])  # only go "west" to avoid double-counting
    end
  end

  # construct the C vectors for the order parameter:
  CA = Vector{Complex{Float64}}()
  CB = Vector{Complex{Float64}}()
  CC = Vector{Complex{Float64}}()
  CD = Vector{Complex{Float64}}()
  if params.Jpmpm < 0
    CA = [3/2, 3/2*im, 0]
    CB = [1/2, -3/2*im, 0]
    CC = [-1-sqrt(3)/2*im, -sqrt(3)/2, 0]
    CD = [-1+sqrt(3)/2*im, sqrt(3)/2, 0]
  else
    x = (params.Jpmpm + sqrt(params.Jzpm^2 + params.Jpmpm^2)) / params.Jzpm
    costheta = -1 / sqrt(1 + x^2)
    sintheta = x / sqrt(1 + x^2)
    CA = [-3/2*im*system.sintheta, 3/2*system.sintheta, 0]
    CB = [3/2*im*system.sintheta, 1/2*system.sintheta, 2*system.costheta]
    CC = [sqrt(3)/2*system.sintheta, (-1-sqrt(3)/2*im)*system.sintheta, (-1+sqrt(3)*im)*system.costheta]
    CD = [-sqrt(3)/2*system.sintheta, (-1+sqrt(3)/2*im)*system.sintheta, (-1-sqrt(3)*im)*system.costheta]
  end

  Yb(params.L, params.T, Ja1, Ja2, Ja3, spins, energy, Vector{Float64}(), Vector{Float64}(), Vector{Float64}(), Vector{Float64}(), CA, CB, CC, CD, params.L^2)
end
