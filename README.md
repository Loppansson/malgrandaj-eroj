# Malgrandaj Eroj
Malgrandaj Eroj (en: "Small Parts") is a procedurally generated first-person open-world survival game in a low-poly style, featuring the GPLv3 License!

## Rules.

The following set of rules are intended to give the game some sort of consistency, and make collaboration easier.
1. These rules are established with the following intent: To make developing the game promote as much subjective well-being as posible.
2. Subjective well-being is difined as low negative effect, high positive effect, and high over-all life satisfaction.
3. These rules, with the exeption of 1, 2, and 3, may change, if by doing so, they will better achomplish the goal laid out by rule 1.
4. Always act to promote an environment that promotes subjective well-being; Be respectful, listen to one another, and have fun!
5. The game is first-person.
6. The game's visuals should be in a low poly style, close to the work of Quaternius.
7. All additions to the game should be modular; They should not need change in any other part of the game to work in a technical sense, nor should they make it difficult to build the game further.
8. The project should follow the "Best practices" stated in the Godot Docs: [Link.](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)
9. Every contributor get's one folder to them self; they're free to organize this folder to their liking.
10. You're not allowed to edit another contributor's folder.
11. Every contributor is allowed to have a maximum of 200Mb of data in their own folder.
12. Everything that's just by mutiple people is put under "res://common/".
13. All code in "res://common/" should follow the "GDScript style guide" and be documented in acordence with the "Writing guidelines" stated in the Godot Docs: [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html), ["Writing guidelines"](https://docs.godotengine.org/en/stable/contributing/documentation/docs_writing_guidelines.html).
14. The project should not exceed 5Gb in size.

### Example of structure
* addons/
* contributors/
	* contributor 1's name/ (ex: lopano/)
	* contributor 2's name/ (ex: alex/)
	* contributor 3's name/ (ex: steve/)
* common/
	* docs/learning.html
	* models/town/house/
		* house.dae
		* window.png
		* door.png
	* characters/
		* player/
			* cubio.dae
			* cubio.png
		* enemies/goblin/
			* goblin.dae
			* goblin.png
		* npcs/suzanne/
			* suzanne.dae
			suzanne.png
	* levels/riverdale/riverdale.scn
* default_bus_layout.tres
* environment.tres
* icon.svg
