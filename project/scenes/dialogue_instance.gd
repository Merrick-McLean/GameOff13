class_name DialogueInstance
extends Object

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
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anyway what do you think lad? Is that cool or what?", false)
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
			1: await display.say(Dialogue.Actor.CAPTAIN, "Alright, let's get this game started.")
			2: await display.say(Dialogue.Actor.CAPTAIN, "Time for the next round.")
			3: await display.say(Dialogue.Actor.CAPTAIN, "Looks like its just you and me meighty.")
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
		await display.say(args.actor, Dialogue.get_bet_string(args.bet) + "? You're a liar!")
		display.clear_speach()
		return {},
	
	Id.NPC_LOSE_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "Well played lad.")
		display.clear_speach()
		return {},
	
	Id.NPC_WIN_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "I knew it. Goodbye lad.")
		display.clear_speach()
		return {},
	
	Id.QUERY_LIAR: func(args: Dictionary) -> Dictionary:
		var result := await display.push_options([OptionSet.new(args.actor, ["LIAR!", "Pass"])])
		display.clear_speach()
		return {"called": result.index == 0},
	
	Id.NPC_DEATH_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(args.actor, "It's time for me to go.")
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHOOTS: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I shoot you now.")
		display.clear_speach()
		return {},
	
	
	Id.DIALOGUE_PROMPT: func(args: Dictionary) -> Dictionary:
		var last_speaking_actor : Dialogue.Actor
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
			var result : Dictionary = await Dialogue.play(chosen_id).finished
		
		
		await display.say(last_speaking_actor, "But that's enough about me. Time to make your bet.")
		if args.bet.amount > 0:
			await display.say(last_speaking_actor, "Up the bid from " + Dialogue.get_bet_string(args.bet))
		display.clear_speach()
		
		return {},
	
	
	
	Id.INTRO_DIALOGUE: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "Ahoy, welcome aboard the graveyard of The Siren's Wake.") # why does this drop upon finishing?
		await display.say(Dialogue.Actor.CAPTAIN, "I expect ye traveled far to join us sorry souls.")
		await display.say(Dialogue.Actor.CAPTAIN, "What brings ye to me quarters?")
		await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["I seek an ancient secret.", "Immortality."])])
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Yar the secret to immoralitity?")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "The cap'n would know about that...")
		await display.say(Dialogue.Actor.CAPTAIN, "That's right, but I can't give it away for free.")
		await display.say(Dialogue.Actor.CAPTAIN, "How about we settle this with a game.")
		await display.say(Dialogue.Actor.CAPTAIN, "If you can defeat all three of us in Liars Dice.")
		await display.say(Dialogue.Actor.CAPTAIN, "Then I'll tell ye the secret.")
		await display.say(Dialogue.Actor.CAPTAIN, "If ye lose however...")
		await display.say(Dialogue.Actor.CAPTAIN, "Ye pay with yer life.")
		await display.say(Dialogue.Actor.CAPTAIN, "Deal?")
		await display.push_options([OptionSet.new(Dialogue.Actor.CAPTAIN, ["Deal", "Aye"])])
		display.clear_speach()
		GameMaster.flash_lightning()
		await Dialogue.play(Id.INTRO_DIALOGUE_2).finished
		return {},
	
	Id.INTRO_DIALOGUE_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await Dialogue.get_tree().create_timer(2.0).timeout
		await display.say(Dialogue.Actor.CAPTAIN, "Aye, matey.")
		await display.say(Dialogue.Actor.CAPTAIN, "Do ye remember how to play Liars Dice?")
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
	
	Id.GAME_INSTRUCTIONS: func(args: Dictionary) -> Dictionary: #TODO MANAGE OR SHORTEN THESE FOR SCREEN
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "Blimey, I don't know a Buccaneer or a Corsair who don't.")
		await display.say(Dialogue.Actor.CAPTAIN, "Not to worry.")
		LiarsDice.start_new_game(true)
		await display.say(Dialogue.Actor.CAPTAIN, "We each have 5 dice to our name.")
		await display.say(Dialogue.Actor.CAPTAIN, "But ye only know the values of yer own dice.")
		await display.say(Dialogue.Actor.CAPTAIN, "On ye turn, make a bet")
		await display.say(Dialogue.Actor.CAPTAIN, "And tell us how many dice you think share one side.")
		await display.say(Dialogue.Actor.CAPTAIN, "The tricky part is yer bet includes all the dice.")
		await display.say(Dialogue.Actor.CAPTAIN, "Even the ones you don't know.")
		await display.say(Dialogue.Actor.CAPTAIN, "I might claim there be 5 dice showin' sixes.")
		await display.say(Dialogue.Actor.CAPTAIN, "But, a sharp-witted scallywag might reckon there only be 4.")
		await display.say(Dialogue.Actor.CAPTAIN, "He could call [shake rate=20.0 level=5 connected=1]LIAR![/shake]...")
		await display.say(Dialogue.Actor.CAPTAIN, "an' we'll settle who's right.")
		await display.say(Dialogue.Actor.CAPTAIN, "The only catch[set speed=5]...") # rephrase?
		await display.say(Dialogue.Actor.CAPTAIN, "Ye must bet more or bigger than the last Swashbuckler.")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "And remember the [wave amp=20.0 freq=5.0 connected=1]Golden Rule[/wave].")
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "[set speed=20]The Captain [set pause_time=0.7]always [set pause_time=0.7]wins.")
		await display.say(Dialogue.Actor.PIRATE_LEFT, "[wave amp=20.0 freq=5.0 connected=1]Heh [set pause_time=0.4]heh [set pause_time=0.4]heh.[/wave]")
		LiarsDice.ready_for_game_start.emit()
		return {},
	
	######################################1
	## PIRATE DIALOGUE
	######################################
	Id.PIRATE_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anton Roberts...");
		Progress.know_pirate_name = true
		await display.say(Dialogue.Actor.PIRATE_LEFT, "though most just called me Snarling Roberts. ");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Proud bo's'n aboard the Scourge of Port Royal...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "till its very end.");
		display.clear_speach()
		return {},
	
	Id.PIRATE_NAME_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I earned the name 'cause I kept me crew in line ");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "with a tongue sharp as me blade.");
		Progress.know_pirate_name_backstory = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "When I went to the depths, ");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Captain Skinner offered me to join his crew. ");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Gave me a second chance, he did.");
		Progress.know_pirate_recruitment = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I wish I could say nobly. But our crew fell for greed.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "We was around Bellaforma, after some booty.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Anchored down, and I, among a few, was left to the ship.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I hear call from above deck...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "a little boat from the lee side o' the island, guns a blazing.");
		display.clear_speach()
		return {},
	
	Id.PIRATE_DEATH_3: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Nay. In the Quarters I was.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Suddenly came footsteps, then the smell of gunpowder...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "the flash o' a golden gun...");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "and a searing pain in my back.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Wasn't much of a battle,");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "more an unfortuante turn o'events.");
		Progress.know_pirate_death = true
		display.clear_speach()
		return {},
	
	Id.PIRATE_NOW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Feels not much like a pirate life, if ye ask me.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "We be stuck on this cursed shore... ");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "no treasure or glory to claim.");
		display.clear_speach()
		return {},
	
	Id.PIRATE_SECRET_FAIL: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		if LiarsDice.Player.PIRATE_RIGHT in LiarsDice.alive_players:
			await display.say(Dialogue.Actor.PIRATE_LEFT, "Nay...");
			await display.say(Dialogue.Actor.PIRATE_LEFT, "and I wont reveal any tricks around certain company neither...");
		else:
			await Dialogue.play(Id.PIRATE_SECRET).finished
		display.clear_speach()
		return {},
	
	Id.PIRATE_SECRET: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_LEFT, "Just between us, my dice aren't as random as yours.");
		await display.say(Dialogue.Actor.PIRATE_LEFT, "I don't be takin' chances no more.");
		display.clear_speach()
		return {},
	

	######################################
	## NAVY DIALOGUE
	######################################
	Id.NAVY_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Me name be Elias Shaw.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "A hand aboard The Skipping Hen.");
		Progress.know_navy_name = true
		display.clear_speach()
		return {},
	
	Id.NAVY_NOW_1: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I'm as sharp as a cutlass");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "It just be the roguish complexion that curses me now.");
		display.clear_speach()
		return {},
	
	Id.NAVY_NOW_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Aye, we are... but not what we once were. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "We be bound by this cursed shore. ");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Thanks to Captin Reaver, we live... but not truly.");
		display.clear_speach()
		return {},
	
	Id.NAVY_SHIP: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "The Skipping Hen was a small ship, only 30 of us,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "she was s'pose to be quick and unpredictable...");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "wasn't much of a ship, barely held together. ");
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
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "We already pushed our luck in her first scuffle.");
		Progress.know_navy_sink = true
		display.clear_speach()
		return {},
	
	Id.NAVY_IS_NAVY: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Arr, I sailed under the Royal Navy's flag.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "But I found it too constricting,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "for a man of ambition like me.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "They caught wind o' the rum I'd nicked from 'em.");
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
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "The Scourge o' Port Royal");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Thrice the size o' our ship...");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "but with half their crew marooned on some wretched isle");
		display.clear_speach()
		return {},
	
	Id.NAVY_SECRET_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "I boarded an' took 3 men myself,");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "One of' em be Snarling Roberts.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Got em right in the back with my golden gun.");
		await display.say(Dialogue.Actor.PIRATE_RIGHT, "Funny that I now be playin dice with him in the Afterlife");
		Progress.know_navy_secret = true
		display.clear_speach()
		return {},
	

	######################################
	## CAPTAIN DIALOGUE
	######################################
	Id.CAPTAIN_NAME: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The name's Captain James Reaver.");
		await display.say(Dialogue.Actor.CAPTAIN, "Glad to have a new sea dog at the table.");
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
		await display.say(Dialogue.Actor.CAPTAIN, "cut through the water like a blade through flesh.");
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_SHIP_2: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I captained The Siren's Wake from the very start.");
		await display.say(Dialogue.Actor.CAPTAIN, "In her swan song, I took a deal,");
		await display.say(Dialogue.Actor.CAPTAIN, "I gave me life for this fine wreck and a crew.");
		Progress.know_captain_ship = true
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_CREW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "The rest o' my crew be here,");
		await display.say(Dialogue.Actor.CAPTAIN, "same as us, roaming these decks.");
		await display.say(Dialogue.Actor.CAPTAIN, "These two scallywags joined me to pass the time.");
		display.clear_speach()
		return {},
	
	Id.CAPTAIN_NOW: func(args: Dictionary) -> Dictionary:
		display.clear_options()
		await display.say(Dialogue.Actor.CAPTAIN, "I wouldn't call it a curse.");
		await display.say(Dialogue.Actor.CAPTAIN, "I get to stay with me ship once again.");
		await display.say(Dialogue.Actor.CAPTAIN, "Any pirate who meets a watery grave may join me crew.");
		display.clear_speach()
		return {},
	
	
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
		Dialogue.Actor.PIRATE_LEFT: 	[Id.PIRATE_NAME, Id.PIRATE_NAME_2, Id.PIRATE_DEATH_1, Id.PIRATE_DEATH_2, Id.PIRATE_DEATH_3, Id.PIRATE_NOW, Id.PIRATE_SECRET_FAIL, Id.PIRATE_SECRET,],
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
		Id.PIRATE_SECRET_FAIL: 	return	Progress.know_pirate_name and Progress.know_pirate_recruitment
		Id.PIRATE_SECRET: 		return	Progress.know_pirate_name and Progress.know_pirate_recruitment and LiarsDice.is_out(LiarsDice.Player.PIRATE_RIGHT)
		
		Id.NAVY_NAME: 			return	not Progress.know_navy_name
		Id.NAVY_NOW_1: 			return	not Progress.know_navy_now and Progress.know_navy_name
		Id.NAVY_NOW_2: 			return	not Progress.know_navy_now and Dialogue.is_completed(Id.NAVY_NOW_1)
		Id.NAVY_SHIP: 			return	not Progress.know_navy_ship and Progress.know_navy_name
		Id.NAVY_SHIP_2: 		return	not Progress.know_navy_ship and Dialogue.is_completed(Id.NAVY_SHIP)
		Id.NAVY_EVENT_1: 		return	not Progress.know_navy_sink and Progress.know_navy_ship
		Id.NAVY_IS_NAVY: 		return	not Progress.know_navy_is_navy and Progress.know_navy_sink
		Id.NAVY_SECRET_FAIL: 	return	Progress.know_navy_ship
		Id.NAVY_SECRET: 		return	Progress.know_navy_ship and LiarsDice.is_out(LiarsDice.Player.PIRATE_LEFT)
		Id.NAVY_SECRET_2: 		return	Dialogue.is_completed(Id.NAVY_SECRET)
		
		Id.CAPTAIN_NAME: 		return	not Progress.know_captain_name
		Id.CAPTAIN_KNOW_SECRET: return	not Progress.asked_captain_about_secret and Progress.know_captain_name
		Id.CAPTAIN_SHIP: 		return	not Progress.know_captain_ship and Progress.know_captain_name
		Id.CAPTAIN_SHIP_2: 		return	not Progress.know_captain_ship and Dialogue.is_completed(Id.CAPTAIN_SHIP)
		Id.CAPTAIN_CREW: 		return	not Progress.know_captain_crew and Progress.know_captain_name
		Id.CAPTAIN_NOW: 		return	not Progress.know_captain_now and Progress.know_captain_name
	return true


