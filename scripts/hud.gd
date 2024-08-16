extends CanvasLayer

var coins: int = 1000

func publish_coins():
	$CoinLabel.text = "Coins: " + str(coins)

func get_coins():
	return coins
	
func add_coins(coinAmt):
	coins += coinAmt
	publish_coins()

# Called when the node enters the scene tree for the first time.
func _ready():
	publish_coins()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
