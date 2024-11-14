#! /bin/bash
# Expect protocol name as first parameter (tcp or udp)

# Define input and output file names
ThroughFile="../data/$1_throughput.dat";
PngName="../data/LB$1"Final".png";

#getting the first and the last line of the file
HeadLine=($(head $ThroughFile --lines=1))
TailLine=($(tail $ThroughFile --lines=1))

#getting the information from the first and the last line
FirstN=${HeadLine[0]}
LastN=${TailLine[0]}

# TO BE DONE START

  FirstT=${HeadLine[1]}
  LastT=${TailLine[1]}

  FirstN=$(printf "%.10f" $FirstN)
  LastN=$(printf "%.10f" $LastN)
  FirstT=$(printf "%.10f" $FirstT)
  LastT=$(printf "%.10f" $LastT)

  DelayFirst=$(echo "scale=10; $FirstN / $FirstT" | bc)
  DelayLast=$(echo "scale=10; $LastN / $LastT" | bc)


  Band=$(echo "scale=10; ($LastN - $FirstN) / ($DelayLast - $DelayFirst)" | bc )

  Latency=$(echo "scale=10; ($DelayFirst * $LastN - $DelayLast * $FirstN) / ($LastN - $FirstN)" | bc)

# TO BE DONE END


# Plotting the results
gnuplot <<-eNDgNUPLOTcOMMAND
  set term png size 900, 700
  set output "${PngName}"
  set logscale x 2
  set logscale y 10
  set xlabel "msg size (B)"
  set ylabel "throughput (KB/s)"
  set xrange[$FirstN:$LastN]
  lbmodel(x)= x / ($Latency + (x/$Band))

# TO BE DONE START

  plot "${ThroughFile}" using 1:2 title "Measured Throughput" with linespoints, \
       lbmodel(x) title "Latency-Bandwidth Model" with linespoints

# TO BE DONE END

  clear

eNDgNUPLOTcOMMAND
