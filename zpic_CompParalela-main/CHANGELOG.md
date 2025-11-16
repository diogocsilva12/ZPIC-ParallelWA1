## 1st Run - Initial release of the project. Without OPENPM PARALLEL support.


Simulation ended.

Time for spec. advance = 39.598778 s
Time for emf   advance = 3.090624 s
Total simulation time  = 47.198310 s

Particle advance [nsec/part] = 208.948275 
Particle advance [Mpart/sec] = 4.785873 
Starting simulation ...

n = 0, t = 0.0
Energy (fields | particles | total) = 3.000000e+02 0.000000e+00 3.000000e+02
n = 42106, t = 40.000702
Energy (fields | particles | total) = 2.985474e+02 1.624787e+00 3.001722e+02
Initial energy: 3.000000e+02, Final energy: 3.001722e+02

Final energy different from Initial Energy. Change in total energy is: 0.06 % 

 Performance counter stats for './zpic':

         47,223.58 msec task-clock                #    1.000 CPUs utilized          
                75      context-switches          #    0.002 K/sec                  
                 0      cpu-migrations            #    0.000 K/sec                  
               172      page-faults               #    0.004 K/sec                  
    94,446,590,597      cycles                    #    2.000 GHz                    
    48,691,290,002      instructions              #    0.52  insn per cycle         
   <not supported>      branches                                                    
        38,676,566      branch-misses                                               

      47.230772755 seconds time elapsed

      47.195220000 seconds user
       0.029996000 seconds sys


## 2nd Run - Added OPENPM PARALLEL support.
### Function Kernel_X


Simulation ended.

Time for spec. advance = 39.124458 s
Time for emf   advance = 3.139052 s
Total simulation time  = 45.640501 s

Particle advance [nsec/part] = 206.445462 
Particle advance [Mpart/sec] = 4.843894 
Starting simulation ...

n = 0, t = 0.0
Energy (fields | particles | total) = 3.000000e+02 0.000000e+00 3.000000e+02
n = 42106, t = 40.000702
Energy (fields | particles | total) = 2.985474e+02 1.624787e+00 3.001722e+02
Initial energy: 3.000000e+02, Final energy: 3.001722e+02

Final energy different from Initial Energy. Change in total energy is: 0.06 % 

 Performance counter stats for './zpic':

        200,140.52 msec task-clock                #    4.382 CPUs utilized          
           104,040      context-switches          #    0.520 K/sec                  
               853      cpu-migrations            #    0.004 K/sec                  
               172      page-faults               #    0.001 K/sec                  
   399,839,428,268      cycles                    #    1.998 GHz                    
   705,984,727,240      instructions              #    1.77  insn per cycle         
   <not supported>      branches                                                    
        59,567,743      branch-misses                                               

      45.673531274 seconds time elapsed

     198.158666000 seconds user
       2.457921000 seconds sys


Não está a ter muito proveito a usar as threads no kernel X. Talvez porque o tempo gasto no kernel X não seja muito significativo em relação ao tempo total de simulação.
Tenho que melhorar o paralelismo do kernel_X

## 3rd Run - YEE_B and Yee_e

Simulation ended.

Time for spec. advance = 40.344403 s
Time for emf   advance = 4.163361 s
Total simulation time  = 47.969967 s

Particle advance [nsec/part] = 212.882665 
Particle advance [Mpart/sec] = 4.697423 
Starting simulation ...

n = 0, t = 0.0
Energy (fields | particles | total) = 3.000000e+02 0.000000e+00 3.000000e+02
n = 42106, t = 40.000702
Energy (fields | particles | total) = 2.985474e+02 1.624787e+00 3.001722e+02
Initial energy: 3.000000e+02, Final energy: 3.001722e+02

