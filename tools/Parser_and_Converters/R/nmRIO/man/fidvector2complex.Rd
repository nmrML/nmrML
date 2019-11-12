\name{fidvector2complex}
\alias{fidvector2complex}
\title{fidvector2complex}
\usage{
  fidvector2complex(doubles, dimensions = 1)
}
\arguments{
  \item{doubles}{numeric A vector of doubles decoded from
  the nmrML file}

  \item{dimensions}{numeric depending on how we'll
  implement nD NMR data, either the number of dimensions,
  or a vector with n elements and the length of each
  dimension}
}
\value{
  A vector or array with the complex values of the FID data
}
\description{
  Convert a vector of double into a vector or array of
  complex numbers with row-major order
}
\details{
  for 1D fid: [1+1i,2+2i,3+3i]

  when we store it we flatten the complex numbers to
  adjacent floats, giving: [1,1i,2,2i,3,3i]

  This case extends to 2D, up to ND, I will give an example
  with 3D so that all is clear:

  For 3D with dimensions X=3,Y=3,Z=3: [ [ [1+1i,2+2i,3+3i],
  [4+4i,5+5i,6+6i], [7+7i,8+8i,9+9i] ],[ [1+1i,2+2i,3+3i],
  [4+4i,5+5i,6+6i], [7+7i,8+8i,9+9i] ],[ [1+1i,2+2i,3+3i],
  [4+4i,5+5i,6+6i], [7+7i,8+8i,9+9i] ] ]

  When flattened is: [
  1,1i,2,2i,3,3i,4,4i,5,5i,6,6i,7,7i,8,8i,9,9i,
  1,1i,2,2i,3,3i,4,4i,5,5i,6,6i,7,7i,8,8i,9,9i,
  1,1i,2,2i,3,3i,4,4i,5,5i,6,6i,7,7i,8,8i,9,9i ]

  If the array is stored in a block of contiguous memory,
  we can use the following pointer arithmetic to access the
  data

  To access the real part of number at [x][y][z] (multiply
  Z by 2 since we flatten complex into two floats):
  [x*Y*Z*2 + y*Z*2 + 2*z ]

  To access the imaginary part of number at [x][y][z]:
  [x*Y*Z*2 + y*Z*2 + (2*z+1)]

  so for example to access [1][2][2] ( in bold )

  in our case, X=3,Y=3,Z=3

  [1*3*3*2 + 2*3*2 + 2*2] = 30 [1*3*3*2 + 2*3*2 + 2*2+1] =
  31

  In a real FID the dimensions are defined as so: Z =
  number of datapoints in direct dimension Y = number of
  datapoints in first indirect dimension X = number of
  datapoints in 2nd indirect dimension
}
\author{
  Steffen Neumann
}

