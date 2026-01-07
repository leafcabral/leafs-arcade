# To do

## Features
- Aliens space ship that floats in randomly changing directions that shoots 
at random directions. Its shots will damage the player and asteroids, but the 
latter won't increase the score. They will increase the player score by 500 when
defeated by them, but they can also be killed by asteroids.

## Fixes
- Message: Condition "p_child->data.parent != this" is true.
	- Cause: Calling remove_child(...) with player in world.gd
- HUD score starting without any number


## Refactors
*None*
