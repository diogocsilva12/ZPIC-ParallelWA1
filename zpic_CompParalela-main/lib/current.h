/** 
 *  @file current.h
 *  @author Diogo Silva, Ricardo Fonseca, Tomás Pereira
 *  @brief Electric current density
 *  @date 2025/11/24
 * 	@version 0.2
 *  @copyright Copyright (c) 2022
 *
 *
 *  Created by Ricardo Fonseca on 12/8/10.
 *  Copyright 2010 Centro de Física dos Plasmas. All rights reserved.
 *
 */

#ifndef __CURRENT__
#define __CURRENT__

#include "zpic.h"

/**
 * @brief Types of digital filtering
 * 
 */
enum smooth_type { 
	NONE,		///< No filtering 
	BINOMIAL,	///< Binomial filtering
	COMPENSATED	///< Compensated binomial filtering
};

/**
 * @brief Types of boundary conditions
 * 
 */
enum current_boundary{ 
	CURRENT_BC_NONE,		///< No boundary conditions
	CURRENT_BC_PERIODIC		///< Periodic boundary conditions
};

/**
 * @brief Digital filtering parameters
 * 
 * Stores digital filtering parameters
 */
typedef struct Smooth {
	enum smooth_type xtype;	///< Type of digital filtering
	int xlevel;				///< Number of filter passes
} t_smooth;

/**
 * @brief Current density object
 */
typedef struct Current {
	
	float* J_0x;	///< Pointer to grid cell 0
	float* J_0y;	///< Pointer to grid cell 0
	float* J_0z;	///< Pointer to grid cell 0
	
	float3Buffer J_buf;	///< Current density buffer (includes guard cells)
	
	int nx;			///< Number of grid points (excluding guard cells)
	int gc[2];		///< Number of guard cells (lower/upper)
	
	float box;		///< Physical size of simulation box
	
	float dx;		///< Grid cell size

	t_smooth smooth;	///< Digital filtering parameters

	float dt;			///< Time step

	int iter;			///< Current iteration number

	enum current_boundary bc_type;	///< Type of boundary condition
	
} t_current;

/**
 * @brief Initializes Electric current density object
 * 
 * @param current   Electric current density
 * @param nx        Number of grid cells
 * @param box       Physical box size
 * @param dt        Simulation time step
*/ 
void current_new(t_current *current, int nx, float box, float dt);

/**
 * @brief Frees dynamic memory from electric current density
 * 
 * @param current Electric current density object
 */
void current_delete(t_current *current);

/**
 * @brief Sets all electric current density values to zero
 * 
 * @param current Electric current density object
 */
void current_zero(t_current *current);

/**
 * @brief Advances electric current density 1 time step
 * 
 * The routine will:
 * 1. Update the guard cells
 * 2. Apply digitial filtering (if configured)
 * 3. Advance iteration number
 * 
 * @param current Electric current density
*/
void current_update(t_current *current);

/**
 * @brief Updates guard cell values
 * 
 * When using periodic boundaries the electric current that was added to
 * the upper guard cells will be added to the corresponding lower grid
 * cells, and the values then copied to the upper grid cells
 * 
 * @param current Electric current density
 */
void current_update_gc(t_current *current);

/**
 * @brief Applies digital filtering to the current density
 * 
 * Filtering is applied through a sequence of 3 point kernel convolutions.
 * The routine will apply a binomial kernel ([1,2,1]) n times, followed by
 * an optional compensator kernel.
 * 
 * Filtering parameters are set by the `current -> smooth` variable.
 * 
 * @param current Electric current density
 */
void current_smooth(t_current* const current);

/**
 * @brief Gets the value of the compensator kernel for an n pass binomial kernel
 * 
 * This kernel eliminates the $k^2$ dependency of the transfer function
 * near $k = 0$. The resulting kernel will be in the form [a,b,a], with
 * the values of a and b being determined by this function. The result
 * is normalized.
 * 
 * @param n Number of binomial passes
 * @param sa a value of the compensator kernel
 * @param sb b value of the compensator kernel
 */
void get_smooth_comp(int n, float* sa, float* sb);

/**
 * @brief Saves electric current density diagnostic information to disk
 * 
 * @param current Electric current density object
 * @param jc Current component to save, must be one of {0,1,2}
 */
void current_report(const t_current *current, const int jc);

/**
 * @brief Applies a 3 point kernel convolution along x
 * 
 * The kernel has the form [a,b,a]. The routine accounts for periodic
 * boundaries.
 * 
 * @param current 
 * @param sa kernel a value
 * @param sb kernel b value
*/
void kernel_x(t_current* const current, const float sa, const float sb);

/**
 * @brief Allocates a temporary buffer of size nx (Number of grid cells)
 * @brief Our approach works because number of grid cells is constant during the simulation
 * @param nx Number of grid cells
 * @note This temporary buffer also avoids multiple alloc_float3Buffer calls which stress cache too much for kernel_x function
*/
void kernel_tmpbuf_init(int nx);

/**
 * @brief Free the temporary buffer (call once after simulation ends)
*/
void kernel_tmpbuf_cleanup();

/**
 * @brief Return pointer to temporary buffer
*/
float3Buffer* kernel_tmpbuf_get();

#endif