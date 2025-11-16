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