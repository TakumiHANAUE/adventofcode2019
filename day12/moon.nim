import logging
import typedef

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

method getPosition(moon: Moon): Position {.base.} =
    return moon.position

method calcPotentioalEnergy*(moon: Moon): void {.base.} =
    moon.potential = uint(abs(moon.position.x) + abs(moon.position.y) + abs(moon.position.z))

method calcKineticEnergy*(moon: Moon): void {.base.} =
    moon.kinetic = uint(abs(moon.velocity.vx) + abs(moon.velocity.vy) + abs(moon.velocity.vz))

method calcTotalEnergy*(moon: Moon): uint {.base.} =
    return (moon.potential * moon.kinetic)

method calcAccelerationAgainst*(moon: Moon, counterpart: Moon): void {.base.} =
    var counterpartPosition: Position = counterpart.getPosition()
    # acceleration.ax
    var cmpResultX = cmp(moon.position.x, counterpartPosition.x)
    if cmpResultX < 0:
        inc(moon.acceleration.ax, 1)
    elif cmpResultX > 0:
        inc(moon.acceleration.ax, -1)
    # acceleration.ay
    var cmpResultY = cmp(moon.position.y, counterpartPosition.y)
    if cmpResultY < 0:
        inc(moon.acceleration.ay, 1)
    elif cmpResultY > 0:
        inc(moon.acceleration.ay, -1)
    # acceleration.az
    var cmpResultZ = cmp(moon.position.z, counterpartPosition.z)
    if cmpResultZ < 0:
        inc(moon.acceleration.az, 1)
    elif cmpResultZ > 0:
        inc(moon.acceleration.az, -1)

method updateVelocity*(moon: Moon): void {.base.} =
    inc(moon.velocity.vx, moon.acceleration.ax)
    inc(moon.velocity.vy, moon.acceleration.ay)
    inc(moon.velocity.vz, moon.acceleration.az)
    moon.acceleration = (0, 0, 0)

method updatePosition*(moon: Moon): void {.base.} =
    inc(moon.position.x, moon.velocity.vx)
    inc(moon.position.y, moon.velocity.vy)
    inc(moon.position.z, moon.velocity.vz)
