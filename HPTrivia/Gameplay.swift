//
//  Gameplay.swift
//  HPTrivia
//
//  Created by Kinamic Kinamic on 26/11/2024.
//

import SwiftUI
import AVKit

struct Gameplay: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: Game
    
    @Namespace private var namespace
    
    @State private var musicPlayer: AVAudioPlayer!
    @State private var sfxPlayer: AVAudioPlayer!
    
    @State private var animateViewsIn = false
    @State private var tappedCorrectAnswer = false
    @State private var hintWiggle = false
    @State private var scaleNextButton = false
    @State private var movePointsToScore = false
    @State private var revealHint = false
    @State private var revealBook = false
    @State private var wrongAnswersTapped: [Int] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("hogwarts")
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height * 1.05)
                    .overlay(Rectangle().foregroundColor(.black.opacity(0.8)))
                
                VStack {
                    // MARK: Controls
                    HStack {
                        Button("End Game") {
                            game.endGame()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.5))
                        
                        Spacer()
                        
                        Text("Score: \(game.gameScore)")
                    }
                    .padding()
                    .padding(.vertical, 30)
                    
                    // MARK: Question
                    VStack {
                        if animateViewsIn {
                            Text(game.currentQuestion.question)
                                .font(.custom(Constants.hpFont, size: 50))
                                .multilineTextAlignment(.center)
                                .padding()
                                .transition(.scale)
                                .opacity(tappedCorrectAnswer ? 0.1 : 1)
                        }
                    }
                    .animation(.easeInOut(duration: animateViewsIn ? 2 : 0), value: animateViewsIn)
                    
                    Spacer()
                    
                    // MARK: Hints
                    HStack {
                        VStack {
                            if animateViewsIn {
                                Image(systemName: "questionmark.app.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundColor(.cyan)
                                    .rotationEffect(.degrees(hintWiggle ? -13 : -17))
                                    .padding()
                                    .padding(.leading, 20)
                                    .transition(.offset(x: -geo.size.width/2))
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.1).repeatCount(9).delay(5).repeatForever()) {
                                            hintWiggle = true                                        }
                                    }
                                    .onTapGesture(perform: {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealHint = true
                                        }
                                        
                                        playSound(title: "page-flip")
                                        game.questionScore -= 1
                                    })
                                    .rotation3DEffect(.degrees(revealHint ? 1440 : 0), axis: (x: 0.0, y: 1.0, z: 0.0))
                                    .scaleEffect(revealHint ? 5 : 1)
                                    .opacity(revealHint ? 0 : 1)
                                    .offset(x: revealHint ? geo.size.width/2 : 0)
                                    .overlay(
                                        Text(game.currentQuestion.hint)
                                            .padding(.leading, 33)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .opacity(revealHint ? 1 : 0)
                                            .scaleEffect(revealHint ? 1.33 : 1)
                                    )
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0).delay(animateViewsIn ? 2 : 0), value: animateViewsIn)
                        
                        Spacer()
                        
                        VStack {
                            if animateViewsIn {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .foregroundColor(.black)
                                    .frame(width: 100, height: 100)
                                    .background(.cyan)
                                    .cornerRadius(20)
                                    .rotationEffect(.degrees(hintWiggle ? 13 : 17))
                                    .padding()
                                    .padding(.trailing, 20)
                                    .transition(.offset(x: geo.size.width/2))
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.1).repeatCount(9).delay(5).repeatForever()) {
                                            hintWiggle = true                                        }
                                    }
                                    .onTapGesture(perform: {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealBook = true
                                        }
                                        playSound(title: "page-flip")
                                        game.questionScore -= 1
                                    })
                                    .rotation3DEffect(.degrees(revealBook ? 1440 : 0), axis: (x: 0.0, y: 1.0, z: 0.0))
                                    .scaleEffect(revealBook ? 5 : 1)
                                    .opacity(revealBook ? 0 : 1)
                                    .offset(x: revealBook ? -geo.size.width/2 : 0)
                                    .overlay(
                                        Image("hp\(game.currentQuestion.book)")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(.trailing, 33)
                                            .opacity(revealBook ? 1 : 0)
                                            .scaleEffect(revealBook ? 1.33 : 1)
                                            .padding(.bottom, 10)
                                    )
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0).delay(animateViewsIn ? 2 : 0), value: animateViewsIn)
                    }
                    .padding(.bottom)
                    
                    
                    // MARK: Answers
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(Array(game.answers.enumerated()), id:  \.offset) { i, answer in
                            if game.currentQuestion.answers[answer] == true {
                                VStack {
                                    if animateViewsIn {
                                        if tappedCorrectAnswer == false {
                                            Text(answer)
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                                .frame(width: geo.size.width/2.15, height: 80)
                                                .background(.green.opacity(0.5))
                                                .cornerRadius(25)
                                                .transition(.asymmetric(insertion: .scale, removal: .scale(scale: 5).combined(with: .opacity.animation(.easeOut(duration: 0.5)))))
                                                .matchedGeometryEffect(id: "answer", in: namespace)
                                                .onTapGesture {
                                                    withAnimation(.easeOut(duration: 1)) {
                                                        tappedCorrectAnswer = true
                                                    }
                                                    playSound(title: "magic-wand")
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                                        game.correct()
                                                    }
                                                }
                                        }
                                    }
                                }
                                .animation(.easeOut(duration: animateViewsIn ? 1 : 0).delay(animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                            } else {
                                VStack {
                                    if animateViewsIn {
                                        Text(answer)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .padding(10)
                                            .frame(width: geo.size.width/2.15, height: 80)
                                            .background(wrongAnswersTapped.contains(i) ? .red.opacity(0.5) : .green.opacity(0.5))
                                            .cornerRadius(25)
                                            .transition(.scale)
                                            .onTapGesture {
                                                withAnimation(.easeOut(duration: 1)) {
                                                    wrongAnswersTapped.append(i)
                                                }
                                                playSound(title: "negative-beeps")
                                                giveWrongFeedback()
                                                game.questionScore -= 1
                                            }
                                            .scaleEffect(wrongAnswersTapped.contains(i) ? 0.8 : 1)
                                            .disabled(wrongAnswersTapped.contains(i) || tappedCorrectAnswer)
                                            .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    }
                                }
                                .animation(.easeOut(duration: animateViewsIn ? 1 : 0).delay(animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                            }
                        }
                            
                    }
                    
                    Spacer()
                }
                .frame(width: geo.size.width, height:geo.size.height)
                .foregroundColor(.white)
                
                // MARK: Celebration
                VStack {
                    Spacer()
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Text("\(game.questionScore)")
                                .font(.largeTitle)
                                .padding(.top, 50)
                                .transition(.offset(y: -geo.size.height/4))
                                .offset(x: movePointsToScore ? geo.size.width/2.3 : 0, y: movePointsToScore ? -geo.size.height/13 : 0).opacity(movePointsToScore ? 0 : 1)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1).delay(3)) {
                                        movePointsToScore = true
                                    }
                                }
                        }
                    }
                    .animation(.easeInOut(duration: 1).delay(2), value: tappedCorrectAnswer)
                    
                    Spacer()
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Text("Brilliant!")
                                .font(.custom(Constants.hpFont, size: 100))
                                .transition(.scale.combined(with: .offset(y: -geo.size.height/2)))
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 1 : 0).delay(tappedCorrectAnswer ? 1 : 0), value: tappedCorrectAnswer)
                                    
                    Spacer()
                    
                    if tappedCorrectAnswer {
                        Text(game.correctAnswer)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .frame(width: geo.size.width/2.15, height: 80)
                            .background(.green.opacity(0.5))
                            .cornerRadius(25)
                            .scaleEffect(2)
                            .matchedGeometryEffect(id: "answer", in: namespace)
                    }
                    
                    Group {
                        Spacer()
                        Spacer()
                    }
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Button("Next Level>"){
                                animateViewsIn = false
                                tappedCorrectAnswer = false
                                revealHint = false
                                revealBook = false
                                movePointsToScore = false
                                wrongAnswersTapped = []
                                
                                game.newQuestion()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    animateViewsIn = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue.opacity(0.5))
                            .font(.largeTitle)
                            .transition(.offset(y: geo.size.height/3))
                            .scaleEffect(scaleNextButton ? 1.2 : 1)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                    scaleNextButton.toggle()
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 2.7 : 0).delay(tappedCorrectAnswer ? 2.7 : 0), value: tappedCorrectAnswer)

                    Group {
                        Spacer()
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            animateViewsIn = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                playMusic()
            }
        }
    }
    
    private func playMusic() {
        let songs = ["let-the-mistery-unfold", "spellcraft", "hiding-place-in-the-forest", "deep-in-the-dell"]
        
        let i = Int.random(in: 0...3)
        
        let sound = Bundle.main.path(forResource: songs[i], ofType: "mp3")
        musicPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        musicPlayer.volume = 0.1
        musicPlayer.numberOfLoops = -1
        musicPlayer.play()
    }

    private func playSound(title: String) {
        let sound = Bundle.main.path(forResource: title, ofType: "mp3")
        
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        sfxPlayer.play()
    }
    
    private func giveWrongFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

#Preview {
    Gameplay()
        .environmentObject(Game())
}
