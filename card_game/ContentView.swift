//
//  ContentView.swift
//  card_game
//
//  Created by Hao Su on 5/12/21.
//

import SwiftUI
import Combine



extension View {
    func stacked(at position: Int, in total: Int, for axis:String) -> some View{
        let offset = CGFloat(total - position)
        if axis == "vertical"{
            return self.offset(CGSize(width:0, height: offset*60))
        }
        else{
            return self.offset(CGSize(width:0, height: 0))
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]]{
        let returnArray = stride(from: 0, to: count, by: size).map{
            Array(self[$0 ..< Swift.min($0+size, count)])
        }
        return returnArray
    }
// why this always returns "No Exact Matches in call to instance method 'append'"
//        let lastArray = returnArray.last!
//
//        if let lastRemainingSize:Int? = lastArray.count{
//            for i in (lastRemainingSize!..<size){
//                lastArray.append(0)
//            }
//        }
// }
}


extension Image {
    func asThumbnail(withMaxWidth maxWidth: CGFloat = 60) -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: maxWidth)
    }
}

class cards: ObservableObject {
    @Published var playerCardList:[Int] = []
    @Published var cpuCardList:[Int] = []
}


struct CardView: View{
    var cardNumber:Int
    
    var body: some View{
        Image("card"+String(cardNumber)).asThumbnail()

    }
}

struct currentCardsView: View{
        @ObservedObject var currentDecks:cards
        var background: Image
        func shuffle(){
            currentDecks.playerCardList = currentDecks.playerCardList.shuffled()
        }
        @State private var startPosition = 0
        var body: some View{
            let cardRows = Array(currentDecks.playerCardList).chunked(into: 6)
            ZStack{
                background.ignoresSafeArea()
                
                VStack{
                    Spacer()
                    Button(action: {
                        shuffle()
                    }, label: {Text("SHUFFLE CARDS")
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundColor(Color.white)
                            })
                    Spacer()

                    ForEach(0...cardRows.count-1, id: \.self) {index2 in
                        HStack{
                            ForEach(0...cardRows[index2].count-1, id: \.self) { index in
                                CardView(cardNumber:cardRows[index2][index])
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }


    
struct CardCompareView: View{
    @Binding var playerCardString:String
    @Binding var cpuCardString:String
    var body: some View {
        HStack(){
            Spacer()
            Image(playerCardString)
            Spacer()
            Image(cpuCardString)
            Spacer()
        }
    }
}
    
struct DealButtonView: View{
    @ObservedObject var currentDecks:cards
    @Binding var playerCard:Int
    @Binding var cpuCard:Int
    @Binding var playerCardString:String
    @Binding var cpuCardString:String
    @Binding var playerScore:Int
    @Binding var cpuScore:Int
    func deal(){
        playerCard = currentDecks.playerCardList.removeFirst()
        cpuCard = currentDecks.cpuCardList.removeFirst()
        playerCardString = "card"+String(playerCard)
        cpuCardString = "card"+String(cpuCard)
    }
    var body: some View{
        Button(action: {
            //
            deal()
            print("playerCard:\(playerCard)")
            print("cpuCard:\(cpuCard)")

            if playerCard>cpuCard {
                print("player card greater")
                currentDecks.playerCardList.append(playerCard)
                currentDecks.playerCardList.append(cpuCard)

            }
            else if cpuCard>playerCard {
                print("cpu card greater")

                currentDecks.cpuCardList.append(playerCard)
                currentDecks.cpuCardList.append(cpuCard)
            }
            else{
                print("they are equal")
                currentDecks.playerCardList.append(playerCard)
                currentDecks.cpuCardList.append(playerCard)
            }
            playerScore=currentDecks.playerCardList.count
            cpuScore=currentDecks.cpuCardList.count
            print("currentPlayerCards.cardList:\(currentDecks.playerCardList)")
            print("currentCPUCards.cardList:\(currentDecks.cpuCardList)")
            print("playerScore:\(playerScore)")
            print("cpuScore:\(cpuScore)")
            //update score
        }, label: {
            Image("dealbutton")
        })
    }
}

struct NewGameButtonView: View{
    @ObservedObject var currentDecks:cards
    @Binding var playerCard:Int
    @Binding var cpuCard:Int
    @Binding var playerCardString:String
    @Binding var cpuCardString:String
    @Binding var playerScore:Int
    @Binding var cpuScore:Int
    func initCards(){
        let cardValues:[Int] = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
        var allCards:[Int] = []
        for cardValue in cardValues{
            allCards = allCards + Array(repeating:cardValue, count:4)
            allCards = allCards.shuffled()
        }
        currentDecks.playerCardList = Array(allCards[0...25])
        currentDecks.cpuCardList = Array(allCards[26...])
        print("initial currentPlayerCards.cardList:\(currentDecks.playerCardList)")
        print("initial currentCPUCards.cardList:\(currentDecks.cpuCardList)")

        playerScore = currentDecks.playerCardList.count
        cpuScore = currentDecks.cpuCardList.count
        playerCard = currentDecks.playerCardList.first!
        cpuCard = currentDecks.cpuCardList.first!
        playerCardString = "card"+String(playerCard)
        cpuCardString = "card"+String(cpuCard)
    }

    var body: some View{
    Button(action: {
            initCards()
        }, label: {
            Text("NEW GAME")
                .fontWeight(.heavy)
                .foregroundColor(Color.white)
                .padding(.vertical, 12.0)
        })
    }
}


struct scoreView: View{
    @ObservedObject var currentDecks:cards
    var body: some View{
        HStack(){
            Spacer()
            VStack(){
                Text("Player")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.bottom, 10.0)
                Text(String(currentDecks.playerCardList.count))
                    .font(.headline)
                    .foregroundColor(Color.white)
            }
            Spacer()
            VStack(){
                Text("CPU")
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .padding(.bottom, 10.0)
                Text(String(currentDecks.cpuCardList.count))
                    .font(.headline)
                    .foregroundColor(Color.white)
            }
            Spacer()
        }
    }
}

struct GameView: View{
    @State private var playerCard = 0
    @State private var cpuCard = 0
    @State private var playerCardString = "card5"
    @State private var cpuCardString = "card9"
    @State private var playerScore=0
    @State private var cpuScore=0
    @ObservedObject var currentDecks:cards

    var body: some View {
        ZStack{
            Image("background").ignoresSafeArea()
            VStack(){
                Image("logo")
                Spacer()
                CardCompareView(playerCardString: $playerCardString, cpuCardString: $cpuCardString)
                NewGameButtonView(currentDecks: currentDecks, playerCard: $playerCard, cpuCard: $cpuCard, playerCardString: $playerCardString, cpuCardString: $cpuCardString, playerScore: $playerScore, cpuScore: $cpuScore)
                NavigationLink(destination: currentCardsView(currentDecks:currentDecks, background: Image("background")), label: {
                    Text("CurrentCards")
                        .foregroundColor(Color.white)
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                })
                DealButtonView(currentDecks: currentDecks, playerCard: $playerCard, cpuCard: $cpuCard, playerCardString: $playerCardString, cpuCardString: $cpuCardString, playerScore: $playerScore, cpuScore: $cpuScore)
                Spacer()
                scoreView(currentDecks:currentDecks)
                Spacer()
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var currentDecks:cards
    var body: some View {
        NavigationView{
            GameView(currentDecks:currentDecks)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
