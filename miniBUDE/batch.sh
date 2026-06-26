#!/usr/bin/env julia

function run_minibude(ppwi::Int, wgsize::Int, iteration::Int, target_log_file::String)
    start_time = time()
    
    # This directly forwards the parameters down into your codebase where ArgParse reads them!
    cmd = `julia --project=. src/JACCBUDE.jl -p $ppwi --deck data/bm1 -w $wgsize`
    
    temp_log = "minibude_p$(ppwi)_w$(wgsize)_temp.log"
    
    # Run and redirect output to the temporary file
    open(temp_log, "w") do io
        process = run(pipeline(cmd, stdout=io, stderr=io), wait=false)
        pid = getpid(process)
        
        while process_running(process)
            if (time() - start_time) > 300
                try run(`kill -9 $pid`) catch end
                println("   -> Timeout reached for run $iteration. Skipping.")
                close(io)
                rm(temp_log, force=true)
                return
            end
            sleep(0.1)
        end
    end
    
    # Parse out only the GFLOP/s numeric value
    try
        if isfile(temp_log)
            log_content = read(temp_log, String)
            m = match(r"(?i)GFLOP.*?([0-9.]+)", log_content)
            
            if m !== nothing
                gflops_value = m.captures[1]
                open(target_log_file, "a") do f
                    write(f, "$gflops_value\n")
                end
            else
                println("   -> Warning (Run $iteration): Could not parse GFLOP/s text.")
            end
            rm(temp_log, force=true)
        end
    catch e
        println("   -> Error extracting values on run $iteration: $e")
    end
    
    sleep(0.2)
end

function main()
    # Simple positional error boundary check
    if length(ARGS) < 2
        println("Error: Missing parameters.")
        println("Usage: julia run_minibude.jl [ppwi_value] [wgsize_value]")
        println("Example: julia run_minibude.jl 1 64")
        exit(1)
    end

    # Read clean values straight out of the native ARGS array
    ppwi = parse(Int, ARGS[1])
    wgsize = parse(Int, ARGS[2])
    num_iterations = 100
    
    mkpath("minibude_batchresults")
    final_log_file = "minibude_batchresults/ppwi_$(ppwi)_wgsize_$(wgsize).log"
    rm(final_log_file, force=true) # Fresh baseline override
    
    println("==================================================")
    println("Starting 100 iterations: PPWI=$ppwi | WGSIZE=$wgsize")
    println("Logging 100 clean GFLOP/s points -> $final_log_file")
    println("==================================================")
    
    start_time = time()
    for iter in 1:num_iterations
        run_minibude(ppwi, wgsize, iter, final_log_file)
        if iter % 10 == 0
            println("Progress: Completed $iter/$num_iterations runs...")
        end
    end
    
    total_time = time() - start_time
    println("\nFinished 100 runs in $(round(total_time/60, digits=2)) minutes.")
end

main()
