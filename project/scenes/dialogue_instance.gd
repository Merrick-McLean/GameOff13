class_name DialogueInstance
extends Object

signal killed #never actually called lol
signal finished(index: Dictionary)

enum Id {
	TEST_1,
	TEST_2,
	ROUND_START_1,
	NPC_BET_1,
	NPC_CALL_1,
	NPC_LOSE_1,
	NPC_WIN_1,
	NPC_DEATH_1,
	QUERY_LIAR,
	CAPTAIN_SHOOTS,
	DIALOGUE_PROMPT,
	
	## INTRO
	INTRO_DIALOGUE,
	INTRO_DIALOGUE_2,
	GAME_INSTRUCTIONS,
	
	## PIRATE DIALOGUE
	PIRATE_NAME,
	PIRATE_NAME_2,
	PIRATE_DEATH_1,
	PIRATE_DEATH_2,
	PIRATE_DEATH_3,
	PIRATE_NOW,
	PIRATE_SECRET_FAIL,
	PIRATE_SECRET,
	PIRATE_REVEAL,
	
	## NAVY DIALOGUE
	NAVY_NAME,
	NAVY_NOW_1,
	NAVY_NOW_2,
	NAVY_SHIP,
	NAVY_SHIP_2,
	NAVY_EVENT_1,
	NAVY_IS_NAVY,
	NAVY_SECRET_FAIL,
	NAVY_SECRET,
	NAVY_SECRET_2,
	
	## CAPTAIN DIALGOUE
	CAPTAIN_NAME,
	CAPTAIN_KNOW_SECRET,
	CAPTAIN_SHIP,
	CAPTAIN_SHIP_2,
	CAPTAIN_CREW,
	CAPTAIN_NOW,
	CAPTAIN_REVEAL,
	
	## NOT REAL DIALOGUES
	LIAR,
	PASS
}

var display : DialogueDisplay
var my_id : Id
var arguments : Dictionary
var is_playing := false

