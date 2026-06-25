#!/bin/bash 

for i in {1..10}; do 
	julia --project=. run_minibude.jl 64
	cat minibude_results/minibude_p*  
done 
