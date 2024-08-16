extends CanvasLayer

func publish_coins():
	$CoinLabel.text = "Coins: " + str($/root/Root.coins)

# Called when the node enters the scene tree for the first time.
func _ready():
	publish_coins()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