var dialogues : Dictionary = {
	Id.TEST_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I can talk normally,[set speed=5] I can talk slow,[set speed=200] and I can talk fast")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I can also pause,[set pause_time=0.9] dramatically[set pause_time=2][set speed=5]...")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anyway what do ye think lad? Is that cool or what?", false)
		var result := await display.push_options([OptionSet.new(Dialogue.Actor.PIRATE_LEFT, ["Yes. Super Cool", "No..."])])
		match result.index:
			0: await display.say(Dialogue.Actor.PIRATE_LEFT, "That's the [wave amp=20.0 freq=5.0 connected=1]spirit[/wave]")
			1: await display.say(Dialogue.Actor.PIRATE_LEFT, "Fuck you.")
		return {},
	
	Id.TEST_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I'm talking over here on the left.")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I talk over here on the right.")
		await display.say(Dialogue.Actor.CAPTAIN, "And I talk in[set pause_time=0.2] the[set pause_time=0.2] middle.")
		return {},
	
	Id.ROUND_START_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		match args.round_number:
			1: await display.say(Dialogue.Actor.CAPTAIN, "Let us begin.") 
			2: await display.say(Dialogue.Actor.CAPTAIN, "Time fer the next toss.")
			3: await display.say(Dialogue.Actor.CAPTAIN, "Looks like it's down to just us, matey.")
		display.clear_speach()
		return {},
	
	Id.NPC_BET_1: func(args: Dictionary) -> Dictionary:
		var actor : Dialogue.Actor = args.actor
		var bet : LiarsDice.Round.Bet = args.bet
		
		display.clear_options()
		await display.say(actor, "I bet " + Dialogue.get_bet_string(bet), false)
		return {},
	
	Id.NPC_CALL_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, Dialogue.get_bet_string(args.bet) + "? Ye be a liar!") # or just Liar! ?
		display.clear_speach()
		return {},
	
	Id.NPC_LOSE_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "Well played matey.")
		display.clear_speach()
		return {},
	
	Id.NPC_WIN_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		
		await display.say(args.actor, "I knew it.")
		
		
		display.clear_speach()
		return {},
	
	Id.QUERY_LIAR: func(args: Dictionary) -> Dictionary:
		var result := await display.push_options([OptionSet.new(args.actor, ["LIAR!", "Pass"])])
		display.clear_speach()
		return {"called": result.index == 0},
	
	Id.NPC_DEATH_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "It's time fer me to go.")
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHOOTS: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		
		
		if LiarsDice.physical.pirate_gun.state == Gun.State.ON_TABLE:
			## FINAL ENDING SEQUENCE
			await display.say(Dialogue.Actor.CAPTAIN, "Alas, ye just never learn.")
			await display.say(Dialogue.Actor.CAPTAIN, "Ye can try all ye want.") 
			await display.say(Dialogue.Actor.CAPTAIN, "Rile up me crew. Cause a rucuss.")
			LiarsDice.physical.pan_camera_to_pirate_gun()
			display.say(Dialogue.Actor.CAPTAIN, "But the Captain [set pause_time=0.7]always [set pause_time=0.7]wins.", false, false)
			await LiarsDice.physical.pirate_gun.picked_up
			LiarsDice.physical.pan_camera_to_npc(Dialogue.Actor.CAPTAIN)
			await display.get_tree().create_timer(0.5).timeout
			await display.say(Dialogue.Actor.CAPTAIN, "Avast their matey.")
			await display.say(Dialogue.Actor.CAPTAIN, "We don't gotta part ways like this.")
			var result := await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Goodbye Captain"])])
			await display.get_tree().create_timer(0.5).timeout
			LiarsDice.physical.play_credits()
			await killed
		elif LiarsDice.alive_players.size() == 2 and not Progress.know_captain_secret and Progress.player_death_count > 0:
			## CAPTAIN REVEAL
			await Dialogue.play(Id.CAPTAIN_REVEAL).finished
		else:
			await display.say(Dialogue.Actor.CAPTAIN, "Well ye know the rules...")
			LiarsDice.physical.is_captain_gun_drawn = true
			await display.say(Dialogue.Actor.CAPTAIN, "Farewell ye sea dog.")
		display.clear_speach()
		return {},
	
	
	Id.DIALOGUE_PROMPT: func(args: Dictionary) -> Dictionary:
		var last_speaking_actor : Dialogue.Actor
		var result : Dictionary
		for i in args.max_dialogue_count:
			await Dialogue.get_tree().create_timer(0.1).timeout
			var options : Array[OptionSet]
			var possible_ids := {}
			for actor: Dialogue.Actor in args.actors:
				possible_ids[actor] = get_npc_dialogue_options(actor, false)
				options.append(OptionSet.new(actor, possible_ids[actor].map(get_dialogue_option_lead)))
			
			var option_result := await display.push_options(options)
			var chosen_id : DialogueInstance.Id = possible_ids[option_result.actor][option_result.index]
			last_speaking_actor = option_result.actor
			display.clear_options()
			result = await Dialogue.play(chosen_id).finished
			if "start_new_round" in result: return result
		
		
		await display.say(last_speaking_actor, "But enough 'bout me. Time to make yer bet.")
		if args.bet.amount > 0:
			await display.say(last_speaking_actor, "Up the bid from " + Dialogue.get_bet_string(args.bet))
		display.clear_speach()
		
		return {},
	
	
	
	Id.INTRO_DIALOGUE: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "Ahoy, welcome aboard the graveyard of The Siren's Wake.") 
		await display.say(Dialogue.Actor.CAPTAIN, "I expect ye traveled far to join us sorry souls.")
		await display.say(Dialogue.Actor.CAPTAIN, "What brings ye to me quarters?")
		await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["I seek an ancient secret.", "Immortality."])])
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Yar, the secret to immoralitity?")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "The cap'n knows about that...")
		await display.say(Dialogue.Actor.CAPTAIN, "Aye, but I can't share it for nothin'.")
		await display.say(Dialogue.Actor.CAPTAIN, "How 'bout we settle this with a game.")
		await display.say(Dialogue.Actor.CAPTAIN, "If ye can best all three o' us in Liar's Dice,")
		await display.say(Dialogue.Actor.CAPTAIN, "then I'll tell ye the secret.")
		await display.say(Dialogue.Actor.CAPTAIN, "But If ye lose...")
		await display.say(Dialogue.Actor.CAPTAIN, "Ye pay with yer life.")
		await display.say(Dialogue.Actor.CAPTAIN, "Have we a deal?")
		await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Aye", "Deal"])])
		display.clear_speach()
		GameMaster.flash_lightning()
		await Dialogue.play(Id.INTRO_DIALOGUE_2).finished
		return {},
	
	Id.INTRO_DIALOGUE_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await Dialogue.get_tree().create_timer(2.0).timeout
		await display.say(Dialogue.Actor.CAPTAIN, "Aye, matey.")
		await display.say(Dialogue.Actor.CAPTAIN, "Do ye know how to play Liars Dice?")
		if Progress.player_death_count == 0:
			await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Remind me."])])
			await Dialogue.play(Id.GAME_INSTRUCTIONS)
		else:
			var result := await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Yar", "Remind me."])])
			if result.index == 1:
				await Dialogue.play(Id.GAME_INSTRUCTIONS)
			else:
				await display.say(Dialogue.Actor.CAPTAIN, "Grand.")
				LiarsDice.start_new_game(false)
		
		return {},
	
	Id.GAME_INSTRUCTIONS: func(args: Dictionary) -> Dictionary: 
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I don't know a Buccaneer or a Corsair who doesn't!")
		await display.say(Dialogue.Actor.CAPTAIN, "Not to worry.")
		LiarsDice.start_new_game(true)
		await display.say(Dialogue.Actor.CAPTAIN, "We each have 5 dice.")
		LiarsDice.physical.pan_camera_to_cup()
		await display.say(Dialogue.Actor.CAPTAIN, "But ye only know the values of yer own.")
		LiarsDice.physical.pan_camera_to_npc(Dialogue.Actor.CAPTAIN)
		await display.say(Dialogue.Actor.CAPTAIN, "On ye turn, make a bet.")
		await display.say(Dialogue.Actor.CAPTAIN, "Bet how many of all the dice share share a certain value.")
		#await display.say(Dialogue.Actor.CAPTAIN, "The tricky part is yer bet includes all the dice.")
		await display.say(Dialogue.Actor.CAPTAIN, "Even the ones ye don't know.")
		await display.say(Dialogue.Actor.CAPTAIN, "I might bet 5 dices rolled six.")
		#await display.say(Dialogue.Actor.CAPTAIN, "But, ye might reckon there only be 4.")
		await display.say(Dialogue.Actor.CAPTAIN, "But ye could call me a [shake rate=20.0 level=5 connected=1]LIAR![/shake]...")
		await display.say(Dialogue.Actor.CAPTAIN, "An' then we'll settle who's right.")
		await display.say(Dialogue.Actor.CAPTAIN, "The only catch[set speed=5]...")
		await display.say(Dialogue.Actor.CAPTAIN, "Ye must always bet a bigger value than the last player.")
		await display.say(Dialogue.Actor.CAPTAIN, "Or more dice than the last player.")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "And remember the [wave amp=20.0 freq=5.0 connected=1]Golden Rule[/wave].")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "[set speed=20]The Captain [set pause_time=0.7]always [set pause_time=0.7]wins.")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "[wave amp=20.0 freq=5.0 connected=1]Yo [set pause_time=0.4]ho [set pause_time=0.4]ho.[/wave]") # morew piratey life perchance?
		LiarsDice.ready_for_game_start.emit()
		return {},
	
	######################################1
	## PIRATE DIALOGUE
	######################################
	Id.PIRATE_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anton Roberts...");
		Progress.know_pirate_name = true
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Though most just called me Snarling Roberts. ");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Proud bo's'n aboard the Scourge of Port Royal...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Till its very end.");
		display.clear_speach()
		return {},
	
	Id.PIRATE_NAME_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I earned the name 'cause I kept me crew in line...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "With a tongue sharp as me blade.");
		Progress.know_pirate_name_backstory = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "When I met my fate, I was bound for Davy Jones's locker.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "But Captain Reaver beckoned me to join his crew."); 
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Gave me a second chance, he did.");
		Progress.know_pirate_recruitment = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I wish I could say nobly. But our crew fell for greed.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "We was around Bellaforma, after some booty."); # do we wanna stick with Bellaforma as the island?
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anchored down, and I, among a few, was left to the ship.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I hear call from above deck...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "A little boat from the lee side o' the island, guns a blazing."); 
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_3: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Nay. In the Quarters I was.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "A ruckus came from above,");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "And the stench of gunpowder filled the air.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Suddenly came footsteps...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Then a searing pain in my back...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "And a glint o' a golden cutlass through my guts."); # glint, glimmer, flash or shine
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Wasn't much of a battle,");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "More an unfortuante turn o'events.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I Never laid eyes on the freebooter who sent me to my watery grave.");
		Progress.know_pirate_death = true
		Progress.know_pirate_death = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_NOW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Feels not much like a pirate life, if ye ask me.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "We be stuck on this cursed shore...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "no treasure or glory to claim.");
		display.clear_speach()
		return {},
	
	Id.PIRATE_SECRET_FAIL: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		if LiarsDice.Player.PIRATE_RIGHT in LiarsDice.alive_players:
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Nay...");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "And I wont reveal any tricks around certain company neither...");
		else:
			await Dialogue.play(Id.PIRATE_SECRET).finished
		display.clear_speach()
		return {},
	
	Id.PIRATE_SECRET: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Just between us...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "My dice aren't as random as yers.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I don't be takin' chances no more.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Keep me flintlock close too, should trouble stir.");
		display.clear_speach()
		Progress.know_pirate_secret = true
		return {},
	
	Id.PIRATE_REVEAL: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		var dialogue_result := {}
		Dialogue.is_betting_locked = true
		await display.say(Dialogue.Actor.PIRATE_LEFT, "And what makes ye say that matey?");
		if Progress.know_pirate_death:
			var result := await display.push_options([OptionSet.new(Dialogue.Actor.PIRATE_LEFT, ["He has a golden cutlass."])])
			await display.say(Dialogue.Actor.PIRATE_LEFT, "A golden cutlass[set speed=3]...");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "That true Shaw? Are ye the one?");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "The coward who stormed an anchored boat...");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "And drove a blade in me back?");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "That puney crew... nay... they couldn't.");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Let me see yer sword, Elias.");
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "I don't know what this swab be blabberin' 'bout.");
			LiarsDice.physical.pirate_gun.state = Gun.State.DRAWN
			await display.say(Dialogue.Actor.PIRATE_LEFT, "DRAW YER SWORD NOW, YE SCURVY DOG!");
			await display.say(Dialogue.Actor.PIRATE_RIGHT, "Let's just calm down 'ere for a second.");
			LiarsDice.physical.pirate_shoot()
			LiarsDice.kill_npc(LiarsDice.Player.PIRATE_RIGHT)
			await display.get_tree().create_timer(1.0).timeout
			await display.say(Dialogue.Actor.CAPTAIN, "AVAST");
			LiarsDice.physical.pirate_gun.state = Gun.State.ON_TABLE
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Sorry cap'n...");
			await display.say(Dialogue.Actor.CAPTAIN, "If I cant trust ye to not cause a fuss...");
			await display.say(Dialogue.Actor.CAPTAIN, "I'll be finishin' this meself, then.");
			await display.say(Dialogue.Actor.CAPTAIN, "OFF WITH YE!");
			LiarsDice.kill_npc(LiarsDice.Player.PIRATE_LEFT)
			dialogue_result.start_new_round = true
		else:
			Dialogue.is_betting_locked = false
			await display.push_options([OptionSet.new(Dialogue.Actor.PIRATE_LEFT, ["... trust me."])])
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Ye be needin' more proof than that, me heartie.")
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Yer just tryna district me from the game, ain't ye?")
		
		display.clear_speach()
		return dialogue_result,

	######################################
	## NAVY DIALOGUE
	######################################
	Id.NAVY_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Me name be Elias Shaw.");
		Progress.know_navy_name = true
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "A hand aboard The Skipping Hen.");
		display.clear_speach()
		return {},
	
	Id.NAVY_NOW_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Nay, I be sturdy as an anchor."); # not sure about this
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "It just be me roguish complexion that curses me now.");
		display.clear_speach()
		return {},
	
	Id.NAVY_NOW_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Aye, we are... but not what we once were. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "We be bound by this cursed shore. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Thanks to Captin Reaver, we live...");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But not truly.");
		display.clear_speach()
		return {},
	
	Id.NAVY_SHIP: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "The Skipping Hen was a small ship, only 30 of us,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "She was s'pose to be quick and unpredictable...");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Wasn't much of a ship in the end, barely held together. ");
		display.clear_speach()
		return {},
	
	Id.NAVY_SHIP_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Yar. The Skipping Hen... sunk in her second battle she was.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Not even a week after I joined the crew. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But we didn't go down without a fight.");
		Progress.know_navy_ship = true
		display.clear_speach()
		return {},
	
	Id.NAVY_EVENT_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Me ship was sunk by the navy... ironic for me.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "We didn't stand a chance.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Already pushed our luck in her first scuffle.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "So rightfully, I met me end in the sea's embrace."); 
		Progress.know_navy_sink = true
		display.clear_speach()
		return {},
	
	Id.NAVY_IS_NAVY: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Arr, I sailed under the Royal Navy's flag.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But I found it too constricting,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "For a man of ambition like me.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "That is, they caught wind o' the rum I'd nicked from 'em.");
		Progress.know_navy_is_navy = true
		display.clear_speach()
		return {},
	
	Id.NAVY_SECRET_FAIL: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I will say it was an infamous crew we plundered. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Caught them offguard.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But I ain't gonna speak to who we sunk... ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Some things are better left unsaid around certain company.");
		display.clear_speach()
		return {},
	
	Id.NAVY_SECRET: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Aye, fortunate buccaneers we were.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Ah our maiden voyage... ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "We spotted an anchored boat abouts Bellaforma...");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Thrice the size o' our ship,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But with half their crew marooned on some wretched isle.");
		display.clear_speach()
		return {},
	
	Id.NAVY_SECRET_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I boarded an' took 3 men myself,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Plunged me golden cutlass right through one of them's back.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Yarr, we really sent the Scourge o' Port Royal to the depths.");
		Progress.know_navy_secret = true
		display.clear_speach()
		return {},
	

	######################################
	## CAPTAIN DIALOGUE
	######################################
	Id.CAPTAIN_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The name's Captain James Reaver.");
		await display.say(Dialogue.Actor.CAPTAIN, "Glad to have a new swashbuckler at the table.");
		Progress.know_captain_name = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_KNOW_SECRET: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The question be whether I'm willin' to share it, matey.");
		await display.say(Dialogue.Actor.CAPTAIN, "Let's let such such matters rest 'til after our game");
		await display.say(Dialogue.Actor.CAPTAIN, "Okay?");
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHIP: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The Siren's Wake... arr, she were a legend.");
		await display.say(Dialogue.Actor.CAPTAIN, "A ship feared 'cross all the seas. ");
		await display.say(Dialogue.Actor.CAPTAIN, "Nearly 200 men strong...");
		await display.say(Dialogue.Actor.CAPTAIN, "Cut through the water like a blade through flesh.");
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHIP_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I captained The Siren's Wake from the very start.");
		await display.say(Dialogue.Actor.CAPTAIN, "In her swan song, I took a deal,");
		await display.say(Dialogue.Actor.CAPTAIN, "I gave me life to keep her wreck and a fine crew.");
		Progress.know_captain_ship = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_CREW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The rest o' my crew be here,");
		await display.say(Dialogue.Actor.CAPTAIN, "Same as us, roaming these decks.");
		await display.say(Dialogue.Actor.CAPTAIN, "These two scallywags joined me to pass the time.");
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_NOW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I wouldn't call it a curse.");
		await display.say(Dialogue.Actor.CAPTAIN, "Me ship's me home again.");
		await display.say(Dialogue.Actor.CAPTAIN, "An' any pirate who meets reaches the ocean floor,"); 
		await display.say(Dialogue.Actor.CAPTAIN, "May find a place among me crew."); 
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_REVEAL: func(args: Dictionary) -> Dictionary:
		
		await display.say(Dialogue.Actor.CAPTAIN, "Victory be mine again.")
		await display.say(Dialogue.Actor.CAPTAIN, "I s'pose there ain't no need fer the ruse.")
		await display.say(Dialogue.Actor.CAPTAIN, "I be sendin ye back to play again.")
		await display.say(Dialogue.Actor.CAPTAIN, "Every time ye 'die', a bit more wind fills me sails.")
		await display.say(Dialogue.Actor.CAPTAIN, "So a few extra rounds don't hurt.")
		await display.say(Dialogue.Actor.CAPTAIN, "An' I must confess...")
		await display.say(Dialogue.Actor.CAPTAIN, "There be no secret to eternal life fer the likes o' ye.")
		await display.say(Dialogue.Actor.CAPTAIN, "Pretty soon ye'll be like the rest of us.")
		await display.say(Dialogue.Actor.CAPTAIN, "The only thing immortal be yer service to this crew.") # calls into question validity of other crewmates free will?
		
		Progress.know_captain_secret = true
		
		return {},
	
	#####################################################
	
	
	
	Id.LIAR: func(args: Dictionary) -> Dictionary:
		await Dialogue.get_tree().create_timer(0.1).timeout
		return { "called": true },
	
	Id.PASS: func(args: Dictionary) -> Dictionary:
		await Dialogue.get_tree().create_timer(0.1).timeout
		return { "called": false },
}


