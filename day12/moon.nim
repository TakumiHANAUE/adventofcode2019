import logging

type
    Axis* = enum
        AXIS_X, AXIS_Y, AXIS_Z

type
    Vector* = array[Axis, int]
    Position* = Vector
    Velocity* = Vector
    Acceleration* = Vector

type
    Moon* = ref object of RootObj
        position: Position
        velocity: Velocity
        acceleration: Acceleration
        potential: uint
        kinetic: uint

method printMoon*(moon: Moon): void {.base.} =
    echo "position: ", moon.position
    echo "velocity: ", moon.velocity
    echo "acceleration: ", moon.acceleration
    echo "potential: ", moon.potential
    echo "kinetic: ", moon.kinetic
    echo ""

method setPosition*(moon: Moon, pos: Position): void {.base.} = 
    moon.position = pos

method getPositionOnAnAxis*(moon: Moon, axis: Axis): int {.base.} =
    return moon.position[axis]

method getPosition*(moon: Moon): Position {.base.} =
    return moon.position

method getVelocityOnAnAxis*(moon: Moon, axis: Axis): int {.base.} =
    return moon.velocity[axis]

method getVelocity*(moon: Moon): Position {.base.} =
    return moon.velocity

method calcPotentioalEnergy*(moon: Moon): void {.base.} =
    moon.potential = uint(abs(moon.position[AXIS_X]) + abs(moon.position[AXIS_Y]) + abs(moon.position[AXIS_Z]))

method calcKineticEnergy*(moon: Moon): void {.base.} =
    moon.kinetic = uint(abs(moon.velocity[AXIS_X]) + abs(moon.velocity[AXIS_Y]) + abs(moon.velocity[AXIS_Z]))

method calcTotalEnergy*(moon: Moon): uint {.base.} =
    return (moon.potential * moon.kinetic)

method calcAccelerationOnAnAxisAgainst*(moon: Moon, counterpart: Moon, axis: Axis): void {.base.} =
    var counterpartPosition: Position = counterpart.getPosition()
    var cmpresult = cmp(moon.position[axis], counterpartPosition[axis])
    if cmpresult < 0:
        inc(moon.acceleration[axis], 1)
    elif cmpresult > 0:
        inc(moon.acceleration[axis], -1)

method calcAccelerationAgainst*(moon: Moon, counterpart: Moon): void {.base.} =
    moon.calcAccelerationOnAnAxisAgainst(counterpart, AXIS_X)
    moon.calcAccelerationOnAnAxisAgainst(counterpart, AXIS_Y)
    moon.calcAccelerationOnAnAxisAgainst(counterpart, AXIS_Z)

method updateVelocityOnAnAxis*(moon: Moon, axis: Axis): void {.base.} =
    inc(moon.velocity[axis], moon.acceleration[axis])
    moon.acceleration[axis] = 0

method updateVelocity*(moon: Moon): void {.base.} =
    moon.updateVelocityOnAnAxis(AXIS_X)
    moon.updateVelocityOnAnAxis(AXIS_Y)
    moon.updateVelocityOnAnAxis(AXIS_Z)

method updatePositionOnAnAxis*(moon: Moon, axis: Axis): void {.base.} =
    inc(moon.position[axis], moon.velocity[axis])

method updatePosition*(moon: Moon): void {.base.} =
    moon.updatePositionOnAnAxis(AXIS_X)
    moon.updatePositionOnAnAxis(AXIS_Y)
    moon.updatePositionOnAnAxis(AXIS_Z)
