# Description
Living World is a mod focused on populating the world with active NPCs that simulate player behavior as well as expanding the existing behavior of some existing NPCs. The NPCs are interact-able and mostly randomly generated. 

# Feature List
* Randomly Generated _active_ NPCs
* Previously Defeated NPCs come back to life (_Some require additional intervention first_)
* Collectible Card Game that can be played with active NPCs
* NPC Sticker Trading
* Captains seek out nearby Rogue Fusions to join the battle
* Dedicated Settings Menu for customizing the mod's many features/behaviors.
* Interactable benches
* Player/Partner Overworld Monster Tranformation

# Player/Partner Overworld Transformation
Currently there are only transformations for monsters that actually have overworld sprites. This transformation is completely cosmetic and has no effect on anything else. While playing local co-op, player 2 can access the same transformation menu to independently transform the partner character.

Shortcuts:
* **T** on Keyboard
* **R3** on Gamepads. 

# Card Game Rules

#### Goal
Your goal is to bring your opponent's health down to 0. This is done by playing cards from your hand to accumulate stats used to attack your opponent at the end of each round. 

#### Playing Cards
When you play a card from your hand to the field your **Stance** is changed based on the total attack and defense value of the cards on your field (_see Stances section_). After the Stance has been updated, your **Power Meter** will fill using the stance's primary stat and you will be awarded a point towards that stat. If the cards you played result in a Remaster Bonus, you will be awarded additional stats regardless of your current Stance.

#### End of Round
When both players have filled up their field, they will deal damage to each other using the stats they have earned during the round.

#### Stances
When playing cards, your Stance changes to match the highest stat value of your played cards on the field. The Stances are as follows:
* **Attacking** - When your highest stat is Attack, you focus all your efforts into dealing damage. This leaves you with no defenses to block incoming attacks at the end of the round. 
* **Defending** - When your highest stat is Defense, you focus all your efforts on blocking/healing. You are unable to deal damage and block incoming damage up to your current Defense. If you have more Defense than your opponent's Attack, you will heal for the remaining points.
* **Balanced** - When total Attack/Defense are equal, you are able to manage both attacking/defending. 

**Note:** _Bonus stats awarded through Remastering cards do not change your Stance and will continue to be used even when a Stance would otherwise ignore that stat._

#### Remastering Cards

When the cards played on the field are part of the same monster family, a **Remaster Bonus** is added to the total stats received for that round. How many stats awarded will depend on how much of the monster family is present on that player's side of the field. However, the bonus is only applied if the cards are played in the correct sequence. 

**Example:**
 Kuneko -> Shinning Kuneko will award a full remaster bonus, but Shinning Kuneko -> Kuneko will not. If an unrelated card is played in between, the remaster bonus is still applied as long as they are still on the correct order. 

![](https://storage.modworkshop.net/mods/images/thumbnail_0tujgAlFBoBcdiOfMLXKwUf4Ph4zved8vBH8xfjR.webp)

#### Rewards
Winning rewards the player with a random card from the opponent's current deck.

#### Editing Deck
In the usual start menu, there is now a **Card Collection** option to access your collection and add/remove cards from your deck.


## Credits
Card Game music track by [FoozleCC](https://soundcloud.com/user-11858974/track-2)
Card Template Designs by Banana Toast - [Twitter](https://twitter.com/BanannerToast) and [Art Station](https://www.artstation.com/banana-toast)
Rainbow shader -  [Godot Shaders](https://godotshaders.com/shader/moving-rainbow-gradient/)

## Compatibility
Tested on V1.5
* **Safe to Remove:** Yes
* **Save Tag:** None
* **Net Tag:** Yes, online players require matching mods to play together.

### Source
[Github Repository](https://github.com/ninaforce13/LivingWorld)
