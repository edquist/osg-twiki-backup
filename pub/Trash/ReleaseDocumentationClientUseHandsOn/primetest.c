#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{   unsigned long long num, start, end, i;
   if(argc != 4 && argc != 2)  {
       printf("Usage: %s <number> [<start> <end>]\n", argv[0]);
       exit(1);
   }
   num = atoll(argv[1]);
   if(argc == 4) {
       start = atoll(argv[2]);
       end = atoll(argv[3]);
   } else {
       start = 2;
       end = num-1;
   }

   for(i = start;i <= end; i++) {
       if(num % i == 0) {
           printf("NO - %lld is a factor\n", i);
           exit(0);
       }
   }

   printf("YES - no factors found in range %lld to %lld\n",start,end);
   return 0;
}