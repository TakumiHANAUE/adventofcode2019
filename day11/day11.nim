import paintingRobot

let filename: string = "./day11input.txt"

var robot: PaintingRobot = PaintingRobot()
robot.initialize()

robot.readProgram(filename)

while robot.isRunning():
    echo "# cycle"
    robot.scanPanelColor()
    var painted: bool = robot.paintPanel()
    if painted == true:
        robot.move()
robot.outputPaintedPanelNum()
robot.showRegistrationIdentifier()