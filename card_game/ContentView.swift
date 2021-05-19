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
    @Published var playerCard:Int = 0
    @Published var cpuCard:Int = 0
    
    func shuffle(){
        playerCardList = playerCardList.shuffled()
    }
    func deal(){
        playerCard = playerCardList.removeFirst()
        cpuCard = cpuCardList.removeFirst()
        
        print("playerCard:\(playerCard)")
        print("cpuCard:\(cpuCard)")

        if playerCard>cpuCard {
            print("player card greater")
            playerCardList.append(playerCard)
            playerCardList.append(cpuCard)

        }
        else if cpuCard>playerCard {
            print("cpu card greater")

            cpuCardList.append(playerCard)
            cpuCardList.append(cpuCard)
        }
        else{
            print("they are equal")
            playerCardList.append(playerCard)
            cpuCardList.append(playerCard)
        }
        print("currentPlayerCards.cardList:\(playerCardList)")
        print("currentCPUCards.cardList:\(cpuCardList)")
    }
    func initCards(){
        let cardValues:[Int] = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
        var allCards:[Int] = []
        for cardValue in cardValues{
            allCards = allCards + Array(repeating:cardValue, count:4)
            allCards = allCards.shuffled()
        }
        playerCardList = Array(allCards[0...25])
        cpuCardList = Array(allCards[26...])
        print("initial currentPlayerCards.cardList:\(playerCardList)")
        print("initial currentCPUCards.cardList:\(cpuCardList)")
        playerCard = playerCardList.first!
        cpuCard = cpuCardList.first!
    }
        
    
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
        var body: some View{
            let cardRows = Array(currentDecks.playerCardList).chunked(into: 6)
            ZStack{
                background.ignoresSafeArea()
                
                VStack{
                    Spacer()
                    Button(action: {
                        currentDecks.shuffle()
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
    @ObservedObject var currentDecks:cards
    var body: some View {
        HStack(){
            Spacer()
            Image("card"+String(currentDecks.playerCard))
            Spacer()
            Image("card"+String(currentDecks.cpuCard))
            Spacer()
        }
    }
}
    
struct DealButtonView: View{
    @ObservedObject var currentDecks:cards
    var body: some View{
        Button(action: {
            currentDecks.deal()
        }, label: {
            Image("dealbutton")
        })
    }
}

struct NewGameButtonView: View{
    @ObservedObject var currentDecks:cards
    var body: some View{
    Button(action: {
        currentDecks.initCards()
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
    @ObservedObject var currentDecks:cards
    var body: some View {
        ZStack{
            Image("background").ignoresSafeArea()
            VStack(){
                Image("logo")
                Spacer()
                CardCompareView(currentDecks: currentDecks)
                NewGameButtonView(currentDecks: currentDecks)
                NavigationLink(destination: currentCardsView(currentDecks:currentDecks, background: Image("background")), label: {
                    Text("CurrentCards")
                        .foregroundColor(Color.white)
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                })
                DealButtonView(currentDecks:currentDecks)
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
