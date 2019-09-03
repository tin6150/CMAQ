/* function to return type of file given filename */

#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <io.h>
#define access _access
#endif


/*************************************************/
int filetype( char* fname )
{
/*   return -1 file does not exist
             0 file exist with no permissions
             1 file is write only
             2 file is read only
             3 file is read & write
*/

    int flag=-1;

    if(access( fname, 0) == 0) flag=0;
    if(access( fname, 2) == 0) flag=1;
    if(access( fname, 4) == 0) flag=2;
    if(access( fname, 6) == 0) flag=3;

    return flag;

}

