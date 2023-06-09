# Malgrandaj Eroj
Malgrandaj Eroj (en: "Small Parts") is a project that intend to provide a fun time while building a procedurally generated first-person open-world survival sandbox game in a low-poly style, featuring the GPLv3 License!

## Rules for Collaboration (0.3.2)

1. These rules are established with the following intent: To make developing the game promote as much subjective well-being as posible.
2. Subjective well-being is difined as low negative affect, high positive affect, and high over-all life satisfaction.
3. These rules, with the exeption of 1, 2, and 3, may change, if by doing so, they will better achomplish the goal laid out by rule 1.
4. Always act to promote an environment that promotes subjective well-being; Be respectful, listen to one another, and bring cozy vibes!
5. The game is constructed in Godot 4.0.
6. The game MUST: 
	1. be in First-person.
	2. have a procedurally generated environment. (Initial load MUST NOT take longer than 30 secounds on an average gaming pc. Use the "Most Popular" from the Steam Hardware & Software Survey for reference: [Link](https://store.steampowered.com/hwsurvey))
	3. be open-world.
	4. be in the sanbox and survival genres.
	5. be in a low poly style, close to the work of Quaternius. (Using their work is recomended.)
	6. give proper support for a pasafist play-style.
7. All additions to the game MUST be modular; They MUST NOT need change in any other part of the game to work in a technical sense, and they MUST NOT make it difficult to build the game further.
8. The project SHOULD follow the "Best practices" stated in the Godot Docs: [Link.](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)
9. Every contributor get's one folder to them self; they're free to organize this folder to their liking.
10. You MUST NOT edit another contributor's folder.
11. Every contributor MUST NOT have more than 200Mb of data in their own folder.
12. Everything that's used by mutiple people is put under "res://common/".
13. All code in "res://common/" should follow the "GDScript style guide" and be documented in acordence with the "Writing guidelines" stated in the Godot Docs: [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html), [Writing guidelines](https://docs.godotengine.org/en/stable/contributing/documentation/docs_writing_guidelines.html).
14. Addons installed from the Asset Library should not be modified in "res://addons/".
15. The project should not exceed 5Gb in size.
16. The project's releases must follow Semantic Versioning 2.0.0. [Link](https://semver.org/)

### Example of structure
* addons/
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
* contributors/
	* contributor 1's name/ (ex: lopano/)
	* contributor 2's name/ (ex: alex/)
	* contributor 3's name/ (ex: steve/)
* default_bus_layout.tres
* environment.tres
* icon.svg
