![Alt text for the image](waveform_result.png)
Waveform result of systolic data element being passed down.
![Alt text for the image](test_table.png)
Expected and resulting values.
![Alt text for the image](pe_block.png)
Block architecture of PE.
![Alt text for the image](4x4_block.png)
Block architecture for 4x4 systolic array.
![Alt text for the image](test_results.png)
Test results(Matrix output would not show in surfer & GTKwave).

The A & B inputs move differently, where A moves by the column, and B moves by the row. For example, on cycle 0, the A inputs are A[][0], and B inputs are B[0][]. Each PE should recieve the correct A and B pair as data propagates through the array. 

It takes 4 cycles to finish injecting all values into a 4x4 systolic array. It then takes a following 3 + 3 cycles for A and B to propagate to the end, at PE[3][3], resulting in a total of 10 cycles.
