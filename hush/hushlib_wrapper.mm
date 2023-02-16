//
//  hushlib_wrapper.m
//  hush
//
//  Created by Edhem Avdagic on 2/15/23.
//

#import "hushlib_wrapper.h"
#import "hushlib.hpp"


@implementation hushlib_wrapper

- ( float ) generate_whitenoise: ( float ) phase
{
    return hush::white_noise( phase );
}

@end
