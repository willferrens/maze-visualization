<div align="center">

# **Maze Builder and Visualization**

*General Information:*

![Last Commit](https://img.shields.io/badge/last%20commit-5%2F28%2F2025-orange)
![JavaScript](https://img.shields.io/badge/processing-100%25-blue)
![Languages](https://img.shields.io/badge/languages-2-yellow)

</div>

## Overview

An interactive program built in [Processing](https://processing.org/) that allows users to build custom mazes and test them using altered [Depth-First](https://en.wikipedia.org/wiki/Depth-first_search) and [Breadth-First](https://en.wikipedia.org/wiki/Breadth-first_search) search techniques. These search algorithms that are utilized during the maze visualization are based upon their respective functionality within the application of binary trees and are altered to function within my program.

## Usage

In order to run my program, you will need to download the [Processing](https://processing.org/) software. Once you have it downloaded, download all the proper files and folders and then open the main sketch.pde or any of the corresponding files to open the project in the Processing IDE.\
Once opened, running the program and following all prompts properly will allow for the best overall functionality of the program. Each section has directions that should be read carefully and needed to be adhered to in order for both the Maze Solvers and Builder to run.

### General Restrictions

A maze to be implemented into a program is meant to mimic a binary search tree in the sense that, in this altered case, it must has:
1. A start node acting as the root of the tree and an end node acting as the point to search to
2. Up to three children (allowing for traversal in multiple directions)
3. No cycles to allow for proper backtracking in the DFS algorithm
   
If all criteria are met, both the DFS and BFS algorithms should function as intended.

### Example Mazes
Depth-First Maze           | Breadth-First Maze
:-------------------------:|:-------------------------:
![image](https://github.com/willferrens/maze-visualization/blob/main/dfs.png?raw=true) |  ![image](https://github.com/willferrens/maze-visualization/blob/main/bfs.png?raw=true)

Above are examples of both the algorithms working at the same time solving a maze. In the DFS maze, the current path is marked in magenta blocks while each intersection found is marked in a green block with the most recent one being represented by a navy block. In the BFS maze, the overall path is show through the green blocks with the current active nodes being represented as red blocks.