func _init(p_id: Id, p_display: DialogueDisplay, p_args := {}) -> void:
	display = p_display
	my_id = p_id
	arguments = p_args


func play() -> void:
	assert(not is_playing)
	is_playing = true
	var result : Dictionary = await dialogues[my_id].call(arguments)
	Dialogue.mark_completed(my_id)
	finished.emit(result)
	call_deferred("free")


func end() -> void:
	finished.emit({})
	call_deferred("free")



func get_npc_dialogue_options(actor: Dialogue.Actor, is_better: bool) -> Array[Id]:
	var result : Array[Id] = []
	if is_better:
		result.append(Id.LIAR)
	
	var possible_options : Array = {
		Dialogue.Actor.PIRATE_LEFT: 	[Id.PIRATE_NAME, Id.PIRATE_NAME_2, Id.PIRATE_DEATH_1, Id.PIRATE_DEATH_2, Id.PIRATE_DEATH_3, Id.PIRATE_NOW, Id.PIRATE_SECRET_FAIL, Id.PIRATE_SECRET, Id.PIRATE_REVEAL],
		Dialogue.Actor.PIRATE_RIGHT: 	[Id.NAVY_NAME, Id.NAVY_NOW_1, Id.NAVY_NOW_2, Id.NAVY_SHIP, Id.NAVY_SHIP_2, Id.NAVY_EVENT_1, Id.NAVY_IS_NAVY, Id.NAVY_SECRET_FAIL, Id.NAVY_SECRET, Id.NAVY_SECRET_2,],
		Dialogue.Actor.CAPTAIN: 		[Id.CAPTAIN_NAME, Id.CAPTAIN_KNOW_SECRET, Id.CAPTAIN_SHIP, Id.CAPTAIN_SHIP_2, Id.CAPTAIN_CREW, Id.CAPTAIN_NOW,],
	}[actor]
	
	for id: Id in possible_options:
		if can_give_option(id):
			result.append(id)

	if result.size() <= 1 and is_better:
		result.append(Id.PASS)
	
	result.resize(min(result.size(), Dialogue.MAX_OPTIONS))

	return result


