function Show-Game {
    param(
        $board,
        $tetromino
    )

    cls
    $updatedBoard = $board | % { ,@( $_ ) }
    $tetromino | % {
        $y = $_.Y + $yOffset
        $x = $_.X + $xOffset
        $updatedBoard[$y][$x] = 1
    }
    $updatedBoard | % { ($_ | % { if ($_ -eq 1) { "*" } else { " " } }) -join "" }
}





$boardWidth = 10
$boardHeight = 20
$board = @(,0 * $boardWidth) * $boardHeight

$tetrominoes = @(
    @([PSCustomObject]@{X=0;Y=0},[PSCustomObject]@{X=1;Y=0},[PSCustomObject]@{X=0;Y=1},[PSCustomObject]@{X=1;Y=1})
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
        37 { $xOffset -= 1 }
        39 { $xOffset += 1 }
        40 { $yOffset += 1 }
    }

    $yOffset += 1
    Show-Game -board $board -tetromino $tetromino
    Start-Sleep -Milliseconds 500
}
