function run(args) {
	var name = "";
	var artist = "";
	var album = "";
	
	if (applicationIsOpen("iTunes")) {
		var iTunes = Application("iTunes");
		if (iTunes.playerState() === "playing") {
			name = iTunes.currentTrack().name();
			artist = iTunes.currentTrack().artist();
			album = iTunes.currentTrack().album();
		}
	}
	
	if (applicationIsOpen("VLC")) {
		var VLC = Application("VLC");
		if (VLC.playing() === true) {
			var info = VLC.nameOfCurrentItem().split(" - ");
			name = info[1];
			artist = info[0];
			album = "";
		}
	}
	
	switch (args[0]) {
		case "name":
			return name;
		case "artist":
			return artist;
		case "album":
			return album;
	}
}

function applicationIsOpen(name) {
	return Application("System Events").processes.whose({name: name}).length > 0;
}