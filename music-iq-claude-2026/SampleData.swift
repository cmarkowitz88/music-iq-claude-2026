
import Foundation

extension QuizSet {
    static let sampleSets: [QuizSet] = [
        instrumentSet, timeSigSet, tempoSet, audioLineupSet
    ]

    static let instrumentSet = QuizSet(
        name: "Name that instrument", category: .instrument, clips: [
            Clip(name: "Melodic phrase — 6 sec", fileName: "mc_inst_01.mp3",
                 category: .instrument, setName: "Name that instrument", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What instrument is playing?",
                    options: ["Piano", "Violin", "Flute", "Guitar"], correctIndex: 1)),
            Clip(name: "Solo passage — 8 sec", fileName: "mc_inst_02.mp3",
                 category: .instrument, setName: "Name that instrument", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "Which instrument do you hear?",
                    options: ["Trumpet", "Clarinet", "Oboe", "Saxophone"], correctIndex: 3)),
            Clip(name: "Chord voicing — 5 sec", fileName: "mc_inst_03.mp3",
                 category: .instrument, setName: "Name that instrument", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What family does this instrument belong to?",
                    options: ["Strings", "Woodwinds", "Brass", "Keyboard"], correctIndex: 0)),
            Clip(name: "Rhythmic figure — 7 sec", fileName: "mc_inst_04.mp3",
                 category: .instrument, setName: "Name that instrument", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Which percussion instrument is this?",
                    options: ["Snare drum", "Bongos", "Marimba", "Timpani"], correctIndex: 2)),
        ])

    static let timeSigSet = QuizSet(
        name: "Feel the beat", category: .timeSig, clips: [
            Clip(name: "Groove loop — 8 sec", fileName: "mc_ts_01.mp3",
                 category: .timeSig, setName: "Feel the beat", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "What's the time signature?",
                    options: ["2/4", "3/4", "4/4", "6/8"], correctIndex: 2)),
            Clip(name: "Waltz pattern — 6 sec", fileName: "mc_ts_02.mp3",
                 category: .timeSig, setName: "Feel the beat", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "How many beats per measure?",
                    options: ["2", "3", "4", "6"], correctIndex: 1)),
            Clip(name: "Odd meter — 9 sec", fileName: "mc_ts_03.mp3",
                 category: .timeSig, setName: "Feel the beat", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Which time signature fits?",
                    options: ["4/4", "5/4", "6/8", "7/8"], correctIndex: 3)),
            Clip(name: "March feel — 7 sec", fileName: "mc_ts_04.mp3",
                 category: .timeSig, setName: "Feel the beat", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Simple or compound subdivision?",
                    options: ["Simple (÷2)", "Compound (÷3)", "Mixed", "Can't tell"], correctIndex: 0)),
        ])

    static let tempoSet = QuizSet(
        name: "Speed or slow?", category: .tempo, clips: [
            Clip(name: "Ballad — 10 sec", fileName: "mc_tempo_01.mp3",
                 category: .tempo, setName: "Speed or slow?", difficulty: .easy,
                 question: MultipleChoiceQuestion(
                    text: "How would you describe the tempo?",
                    options: ["Slow (Adagio)", "Moderate", "Fast (Allegro)", "Very fast"], correctIndex: 0)),
            Clip(name: "Dance track — 8 sec", fileName: "mc_tempo_02.mp3",
                 category: .tempo, setName: "Speed or slow?", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "What genre feel is this?",
                    options: ["Bossa nova", "Funk", "Reggae", "Swing"], correctIndex: 3)),
            Clip(name: "Groove excerpt — 7 sec", fileName: "mc_tempo_03.mp3",
                 category: .tempo, setName: "Speed or slow?", difficulty: .medium,
                 question: MultipleChoiceQuestion(
                    text: "Straight or swung rhythm?",
                    options: ["Straight", "Swung", "Triplets", "Dotted"], correctIndex: 1)),
            Clip(name: "Energetic phrase — 5 sec", fileName: "mc_tempo_04.mp3",
                 category: .tempo, setName: "Speed or slow?", difficulty: .hard,
                 question: MultipleChoiceQuestion(
                    text: "Roughly what tempo?",
                    options: ["60–80 BPM", "90–110 BPM", "120–140 BPM", "160+ BPM"], correctIndex: 2)),
        ])

    static let audioLineupSet = QuizSet(
        name: "Audio Lineup", category: .memory, clips: [
            Clip(name: "Mystery clip 1", fileName: "lu_mystery_01.mp3",
                 category: .memory, setName: "Audio Lineup", difficulty: .easy,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Which clip matches what you just heard?",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Slow violin melody",   fileName: "lu_01_choiceA.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Jazz piano riff",      fileName: "lu_01_choiceB.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "Trumpet fanfare",      fileName: "lu_01_choiceC.mp3", isCorrect: true),
                        AudioChoice(label: "Clip D", description: "Bass guitar groove",   fileName: "lu_01_choiceD.mp3", isCorrect: false),
                    ])),
            Clip(name: "Mystery clip 2", fileName: "lu_mystery_02.mp3",
                 category: .memory, setName: "Audio Lineup", difficulty: .medium,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Which clip sounds like the one you heard?",
                    choices: [
                        AudioChoice(label: "Clip A", description: "Flute, major key",  fileName: "lu_02_choiceA.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "Flute, minor key",  fileName: "lu_02_choiceB.mp3", isCorrect: true),
                        AudioChoice(label: "Clip C", description: "Oboe, major key",   fileName: "lu_02_choiceC.mp3", isCorrect: false),
                        AudioChoice(label: "Clip D", description: "Oboe, minor key",   fileName: "lu_02_choiceD.mp3", isCorrect: false),
                    ])),
            Clip(name: "Mystery clip 3", fileName: "lu_mystery_03.mp3",
                 category: .memory, setName: "Audio Lineup", difficulty: .hard,
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "Match the clip from memory — listen carefully!",
                    choices: [
                        AudioChoice(label: "Clip A", description: "4/4, 120 BPM, strings", fileName: "lu_03_choiceA.mp3", isCorrect: false),
                        AudioChoice(label: "Clip B", description: "4/4, 124 BPM, strings", fileName: "lu_03_choiceB.mp3", isCorrect: false),
                        AudioChoice(label: "Clip C", description: "4/4, 120 BPM, brass",   fileName: "lu_03_choiceC.mp3", isCorrect: true),
                        AudioChoice(label: "Clip D", description: "3/4, 120 BPM, strings", fileName: "lu_03_choiceD.mp3", isCorrect: false),
                    ])),
        ])
}