Final energy different from Initial Energy. Change in total energy is: 0.06 % 

 Performance counter stats for './zpic':

        218,515.40 msec task-clock                #    4.552 CPUs utilized          
           112,897      context-switches          #    0.517 K/sec                  
             1,071      cpu-migrations            #    0.005 K/sec                  
               174      page-faults               #    0.001 K/sec                  
   436,545,877,623      cycles                    #    1.998 GHz                    
   733,977,314,544      instructions              #    1.68  insn per cycle         
   <not supported>      branches                                                    
        72,198,358      branch-misses                                               

      48.005715727 seconds time elapsed

     214.184457000 seconds user
       4.822468000 seconds sys




### 4th Run - Parallel spec_adv

Every thread writes on his own private copy of the fields arrays. (Private buffers for each thread).

Only used one critical section at the end of the spec_adv to sum all the private buffers to the global fields arrays.

Simulation ended.

Time for spec. advance = 16.364907 s
Time for emf   advance = 3.953927 s
Total simulation time  = 23.217256 s

Particle advance [nsec/part] = 86.351632 
Particle advance [Mpart/sec] = 11.580557 
Starting simulation ...

n = 0, t = 0.0
Energy (fields | particles | total) = 3.000000e+02 0.000000e+00 3.000000e+02
n = 42106, t = 40.000702
Energy (fields | particles | total) = 2.985474e+02 1.624786e+00 3.001721e+02
                                      2.985474e+02 1.624787e+00 3.001722e+02 (BASE VALUES)
Initial energy: 3.000000e+02, Final energy: 3.001721e+02

Final energy different from Initial Energy. Change in total energy is: 0.06 % 

 Performance counter stats for './zpic':

        368,075.14 msec task-clock                #   15.830 CPUs utilized          
            20,379      context-switches          #    0.055 K/sec                  
               947      cpu-migrations            #    0.003 K/sec                  
               224      page-faults               #    0.001 K/sec                  
   736,063,162,841      cycles                    #    2.000 GHz                    
 1,426,820,409,349      instructions              #    1.94  insn per cycle         
   <not supported>      branches                                                    
        52,475,001      branch-misses                                               

      23.252050951 seconds time elapsed

     366.832962000 seconds user
       1.308868000 seconds sys

### 5th Run 

Spec advance .  A função que chama o kernel x o update gc os yee b yee e e mais duas do ficheiro emf c

Parallelized current_report
Removed code redundancy in the current_update_gc function
Kernel_x -> Boundaries only process 3 elements, so single thread is enough

Final Run with all optimizations in current.c : 


Simulation ended.

Time for spec. advance = 15.574608 s
Time for emf   advance = 4.848840 s
Total simulation time  = 23.144861 s

Particle advance [nsec/part] = 82.181513 
Particle advance [Mpart/sec] = 12.168187 
Starting simulation ...

n = 0, t = 0.0
Energy (fields | particles | total) = 3.000000e+02 0.000000e+00 3.000000e+02
n = 42106, t = 40.000702
Energy (fields | particles | total) = 2.985474e+02 1.624786e+00 3.001722e+02
Initial energy: 3.000000e+02, Final energy: 3.001722e+02

Final energy different from Initial Energy. Change in total energy is: 0.06 % 

 Performance counter stats for './zpic':

        368,033.19 msec task-clock                #   15.876 CPUs utilized          
            10,374      context-switches          #    0.028 K/sec                  
               294      cpu-migrations            #    0.001 K/sec                  
               224      page-faults               #    0.001 K/sec                  
   736,016,471,454      cycles                    #    2.000 GHz                    
 1,414,075,210,275      instructions              #    1.92  insn per cycle         
   <not supported>      branches                                                    
        52,470,306      branch-misses                                               

      23.181077256 seconds time elapsed

     366.382632000 seconds user
       1.687010000 seconds sys

The optimizations made in the current.c file had a significant impact on the performance of the simulation. The time for spec. advance was reduced from 16.364907 s to 15.574608 s, and the total simulation time decreased from 23.217256 s to 23.144861 s.