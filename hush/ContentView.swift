//
//  ContentView.swift
//  hush
//
//  Created by Edhem Avdagic on 2/15/23.
//

import SwiftUI

struct ContentView: View {
    
    let signal_generator = SignalGenerator( sig_type: SignalType.WHITE );
    
    @State private var wave_func_sel: SignalType = SignalType.WHITE;

    var body: some View {
        VStack (spacing: 20){
            Text("Hello, edo!")
                .padding();
            Button {
                signal_generator.generate();
                signal_generator.play( custom_duration: 1 );
            } label: {
                Text("Dirni me edo");
            }
            Button {
                let q = DispatchQueue( label: "av_queue" );
                
                q.async
                {
                    signal_generator.generate();
                    signal_generator.play( custom_duration: 5 );
                }
            } label: {
                Text("Dirni me asinkrono");
            }
            Picker( "wave function", selection: $wave_func_sel ) {
                ForEach( SignalType.allCases, id: \.self ) { value in
                    Text( value.name )
                        .tag( value )
                }
            }
            .onChange( of: wave_func_sel ) { tag in
                signal_generator.set_signal_type( sig_type: tag );
            }
//            Button {
//                signal_generator.set_signal_type( sig_type: SignalType.SINE );
//            } label: {
//                Text( "sine" );
//            }
//            Button {
//                signal_generator.set_signal_type( sig_type: SignalType.WHITE );
//            } label: {
//                Text( "white" );
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView();
    }
}
