#!/bin/bash

<<<<<<< Updated upstream
<<<<<<< Updated upstream
for i in {79650..79700}; do 
=======
for i in {79657..79700}; do 
>>>>>>> Stashed changes
	(( SIZE = 1024 * i )) 
=======
for i in {1..100}; do 
	(( SIZE = 10240000 * i )) 
>>>>>>> Stashed changes
	echo -e "\n\n===== [$i] Attempting Array Size: $SIZE =====\n" 
	julia --project=JACC src/JACCStream.jl -s "$SIZE" 
done 
