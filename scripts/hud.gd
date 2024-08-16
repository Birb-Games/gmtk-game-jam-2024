extends CanvasLayer

var coins: int = 1000

func publishCoins():
	$CoinLabel.text = "Coins: " + str(coins)

func getCoins():
	return coins
	
func addCoins(coinAmt):
	coins += coinAmt
	publishCoins()

# Called when the node enters the scene tree for the first time.
func _ready():
	publishCoins()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