func can_give_option(id: Id) -> bool:
	if Dialogue.is_completed(id):
		return false
	
	match id:
		Id.PIRATE_NAME: 		return not Progress.know_pirate_name
		Id.PIRATE_NAME_2: 		return not Progress.know_pirate_name_backstory and Dialogue.is_completed(Id.PIRATE_NAME)
		Id.PIRATE_DEATH_1: 		return not Progress.know_pirate_recruitment and Progress.know_pirate_name
		Id.PIRATE_DEATH_2: 		return Progress.know_pirate_recruitment
		Id.PIRATE_DEATH_3: 		return Dialogue.is_completed(Id.PIRATE_DEATH_2)
		Id.PIRATE_NOW: 			return	not Progress.know_pirate_now and Progress.know_pirate_recruitment
		Id.PIRATE_SECRET_FAIL: 	return	not Progress.know_pirate_secret and Progress.know_pirate_name and Progress.know_pirate_recruitment
		Id.PIRATE_SECRET: 		return	not Progress.know_pirate_secret and Progress.know_pirate_name and Progress.know_pirate_recruitment and LiarsDice.is_out(LiarsDice.Player.PIRATE_RIGHT)
		Id.PIRATE_REVEAL:		return  Progress.know_captain_secret and Progress.know_navy_secret and not LiarsDice.is_out(LiarsDice.Player.PIRATE_RIGHT)
		
		Id.NAVY_NAME: 			return	not Progress.know_navy_name
		Id.NAVY_NOW_1: 			return	not Progress.know_navy_now and Progress.know_navy_name
		Id.NAVY_NOW_2: 			return	not Progress.know_navy_now and Dialogue.is_completed(Id.NAVY_NOW_1)
		Id.NAVY_SHIP: 			return	not Progress.know_navy_ship and Progress.know_navy_name
		Id.NAVY_SHIP_2: 		return	not Progress.know_navy_ship and Dialogue.is_completed(Id.NAVY_SHIP)
		Id.NAVY_EVENT_1: 		return	not Progress.know_navy_sink and Progress.know_navy_ship
		Id.NAVY_IS_NAVY: 		return	not Progress.know_navy_is_navy and Progress.know_navy_sink
		Id.NAVY_SECRET_FAIL: 	return	Progress.know_navy_ship and not LiarsDice.is_out(LiarsDice.Player.PIRATE_LEFT)
		Id.NAVY_SECRET: 		return	Progress.know_navy_ship and LiarsDice.is_out(LiarsDice.Player.PIRATE_LEFT)
		Id.NAVY_SECRET_2: 		return	Dialogue.is_completed(Id.NAVY_SECRET)
		
		Id.CAPTAIN_NAME: 		return	not Progress.know_captain_secret and not Progress.know_captain_name
		Id.CAPTAIN_KNOW_SECRET: return	not Progress.know_captain_secret and not Progress.asked_captain_about_secret and Progress.know_captain_name
		Id.CAPTAIN_SHIP: 		return	not Progress.know_captain_secret and not Progress.know_captain_ship and Progress.know_captain_name
		Id.CAPTAIN_SHIP_2: 		return	not Progress.know_captain_secret and not Progress.know_captain_ship and Dialogue.is_completed(Id.CAPTAIN_SHIP)
		Id.CAPTAIN_CREW: 		return	not Progress.know_captain_secret and not Progress.know_captain_crew and Progress.know_captain_name
		Id.CAPTAIN_NOW: 		return	not Progress.know_captain_secret and not Progress.know_captain_now and Progress.know_captain_name
	return true


