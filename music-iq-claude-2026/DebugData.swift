
import Foundation

// Debug-only content imported from music_iq_questions_for_insert_with_type_and_active.json.
// Not for production use -- the real app will pull quiz content from S3.
// Skipped at import time (Correct_Answer did not exactly match any option): drum-disco-20394

/// Flip to true to have HomeView show the imported debug question set instead of the
/// hardcoded sample sets. Temporary until quiz content is pulled from S3.
enum DebugConfig {
    static let useDebugQuestionSets = true
}

extension QuizSet {
    static let debugSets: [QuizSet] = [
        debugKnowledgeEasySet, debugKnowledgeMediumSet, debugKnowledgeHardSet, debugAudioLineupSet
    ]

    static var activeSets: [QuizSet] {
        DebugConfig.useDebugQuestionSets ? debugSets : sampleSets
    }

    static let debugKnowledgeEasySet = QuizSet(
        name: "Music Knowledge (Debug - Easy)", category: .other, clips: [
            Clip(name: "This drum track is played in the style o", fileName: "7885556.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This drum track is played in the style of which drummer?",
                    options: ["Phil Collins", "Gene Krupa", "Keith Moon", "John Bonham"], correctIndex: 3)),
            Clip(name: "The drums used in this clip are an examp", fileName: "298652.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "The drums used in this clip are an example of which type?",
                    options: ["Electronic Drums", "Acoustic Drums", "Conga Drums", "Hand Drums"], correctIndex: 0)),
            Clip(name: "This type of agressive guitar part would", fileName: "1000065696.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This type of agressive guitar part would likely be heard in which style of music?",
                    options: ["Blues", "Grunge", "Heavy Metal", "Jazz"], correctIndex: 2)),
            Clip(name: "This musical mode is a synomyn for a maj", fileName: "420.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This musical mode is a synomyn for a major scale and is formed from the first degree of the major scale. What is its name?",
                    options: ["Ionian", "Minor Blues", "Chromatic", "Minor Pentatonic"], correctIndex: 0)),
            Clip(name: "The drum beat featured in this clip is c", fileName: "2003363.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "The drum beat featured in this clip is common to which style of music?",
                    options: ["Bluegrass", "Folk", "Disco", "Jazz"], correctIndex: 2)),
            Clip(name: "What is the interval heard in this sould", fileName: "1230000.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval heard in this sould clip?",
                    options: ["Minor Third", "Major Third", "Tritone", "Octave"], correctIndex: 3)),
            Clip(name: "This an example of what?", fileName: "100002086.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This an example of what?",
                    options: ["Two-Handed Tapping", "Pick Slides", "Sweep Picking", "Pinch Harmonics"], correctIndex: 1)),
            Clip(name: "What is the name of this percussion inst", fileName: "10000656799.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this percussion instrument?",
                    options: ["Conga", "Cowbell", "Triangle", "Pan Flute"], correctIndex: 1)),
            Clip(name: "Who is the composer of this composition?", fileName: "50065599650.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "Who is the composer of this composition?",
                    options: ["George Gershwin", "J.S. Bach", "Paul Simon", "Cole Porter"], correctIndex: 1)),
            Clip(name: "What is the correct tempo marking of thi", fileName: "75030.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the correct tempo marking of this composition?",
                    options: ["Free time", "Common time", "Waltz time", "Double time"], correctIndex: 0)),
            Clip(name: "What is the tonality of this scale?", fileName: "30000.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the tonality of this scale?",
                    options: ["Minor", "Pentatonic", "Major", "Natural Minor"], correctIndex: 2)),
            Clip(name: "What is the name of the instrument featr", fileName: "5669965.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument featrued in this sound clip?",
                    options: ["Piano", "Pipe Organ", "Electric Piano", "Harpsichord"], correctIndex: 1)),
            Clip(name: "This is an effect that is commonly used ", fileName: "2.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This is an effect that is commonly used on an electric guitar and was incorporated into eary guitar amplifiers.",
                    options: ["Tremolo", "Flanger", "Wah Wah", "Delay"], correctIndex: 0)),
            Clip(name: "What is the name of the instrument featu", fileName: "2569650.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument featured in this clip?",
                    options: ["Banjo", "Flute", "Nylon String Guitar", "Trumpet"], correctIndex: 2)),
            Clip(name: "This sound clip is an example of what ty", fileName: "1255.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of what type of musical interval?",
                    options: ["Consonant", "Dissonant", "Whole", "Half"], correctIndex: 1)),
            Clip(name: "This is an example of what?", fileName: "1290.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This is an example of what?",
                    options: ["Arpeggio", "Major Scale", "Rudiment", "Guitar"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of what ty", fileName: "1250.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of what type of musical interval?",
                    options: ["Consonant", "Dissonant", "Sharp", "Flat"], correctIndex: 0)),
            Clip(name: "What is the time signature of this track", fileName: "693254.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this track?",
                    options: ["4/4", "6/8", "3/4", "7/5"], correctIndex: 0)),
            Clip(name: "This type of guitar part would most like", fileName: "56536565.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This type of guitar part would most likely be found in which style of music?",
                    options: ["Heavy Metal", "Jazz", "Classical", "Funk"], correctIndex: 3)),
            Clip(name: "This J.S. Bach composition is being perf", fileName: "566996551.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This J.S. Bach composition is being performed on which of the following instruments?",
                    options: ["Harp", "Piano", "Electric Piano", "Harpsichord"], correctIndex: 3)),
            Clip(name: "In this soundclip of J.S. Bachs Jesu, Jo", fileName: "256965155.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "In this soundclip of J.S. Bachs Jesu, Joy of Mans Desiring what instrument is being featured?",
                    options: ["Piano", "Harpsichord", "Clavinet", "Harp"], correctIndex: 0)),
            Clip(name: "What is the name of this instrument?", fileName: "500005.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this instrument?",
                    options: ["Flute", "Harmonica", "Recorder", "Picollo"], correctIndex: 1)),
            Clip(name: "What is the name of the instrument that ", fileName: "100006566650.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument that is played on beats 3-&-4 of this track?",
                    options: ["Cowbell", "Triangle", "Tambourine", "Cymbal"], correctIndex: 2)),
            Clip(name: "This is an example of which instrument?", fileName: "565387.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This is an example of which instrument?",
                    options: ["Mandolin", "Piano", "Cello", "Electric Bass Guitar"], correctIndex: 3)),
            Clip(name: "This sound clip is an example of what co", fileName: "86582214.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of what common chord progression?",
                    options: ["1-5-4", "1-4-3", "1-4-5", "6-2-1"], correctIndex: 2)),
            Clip(name: "Identify the type of scale played in thi", fileName: "968475.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "Identify the type of scale played in this track.",
                    options: ["Natural Minor Scale", "Major Scale", "Harmonic Minor Scale", "Minor Pentatonic Scale"], correctIndex: 1)),
            Clip(name: "What is the name of this instrument?", fileName: "9685632.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this instrument?",
                    options: ["Hi Hat", "Cymbal", "Cowbell", "Tambourine"], correctIndex: 1)),
            Clip(name: "This sound clip is an example of which t", fileName: "1288.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which type of arpeggio?",
                    options: ["Minor Arpeggio", "Major Chord", "Major Arpeggio", "Pentatonic Scale"], correctIndex: 2)),
            Clip(name: "This track is an example of what style o", fileName: "94494949.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This track is an example of what style of bass playing?",
                    options: ["Blues Rock Guitar", "Funk Bass", "Heavy Metal Guitar", "Neo-Classical Guitar"], correctIndex: 1)),
            Clip(name: "This Chopin composition was written in w", fileName: "50004075.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This Chopin composition was written in which musical era?",
                    options: ["20th Century Classical", "Baroque", "Romantic", "Medieval"], correctIndex: 2)),
            Clip(name: "This musical excerpt is an example of wh", fileName: "5000135.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This musical excerpt is an example of which of the following?",
                    options: ["Chord", "Scale", "Harmony", "Octave"], correctIndex: 1)),
            Clip(name: "What is the name of instrument featured ", fileName: "986556.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of instrument featured in this sound clip?",
                    options: ["Cello", "Acoustic Guitar", "Electric Guitar", "Flute"], correctIndex: 1)),
            Clip(name: "Which type of piano technique is employe", fileName: "500045.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "Which type of piano technique is employed in this sound clip?",
                    options: ["Stride Piano", "Allegro", "Octaves", "Stride Organ"], correctIndex: 0)),
            Clip(name: "This is an example of what style of drum", fileName: "2656325.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This is an example of what style of drum beat?",
                    options: ["Samba", "One Drop", "Hip Hop", "Latin"], correctIndex: 2)),
            Clip(name: "What is the name of the instrument featu", fileName: "256965.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument featured in this clip?",
                    options: ["Ukulele", "Mandolin", "Banjo", "Guitar"], correctIndex: 1)),
            Clip(name: "This musical excerpt is an example of wh", fileName: "566996568.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This musical excerpt is an example of which type of minor scale?",
                    options: ["Major", "Chromatic", "Minor Blues", "Major Pentatonic"], correctIndex: 2)),
            Clip(name: "What is the name of the instrument featu", fileName: "63252.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument featured in this sound clip?",
                    options: ["Guitar", "Sitar", "Banjo", "Ukelee"], correctIndex: 1)),
            Clip(name: "What is the title of this composition?", fileName: "75000.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the title of this composition?",
                    options: ["Minuet in G", "Pavane", "Clair de Lune", "Lullaby"], correctIndex: 0)),
            Clip(name: "What style of guitar picking is being us", fileName: "26356635.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What style of guitar picking is being used in this track?",
                    options: ["Flatpicking", "Fingerpicking", "Travis Picking", "Strumming"], correctIndex: 1)),
            Clip(name: "What is the time signature of this clip?", fileName: "84632525.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this clip?",
                    options: ["4/4", "6/8", "7/5", "3/4"], correctIndex: 0)),
            Clip(name: "This instrument is used to help sub-divi", fileName: "9633252.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This instrument is used to help sub-divide musical time on a drum kit.",
                    options: ["Hi-hat", "Ride Cymbal", "Splash Cymbal", "China Cymbal"], correctIndex: 0)),
            Clip(name: "What is the name of the drum featured in", fileName: "900000.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the drum featured in this clip?",
                    options: ["Bass Drum", "Snare Drum", "Floor Tom", "Tom Tom"], correctIndex: 0)),
            Clip(name: "What is the name of the drum featured in", fileName: "90000099.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the drum featured in this clip?",
                    options: ["Bass Drum", "Snare Drum", "Conga Drum", "Tom Tom"], correctIndex: 3)),
            Clip(name: "What is the name of the instrument featu", fileName: "896586.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument featured in this clip?",
                    options: ["Acoustic Guitar", "Electric Guitar", "Organ", "Harmonica"], correctIndex: 1)),
            Clip(name: "What is the interval between each of the", fileName: "1235.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval between each of the notes in this sequence?",
                    options: ["Fifth", "Third", "Root", "Symphony"], correctIndex: 1)),
            Clip(name: "What is the name of this instrument?", fileName: "96855365.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this instrument?",
                    options: ["Xzylophone", "Vibes", "Wind Chimes", "Glockenspiel"], correctIndex: 0)),
            Clip(name: "Which term best decribes the type of pia", fileName: "5000405.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "Which term best decribes the type of piano composition heard in this track?",
                    options: ["Boogie-Woogie", "Minuet", "Waltz", "Canon"], correctIndex: 0)),
            Clip(name: "This J.S. Bach composition is being play", fileName: "25696557.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This J.S. Bach composition is being played on which instrument?",
                    options: ["Organ", "Piano", "Banjo", "Guitar"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of what?", fileName: "3.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of what?",
                    options: ["Arpeggios", "Vibrato", "Power Chords", "Minor Scale"], correctIndex: 2)),
            Clip(name: "What is the rest value for this track?", fileName: "12300099.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the rest value for this track?",
                    options: ["Half Rest", "Whole Rest", "Minor Rest", "Major Rest"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of which t", fileName: "1280.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which type of musical element?",
                    options: ["Cadence", "Arpeggio", "Scale", "Piano"], correctIndex: 0)),
            Clip(name: "What is the name of the instrument featu", fileName: "5000025.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument featured in this sound clip?",
                    options: ["Timpani", "Gong", "Vibraphone", "Triangle"], correctIndex: 0)),
            Clip(name: "This theme represents the main character", fileName: "550.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This theme represents the main character from Sergei Prokofievs symphonic fairy tale for children. What is the name of the composition?",
                    options: ["Peter and the Wolf", "Swan Lake", "The Nutcracker", "Water Music"], correctIndex: 0)),
            Clip(name: "What is the title of this composition?", fileName: "500015.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the title of this composition?",
                    options: ["Twinkle Twinkle", "Chopsticks", "Heart and Soul", "Happy Birthday"], correctIndex: 1)),
            Clip(name: "This is an example of what?", fileName: "256966.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This is an example of what?",
                    options: ["Finger Picking", "Strumming", "String Muting", "Travis Picking"], correctIndex: 1)),
            Clip(name: "What is the name of the drum that is fea", fileName: "66332255.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the drum that is featured in this track?",
                    options: ["Snare Drum", "Bass Drum", "Conga Drum", "Tom-Tom"], correctIndex: 3)),
            Clip(name: "This guitar part would be found in which", fileName: "12.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This guitar part would be found in which style of music?",
                    options: ["Country & Western", "Reggae", "R&B", "Heavy Metal"], correctIndex: 1)),
            Clip(name: "This sound clip is an example of which t", fileName: "1278.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which type of cadence?",
                    options: ["Half Cadence", "Minor Scale", "Trill", "Triad"], correctIndex: 0)),
            Clip(name: "What is the name of the drum featured in", fileName: "900001.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the drum featured in this clip?",
                    options: ["Timpani Drum", "Snare Drum", "Djembe Drum", "Tabla Drum"], correctIndex: 1)),
            Clip(name: "What is the name of the drum that is fea", fileName: "9687547.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the drum that is featured in this sound clip?",
                    options: ["Bass Drum", "Snare Drum", "Hand Drum", "Floor Tom"], correctIndex: 1)),
            Clip(name: "What is the name of the instrument featu", fileName: "56699655.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument featured in this sound clip?",
                    options: ["Piano", "Pipe Organ", "Electric Piano", "Harpsichord"], correctIndex: 3)),
            Clip(name: "What's the name of the little green stom", fileName: "TubeScreamer.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What's the name of the little green stomp box used in this clip?",
                    options: ["Boss SD-1 Super Overdrive", "Pro Co RAT", "Ibanez Tube Screamer", "Big Muff Pi"], correctIndex: 2)),
            Clip(name: "What is the name of this modulation effe", fileName: "Flanger.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this modulation effect?",
                    options: ["Flanging", "Phase Shifting", "Spring Reverb", "Digital Delay"], correctIndex: 0)),
            Clip(name: "This device is used by musicians to help", fileName: "Metronome.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This device is used by musicians to help keep a consistent tempo.",
                    options: ["Violin", "Pulse", "Metronome", "Miramba"], correctIndex: 2)),
            Clip(name: "This type of track is used to help keep ", fileName: "Click-Track.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This type of track is used to help keep musicians in time when recording or performing.",
                    options: ["Chase Fade", "Rim Shot", "Rhythm Track", "Click Track"], correctIndex: 3)),
            Clip(name: "This drumbeat is likely to be found in w", fileName: "SurfDrumBeat.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "This drumbeat is likely to be found in which musical genre?",
                    options: ["Soul", "Latin", "Techno", "Surf"], correctIndex: 3)),
            Clip(name: "What is the title of this composition?", fileName: "Star-Spangled-Banner.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the title of this composition?",
                    options: ["The Stars and Stripes Forever", "Twinkle Twinkle Little Star", "America the Beautiful", "The Star-Spangled Banner"], correctIndex: 3)),
            Clip(name: "What is the name of this reference note?", fileName: "Middle-C.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Easy)", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this reference note?",
                    options: ["Open G", "Drop D", "Open E", "Middle C"], correctIndex: 3)),
        ])

    static let debugKnowledgeMediumSet = QuizSet(
        name: "Music Knowledge (Debug - Medium)", category: .other, clips: [
            Clip(name: "This device is used to raise the pitch o", fileName: "2656965.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This device is used to raise the pitch of a guitar.",
                    options: ["Slide", "Capo", "Pick", "Bridge"], correctIndex: 1)),
            Clip(name: "This is an example of using which of the", fileName: "100009996.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This is an example of using which of these?",
                    options: ["Harmonics", "Arpeggios", "Circle of Fifths", "Dorian Mode"], correctIndex: 0)),
            Clip(name: "This track is in the style of which guit", fileName: "86547822.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This track is in the style of which guitar legend?",
                    options: ["Edward Van Halen", "Angus Young", "Jimmy Page", "Les Paul"], correctIndex: 2)),
            Clip(name: "What type of scale is this?", fileName: "500023.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of scale is this?",
                    options: ["Blues Scale", "Major Pentatonic", "Minor Pentatonic", "Harmonic Minor"], correctIndex: 1)),
            Clip(name: "What is the tempo marking of this track?", fileName: "5000096580.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the tempo marking of this track?",
                    options: ["Allegro", "Vivace", "Prestissimo", "Andante"], correctIndex: 3)),
            Clip(name: "This composition is typical of which mus", fileName: "500050.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This composition is typical of which musical era?",
                    options: ["20th Century Classical", "Renaissance", "Romantic", "Medieval"], correctIndex: 0)),
            Clip(name: "What is the time signature of this track", fileName: "9449494949.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this track?",
                    options: ["4/4", "5/4", "7/4", "3/4"], correctIndex: 0)),
            Clip(name: "This composition is in the style of whic", fileName: "500655996.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This composition is in the style of which composer?",
                    options: ["George Gershwin", "Irving Berlin", "Stephen Foster", "Cole Porter"], correctIndex: 0)),
            Clip(name: "What is the title of this composition?", fileName: "12300085.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the title of this composition?",
                    options: ["Greensleeves", "Billy Boy", "A Sailors Life", "Willow Song"], correctIndex: 0)),
            Clip(name: "This chord is usually referred to as the", fileName: "56537.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This chord is usually referred to as the Hendrix chord.",
                    options: ["Dmin", "F", "E7#9", "Cmaj9"], correctIndex: 2)),
            Clip(name: "What is the name of this instrument?", fileName: "50004002.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this instrument?",
                    options: ["Organ", "Piano", "Synthesizer", "Melotron"], correctIndex: 2)),
            Clip(name: "What type of electric bass guitar is bei", fileName: "56538465.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of electric bass guitar is being played in this track?",
                    options: ["Rickenbacker", "Fender Precision", "Hofner", "Fender Jazz"], correctIndex: 2)),
            Clip(name: "The hi-hat is playing what note duration", fileName: "10000999.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "The hi-hat is playing what note duration?",
                    options: ["Eighth Notes", "Sixteenth Notes", "Whole Notes", "Quarter Notes"], correctIndex: 1)),
            Clip(name: "This sound clip is an example of which t", fileName: "59868.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which technique?",
                    options: ["Pizzicato", "Stacato", "Spiccato", "Legato"], correctIndex: 0)),
            Clip(name: "What is the time signature of this piece", fileName: "100036.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this piece?",
                    options: ["4/4", "7/4", "7/5", "3/4"], correctIndex: 3)),
            Clip(name: "What is the name of the instrument featu", fileName: "56699656.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the instrument featured in this sound clip?",
                    options: ["Acoustic Guitar", "Acoustic Bass", "Electric Guitar", "Dobro"], correctIndex: 1)),
            Clip(name: "This drum track is palyed in the style o", fileName: "8787875.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This drum track is palyed in the style of which drummer?",
                    options: ["Keith Moon", "Phil Collins", "Ringo Starr", "Zach Starkey"], correctIndex: 1)),
            Clip(name: "Who is the composer of this piece of mus", fileName: "500655.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Who is the composer of this piece of music?",
                    options: ["Mozart", "Bach", "Haydn", "Stamitz"], correctIndex: 2)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230007.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Seventh", "Major Third", "Minor Second", "Major Ninth"], correctIndex: 3)),
            Clip(name: "What is the time signature of this track", fileName: "965665.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this track?",
                    options: ["3/4", "4/4", "6/8", "7/5"], correctIndex: 1)),
            Clip(name: " What type of guitar tuning is being use", fileName: "565365.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: " What type of guitar tuning is being used in this sound clip?",
                    options: ["Standard Tuning", "Open G Tuning", "Drop D Tuning", "Open E Tuning"], correctIndex: 2)),
            Clip(name: "Listen to this track. What is the length", fileName: "63253.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Listen to this track. What is the length of the notes being played.",
                    options: ["Quarter Notes", "Whole Notes", "Sixteenth Notes", "Dotted Sixteenth Notes"], correctIndex: 2)),
            Clip(name: "This drum track is played in the style o", fileName: "711711.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This drum track is played in the style of which drummer?",
                    options: ["Bill Ward", "Ian Paice", "Stewart Copeland", "Billy Cobham"], correctIndex: 2)),
            Clip(name: "What is this common chord progression?", fileName: "5655665.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is this common chord progression?",
                    options: ["I-IV-V", "I-VI-IV-V", "I-II-V", "I-V-IV"], correctIndex: 1)),
            Clip(name: "What type of chord is this?", fileName: "999555565.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of chord is this?",
                    options: ["maj", "min7", "m11", "m13"], correctIndex: 1)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230008.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Seventh", "Major Third", "Major Second", "Major Ninth"], correctIndex: 2)),
            Clip(name: "Listen Closely. What type of guitar stom", fileName: "988565.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Listen Closely. What type of guitar stomp box is this guitar player using?",
                    options: ["Vibrato", "Overdrive", "Harmonizer", "Reverb"], correctIndex: 0)),
            Clip(name: "What is the time signature of this track", fileName: "100200.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this track?",
                    options: ["7/5", "7/4", "6/8", "6/4"], correctIndex: 2)),
            Clip(name: "This drum track is palyed in the style o", fileName: "963555.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This drum track is palyed in the style of which drummer?",
                    options: ["Steve Gadd", "Max Roach", "Buddy Rich", "Gene Krupa"], correctIndex: 0)),
            Clip(name: "What type of open guitar tuning is being", fileName: "2154525.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of open guitar tuning is being used in this track?",
                    options: ["Standard Tuning", "Drop D Tuning", "Open G Tuning", "Open E Tuning"], correctIndex: 2)),
            Clip(name: "This drum beat is an example of which be", fileName: "1096650.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This drum beat is an example of which beat?",
                    options: ["First Line", "Second Line", "Regaee", "Bluegrass"], correctIndex: 1)),
            Clip(name: "This is an example of ...?", fileName: "7845236.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This is an example of ...?",
                    options: ["Turnaround", "Vamp", "Walking Bass Line", "Shuffle"], correctIndex: 2)),
            Clip(name: "What is the name of the guitar effect fe", fileName: "15233.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the guitar effect featured in this clip?",
                    options: ["Phaser", "Envelope Filter", "Wah Wah", "Reverb"], correctIndex: 2)),
            Clip(name: "This major sounding musical mode is form", fileName: "450.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This major sounding musical mode is formed from the fifth degree of the major scale. What is its name?",
                    options: ["Mixolydian", "Minor", "Melodic Minor", "Minor Blues"], correctIndex: 0)),
            Clip(name: "This bass line can be found in this styl", fileName: "3659885.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This bass line can be found in this style of music ...",
                    options: ["Heavy Metal", "Rock", "Rhythm and Blues", "Ska"], correctIndex: 2)),
            Clip(name: "What is the correct time signature for t", fileName: "7500050.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the correct time signature for this sound clip?",
                    options: ["4/4", "3/4", "7/8", "2/4"], correctIndex: 1)),
            Clip(name: "What is the name of this instrument?", fileName: "50004001.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this instrument?",
                    options: ["Organ", "Piano", "Harp", "Accordion"], correctIndex: 0)),
            Clip(name: "What is the name of this scale?", fileName: "500013.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this scale?",
                    options: ["Melodic Minor", "Major", "Blues", "Harmonic Minor"], correctIndex: 2)),
            Clip(name: "What is the most appropriate tempo marki", fileName: "500.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the most appropriate tempo marking?",
                    options: ["Adagio", "Presto", "Prestissimo", "Moderato"], correctIndex: 0)),
            Clip(name: "Who is the composer of this piece of mus", fileName: "500078.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Who is the composer of this piece of music?",
                    options: ["Mozart", "Bach", "Vivaldi", "Schubert"], correctIndex: 0)),
            Clip(name: "This bass track is played in what time s", fileName: "8658221434.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This bass track is played in what time signature?",
                    options: ["6/8", "5/4", "4/4", "3/4"], correctIndex: 2)),
            Clip(name: "What type of chord is this?", fileName: "125896554.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of chord is this?",
                    options: ["maj7", "min7", "7", "min"], correctIndex: 2)),
            Clip(name: "What style of music would this drum beat", fileName: "5259985.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What style of music would this drum beat be most commonly found?",
                    options: ["Funk", "Heavy Metal", "Disco", "Salsa"], correctIndex: 0)),
            Clip(name: "What is the name of this chord?", fileName: "3625522.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this chord?",
                    options: ["Emin", "Emaj7", "E6", "E7"], correctIndex: 2)),
            Clip(name: "What is the time signature of this track", fileName: "1000020.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this track?",
                    options: ["5/4", "7/4", "6/8", "3/4"], correctIndex: 3)),
            Clip(name: "The drum track is played in the style of", fileName: "9652141.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "The drum track is played in the style of which drummer?",
                    options: ["Mitch Mitchell", "Ginger Baker", "Dave Grohl", "Vinnie Calautti"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of...", fileName: "98554415.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of...",
                    options: ["Backtracking", "Octaves", "Circle of Fifths", "Jazz"], correctIndex: 0)),
            Clip(name: "What type of guitar stomp box is being u", fileName: "1254552.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of guitar stomp box is being used on this track?",
                    options: ["Reverb", "Octave", "Wah-Wah", "Chorus"], correctIndex: 1)),
            Clip(name: "This musical mode is identical to the na", fileName: "400.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This musical mode is identical to the natural minor scale. What is its name?",
                    options: ["Aeloian", "Major", "Locrian", "Chromatic"], correctIndex: 0)),
            Clip(name: "What is the name of this instrument?", fileName: "50004008.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this instrument?",
                    options: ["Accordion", "Hooter", "Clavinet", "Melotron"], correctIndex: 2)),
            Clip(name: "This composition is typical of which mus", fileName: "500040.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This composition is typical of which musical era?",
                    options: ["20th Century Classical", "Baroque", "Romantic", "Medieval"], correctIndex: 0)),
            Clip(name: "What type of scale is this?", fileName: "12300034.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of scale is this?",
                    options: ["Minor", "Major", "Chromatic", "Major Pentatonic"], correctIndex: 2)),
            Clip(name: "This drum track is played in the style o", fileName: "5666552.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This drum track is played in the style of which drummer?",
                    options: ["Chad Smith", "Neil Peart", "Alex Van Halen", "Stewart Copenland"], correctIndex: 1)),
            Clip(name: "What type of tuning is being used in thi", fileName: "6585421.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of tuning is being used in this sound clip?",
                    options: ["Standard Tuning", "Open G Tuning", "Drop D Tuning", "Open E Tuning"], correctIndex: 2)),
            Clip(name: "Listen Closely. What type of harmony is ", fileName: "9652334.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Listen Closely. What type of harmony is being played?",
                    options: ["Third", "Fourth", "Fifth", "Seventh"], correctIndex: 1)),
            Clip(name: "This drum track is played in the style o", fileName: "658545.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This drum track is played in the style of which drummer?",
                    options: ["Max Roach", "Buddy Rich", "Carl Palmer", "Simon Kirke"], correctIndex: 3)),
            Clip(name: "This musical mode is formed from the sec", fileName: "410.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This musical mode is formed from the second degree of the major scale and has a minor tonality. What is its name?",
                    options: ["Dorian", "Major Blues", "Chromatic", "Major Pentatonic"], correctIndex: 0)),
            Clip(name: "What is the interval in this sould clip?", fileName: "12300012.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Sixth", "Minor Third", "Tritone", "Octave"], correctIndex: 2)),
            Clip(name: "Listen to this sound clip. What type of ", fileName: "1000065697.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Listen to this sound clip. What type of effect is used in the clip?",
                    options: ["Digital Delay", "Compression", "Limiting", "Modulation"], correctIndex: 0)),
            Clip(name: "This bass track is played in the style o", fileName: "5425336.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This bass track is played in the style of ...",
                    options: ["Jack Bruce", "Geddy Lee", "Paul McCartney", "Stanley Clarke"], correctIndex: 2)),
            Clip(name: "If the tempo of this track was previousl", fileName: "1525252.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "If the tempo of this track was previously half the current tempo, the current tempo is ...",
                    options: ["Double-Time", "Half-Time", "Common-Time", "Normal-Time"], correctIndex: 0)),
            Clip(name: "Listen to this track. What type of modul", fileName: "86869588.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Listen to this track. What type of modulation effect is likely being used on this track?",
                    options: ["Phasing", "Delay", "Reverb", "Chorus"], correctIndex: 3)),
            Clip(name: "This type of rock ensemble consists of d", fileName: "955246.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This type of rock ensemble consists of drums, bass, and guitar. Bands like Cream and Rush are just a few examples of this type of ensemble.",
                    options: ["Power Trio", "Chamber Strings", "Jazz Band", "Orchestra"], correctIndex: 0)),
            Clip(name: "This composition is in the style of...", fileName: "500060.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This composition is in the style of...",
                    options: ["Chopin", "Bach", "Satie", "Beethoven"], correctIndex: 2)),
            Clip(name: "Who is the composer of this piece of mus", fileName: "500965.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Who is the composer of this piece of music?",
                    options: ["Mozart", "Bach", "Haydn", "Stamitz"], correctIndex: 0)),
            Clip(name: "What is the title of this composition?", fileName: "12300080.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the title of this composition?",
                    options: ["The Messiah", "The Four Seasons", "In the Hall of the Mountain King", "Requiem"], correctIndex: 2)),
            Clip(name: "In what style of music would this drum b", fileName: "5863214.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "In what style of music would this drum beat be found?",
                    options: ["Rock", "Regaee", "Jazz", "Shuffle"], correctIndex: 0)),
            Clip(name: "Listen Closely. What type of guitar stom", fileName: "8989996.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Listen Closely. What type of guitar stomp box is this guitar player using?",
                    options: ["Overdrive", "Fuzz", "Reverb", "Wah-Wah"], correctIndex: 1)),
            Clip(name: "Listen to this track. What type of scale", fileName: "89895656.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Listen to this track. What type of scale is being used?",
                    options: ["Major Scale", "Minor Scale", "Minor Pentatonic Scale", "Blues Scale"], correctIndex: 2)),
            Clip(name: "What type of scale is being used in this", fileName: "2658885.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of scale is being used in this recording?",
                    options: ["Major Pentatonic", "Harmonic Minor", "Blues Scale", "Minor Pentatonic"], correctIndex: 3)),
            Clip(name: "This guitar track is played in the style", fileName: "100006575.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This guitar track is played in the style of which artist?",
                    options: ["Little Richard", "Chuck Berry", "Muddy Waters", "Carl Perkins"], correctIndex: 1)),
            Clip(name: "This track is played in the style of thi", fileName: "955244.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This track is played in the style of this drummer...",
                    options: ["Jeff Porcaro", "Ringo Starr", "Ginger Baker", "Dave Grohl"], correctIndex: 0)),
            Clip(name: "What is the interval in this sould clip?", fileName: "12300010.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Major Sixth", "Major Third", "Octave", "Major Ninth"], correctIndex: 1)),
            Clip(name: "What is the tempo marking of this track?", fileName: "500000.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the tempo marking of this track?",
                    options: ["Grave", "Presto", "Largo", "Andante"], correctIndex: 3)),
            Clip(name: "What type of guitar chords are featured ", fileName: "63257.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of guitar chords are featured in this clip?",
                    options: ["Barre Chords", "First Position Chords", "Funk Chords", "Suspended Chords"], correctIndex: 1)),
            Clip(name: "Which type of string winding is most lik", fileName: "Flatwound.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Which type of string winding is most likely being used on this bass groove",
                    options: ["Stringwound", "Tapewound", "Roundwound", "Flatwound"], correctIndex: 3)),
            Clip(name: "The bass line in this track is employing", fileName: "Flatwound-2-Full.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "The bass line in this track is employing which technique?",
                    options: ["Shredding", "Tapping", "Octaves", "Slapping"], correctIndex: 2)),
            Clip(name: "This style of drum groove is likely to b", fileName: "MotownDrumBeat.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This style of drum groove is likely to be found in which musical genre?",
                    options: ["Classical", "World Music", "Motown", "Calypso"], correctIndex: 2)),
            Clip(name: "Which jazz drum pattern is featured in t", fileName: "Drums-Jazz-Shuffle.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Which jazz drum pattern is featured in this audio clip?",
                    options: ["Four On The Floor Pattern", "16th Note Pattern", "Funk Pattern", "Jazz Shuffle Pattern"], correctIndex: 3)),
            Clip(name: "Which drum pattern is featured in this a", fileName: "Drums-Regaee-Beat.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Which drum pattern is featured in this audio clip?",
                    options: ["16th Note Pattern", "Jazz-Swing Pattern", "Reggae Pattern", "Hip-Hop Pattern"], correctIndex: 2)),
            Clip(name: "This track is played in the style of whi", fileName: "Style-Of-AC-DC.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This track is played in the style of which band?",
                    options: ["Pink Floyd", "AC/DC", "Yes", "Genesis"], correctIndex: 1)),
            Clip(name: "This track is in which time signature?", fileName: "Loop.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This track is in which time signature?",
                    options: ["6/8", "3/4", "4/4", "5/4"], correctIndex: 2)),
            Clip(name: "This audio clip is an example of which g", fileName: "DiveBomb.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "This audio clip is an example of which guitar technique?",
                    options: ["Dive Bomb", "Palm Muting", "Tremolo Picking", "Hammer On"], correctIndex: 0)),
            Clip(name: "What is the correct time signature for t", fileName: "Drums-6-8-Blues.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What is the correct time signature for this track?",
                    options: ["4/4", "7/4", "5/4", "6/8"], correctIndex: 3)),
            Clip(name: "What type of groove is featured in this ", fileName: "Drums-16th-Note-Groove.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What type of groove is featured in this audio clip?",
                    options: ["Surf Groove", "Bassanova Groove", "16th Note Groove", "8th Note Groove"], correctIndex: 2)),
            Clip(name: "What item is being used to strike the dr", fileName: "Drums-Brushes.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Medium)", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What item is being used to strike the drums in this clip?",
                    options: ["Rollers", "Mallets", "Brushes", "Sticks"], correctIndex: 2)),
        ])

    static let debugKnowledgeHardSet = QuizSet(
        name: "Music Knowledge (Debug - Hard)", category: .other, clips: [
            Clip(name: "The first chord of this three chord prog", fileName: "598682.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "The first chord of this three chord progression is built upon the lowered second scale degree. What is the name of chord?",
                    options: ["Major", "Minor", "Augmented", "Neapolitan Sixth Chord"], correctIndex: 3)),
            Clip(name: "What type of chord is this?", fileName: "986655225.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of chord is this?",
                    options: ["9", "min7", "aug7", "dim"], correctIndex: 0)),
            Clip(name: "This major sounding musical mode is form", fileName: "440.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This major sounding musical mode is formed from the fourth degree of the major scale. What is its name?",
                    options: ["Lydian", "Minor", "Melodic Minor", "Minor Blues"], correctIndex: 0)),
            Clip(name: "This Kabalevsky excerpt is from which mu", fileName: "5000504.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This Kabalevsky excerpt is from which musical era?",
                    options: ["20th Century Classical", "Baroque", "Classical", "Medieval"], correctIndex: 0)),
            Clip(name: "What is the tonality of this scale?", fileName: "500012.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the tonality of this scale?",
                    options: ["Melodic Minor", "Major", "Blues", "Harmonic Minor"], correctIndex: 0)),
            Clip(name: "This bass track is played in what time s", fileName: "896665.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This bass track is played in what time signature?",
                    options: ["3/4", "5/4", "6/8", "7/5"], correctIndex: 1)),
            Clip(name: "The Edward MacDowell composition \"To a W", fileName: "50005075.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "The Edward MacDowell composition \"To a Wild Rose\" employs which tempo marker?",
                    options: ["Andante", "Grave", "Allegro", "Presto"], correctIndex: 0)),
            Clip(name: "What type of scale is this?", fileName: "5687563.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of scale is this?",
                    options: ["Major Pentatonic", "Natural Minor", "Harmonic Minor", "Major"], correctIndex: 2)),
            Clip(name: "What type of drum rudiment is this an ex", fileName: "100006566632.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of drum rudiment is this an example of?",
                    options: ["Five Stroke Roll", "Drag", "Flam", "Double Flam"], correctIndex: 2)),
            Clip(name: "This minor sounding musical mode is form", fileName: "430.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This minor sounding musical mode is formed from the seventh degree of the major scale. What is its name?",
                    options: ["Locrian", "Major", "Chromatic", "Major Pentatonic"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of what ty", fileName: "2700.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of what type of Arpeggio?",
                    options: ["Augmented Arpeggio", "Minor Scale", "Harmonic Minor Scale", "Major Arpeggio"], correctIndex: 0)),
            Clip(name: "This drum track is played in the style o", fileName: "78588865.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This drum track is played in the style of which drummer?",
                    options: ["Buddy Rich", "Neil Peart", "Steve Gadd", "Steve Smith"], correctIndex: 2)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230006.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Seventh", "Flat Ninth", "Minor Second", "Octave"], correctIndex: 1)),
            Clip(name: "Listen Carefully. What modulation effect", fileName: "86869585958.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Listen Carefully. What modulation effect is used in this track?",
                    options: ["Univibe", "Reverb", "Overdrive", "Chorus"], correctIndex: 0)),
            Clip(name: "This chord progression is moving in what", fileName: "1260.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This chord progression is moving in what interval?",
                    options: ["Fourths", "Fifths", "Octaves", "Minor Thirds"], correctIndex: 0)),
            Clip(name: "Which type of drum beat is featured in t", fileName: "100006565.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Which type of drum beat is featured in this clip?",
                    options: ["Samba", "Bassanova", "Shuffle", "Clypso"], correctIndex: 1)),
            Clip(name: "This guitar track is played in the style", fileName: "100006570.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This guitar track is played in the style of who?",
                    options: ["Little Richard", "Chuck Berry", "Muddy Waters", "Carl Perkins"], correctIndex: 1)),
            Clip(name: "The Erik Satie composition \"Three Gymnop", fileName: "50005078.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "The Erik Satie composition \"Three Gymnopedies employs which type of dynamics?",
                    options: ["Pianissimo", "Forte", "Fortissimo", "Sforzando"], correctIndex: 0)),
            Clip(name: "This drum beat is played in the style of", fileName: "1000365.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This drum beat is played in the style of?",
                    options: ["Purdie Shuffle", "Triplet Swing", "One Drop", "Swing Beat"], correctIndex: 0)),
            Clip(name: "What is the interval in this sould clip?", fileName: "12300011.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Sixth", "Minor Third", "Minor Second", "Major Ninth"], correctIndex: 2)),
            Clip(name: "This J.S. Bach piece employs a technique", fileName: "25696515.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This J.S. Bach piece employs a technique known as ...",
                    options: ["Staccato", "Rubato", "Trill", "Modulation"], correctIndex: 0)),
            Clip(name: "This minor sounding musical mode is form", fileName: "460.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This minor sounding musical mode is formed from the third degree of the major scale. What is its name?",
                    options: ["Phrygian", "Major", "Major Pentatonic", "Minor Blues"], correctIndex: 0)),
            Clip(name: "This J.S. Bach composition employs which", fileName: "5000400250.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This J.S. Bach composition employs which one of these musical techniques? ",
                    options: ["Ornamentation", "Improvisation", "Staccato", "Glissando"], correctIndex: 0)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230001.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Second", "Major Third", "Tritone", "Perfect Fifth"], correctIndex: 3)),
            Clip(name: "This sound clip is an example of which c", fileName: "1298.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which chord?",
                    options: ["Emin", "A", "Fdim", "Dsus4"], correctIndex: 0)),
            Clip(name: "What type of scale is this?", fileName: "51515059.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of scale is this?",
                    options: ["Natural Minor", "Major", "Blues", "Harmonic Minor"], correctIndex: 0)),
            Clip(name: "What type of drum rudiment is this an ex", fileName: "100006566639.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of drum rudiment is this an example of?",
                    options: ["Five Stroke Roll", "Drag", "Shuffle", "Clypso"], correctIndex: 0)),
            Clip(name: "What type of guitar is most likely being", fileName: "100006569.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of guitar is most likely being used in this sound clip.",
                    options: ["Fender Stratocaster", "Gibson SG", "Ibanez Destroyer", "Gretch Falcon"], correctIndex: 0)),
            Clip(name: "Name this common turnaround chord progre", fileName: "565566585.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Name this common turnaround chord progression typically found in Jazz music?",
                    options: ["1-4-5", "2-5-1", "1-6-2-5", "2-5-7-1"], correctIndex: 2)),
            Clip(name: "What is the tonality of this piano chord", fileName: "5653775.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the tonality of this piano chord?",
                    options: ["Major", "Minor", "Diminished", "Suspended"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of which t", fileName: "1279.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which type of minor cadence?",
                    options: ["Half Cadence", "Half Cadence Minor", "Perfect Authentic Cadence", "Perfect Authentic Cadenece Minor"], correctIndex: 1)),
            Clip(name: "J.S Bachs Prelude in C Major is part of ", fileName: "50004002505.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "J.S Bachs Prelude in C Major is part of which larger collection? ",
                    options: ["The Well-Tempered Clavier", "St John Passion", "Goldberg Variatons", "Christmas Oratorio"], correctIndex: 0)),
            Clip(name: "This repeated musical pattern played on ", fileName: "555.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This repeated musical pattern played on the left hand is an example of ...",
                    options: ["Ostinato", "Improvisation", "Figured Bass", "Staccato"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of which t", fileName: "1276.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which type of arpeggio?",
                    options: ["Deceptive Cadence", "Diminished Arpeggio Pure", "Major Arpeggio", "Scale"], correctIndex: 1)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230004.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Major Third", "Minor Third", "Perfect Fourth", "Perfect Fifth"], correctIndex: 1)),
            Clip(name: "This sound clip is an example of which t", fileName: "1277.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which type of dominant arpeggio?",
                    options: ["Dominant Seventh Arpeggio", "Major Chord", "Major Arpeggio", "Pentatonic Scale"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of which t", fileName: "1285.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which type of musical cadence?",
                    options: ["Perfect Cadence", "Half Cadence", "Plagal Cadence", "Imperfect Cadence"], correctIndex: 2)),
            Clip(name: "What is the tonality of this scale?", fileName: "30001.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the tonality of this scale?",
                    options: ["Harmonic Minor", "Melodic Minor", "Major", "Natural Minor"], correctIndex: 3)),
            Clip(name: "What is the time signature of this track", fileName: "9000009955.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this track? ",
                    options: ["Common Time", "Waltz Time", "March Time", "Compound Time"], correctIndex: 1)),
            Clip(name: "What is the time signature of this track", fileName: "8759996.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this track?",
                    options: ["4/4", "7/4", "5/4", "6/8"], correctIndex: 3)),
            Clip(name: "What type of chord is this?", fileName: "9585565.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of chord is this?",
                    options: ["7th", "Major 7th", "Minor 7th", "Minor"], correctIndex: 1)),
            Clip(name: "Who was the composer of this piece of mu", fileName: "75010.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Who was the composer of this piece of music?",
                    options: ["JS Bach", "Fredrick Chopin", "Wolfgang Amadeus Mozart", "Christian Petzold"], correctIndex: 3)),
            Clip(name: "Listen to this sound clip. This is an ex", fileName: "56899658.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Listen to this sound clip. This is an example of what type of drum rudiment?",
                    options: ["Single Stroke Roll", "Double Paradiddle", "Rim Shot", "Samba"], correctIndex: 1)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230005.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Seventh", "Major Third", "Perfect Fourth", "Octave"], correctIndex: 2)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230002.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Second", "Diminshed Fourth", "Perfect Fourth", "Sharp Eleven"], correctIndex: 3)),
            Clip(name: "This sound clip is an example of which t", fileName: "1275.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of which type of musical cadence?",
                    options: ["Deceptive Cadence", "Harmonic Minor", "Perfect Cadence Major", "Scale"], correctIndex: 0)),
            Clip(name: "Which type of drum beat is featured in t", fileName: "100006567.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Which type of drum beat is featured in this clip?",
                    options: ["Samba", "Bossa Nova", "Shuffle", "Clypso"], correctIndex: 0)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230003.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Sixth", "Minor Seventh", "Perfect Fourth", "Sharp Eleven"], correctIndex: 0)),
            Clip(name: "What is the name of this composition?", fileName: "2569651.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this composition?",
                    options: ["Jesu Joy of Mans Desiring", "Fur Elise", "Claire De Lune", "Moonlight Sonata"], correctIndex: 0)),
            Clip(name: "This sound clip is an example of what ty", fileName: "125.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This sound clip is an example of what type of compound interval?",
                    options: ["Flat 9", "Perfect 5th", "Major Scale", "Arpeggio"], correctIndex: 0)),
            Clip(name: "What type of drum rudiment is this an ex", fileName: "100006566636.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of drum rudiment is this an example of?",
                    options: ["Double Stroke Roll", "Drag", "Shuffle", "Clypso"], correctIndex: 1)),
            Clip(name: "What is the interval in this sould clip?", fileName: "1230009.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Major Sixth", "Major Third", "Minor Seventh", "Major Ninth"], correctIndex: 0)),
            Clip(name: "What type of drum rudiment is this an ex", fileName: "100006566637.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of drum rudiment is this an example of?",
                    options: ["Double Stroke Roll", "Single Stroke Roll", "Five Stroke Roll", "Fifteen Stroke Roll"], correctIndex: 3)),
            Clip(name: "What is the time signature of this track", fileName: "875999699.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the time signature of this track?",
                    options: ["4/4", "7/4", "5/4", "14/4"], correctIndex: 3)),
            Clip(name: "What is the interval in this sould clip?", fileName: "12300023.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the interval in this sould clip?",
                    options: ["Minor Second", "Minor Seventh", "Tritone", "Perfect Fifth"], correctIndex: 1)),
            Clip(name: "What is the tonality of this scale?", fileName: "500030.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the tonality of this scale?",
                    options: ["Natural Minor", "Major", "Blues", "Harmonic Minor"], correctIndex: 3)),
            Clip(name: "What is this chord progression?", fileName: "9656636.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is this chord progression?",
                    options: ["I-IV-V", "I-VI-IV-V", "II-V-I", "I-V-IV"], correctIndex: 2)),
            Clip(name: "What type of drum rudiment is this an ex", fileName: "100006566633.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What type of drum rudiment is this an example of?",
                    options: ["Five Stroke Roll", "Drag", "Flam Accent", "Double Flam"], correctIndex: 2)),
            Clip(name: "This is which type of chord progression?", fileName: "2-5-1-ChordProgression.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This is which type of chord progression?",
                    options: ["vi-IV-I-V", "ii-V-I", "I-V-vi-IV", "I-IV-V"], correctIndex: 1)),
            Clip(name: "What is the name of this type of drum-be", fileName: "Mambo-Drum-Beat.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of this type of drum-beat?",
                    options: ["Bossa Nova", "Rhumba", "Samba", "Mambo"], correctIndex: 3)),
            Clip(name: "This style of clean guitar tone was comm", fileName: "RockMan-Clean.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This style of clean guitar tone was commonly heard on recordings in which decade?",
                    options: ["1940's", "1960's", "2000's", "1980's"], correctIndex: 3)),
            Clip(name: "What is the name of the drum pattern fea", fileName: "Drum-Jazz-Waltz.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the name of the drum pattern featured in this clip?",
                    options: ["Purdie Shuffle", "Half-Time Shuffle", "Shuffle", "Jazz-Swing Waltz"], correctIndex: 3)),
            Clip(name: "This audio clip features which drum patt", fileName: "Drum-MidTempo-Swing.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This audio clip features which drum pattern?",
                    options: ["Jazz Waltz Pattern", "Half-Time Shuffle Pattern", "Slow Shuffle Pattern", "Mid-Tempo Swing Pattern"], correctIndex: 3)),
            Clip(name: "This drum groove is an example of which ", fileName: "Drums-Soca.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This drum groove is an example of which type of pattern?",
                    options: ["Soca Pattern", "Jazz-Swing Pattern", "Half-Time Shuffle Pattern", "Funk Groove Pattern"], correctIndex: 0)),
            Clip(name: "Which type of drum pattern is featured i", fileName: "Drums-Clypso.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Which type of drum pattern is featured in this clip?",
                    options: ["One-Drop Pattern", "Calypso Pattern", "Hip Hop Pattern", "New Wave Pattern"], correctIndex: 1)),
            Clip(name: "Which drum pattern is featured in this a", fileName: "Drums-Bassanova.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Which drum pattern is featured in this audio clip?",
                    options: ["Bolero Pattern", "Songo Pattern", "Cha-Cha Pattern", "Bossanova Pattern"], correctIndex: 3)),
            Clip(name: "Which type of drum pattern is featured i", fileName: "Samba-Drumbeat.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Which type of drum pattern is featured in this sound clip?",
                    options: ["Fatback Pattern", "Shuffle Pattern", "Reggae Pattern", "Samba Pattern"], correctIndex: 3)),
            Clip(name: "This track is an example of which drum t", fileName: "Drums-Ghost_notes.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "This track is an example of which drum technique?",
                    options: ["Paradiddle", "Ghost Note", "Tap", "Ruff"], correctIndex: 1)),
            Clip(name: "What is the correct time signature for t", fileName: "Drum-9-8-V3.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the correct time signature for this track?",
                    options: ["7/4", "4/4", "9/8", "3/4"], correctIndex: 2)),
            Clip(name: "Which drum pattern is featured in this a", fileName: "Drums-Basic-Shuffle.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Which drum pattern is featured in this audio track?",
                    options: ["16th Note Groove", "Samba", "One Drop", "Shuffle"], correctIndex: 3)),
            Clip(name: "What is the correct time signature for t", fileName: "Drums-Afro-Cuban-6-8.mp3",
                 category: .other, setName: "Music Knowledge (Debug - Hard)", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "What is the correct time signature for this sound clip?",
                    options: ["12/8", "7/4", "6/8", "4/4"], correctIndex: 2)),
        ])

    static let debugAudioLineupSet = QuizSet(
        name: "Audio Lineup (Debug)", category: .memory, clips: [
            Clip(name: "mm10000 - mq-drum-bass-1.mp3", fileName: "mq-drum-bass-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "mq-drum-bass-1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "mq-drum-bass-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "mq-drum-bass-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "mq-drum-bass-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm10000 - mq2-drum-bass-4.mp3", fileName: "mq2-drum-bass-4.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "mq2-drum-bass-1.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "mq2-drum-bass-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "mq2-drum-bass-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "mq2-drum-bass-4.mp3", isCorrect: true),
                    ])),
            Clip(name: "mm10000 - mq-funky-tele-1.mp3", fileName: "mq-funky-tele-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "mq-funky-tele-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "mq-funky-tele-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "mq-funky-tele-4.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "mq-funky-tele-1.mp3", isCorrect: true),
                    ])),
            Clip(name: "mm-synth-q1 - mmq-synth-q1-3.mp3", fileName: "mmq-synth-q1-3.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "mmq-synth-q1-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "mmq-synth-q1-4.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "mmq-synth-q1-1.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "mmq-synth-q1-3.mp3", isCorrect: true),
                    ])),
            Clip(name: "mm - mm-loop-funky-1.mp3", fileName: "mm-loop-funky-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .hard,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "mm-loop-funky-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "mm-loop-funky-4.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "mm-loop-funky-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "mm-loop-funky-1.mp3", isCorrect: true),
                    ])),
            Clip(name: "mm - mm-synth-piano-pad-1.mp3", fileName: "mm-synth-piano-pad-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "mm-synth-piano-pad-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "mm-synth-piano-pad-4.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "mm-synth-piano-pad-1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "mm-synth-piano-pad-2.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - MQ-PianoKeyThing-4.mp3", fileName: "MQ-PianoKeyThing-4.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .medium,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "MQ-PianoKeyThing-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "MQ-PianoKeyThing-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "MQ-PianoKeyThing-4.mp3", isCorrect: true),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "MQ-PianoKeyThing-1.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - Drum-9-8-V1.mp3", fileName: "Drum-9-8-V1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .hard,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "Drum-9-8-V1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "Drum-9-8-V2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "Drum-9-8-V3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "Drum-9-8-V4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - LoopChill-1.mp3", fileName: "LoopChill-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .medium,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "LoopChill-1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "LoopChill-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "LoopChill-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "LoopChill-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm-drums-7-8 - Drums-7-8-Drums-2.mp3", fileName: "Drums-7-8-Drums-2.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .hard,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "Drums-7-8-Drums-1.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "Drums-7-8-Drums-2.mp3", isCorrect: true),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "Drums-7-8-Drums-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "Drums-7-8-Drums-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - PinkFloydish-1.mp3", fileName: "PinkFloydish-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .hard,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "PinkFloydish-1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "PinkFloydish-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "PinkFloydish-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "PinkFloydish-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - Beginner-MM-Synth-1.mp3", fileName: "Beginner-MM-Synth-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "Beginner-MM-Synth-1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "Beginner-MM-Synth-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "Beginner-MM-Synth-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "Beginner-MM-Synth-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - Beginner-Piano-1.mp3", fileName: "Beginner-Piano-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "Beginner-Piano-1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "Beginner-Piano-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "Beginner-Piano-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "Beginner-Piano-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm-classical-gtr-memory - Classical-Gtr-3.mp3", fileName: "Classical-Gtr-3.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "Classical-Gtr-1.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "Classical-Gtr-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "Classical-Gtr-3.mp3", isCorrect: true),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "Classical-Gtr-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - synth-clr-1.mp3", fileName: "synth-clr-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "synth-clr-1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "synth-clr-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "synth-clr-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "synth-clr-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - piano-beg-1-chrd-3.mp3", fileName: "piano-beg-1-chrd-3.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "piano-beg-1-chrd-1.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "piano-beg-1-chrd-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "piano-beg-1-chrd-3.mp3", isCorrect: true),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "piano-beg-1-chrd-4.mp3", isCorrect: false),
                    ])),
            Clip(name: "mm - arpeg-1.mp3", fileName: "arpeg-1.mp3",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .hard,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Listen carefully to this track, then click the play button next to each of the potential answers, then select the answer that's identical to what you first heard.",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Candidate 1", fileName: "arpeg-1.mp3", isCorrect: true),
                        AudioChoice(label: "Clip B", description: "Candidate 2", fileName: "arpeg-2.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Candidate 3", fileName: "arpeg-3.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Candidate 4", fileName: "arpeg-4.mp3", isCorrect: false),
                    ])),
        ])
}