func get_dialogue_option_lead(id: Id) -> String:
	match id:
		Id.PIRATE_NAME: 		return "What be yer name?"
		Id.PIRATE_NAME_2: 		return "Why Snarling Roberts?"
		Id.PIRATE_DEATH_1: 		return "Do ye call this home?"
		Id.PIRATE_DEATH_2: 		return "How'd ye die?"
		Id.PIRATE_DEATH_3: 		return "So ye died in battle?"
		Id.PIRATE_NOW: 			return "Is this a fine crew?"
		Id.PIRATE_SECRET_FAIL: 	return "Do ye have a tell?"
		Id.PIRATE_SECRET: 		return "So.. your trick?"
		
		Id.NAVY_NAME: 			return "What shall I call ye?"
		Id.NAVY_NOW_1: 			return "Ye look sick"
		Id.NAVY_NOW_2: 			return "Ye still flesh n' bone?"
		Id.NAVY_SHIP: 			return "So, yer seafaring..."
		Id.NAVY_SHIP_2: 		return "Did ya sink?"
		Id.NAVY_EVENT_1: 		return "So how'd ye sink?"
		Id.NAVY_IS_NAVY: 		return "Ye be a Navy boy?"
		Id.NAVY_SECRET_FAIL: 	return "So yer first battle?"
		Id.NAVY_SECRET: 		return "So... your first clash."
		Id.NAVY_SECRET_2: 		return "Ye sunk Port Royal?"
		
		Id.CAPTAIN_NAME: 		return "Ye be the Captain?"
		Id.CAPTAIN_KNOW_SECRET: return "Do ye know the secret?"
		Id.CAPTAIN_SHIP: 		return "Tell me bout yer ship."
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