func get_dialogue_option_lead(id: Id) -> String:
	match id:
		Id.PIRATE_REVEAL:		return "Elias killed ye."
		Id.PIRATE_NAME: 		return "What be yer name?"
		Id.PIRATE_NAME_2: 		return "Why Snarling Roberts?"
		Id.PIRATE_DEATH_1: 		return "Do ye call this home?"
		Id.PIRATE_DEATH_2: 		return "How'd ye meet yer fate?"
		Id.PIRATE_DEATH_3: 		return "So ye died in battle?"
		Id.PIRATE_NOW: 			return "Is this a fine crew?"
		Id.PIRATE_SECRET_FAIL: 	return "Do ye have a tell?"
		Id.PIRATE_SECRET: 		return "So.. yer trick?"
		
		Id.NAVY_NAME: 			return "What shall I call ye?"
		Id.NAVY_NOW_1: 			return "Ye look sick"
		Id.NAVY_NOW_2: 			return "Ye still flesh n' bone?"
		Id.NAVY_SHIP: 			return "So, yer seafaring..."
		Id.NAVY_SHIP_2: 		return "Did ye sink?"
		Id.NAVY_EVENT_1: 		return "So how'd ye sink?"
		Id.NAVY_IS_NAVY: 		return "Ye be a Navy man?"
		Id.NAVY_SECRET_FAIL: 	return "So yer first battle?"
		Id.NAVY_SECRET: 		return "So... yer first clash."
		Id.NAVY_SECRET_2: 		return "Ye sunk a Galleon?" # this one is iffy
		
		Id.CAPTAIN_NAME: 		return "Ye be the Captain?"
		Id.CAPTAIN_KNOW_SECRET: return "So... the secret?"
		Id.CAPTAIN_SHIP: 		return "Tell me 'bout yer ship."
		Id.CAPTAIN_SHIP_2: 		return "How'd ye become captain?"
		Id.CAPTAIN_CREW: 		return "Is this yer whole crew?"
		Id.CAPTAIN_NOW: 		return "Are ye cursed?"
		
		Id.PASS: 				return "Pass"
		Id.LIAR:				return "LIAR!"
	
	assert(false, "Missing dialogue lead")
	return ""



class OptionSet:
	var actor : Dialogue.Actor
	var options : Array
	
	func _init(p_actor: Dialogue.Actor, p_options: Array) -> void:
		actor = p_actor
		assert(options.size() <= Dialogue.MAX_OPTIONS)
		options = p_options

class OptionResult:
	var actor : Dialogue.Actor
	var index : int
	
	func _init(p_actor: Dialogue.Actor, p_index: int) -> void:
		actor = p_actor
		index = p_index
