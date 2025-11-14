
#define _POSIX_C_SOURCE 200112L
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "../lib/zpic.h"


/**
 * @brief Allocates a float3Buffer 
 * @param buffer Pointer to the buffer
 * @param size Number of elements in the buffer
 */
void alloc_float3Buffer(float3Buffer* buffer, int size) {
    
    // Allocate memory for x, y and z components

    if (posix_memalign((void**)&buffer->x, 64, size * sizeof(float))) {
        fprintf(stderr, "(*error*) Could not allocate memory for float3Buffer\n");
        exit(EXIT_FAILURE);
    }

    if (posix_memalign((void**)&buffer->y, 64, size * sizeof(float))) {
        fprintf(stderr, "(*error*) Could not allocate memory for float3Buffer\n");
        exit(EXIT_FAILURE);
    }

    if (posix_memalign((void**)&buffer->z, 64, size * sizeof(float))) {
        fprintf(stderr, "(*error*) Could not allocate memory for float3Buffer\n");
        exit(EXIT_FAILURE);
    }
}

/**
 * @brief Sets a float3Buffer to a value
 * @param buffer Pointer to the buffer
 * @param size Number of elements in the buffer
 * @param value Value to initialize the buffer
 */
void mem_set_float3Buffer(float3Buffer* buffer, int size, float value) {
    memset(buffer->x, value, size * sizeof(float));
    memset(buffer->y, value, size * sizeof(float));
    memset(buffer->z, value, size * sizeof(float));
}

/**
 * @brief Frees a float3Buffer (Only frees afer checjking if the buffer is not NULL)
 * @param buffer Pointer to the buffer
 */
void free_float3Buffer(float3Buffer* buffer) {
    
    if (buffer->x) free(buffer->x);
    if (buffer->y) free(buffer->y);
    if (buffer->z) free(buffer->z);

    buffer->x = NULL;
    buffer->y = NULL;
    buffer->z = NULL;
}