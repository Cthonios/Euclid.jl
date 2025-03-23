using Aqua
using Euclid
using JET
using StaticArrays
using Test

import Euclid: BoundingBox, Point
import Euclid: Cube, Sphere, translate

# basic type testing
function test_bounding_box()
  p1 = Point(0., 0., 0.)
  p2 = Point(1., 1., 1.)
  p3 = Point(-1., -1., -1.)
  bb1 = BoundingBox(p1, p2)
  bb2 = BoundingBox(p3, p1)
  bb3 = intersect(bb1, bb2)
  bb4 = union(bb1, bb2)
  @test bb3.min == p1
  @test bb3.max == p1
  @test bb4.min == p3
  @test bb4.max == p2

  @test_throws AssertionError BoundingBox(p1, p3)
end

function test_points()
  p1 = Point(0., 0., 0.)
  p2 = Point(1., 1., 1.)
  @test p1 < p2
  @test min(p1, p2) == p1
  @test max(p1, p2) == p2
end 

test_bounding_box()
test_points()

# primitive tests
function test_cube()
  c = Cube(1.)
  bb = boundingbox(c)
  @test bb.min ≈ Point(0., 0., 0.)
  @test bb.max ≈ Point(1., 1., 1.)
  @test sdf(c, Point(0.5, 0.5, 0.5)) < 0.
  @test sdf(c, Point(0., 0.5, 0.5)) ≈ 0.
  @test sdf(c, Point(2., 0., 0.)) > 0.

  c = Cube(2.)
  bb = boundingbox(c)
  @test bb.min ≈ Point(0., 0., 0.)
  @test bb.max ≈ Point(2., 2., 2.)
  @test sdf(c, Point(1., 0.5, 0.5)) < 0.
  @test sdf(c, Point(0., 0.5, 0.5)) ≈ 0.
  @test sdf(c, Point(3., 0., 0.)) > 0.

  @test_throws AssertionError Cube(0.)
end

function test_sphere()
  s = Sphere(1.)
  # simple tests
  @test eltype(s) == Float64
  @test ndims(s) == 3
  @test s.radius == 1.

  bb = boundingbox(s)
  @test bb.min == Point(-1., -1., -1.)
  @test bb.max == Point(1., 1., 1.)

  @test sdf(s, Point(0., 0., 0.)) < 0.
  @test sdf(s, Point(1., 0., 0.)) ≈ 0.
  @test sdf(s, Point(2., 0., 0.)) > 0.

  s = Sphere(2.)
  bb = boundingbox(s)
  @test bb.min == Point(-2., -2., -2.)
  @test bb.max == Point(2., 2., 2.)
  @test sdf(s, Point(0., 0., 0.)) < 0.
  @test sdf(s, Point(2., 0., 0.)) ≈ 0.
  @test sdf(s, Point(4., 0., 0.)) > 0.

  @test_throws AssertionError Sphere(0.)
end

test_cube()
test_sphere()

# affine tests
function test_rotation()
  # TODO add sdf tests
  c = Cube(1.)
  r = rotate(c, :z, π / 4.)
  bb = boundingbox(r)
  @test bb.min ≈ Point(-1. / sqrt(2.), 0., 0.)
  @test bb.max ≈ Point(1. / sqrt(2.), 2. / sqrt(2.), 1.)

  c = Cube(1.)
  r = rotate(c, :x, π / 4.)
  bb = boundingbox(r)
  @test bb.min ≈ Point(0., -1. / sqrt(2.), 0.)
  @test bb.max ≈ Point(1., 1. / sqrt(2.), 2. / sqrt(2.))

  c = Cube(1.)
  r = rotate(c, :y, π / 4.)
  bb = boundingbox(r)
  @test bb.min ≈ Point(0., 0., -1. / sqrt(2.))
  @test bb.max ≈ Point(2. / sqrt(2.), 1., 1. / sqrt(2.))

end

function test_translation()
  s = Sphere(1.)

  t = translate(s, 1., 0., 0.)
  bb = boundingbox(t)
  @test bb.min == Point(0., -1., -1.)
  @test bb.max == Point(2., 1., 1.)
  @test sdf(t, Point(1., 0., 0.)) < 0.
  @test sdf(t, Point(0., 0., 0.)) ≈ 0.
  @test sdf(t, Point(2., 0., 0.)) ≈ 0.
  @test sdf(s, Point(4., 0., 0.)) > 0.

  t = translate(s, 0., 2., 0.)
  bb = boundingbox(t)
  @test bb.min == Point(-1., 1., -1.)
  @test bb.max == Point(1., 3., 1.)
  @test sdf(t, Point(0., 2., 0.)) < 0.
  @test sdf(t, Point(0., 1., 0.)) ≈ 0.
  @test sdf(t, Point(0., 3., 0.)) ≈ 0.
  @test sdf(t, Point(0., 5., 0.)) > 0.

  t = translate(s, 0., 0., 3.)
  bb = boundingbox(t)
  @test bb.min == Point(-1., -1., 2.)
  @test bb.max == Point(1., 1., 4.)
end

test_rotation()
test_translation()

function test_aqua()
  Aqua.test_all(Euclid)
end

function test_jet()
  JET.test_package("Euclid"; target_defined_modules=true)
end

# test_aqua()
test_jet()