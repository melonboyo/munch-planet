extends Node

var moods := {
	Constants.Mood.Sad : "Sad",
	Constants.Mood.Happy : "Happy",
	Constants.Mood.Angry : "Angry",
	Constants.Mood.Bored : "Bored",
}


var shadow_atlas_size := {
	Constants.Graphics.Low : 2048,
	Constants.Graphics.Medium : 4096,
	Constants.Graphics.High : 8192,
}


var msaa := {
	Constants.Graphics.Low : 0,
	Constants.Graphics.Medium : 1,
	Constants.Graphics.High : 2,
}

var ssao_and_ssil := {
	Constants.Graphics.Low : 1,
	Constants.Graphics.Medium : 2,
	Constants.Graphics.High : 3,
}
