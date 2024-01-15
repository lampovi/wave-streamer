# This file contains some useful functions that we didn't find in standard
# Liquidsoap libruary

# Returns new list with updated pair if it exists, adds it otherwise.
# Same function in Liquidsoap liqruary wasn't found.
# WARNING! Changes pair location (index)!
def list_assoc_update(lst, pair) = 
	lst = if list.mem_assoc(fst(pair), lst)
        then list.remove_assoc(fst(pair), lst)
        else lst
	end
	list.add(pair, lst)
end