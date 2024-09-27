
// API Script for Template Assist

// Set up same states as AssistStats (by excluding "var", these variables will be accessible on timeline scripts!)
STATE_IDLE = 0;
STATE_JUMP = 1;
STATE_FALL = 2;
STATE_SLAM = 3;
STATE_OUTRO = 4;


var SPAWN_X_DISTANCE = 0; // How far in front of player to spawn
var SPAWN_HEIGHT = 0; // How high up from player to spawn



var deckResource = match.createCustomGameObject(self.getResource().getContent("deck"), self);

/**
 * @type {Object} Deck

 * @property {function} createAction
 * @property {function} init
 */
var deck: object = deckResource.exports;



// Below are a a list of conditions you can use to set cards, Range Condition being the most basic one you need

function rangeCondition(lo: Int, hi: Int) {
	return function (card: Int) {
		if (card >= lo && card <= hi) {
			return true;
		} else {
			return false;
		}
	}
}

function airRangeCondition(lo: Int, hi: Int) {
	var predicate = rangeCondition(lo, hi);

	return function (card) {
		return !self.getRootOwner().isOnFloor() && predicate(card);
	}
}

function groundRangeCondition(lo: Int, hi: Int) {
	var predicate = rangeCondition(lo, hi);

	return function (card) {
		return self.getRootOwner().isOnFloor() && predicate(card);
	}
}


function damageRangeCondition(minDamage: Int, maxDamage: Int, lo: Int, hi: Int) {
	var predicate = rangeCondition(lo, hi);

	return function (card) {
		var damage = self.getRootOwner().getDamage();
		var withinDamageRange = damage >= minDamage && damage <= maxDamage;
		return withinDamageRange && predicate(card);
	}
}

function maxDamageCondition(maxDamage: Int, lo: Int, hi: Int) {
	var predicate = rangeCondition(lo, hi);

	return function (card) {
		var damage = self.getRootOwner().getDamage();
		var withinDamageRange = damage <= maxDamage;
		return withinDamageRange && predicate(card);
	}
}

function minDamageCondition(minDamage: Int, lo: Int, hi: Int) {
	var predicate = rangeCondition(lo, hi);

	return function (card) {
		var damage = self.getRootOwner().getDamage();
		var withinDamageRange = damage >= minDamage;
		return withinDamageRange && predicate(card);
	}
}




/*

Now for a brief explaination of how to use all this:

First and foremost: Actions themselves are just functions, but wrapped around with some metadata for the system to use

Creating an action would work as follows:

- Write a function that spawns a projectile/causes a status effect etc
Lets assume you already have that function, lets call it attackWave and assume you've already defined the projectile yourself, 
either using the projectile creator or manually:
function attackWave() {
	match.createProjectile(self.getResource().getContent("assisttemplateProjectile"), self);
}

Lets say we wanted this to only run when:
- We have a card thats between 0 and 5
- Has a cooldown time of 60 frames
- And has an iconId name of "wave"[1]

var attackWaveAction = deck.createAction(attackWave, rangeCondition(0,5), 60, "wave");

Now lets cover some different cases to get an idea of what else you can do:

- Only usable when damage is 50 or above and with card values between 5 and 9
var attackWaveActionAbove50Damage = deck.createAction(attackWave, minDamageCondition(50 ,0,5), 60, "wave");


- Only usable whilst in the air, but for all cards from 0 to 9
var attackWaveActionAirOnly = deck.createAction(attackWave, airRangeCondition(9,9), 60, "wave");


and inside initialise you would simply call it like so to add these all to the deck
	
deck.init([attackWaveAction, attackWaveActionAbove50Damage,attackWaveActionAirOnly ], ""); 

Another thing to add would be sound effects, you can optionally add the Id of whatever sound effect you
wish to play when cooldowns end, I cannot distribute them to you so you would have to 
get the sounds yourself, but the process is just a matter of setting the Id of said file and passing 
it as a string  like so:

deck.init([attackWaveAction, attackWaveActionAbove50Damage,attackWaveActionAirOnly ], "soundId"); 


[1] As for icons, keep in mind that icons should be added by adding new animation with the iconId being 
the animation name you set and a single image in the icons.entity file in this project.

TODO: Add proper documentation
*/

// Runs on object init
function initialize() {
	deck.init([], ""); // You 

	//	deck.initializeDeck(3, [], "cards", "cards_cooldown", "card_icons");

	// Face the same direction as the user
	if (self.getOwner().isFacingLeft()) {
		self.faceLeft();
	}

	// Reposition relative to the user
	Common.repositionToEntityEcb(self.getOwner(), self.flipX(SPAWN_X_DISTANCE), -SPAWN_HEIGHT);

	// Add fade in effect
	Common.startFadeIn();

}

function update() {

}
function onTeardown() {

}


