//
//  hushlib.cpp
//  hush
//
//  Created by Edhem Avdagic on 2/15/23.
//

#include "hushlib.hpp"


namespace hush
{


float white_noise ( float phase )
{
    // return ( ( Float( arc4random_uniform( UINT32_MAX ) ) / Float( UINT32_MAX ) ) * 2 - 1 );
    
    return ( ( float )( rand() % 1000 ) / 1000.0 ) * 2.0 - 1 ;
}


} // namespace hush
