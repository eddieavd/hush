//
//  SignalGenerator.swift
//  hush
//
//  Created by Edhem Avdagic on 2/15/23.
//

import Foundation;
import AVFoundation;
import CoreAudio;

enum SignalType: String, Equatable, CaseIterable
{
    case SINE  =          "sine"
    case WHITE =    "whitenoise"
    case SAW_U =   "sawtooth_up"
    case SAW_D = "sawtooth_down"
    case SQR   =        "square"
    case TRI   =      "triangle"

    var name: String { String( rawValue ) };
};

open class SignalGenerator
{
    let engine = AVAudioEngine();

    init ( sig_type: SignalType )
    {
        frequency = 440 ;
        amplitude = 0.5 ;

        signal_type = sig_type ;

        current_phase = 0.0 ;
        phase_step    = 0.0 ;
        sample_rate   = 0.0 ;
    }

    func generate ()
    {
        mixer_node  = engine.mainMixerNode ;
        output_node = engine   .outputNode ;

        output_fmt  = output_node!.inputFormat( forBus: 0 ) ;
        sample_rate = Float( output_fmt!.sampleRate )       ;

        input_fmt = AVAudioFormat( commonFormat : output_fmt!.commonFormat  ,
                                   sampleRate   : output_fmt!.sampleRate    ,
                                   channels     : 1                         ,
                                   interleaved  : output_fmt!.isInterleaved ) ;

        phase_step = ( two_pi / sample_rate ) * frequency ;

        source_node = AVAudioSourceNode { _, _, frame_count, audio_buffer_list -> OSStatus in

            let abl_ptr = UnsafeMutableAudioBufferListPointer( audio_buffer_list );
            for frame in 0..<Int( frame_count )
            {
                let val = self._get_signal_value( phase: self.current_phase ) * self.amplitude;

                self._shift_phase();

                for buffer in abl_ptr
                {
                    let buff: UnsafeMutableBufferPointer< Float > = UnsafeMutableBufferPointer( buffer );
                    buff[ frame ] = val;
                }
            }
            return noErr;
        }
    }

    func play ( custom_duration: Float )
    {
        if source_node != nil && mixer_node != nil && output_node != nil
        {
            engine.attach( source_node! );

            engine.connect( source_node!, to:  mixer_node!, format:  input_fmt );
            engine.connect(  mixer_node!, to: output_node!, format: output_fmt );

            mixer_node!.outputVolume = 0.5;

            do
            {
                try engine.start();

                CFRunLoopRunInMode( .defaultMode, CFTimeInterval( custom_duration ), false );

                engine.stop();
            }
            catch
            {
                print( "Error initializing audio engine: \( error )" );
            }
        }
        else
        {
            print( "Error: audio nodes not initialized!" );
        }

    }
    func loop ()
    {
    }

    func set_signal_type ( sig_type: SignalType )
    {
        self.signal_type = sig_type;
    }

    var frequency     : Float ;
    var amplitude     : Float ;

    var source_node   : AVAudioSourceNode? ;
    var mixer_node    :  AVAudioMixerNode? ;
    var output_node   : AVAudioOutputNode? ;
    var output_fmt    :     AVAudioFormat? ;
    var input_fmt     :     AVAudioFormat? ;
    var signal_type   :         SignalType ;

    var sample_rate   : Float ;
    var current_phase : Float ;
    var phase_step    : Float ;

    private func _get_signal_value ( phase: Float ) -> Float
    {
        switch( signal_type )
        {
            case SignalType.SINE:
                return          sine( phase: phase );
            case SignalType.WHITE:
                return    whitenoise( phase: phase );
            case SignalType.SAW_U:
                return   sawtooth_up( phase: phase );
            case SignalType.SAW_D:
                return sawtooth_down( phase: phase );
            case SignalType.SQR:
                return        square( phase: phase );
            case SignalType.TRI:
                return      triangle( phase: phase );
        }
    }

    private func _shift_phase ()
    {
        current_phase += phase_step;

        if current_phase >= two_pi {
            current_phase -= two_pi;
        }
        if current_phase < 0.0 {
            current_phase += two_pi;
        }
    }
};

fileprivate var two_pi = 2 * Float.pi;

fileprivate func sine ( phase: Float ) -> Float
{
    return sin( phase );
}
fileprivate func whitenoise ( phase: Float ) -> Float
{
    //return ( ( Float( arc4random_uniform( UINT32_MAX ) ) / Float( UINT32_MAX ) ) * 2 - 1 );
    return hushlib_wrapper().generate_whitenoise( phase );
}
fileprivate func sawtooth_up ( phase: Float ) -> Float
{
    return 1.0 - 2.0 * ( phase * ( 1.0 / two_pi ) );
}
fileprivate func sawtooth_down ( phase: Float ) -> Float
{
    return ( 2.0 * ( phase * ( 1.0 / two_pi ) ) ) - 1.0;
}
fileprivate func square ( phase: Float ) -> Float
{
    return phase <= 1.0 ? 1.0 : -1.0;
}
fileprivate func triangle ( phase: Float ) -> Float
{
    var val = ( 2.0 * ( phase * ( 1.0 / two_pi ) ) ) - 1.0;

    if val < 0.0 {
        val = -val;
    }
    return 2.0 * ( val - 0.5 );
}
