$boardWidth = 10
$boardHeight = 20

$console = $host.UI.RawUI
$console.ForegroundColor = 'White'


function Rotate-Tetromino {
    param(
        $tetromino
    )
    
    $center = $tetromino | Measure-Object -Property X,Y -Average
    $newTetromino = $tetromino | ForEach-Object {
        [PSCustomObject]@{
            X = [int](-($_.Y - $center.Average.Y) + $center.Average.X)
            Y = [int]($_.X - $center.Average.X + $center.Average.Y)
        }
    }
    return $newTetromino
}

function Update-Game {
    param(
        $board,
        $tetromino
    )
    $updatedBoard = Copy-Board -board $board
    $tetromino | % {
        $y = $_.Y + $yOffset
        $x = $_.X + $xOffset
        $updatedBoard[$y][$x] = 1
    }
    $consoleOutput = $updatedBoard | % { ($_ | % { if ($_ -eq 1) { "*" } else { " " } }) -join "" }
    cls
    $consoleOutput
}

function Copy-Board {
    param (
        $board
    )

    $newBoard = New-Object 'System.Collections.Generic.List[Object]'
    foreach ($row in $board) {
        $newRow = $row.Clone()
        $newBoard.Add($newRow)
    }

    return $newBoard
}

function Test-Collision {
    param(
        $board,
        $tetromino,
        $xOffset,
        $yOffset
    )

    foreach ($block in $tetromino) {
        $x = $block.X + $xOffset
        $y = $block.Y + $yOffset
        if ($x -lt 0 -or $x -ge $boardWidth -or $y -ge $boardHeight -or ($y -ge 0 -and $board[$y][$x] -eq 1)) {
            return $true
        }
    }

    return $false
}

$board = New-Object 'System.Collections.Generic.List[Object]'
for ($i = 0; $i -lt $boardHeight; $i++) {
    $row = ,@(0) * $boardWidth
    $board.Add($row)
}


$tetrominoes = @(
    @([PSCustomObject]@{X=0;Y=0},[PSCustomObject]@{X=1;Y=0},[PSCustomObject]@{X=0;Y=1},[PSCustomObject]@{X=1;Y=1}), # O shape
    @([PSCustomObject]@{X=0;Y=0},[PSCustomObject]@{X=1;Y=0},[PSCustomObject]@{X=2;Y=0},[PSCustomObject]@{X=3;Y=0}), # I shape
    @([PSCustomObject]@{X=1;Y=0},[PSCustomObject]@{X=0;Y=1},[PSCustomObject]@{X=1;Y=1},[PSCustomObject]@{X=2;Y=1}), # T shape
    @([PSCustomObject]@{X=0;Y=0},[PSCustomObject]@{X=1;Y=0},[PSCustomObject]@{X=1;Y=1},[PSCustomObject]@{X=2;Y=1}), # Z shape
    @([PSCustomObject]@{X=1;Y=0},[PSCustomObject]@{X=2;Y=0},[PSCustomObject]@{X=0;Y=1},[PSCustomObject]@{X=1;Y=1}), # S shape
    @([PSCustomObject]@{X=0;Y=0},[PSCustomObject]@{X=1;Y=0},[PSCustomObject]@{X=2;Y=0},[PSCustomObject]@{X=2;Y=1}), # L shape
    @([PSCustomObject]@{X=2;Y=0},[PSCustomObject]@{X=0;Y=1},[PSCustomObject]@{X=1;Y=1},[PSCustomObject]@{X=2;Y=1})  # J shape
)


$currentTetrominoIndex = Get-Random -Minimum 0 -Maximum $tetrominoes.Count
$tetromino = $tetrominoes[$currentTetrominoIndex]

$xOffset = [int]($boardWidth / 2)
$yOffset = 0

while ($true) {
    $key = $null
    if ($host.UI.RawUI.KeyAvailable) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }

    switch ($key.VirtualKeyCode) {
        37 { # Left arrow key
            if (-not (Test-Collision -board $board -tetromino $tetromino -xOffset ($xOffset - 1) -yOffset $yOffset)) {
                $xOffset -= 1
            }
        }
        38 { # Up arrow key
            $rotatedTetromino = Rotate-Tetromino -tetromino $tetromino
            if (-not (Test-Collision -board $board -tetromino $rotatedTetromino -xOffset $xOffset -yOffset $yOffset)) {
                $tetromino = $rotatedTetromino
            }
        }
        39 { # Right arrow key
            if (-not (Test-Collision -board $board -tetromino $tetromino -xOffset ($xOffset + 1) -yOffset $yOffset)) {
                $xOffset += 1
            }
        }
        40 { # Down arrow key
            if (-not (Test-Collision -board $board -tetromino $tetromino -xOffset $xOffset -yOffset ($yOffset + 1))) {
                $yOffset += 1
            }
        }
    }

    if (Test-Collision -board $board -tetromino $tetromino -xOffset $xOffset -yOffset ($yOffset + 1)) {
        $tetromino | ForEach-Object {
            $y = $_.Y + $yOffset
            $x = $_.X + $xOffset
            $board[$y][$x] = 1
        }
        $currentTetrominoIndex = Get-Random -Minimum 0 -Maximum $tetrominoes.Count
        $tetromino = $tetrominoes[$currentTetrominoIndex]
        $xOffset = [int]($boardWidth / 2)
        $yOffset = 0
    } else {
        $yOffset += 1
    }

    Update-Game -board $board -tetromino $tetromino
    Start-Sleep -Milliseconds 500
}


