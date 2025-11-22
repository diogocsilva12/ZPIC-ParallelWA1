/**
 * @file simulation.c
 * @author Diogo Silva, Ricardo Fonseca, Tomás Pereira
 * @brief EM1D Simulation
 * @version 0.2
 * @date 2025/11/24
 * 
 * @copyright Copyright (c) 2022
 * 
*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "../lib/simulation.h"
#include "../lib/timer.h"


/* ---------------------------------------------------------------------------
                    ############### SIMULATION ###############
 ------------------------------------------------------------------------------
                        1) - Create new simulation
                        2) - Delete simulation
                        3) - Run a iteration of the simulation
                        4) - Add laser pulse to simulation (laser_particles.c)
                        5) - Set external EM fields for simulation (laser_particles.c)
                        6) - Set smoothing parameters for simulation (laser_particles.c)
						7) - Set moving window for simulation (laser_particles.c)
*/
void sim_new(t_simulation* sim, int nx, float box, float dt, float tmax, int ndump, t_species* species, int n_species){

	sim -> dt = dt;
	sim -> tmax = tmax;
	sim -> ndump = ndump;

	emf_new(&sim -> emf, nx, box, dt);
	current_new(&sim -> current, nx, box, dt);

	sim -> n_species = n_species;
	sim -> species = species;

	// Check time step
	float cour = sim->emf.dx;
	if (dt >= cour){
		fprintf(stderr, "Invalid timestep, courant condition violation, dtmax = %f \n", cour );
		exit(-1);
	}

}

void sim_delete(t_simulation* sim){

	// Delete simulation data
	// Delete particle species
	for (int i = 0; i<sim->n_species; i++) spec_delete( &sim->species[i] );
	free(sim->species);

	// Delete current density
	current_delete(&sim->current);

	// Delete EM fields
	emf_delete(&sim->emf);

}

void sim_iter(t_simulation* sim){

	// Zeroing current density
	current_zero(&sim -> current);

	// Advance particles and deposit current
	for (int i = 0; i<sim -> n_species; i++)
		spec_advance(&sim -> species[i], &sim -> emf, &sim -> current );

	// Update current boundary conditions and advance iteration
	current_update(&sim -> current);

	// Advance EM fields
	emf_advance(&sim -> emf, &sim -> current);
}

void sim_add_laser(t_simulation* sim,  t_emf_laser* laser){
	emf_add_laser(&sim->emf, laser);
}

void sim_set_ext_fld(t_simulation* sim, t_emf_ext_fld* ext_fld){
	emf_set_ext_fld(&sim->emf, ext_fld);
}

void sim_set_smooth(t_simulation* sim,  t_smooth* smooth){
	
	// Set smoothness
    if ((smooth -> xtype != NONE) && (smooth -> xlevel <= 0)) {
    	printf("Invalid smooth level along x direction\n");
    	exit(-1);
    }
	sim -> current.smooth = *smooth;
}

void sim_set_moving_window(t_simulation* sim){

	// Set moving window flag and disable boundary conditions
	sim -> emf.moving_window = 1;
    sim -> emf.bc_type = EMF_BC_NONE;

	// Disable boundary conditions for electric current
	sim -> current.bc_type = CURRENT_BC_NONE;

	// Set moving window flag for all species
	for(int i=0; i<sim -> n_species; i++) sim -> species[i].moving_window = 1;
}


/* ---------------------------------------------------------------------------
                    ############### REPORT ###############
 ------------------------------------------------------------------------------
*/

void sim_timings(t_simulation* sim, uint64_t t0, uint64_t t1){

	// Print total simulation times
	fprintf(stderr, "Time for spec. advance = %f s\n", spec_time());
	fprintf(stderr, "Time for emf   advance = %f s\n", emf_time());
	fprintf(stderr, "Total simulation time  = %f s\n", timer_interval_seconds(t0, t1));
	fprintf(stderr, "\n");

	// Print particle advance times
	double perf = spec_perf();
	if (perf > 0) {
		fprintf(stderr, "Particle advance [nsec/part] = %f \n", 1.e9*perf);
		fprintf(stderr, "Particle advance [Mpart/sec] = %f \n", 1.e-6/perf);
	}
}

void sim_report_energy(t_simulation* sim){
	int i;

	double emf_energy[6];

	// Get EM fields energy
	emf_get_energy(&sim -> emf, emf_energy);

	// Get total EM fields energy
	double tot_emf = emf_energy[0];
	for(i = 0; i < 6; i++) tot_emf += emf_energy[i];

	// Get total particles energy on all species
	double tot_part = 0;
	for(i = 0; i < sim -> n_species; i++) tot_part += sim -> species[i].energy;


	// Print total energy
	printf("Energy (fields | particles | total) = %e %e %e\n", tot_emf, tot_part, tot_emf+tot_part);

}

void sim_report_energy_ret(t_simulation* sim, double* energy){
	int i;

	double emf_energy[6];
	double part_energy[sim -> n_species];

	// Get EM fields energy
	emf_get_energy(&sim -> emf, emf_energy);

	// Get total EM fields energy
	double tot_emf = emf_energy[0];
	for( i = 0; i < 6; i++){
		tot_emf += emf_energy[i];
	}

	// Get total particles energy
	double tot_part = 0;
	for( i = 0; i < sim -> n_species; i++ ){
		part_energy[i] = sim -> species[i].energy;
		tot_part += part_energy[i];
	}
	
	// Sum up total energy
    energy[0]=tot_emf+tot_part; 	
}

int report(int n, int ndump){
	// Report data in intervals (iterations on main)
	if (ndump > 0){
		return ! (n % ndump);
	}
	return 0; 
}