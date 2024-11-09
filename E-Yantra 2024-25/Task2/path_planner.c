
/*
 * EcoMender Bot (EB): Task 2B Path Planner
 *
 * This program computes the valid path from the start point to the end point.
 * Make sure you don't change anything outside the "Add your code here" section.
 */

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#define V 32

#ifdef __linux__ // for host pc

#include <stdio.h>

void _put_byte(char c) { putchar(c); }

void _put_str(char *str)
{
    while (*str)
    {
        _put_byte(*str++);
    }
}

void print_output(uint8_t num)
{
    if (num == 0)
    {
        putchar('0'); // if the number is 0, directly print '0'
        _put_byte('\n');
        return;
    }

    if (num < 0)
    {
        putchar('-'); // print the negative sign for negative numbers
        num = -num;   // make the number positive for easier processing
    }

    // convert the integer to a string
    char buffer[20]; // assuming a 32-bit integer, the maximum number of digits is 10 (plus sign and null terminator)
    uint8_t index = 0;

    while (num > 0)
    {
        buffer[index++] = '0' + num % 10; // convert the last digit to its character representation
        num /= 10;                        // move to the next digit
    }
    // print the characters in reverse order (from right to left)
    while (index > 0)
    {
        putchar(buffer[--index]);
    }
    _put_byte('\n');
}

void _put_value(uint8_t val) { print_output(val); }

#else // for the test device

void _put_value(uint8_t val) {}
void _put_str(char *str) {}

#endif

// main function
int main(int argc, char const *argv[])
{

#ifdef __linux__

    const uint8_t START_POINT = atoi(argv[1]);
    const uint8_t END_POINT = atoi(argv[2]);
    uint8_t NODE_POINT = 0;
    uint8_t CPU_DONE = 0;

#else
// Address value of variables for RISC-V Implementation
#define START_POINT (*(volatile uint8_t *)0x02000000)
#define END_POINT (*(volatile uint8_t *)0x02000004)
#define NODE_POINT (*(volatile uint8_t *)0x02000008)
#define CPU_DONE (*(volatile uint8_t *)0x0200000c)

#endif

    // array to store the planned path
    uint8_t path_planned[32];
    // index to keep track of the path_planned array
    uint8_t idx = 0;

    /* Functions Usage

    instead of using printf() function for debugging,
    use the below function calls to print a number, string or a newline

    for newline: _put_byte('\n');
    for string:  _put_str("your string here");
    for number:  _put_value(your_number_here);

    Examples:
            _put_value(START_POINT);
            _put_value(END_POINT);
            _put_str("Hello World!");
            _put_byte('\n');
    */

    // ############# Add your code here #############
    // prefer declaring variable like this
    uint8_t edge[] = {
        1, 6, 10,      // 0
        0, 2, 11,      // 1
        1, 3, 4, 5,    // 2
        2,             // 3
        2,             // 4
        2,             // 5
        0, 7, 8, 9,    // 6
        6,             // 7
        6,             // 8
        6,             // 9
        0, 11, 24, 26, // 10
        1, 10, 12, 19, // 11
        11, 13, 14,    // 12
        12,            // 13
        12, 15, 16,    // 14
        14,            // 15
        14, 17, 18,    // 16
        16,            // 17
        16, 19, 21,    // 18
        11, 18, 20,    // 19
        19,            // 20
        18, 22, 23,    // 21
        21,            // 22
        21, 24, 30,    // 23
        10, 23, 25,    // 24
        24,            // 25
        10, 27, 28,    // 26
        26,            // 27
        26, 29, 30,    // 28
        28,            // 29
        28, 23, 31,    // 30
        30             // 31
    };
    uint8_t space[] = {0, 3, 6, 10, 11, 12, 13, 17, 18, 19, 20,
                       24, 28, 31, 32, 35, 36, 39, 40, 43, 46, 47, 50, 51, 54, 57,
                       58, 61, 62, 65, 66, 69, 70};
    uint8_t weight[32], prev[32], arr[32];

    // Storing the graph
    uint8_t i;
    uint8_t j = 0;
    for (i = 0; i < 32; i++)
        weight[i] = 32;

    uint32_t visited = 0;
    for (uint8_t i = 0; i < 32; i++)
        arr[i] = i;
    for (uint8_t i = 0; i < 32; i++)
        prev[i] = 32; // Initialize prev array to -1
    uint8_t start = START_POINT;
    uint8_t end = END_POINT;
    uint8_t current = start;
    weight[current] = 0;
    while (current != end)
    {
        visited |= (1 << current); // Mark the current node as visited

        // Explore neighbors and update weights
        for (i = space[current]; i < space[current + 1]; i++)
        {
            if (weight[edge[i]] >= (weight[current] + 1))
            {
                weight[edge[i]] = weight[current] + 1;
                prev[edge[i]] = current;
            }
        }

        // Sort arr based on weight array using Bubble Sort
        for (i = 0; i < V - 1; i++)
        {
            for (j = 0; j < V - 1 - i; j++)
            {
                if (weight[arr[j]] > weight[arr[j + 1]])
                {
                    // Swap arr[j] and arr[j + 1]
                    arr[j] ^= arr[j + 1];
                    arr[j + 1] ^= arr[j];
                    arr[j] ^= arr[j + 1];
                }
            }
        }

        // Find the next unvisited node from arr
        for (i = 0; i < V; i++)
        {
            if (!((visited >> arr[i]) & 1))
            {
                current = arr[i];
                break;
            }
        }
    }
    i = 30;
    arr[31] = end;
    while (end != start)
    {
        arr[i--] = prev[end];
        end = prev[end];
    }
    idx = 31 - i;
    while (i > 0)
    {
        arr[i] = 0;
        i = i - 1;
    }
    arr[i] = 0;
    j = 0;
    for (i = 32-idx; i < 32; i++)
    {
        path_planned[j++] = arr[i];
    }
    while (j < 32)
    {
        path_planned[j++] = 0;
    }
    // ##############################################

    // the node values are written into data memory sequentially.
    for (int i = 0; i < idx; ++i)
    {
        NODE_POINT = path_planned[i];
    }
    // Path Planning Computation Done Flag
    CPU_DONE = 1;

#ifdef __linux__ // for host pc

    _put_str("######### Planned Path #########\n");
    for (int i = 0; i < idx; ++i)
    {
        _put_value(path_planned[i]);
    }
    _put_str("################################\n");

#endif

    return 0;
}
