Access x rows from table Z. 
    Access data -> FULL SCAN (FULL SCAN / INDEX FAST FULL SCAN)
                   INDEX SCAN -> INDEX RANGE SCAN 
    Joins - which method and in which order has the minimal cost
    
FULL SCAN 
    Nie tylko liczba wierszy, ale ich lokalizacja w blokach.
    Jest granica gdzie bardziej siê oplaca FULL SCAN a gdzie index. CBO nie zawsze 
    dobrze ja wylicza.