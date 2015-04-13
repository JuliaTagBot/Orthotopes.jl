module HyperRectangles
using Compat

import Base.split

export AbstractHyperRectangle, HyperRectangle, update!, split

abstract AbstractHyperRectangle{T, N}

type HyperRectangle{T, N} <: AbstractHyperRectangle{T, N}
    min::Vector{T}
    max::Vector{T}
end

function HyperRectangle{T}(max::Vector{T}, min::Vector{T})
    n = length(max)
    m = length(min)
    @assert n == m
    HyperRectangle{T, n}(min, max)
end

function HyperRectangle(t::DataType, n::Int)
    max = fill(typemin(t), n)
    min = fill(typemax(t), n)
    HyperRectangle{t,n}(min, max)
end

@inline Base.max(b::HyperRectangle) = b.max
@inline Base.min(b::HyperRectangle) = b.min

function update!{T, N}(b::HyperRectangle{T, N}, v)
    for i = 1:N
        b.max[i] = max(b.max[i], v[i])
        b.min[i] = min(b.min[i], v[i])
    end
end

function (==){T1, T2, N}(b1::HyperRectangle{T1, N}, b2::HyperRectangle{T2, N})
    b1.min == b2.min && b1.max == b2.max
end

@inline isequal(b1::HyperRectangle, b2::HyperRectangle) = b1 == b2

function Base.contains{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    for i = 1:N
        b2.max[i] <= b1.max[i] && b2.min[i] >= b1.min[i] || return false
    end
    true
end

@inline Base.in(b1::HyperRectangle, b2::HyperRectangle) = contains(b2, b1)

function during{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    for i = 1:N
        b1.max[i] < b2.max[i] && b1.min[i] > b2.min[i] || return false
    end
    true
end

function starts{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    b1.min == b2.min
end

function finishes{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    b1.max == b2.max
end

function meets{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    b1.min == b2.max || b1.max == b2.min
end

# Splits an HyperRectangle into two new ones along an axis
# at a given axis value
function split{T, N}(b::HyperRectangle{T,N}, axis::Int, value::T)
    b1max = copy(b.max)
    b1max[axis] = value

    b2min = copy(b.min)
    b2min[axis] = value

    return HyperRectangle{T, N}(b.min, b1max),
           HyperRectangle{T, N}(b2min, b.max)
end

end # module